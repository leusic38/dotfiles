# Pile mail perso et notifications dans la barre dusk

Date : 2026-09-07
Statut : validé, prêt pour le plan d'implémentation

## Objectif

Lire son courrier personnel dans un client en terminal, et voir le nombre de
messages non lus dans la barre de statut de `dusk`, avec ouverture du client
au clic.

La phase 1 ne couvre **qu'un seul compte** : le serveur personnel, en IMAP
standard avec mot de passe. Les quatre autres boîtes (gmail, hotmail, gmx,
yahoo) sont hors périmètre et traitées en §13.

## Contraintes issues de l'existant

| Contrainte | Conséquence |
| --- | --- |
| `dusk.c:59` définit `NUM_STATUSES 11`, et les slots 0 à 10 sont tous pris | Aucun slot libre : il faut recompiler `dusk` (§2) |
| La barre est une boucle `sh` d'une seconde (`statusbar_launch`) | Le module ne doit faire aucun accès réseau : il lit un Maildir local |
| Le dépôt dotfiles est destiné à être publiable | Aucun secret dans le dépôt : `rbw` + `PassCmd` (§4) |
| Les suckless sont suivis par manifeste, pas en sous-modules | Une recompilation de `dusk` se solde par `suckless-build --pin` + commit du manifeste |
| Le README sert de runbook de réinstallation | Toute brique nouvelle y est documentée (§10) |

## Choix d'architecture

Trois options ont été comparées pour le déclenchement de la synchro :

1. **Timer systemd user** — `mbsync` toutes les 3 min, la barre lit le Maildir.
2. **IMAP IDLE (`goimapnotify`)** — notification immédiate, un daemon par compte.
3. **Boucle `statusbar_launch`** — comme `rss_reload`, zéro brique nouvelle.

**Retenu : option 1.** Elle sépare les responsabilités (le timer synchronise, la
barre affiche), garde le module de barre aussi trivial que `rssmod`, et rend les
échecs réseau visibles dans journald — ce qui compte pour du courrier, contrairement
au RSS. L'option 2 est sur-dimensionnée pour cinq boîtes personnelles et multiplie
les daemons ; l'option 3 fait mourir la synchro avec la barre et masque les échecs.

Latence acceptée : jusqu'à 3 minutes.

## 1. Vue d'ensemble

```
serveur IMAP perso
      |
      |  mbsync (timer systemd, 3 min)
      v
~/.local/share/mail/perso/INBOX/{new,cur,tmp}     <- Maildir local, hors dépôt
      |                                    |
      |  aerc (lecture)                    |  mailmod/mail (comptage)
      v                                    v
   kitty -e aerc                      slot 11 de la barre dusk
```

L'envoi passe par `msmtp`, appelé par `aerc`.

## 2. Le douzième slot de barre

`dusk.c` réserve `NUM_STATUSES 11` entrées, soit les indices 0 à 10, tous
occupés (horloge, volume, mémoire, CPU, mises à jour, météo, disque, réseau,
batterie, RSS, audit composer).

Action : passer `#define NUM_STATUSES 11` à `12` dans
`~/Repo/mySuckless/dusk/dusk.c`, puis :

```bash
suckless-build          # recompile et installe
suckless-build --pin    # réépingle le manifeste sur le nouveau commit
```

Le commit du fork `dusk` est poussé sur `git@github.com:leusic38/dusk.git`
(branche `master`), et `bin/.local/bin/suckless.manifest` est commité dans
dotfiles avec le nouveau SHA.

Le nouveau slot 11 n'est visible qu'après redémarrage de `dusk` (reconnexion
de session).

Alternative écartée : fusionner mail et RSS dans le slot 9, ce qui rendrait le
clic ambigu et gonflerait un module qui a déjà cinq boutons.

## 3. Nouveau paquet stow `mail`

```
mail/.config/isyncrc
mail/.config/msmtp/config
mail/.config/aerc/aerc.conf
mail/.config/aerc/accounts.conf
```

Pas de `binds.conf` livré : `aerc` retombe alors sur `/usr/share/aerc/binds.conf`,
qui convient tel quel tant qu'aucun raccourci n'est modifié.

Le Maildir vit dans `~/.local/share/mail/<compte>/` : ce sont des données, jamais
versionnées. Le découpage par compte est délibéré — ajouter une boîte en phase 2
n'est qu'une strophe supplémentaire dans `mbsyncrc`, sans toucher au reste.

`aerc` est configuré sur le **Maildir local**, pas sur l'IMAP distant : il lit ce
que `mbsync` a déposé. C'est ce qui rend le compteur de la barre cohérent avec ce
que montre le client, et le tout utilisable hors ligne.

## 4. Secrets

Les mots de passe d'Emmanuel sont déjà dans **Bitwarden**. On s'y adosse plutôt
que d'ouvrir un second coffre : `rbw` (dépôt `extra`), le client Bitwarden en
Rust, dont l'agent garde le coffre déverrouillé et dont `rbw get` écrit le mot
de passe sur la sortie standard — exactement la forme attendue par `mbsync` et
`msmtp`.

Les configurations ne contiennent jamais de mot de passe, seulement :

```
PassCmd "rbw get mail-perso"
```

Écarté : `bitwarden-cli`, le client officiel. Il fonctionne par jeton de
session (`bw unlock` exporte `BW_SESSION`), et une unité systemd n'a pas de
session — il faudrait stocker ce jeton quelque part, c'est-à-dire construire un
coffre pour protéger l'accès au coffre.

Écarté aussi : `pass` adossé à une clé GPG dédiée. C'est la solution canonique
et elle marche, mais elle impose un second magasin de secrets à sauvegarder et
à synchroniser en parallèle de Bitwarden.

**Le coffre se verrouille**, et c'est la contrepartie assumée : `lock_timeout`
vaut 28800 s (huit heures), soit un déverrouillage par journée de travail.

Ce point a été révisé en exploitation, et il mérite d'être raconté. Le délai
valait d'abord une heure, au motif que le marqueur `!` de la barre signalerait
un coffre fermé. Deux choses ont démenti ce raisonnement : le marqueur n'était
pas affichable tant que `dusk` n'avait pas son douzième slot, et l'échec
n'était pas propre — `pinentry` ne peut pas s'ouvrir depuis une unité systemd
utilisateur, qui n'a pas de `DISPLAY`, de sorte que `mbsync` se cassait sur lui
à chaque échéance. Résultat mesuré : cinq jours d'arrêt complet, 530 échecs,
aucun signal.

`mail-sync` détecte donc désormais le verrouillage **avant** d'appeler `mbsync`,
et émet **une** notification par épisode — une seule, parce qu'un popup toutes
les trois minutes s'apprend à ignorer. Le marqueur `!` reste le second filet.

Le délai se change à tout moment, sans rien toucher d'autre :

```bash
rbw config set lock_timeout 3600   # 1 h, plus prudent
rbw stop-agent
```

Le fichier `~/.config/rbw/config.json` n'est **pas** stowé : `rbw` le réécrit
lui-même. Les deux commandes ci-dessus sont documentées dans le runbook (§10).

## 5. Synchro et notification — `bin/.local/bin/mail-sync`

Séquence :

1. `flock` sur `~/.cache/statusbar/mail_sync.lock` — jamais deux synchros en parallèle
2. inventaire des noms de fichiers présents dans `*/INBOX/new/`
3. `mbsync -a`
4. inventaire après ; les noms apparus sont les nouveaux messages
5. pour chacun, extraction de `From:` et `Subject:` ; les en-têtes encodés
   (`=?UTF-8?…?=`) sont décodés avec `perl -MEncode -CS -pe` (perl fait partie de
   `base`), avec repli sur la valeur brute en cas d'échec
6. `notify-send` par message ; au-delà de 3 nouveaux messages, un unique popup
   groupé (« 5 nouveaux messages ») pour ne pas noyer dunst
7. horodatage de la dernière synchro **réussie** dans `~/.cache/statusbar/mail_sync`
8. `duskc --ignore-reply run_command setstatus 11 …` pour rafraîchir la barre
   immédiatement plutôt que d'attendre le prochain tour de boucle

En cas d'échec de `mbsync` (réseau coupé, serveur injoignable) : pas de popup,
sortie en erreur, horodatage **non** mis à jour. L'échec est visible dans journald
et, passé 30 minutes, dans la barre (§6).

`--help` documente le comportement, comme les autres scripts de `bin/`.

## 6. Module de barre `bin/.local/bin/statusbar/mailmod/`

### `mail`

Décalque de `rssmod/rss`. Compte les non lus :

- tous les fichiers de `<compte>/INBOX/new/`
- les fichiers de `<compte>/INBOX/cur/` dont les *flags* Maildir (après `:2,`)
  ne contiennent pas `S`

Affiche `✉N`. N'affiche **rien** quand le total est zéro, comme les autres modules.

Si la dernière synchro réussie remonte à plus de 30 minutes, suffixe `!`
(`✉3!`) : un compteur périmé doit se distinguer d'une boîte vide.

Seule `INBOX` est comptée — pas les dossiers de spam ni les archives.

### `mail_click`

| Bouton | Action |
| --- | --- |
| 1 — gauche | `notify-send` d'aide, rappelant les boutons |
| 2 — milieu | `setsid -f "$TERMINAL" -e aerc` |
| 3 — droit | `notify-send` listant les non lus : expéditeur — sujet |
| 4 — molette haut | `mail-sync` immédiat, avec popup « synchronisation… » |
| 5 — molette bas | non assigné |

Décision explicite : **pas** de « tout marquer comme lu » à la molette, contrairement
à `rss_click`. L'action se propagerait au serveur IMAP à la synchro suivante ; c'est
trop destructeur pour un clic accidentel.

## 7. Câblage dans la barre

`statusbar_launch` — rafraîchissement du compteur toutes les 60 s :

```sh
if [ $((secs % 60)) -eq 20 ]; then
    $SETSTATUS 11 "$(~/.local/bin/statusbar/mailmod/mail)" &
fi
```

Le décalage (`-eq 20`) évite de se superposer aux autres créneaux périodiques.
La synchro elle-même n'est **pas** appelée depuis cette boucle : c'est le rôle du
timer systemd.

`statusbar_click` — nouveau `case` :

```sh
11) ~/.local/bin/statusbar/mailmod/mail_click ;;
```

### Correctif de passage

`statusbar_click` ligne 8 route le slot 6 vers `weathermod/disk_click`, chemin
qui n'existe pas — le bon est `diskspacemod/disk_click`. Le clic sur le disque est
donc inopérant aujourd'hui. Corrigé dans le même fichier.

## 8. Unités systemd

`systemd/.config/systemd/user/mbsync.service` :

- `Type=oneshot`
- `ExecStart=%h/.local/bin/mail-sync`
- dépendance sur `network-online.target` en `Wants`/`After` (best effort en session user)

`systemd/.config/systemd/user/mbsync.timer` :

- `OnBootSec=2min`
- `OnUnitActiveSec=3min`
- `Persistent=true` — rattrape une échéance manquée après une suspension
- `WantedBy=timers.target`

Activation : `systemctl --user enable --now mbsync.timer`.

## 9. Handler `mailto:`

`mimeapps/.local/share/applications/aerc.desktop`, sur le modèle des handlers
existants du paquet `mimeapps` :

```
Exec=kitty -e aerc %u
MimeType=x-scheme-handler/mailto;
Terminal=false
```

Plus la ligne correspondante dans `mimeapps/.config/mimeapps.list` :

```
x-scheme-handler/mailto=aerc.desktop
```

## 10. Documentation

README, à mettre à jour dans trois endroits :

1. Une section de runbook « Courrier » : installation des paquets, création de la
   compte `rbw` (`rbw login`, `rbw unlock`), entrée `mail-perso` dans Bitwarden,
   premier `mbsync -a`, activation du timer, et comment changer `lock_timeout`.
2. Le tableau des paquets stow : nouvelle ligne `mail`.
3. La liste des paquets pacman requis : `isync`, `msmtp`, `aerc`, `rbw`, `w3m`.

Mentionner explicitement que le slot 11 exige un `dusk` recompilé (renvoi vers §1.6
du README) — sinon une machine réinstallée affichera tout sauf le mail, sans rien
signaler.

## 11. Paquets à installer

`isync` (fournit `mbsync`), `msmtp`, `aerc`, `rbw`, `w3m`.
Tous dans les dépôts officiels : aucun AUR en phase 1.

Pas de `msmtp-mta`, contrairement à ce qu'un montage msmtp classique installe :
il entre en conflit avec `dma`, déjà présent, qui possède `/usr/bin/sendmail`
et sert de transport aux courriers de `cronie` et `e2fsprogs`. Cette pile
n'emprunte jamais `/usr/bin/sendmail` — `aerc` appelle `msmtp -a perso`
directement — et l'échange serait perdant : la configuration `msmtp` est
adossée à `rbw` et à l'agent de l'utilisateur, inaccessibles à une tâche
lancée par root.

## 12. Vérifications

Aucun framework de test dans ce dépôt : la validation est une liste de commandes
à exécuter et dont la sortie est vérifiée.

| Étape | Commande | Attendu |
| --- | --- | --- |
| Déploiement stow | `stow -n -v mail` | aucun conflit |
| Secret | `rbw get mail-perso` | le mot de passe, coffre déjà déverrouillé |
| Connexion | `mbsync -a --dry-run` | liste des dossiers, aucune erreur d'auth |
| Première synchro | `mbsync -a` puis `find ~/.local/share/mail/perso -type f \| wc -l` | > 0 |
| Compteur | `~/.local/bin/statusbar/mailmod/mail` | `✉N` cohérent avec le webmail |
| Compteur à zéro | tout marquer lu dans aerc, relancer | sortie vide |
| Slot 11 | `duskc --ignore-reply run_command setstatus 11 "✉test"` | `✉test` visible dans la barre |
| Notification | s'auto-envoyer un message, puis `mail-sync` | popup dunst avec expéditeur et sujet |
| Groupement | s'envoyer 4 messages, puis `mail-sync` | un seul popup groupé |
| Marqueur de péremption | reculer l'horodatage du cache de 40 min, relancer `mail` | `✉N!` |
| Échec réseau | couper le réseau, `mail-sync` | code de retour non nul, aucun popup, horodatage inchangé |
| Timer | `systemctl --user list-timers mbsync.timer` | prochaine échéance affichée |
| Clic milieu | clic milieu sur le segment | aerc s'ouvre dans kitty |
| Clic droit | clic droit sur le segment | liste expéditeur — sujet |
| Correctif disque | clic sur le segment disque | `disk_click` s'exécute |
| mailto | `xdg-open mailto:test@example.com` | aerc s'ouvre sur une nouvelle rédaction |

## 13. Suites, hors périmètre

- **Phase 2** — gmail, gmx, yahoo par mots de passe d'application : une strophe
  `mbsyncrc`, une entrée Bitwarden et un compte `aerc` par boîte. Le module de barre
  agrège déjà plusieurs comptes sans modification.
- **Phase 3** — hotmail par OAuth2 via `oama` (AUR), Microsoft ayant supprimé
  l'authentification par mot de passe.
- **Optionnel** — `goimapnotify` en IMAP IDLE si la latence de 3 minutes devient
  gênante ; le reste de la chaîne est inchangé, seul le déclencheur diffère.
