# dotfiles

Configuration personnelle sous Arch Linux, X11, WM `dusk`. Déploiement par
[GNU Stow](https://www.gnu.org/software/stow/) : chaque dossier à la racine est
un « paquet » stow dont l'arborescence interne reflète celle de `~`.

Exemple : `zsh/.config/zsh/.zshrc` devient `~/.config/zsh/.zshrc`.

**Ce dépôt est public.** Aucun hôte, compte ni identifiant interne ne doit y
entrer. Six scripts d'infra professionnelle sont volontairement exclus par
`.gitignore` — voir [Pièges connus](#5-pièges-connus).

---

## 1. Réinstallation

Les étapes sont ordonnées : chacune dépend des précédentes.

### 1.1 Clés SSH d'abord

Tout est cloné en SSH (`git@github.com:…`), y compris ce dépôt. Sans clés en
place, rien ne démarre.

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
# restaurer id_ed25519 et id_ed25519_pgh depuis la sauvegarde
chmod 600 ~/.ssh/id_ed25519 ~/.ssh/id_ed25519_pgh
ssh -T git@github.com   # vérifier avant d'aller plus loin
```

Les deux clés sont chargées automatiquement au login par
`shell/.config/shell/profile`.

### 1.2 Paquets

Voir [Paquets requis](#2-paquets-requis). À faire avant le stow : `stow`
lui-même en fait partie.

### 1.3 Cloner avec les sous-modules

```bash
git clone --recurse-submodules git@github.com:leusic38/dotfiles.git ~/dotfiles
```

Si le dépôt est déjà cloné sans l'option :

```bash
git -C ~/dotfiles submodule update --init --recursive
```

**L'oublier casse silencieusement nvim, ranger et zsh** : leurs dossiers de
plugins restent vides, sans message d'erreur. Six sous-modules :

| Sous-module | Emplacement |
| --- | --- |
| `nvim-config` | `nvim/.config/nvim` |
| `ranger-archives` | `ranger/.config/ranger/plugins/` |
| `ranger_devicons` | `ranger/.config/ranger/plugins/` |
| `zsh-syntax-highlighting` | `zsh/.config/zsh/plugins/` |
| `zsh-autocomplete` | `zsh/.config/zsh/plugins/` |
| `zsh-git-prompt` | `zsh/.config/zsh/plugins/` |

### 1.4 Déployer les paquets stow

```bash
cd ~/dotfiles
stow -t ~ awesome bin cargo dunst dusk gtk-3.0 gtk-4.0 helix i3 i3status-rust \
          ideavim kitty mail mimeapps neovimanu nvim ranger shell sql_formatter \
          systemd x11 zsh
```

`stow` **refuse de remplacer un vrai fichier**. Sur une Arch fraîche, `~/.profile`
et parfois `~/.bashrc` existent déjà : les supprimer ou les renommer d'abord,
sinon le stow échoue sur ce paquet et laisse les autres à moitié déployés.

Vérifier ce qui serait fait, sans rien écrire :

```bash
stow -n -v -t ~ zsh
```

Ne pas stower : `system` (destination `/etc`, voir §4), ni `alacritty`, `lf`,
`bin_old` (dormants, voir §3).

Bon à savoir : stow replie les dossiers entiers quand il peut. `~/.local/bin`
est donc un **lien** vers `dotfiles/bin/.local/bin`, et non un dossier de liens
individuels. Conséquence pratique : un nouveau script ajouté dans `bin/` est
immédiatement sur le `PATH`, sans re-stow.

### 1.5 Les deux liens manuels de la session X

**C'est l'étape qu'on oublie**, parce qu'aucun stow ne la fait. `startx` ne lit
que `~/.xinitrc`, et `xinitrc` ne source que `~/.xprofile` — or le paquet `x11`
place ces fichiers dans `~/.config/x11/`. Les deux liens à la racine de `~` sont
à créer à la main :

```bash
ln -s ~/.config/x11/xinitrc  ~/.xinitrc
ln -s ~/.config/x11/xprofile ~/.xprofile
```

Sans eux : X démarre sur un écran nu, sans WM, sans `dunst`, sans `udiskie`.

### 1.6 Compiler les suckless

**Sans cette étape, la machine n'a aucun environnement graphique.** Le WM et ses
outils ne viennent d'aucun paquet : ils sont compilés depuis quatre dépôts
séparés et installés dans `/usr/local/bin`.

```bash
suckless-build
```

Le script vient du paquet `bin`, déployé à l'étape §1.4. Il lit
`~/.local/bin/suckless.manifest`, clone ce qui manque dans
`~/Repo/mySuckless`, puis compile et installe chaque dépôt.

```bash
suckless-build --check   # état des dépôts, ne compile rien
suckless-build --pin     # réépingler le manifeste après avoir poussé du travail
```

Le manifeste enregistre URL, branche et commit des quatre dépôts. Ce ne sont
volontairement **pas** des sous-modules : ce sont des forks patchés
activement, et un sous-module imposerait un `HEAD` détaché à chaque clone plus
un commit du dépôt parent à chaque recompilation. Le commit du manifeste sert
donc de référence, pas de contrainte — `suckless-build` clone la branche et
signale l'écart s'il y en a.

Ce que ça installe : `dusk` et `duskc` (le WM et son client de contrôle),
`dmenu` / `dmenu_run` / `dmenu_path` / `stest`, `st`, et `slock`.

`slock` est installé **setuid root** — c'est nécessaire pour un verrouilleur
d'écran, et c'est normal de le voir en `-rwsr-xr-x`.

### 1.7 Fichiers système

```bash
sudo ~/dotfiles/system/install-android-mtp.sh
```

Option : `--with-sudoers` ajoute le droit de remonter le téléphone sans mot de
passe. Voir §4.

### 1.8 Shell et services

```bash
chsh -s /usr/bin/zsh
systemctl --user enable --now ssh-agent.service
```

`ZDOTDIR` est défini par `~/.zshenv` (paquet `zsh`), qui pointe zsh vers
`~/.config/zsh/`.

### 1.9 Démarrer une session

Il n'y a **pas de gestionnaire de connexion**. Le login sur `tty1` propose une
session et lance `startx` :

```
Aucune session détectée. Laquelle lancer? [bsp|i3|dwm|dusk|awesome]
```

Répondre `dusk`. La chaîne complète :

```
login tty1
  └─ shell/.config/shell/profile   demande la session, exec startx
       └─ ~/.xinitrc               source ~/.xprofile, puis dispatch
            ├─ ~/.xprofile         picom, xss-lock, dunst, udiskie, xrandr
            └─ dusklaunch          D-Bus, portails XDG, exec dusk
```

### 1.10 Courrier

Le paquet `mail` ne suffit pas : il ne contient aucun secret, par construction.
Deux choses sont à recréer à la main sur une machine neuve.

Paquets nécessaires — `isync`, `msmtp`, `aerc`, `rbw`, `w3m` : voir
[Paquets requis](#2-paquets-requis).

**Le raccordement à Bitwarden**, où le mot de passe vit déjà :

```bash
rbw config set email <adresse-du-compte-bitwarden>
rbw register    # obligatoire sur bitwarden.com, voir ci-dessous
rbw login
rbw config set lock_timeout 28800
```

`rbw register` n'est pas une politesse : le serveur officiel refuse un login par
mot de passe seul, avec un laconique `api request returned error: 400`. Il faut
enregistrer l'appareil avec la clé d'API personnelle du compte (coffre web →
Paramètres du compte → Sécurité → onglet Clés → Afficher la clé d'API).

L'entrée doit s'appeler exactement `mail-perso` — c'est ce nom que `mbsyncrc`
et `msmtp` vont chercher. Vérifier qu'elle se relit sans invite :

```bash
rbw unlock && rbw get mail-perso
```

**Le coffre s'ouvre au démarrage de la session.** `xprofile` (paquet `x11`)
lance `rbw unlock` quelques secondes après `dusk`, ce qui pose une boîte de
dialogue au login et une seule. Le délai de verrouillage est réglé à une
semaine, donc le coffre reste ouvert toute la session.

Le délai est court sur un `sleep` volontaire : `xprofile` s'exécute **avant** le
gestionnaire de fenêtres, et une boîte de dialogue lancée sans lui serait
ingérable.

Ce déverrouillage au login n'est pas un confort, c'est la condition pour que la
synchro tourne : `pinentry` ne peut pas s'ouvrir depuis une unité systemd
utilisateur, qui n'a pas de `DISPLAY`. Le mot de passe maître doit donc être
saisi depuis la session graphique, jamais depuis le timer.

Si le dialogue est annulé, ou si le coffre se verrouille malgré tout,
`mail-sync` le détecte avant même d'appeler `mbsync`, émet **une** notification
disant de lancer `rbw unlock`, et n'en émet plus jusqu'au prochain épisode. La
barre passe en outre à `✉N!` au bout de trente minutes.

Ces deux signaux ne sont pas de la décoration : avant eux, la pile est restée
morte cinq jours sans que rien ne le dise, le timer accumulant 530 échecs
silencieux.

Contrepartie assumée du déverrouillage au login : **tout** le coffre Bitwarden
est lisible par ce qui tourne sous ce compte pendant toute la session. Pour
revenir à un déverrouillage à la demande :

```bash
rbw config set lock_timeout 3600   # 1 h
rbw stop-agent
```

et retirer la ligne `rbw unlock` de `xprofile`.

`~/.config/rbw/config.json` n'est pas stowé : `rbw` le réécrit lui-même.

**Le Maildir et la première synchro** :

```bash
mkdir -p ~/.local/share/mail/perso
mbsync -a --dry-run    # controle l'authentification, n'ecrit rien
mbsync -a              # peut prendre plusieurs minutes
systemctl --user enable --now mbsync.timer
```

Ensuite, `aerc` lit le Maildir local — jamais l'IMAP directement. C'est ce qui
rend le compteur de la barre cohérent avec le client, et le client utilisable
hors ligne.

Le segment `✉` de la barre exige un `dusk` recompilé avec `NUM_STATUSES 12`
(§1.6) : sans ça, tous les autres modules s'affichent et seul le courrier
manque, sans aucun message d'erreur.

---

## 2. Paquets requis

Liste ciblée : uniquement ce dont les configs de ce dépôt dépendent
directement. Elle est dérivée des scripts de `bin/` et des configs, puis
vérifiée contre `pacman`.

### Dépôts officiels

```bash
sudo pacman -S --needed \
  base-devel git stow \
  xorg-server xorg-xinit xorg-xrdb xorg-xrandr xorg-setxkbmap \
  picom xss-lock xdotool xclip maim \
  dbus xdg-desktop-portal-gtk \
  dunst libnotify udiskie gvfs gvfs-mtp \
  zsh kitty ranger neovim helix \
  i3status-rust pamixer networkmanager \
  jq fzf eza reflector pacman-contrib \
  isync msmtp aerc rbw w3m \
  android-tools android-file-transfer \
  ttf-jetbrains-mono-nerd ttf-hack-nerd \
  libx11 libxft libxinerama libxrender libxext libxcursor libxrandr \
  fontconfig freetype2 imlib2 pam libxcrypt
```

La dernière ligne et demie, ce sont les bibliothèques nécessaires pour
**compiler** les suckless (§1.6) — pas pour les exécuter. Elles sont dérivées
des `-l…` de leurs quatre `config.mk` : `imlib2` pour les fonds d'écran de
`dusk` et `slock`, `pam` et `libxcrypt` pour l'authentification de `slock`,
`libxcursor` pour `st`.

À quoi servent les moins évidents :

| Paquet | Pourquoi |
| --- | --- |
| `picom`, `xss-lock` | lancés par `xprofile` (compositing, verrouillage sur inactivité) |
| `xorg-xrdb` | `xinitrc` charge `~/.Xresources`, dont les thèmes `dusk` |
| `maim`, `xclip`, `xdotool` | captures d'écran et presse-papiers des scripts `bin/` |
| `pamixer` | module volume de la barre de statut |
| `jq` | parsing JSON dans les modules de la barre |
| `eza` | `aliasesrc` alias `ls` sur la commande `exa` ; le paquet `exa` n'existe plus, `eza` le remplace et fournit `/usr/bin/exa` en lien de compatibilité |
| `reflector`, `pacman-contrib` | `mirrors` et le module `sysupdatemod` (`checkupdates`) |
| `isync` | fournit `mbsync`, la synchro IMAP → Maildir du courrier |
| `w3m` | rendu des messages HTML dans `aerc` |
| `gvfs-mtp` | neutralisé pour le téléphone (§4), mais requis pour les autres appareils |
| `android-file-transfer` | fournit `aft-mtp-mount`, utilisé par le montage MTP |
| `ttf-jetbrains-mono-nerd` | police de `kitty` (`JetBrainsMono NF`) |

### AUR

`yay` est requis **nommément** : le module de mise à jour de la barre de statut
(`statusbar/sysupdatemod/sysupdate`) appelle `yay -Qua` pour compter les
paquets AUR à mettre à jour. `paru` est aussi installé ici, mais il ne le
remplace pas sans modifier ce script.

Amorcer un assistant AUR depuis une machine nue :

```bash
git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
(cd /tmp/paru-bin && makepkg -si)
paru -S --needed yay
```

### Compilés à la main

`dusk`, `duskc`, `dmenu`, `st`, `slock` — voir §1.6. Aucun paquet ne les
fournit.

---

## 3. Inventaire des paquets stow

### Déployés

| Paquet | Contenu |
| --- | --- |
| `bin` | scripts personnels → `~/.local/bin` : lanceurs de WM, barre de statut, utilitaires, `suckless-build` et son manifeste, `phone-remount` |
| `dusk` | thèmes Xresources du WM actif |
| `x11` | `xinitrc`, `xprofile`, fonds d'écran |
| `shell` | `.profile` et `aliasesrc`, partagés entre shells |
| `zsh` | `.zshenv` (définit `ZDOTDIR`), `.zshrc`, `.zprofile`, thème, 3 plugins |
| `kitty` | terminal (police JetBrainsMono NF) |
| `ranger` | gestionnaire de fichiers, 2 plugins |
| `nvim` | config Neovim principale (sous-module, base LazyVim) |
| `neovimanu` | seconde config Neovim, indépendante |
| `helix` | éditeur alternatif |
| `dunst` | notifications |
| `i3status-rust` | barre de statut |
| `mimeapps` | associations de types MIME, handlers d'URL Firefox / PhpStorm |
| `mail` | `mbsyncrc`, `msmtp`, `aerc` — le compte perso, sans aucun secret (voir §1.10) |
| `gtk-3.0`, `gtk-4.0` | thème des applications GTK |
| `systemd` | unités utilisateur (`ssh-agent.service`) |
| `cargo` | environnement Rust (`~/.cargo/env`) |
| `ideavim` | `.ideavimrc` pour les IDE JetBrains |
| `sql_formatter` | règles de formatage SQL |
| `awesome` | WM alternatif — conservé, non actif |
| `i3` | WM alternatif — conservé, non actif |

### Dormants — ne pas stower

| Paquet | Statut |
| --- | --- |
| `alacritty` | terminal remplacé par `kitty` ; le paquet n'est plus installé |
| `lf` | gestionnaire de fichiers remplacé par `ranger` |
| `bin_old` | anciens scripts, gardés pour référence |

---

## 4. Fichiers système (`system/`)

Ce dossier **ne se stowe pas** : sa destination est `/etc` et `/usr/local/bin`,
pas `~`. Il est déployé par son propre installeur, idempotent :

```bash
sudo ~/dotfiles/system/install-android-mtp.sh              # installation
sudo ~/dotfiles/system/install-android-mtp.sh --with-sudoers  # + droits de remontage
sudo ~/dotfiles/system/install-android-mtp.sh --uninstall   # retrait
```

Il met en place l'automontage MTP du téléphone Android dans
`/run/media/$USER/Galaxy`, au même endroit qu'une clé USB.

| Fichier | Destination |
| --- | --- |
| `etc/systemd/system/android-mtp-automount@.service` | unité de montage |
| `etc/udev/rules.d/99-android-mtp-automount.rules` | déclencheur au branchement |
| `usr/local/bin/android-mtp-ready` | contrôle de disponibilité réelle |
| `etc/sudoers.d/android-mtp` | optionnel, remontage sans mot de passe |

Pourquoi ce n'est pas `udisks2` qui s'en charge : le MTP n'est pas un
périphérique bloc, il n'y a aucune partition à monter. `udisks2` et `udiskie` ne
peuvent donc rien voir. On reproduit leur emplacement de montage avec un
montage FUSE déclenché par udev.

En cas de lenteur extrême à l'accès : `phone-remount`, puis
`phone-remount --reset` si nécessaire. La cause est presque toujours l'écran
verrouillé — Samsung ferme la session MTP dès le verrouillage. Chaque fichier
de `system/` documente en commentaire les raisons de ses choix.

---

## 5. Pièges connus

### Le WM ne vient d'aucun paquet

`dusk`, `dmenu`, `st`, `slock` sont dans `/usr/local/bin` et `pacman -Qo` ne
leur trouve aucun propriétaire. Leurs sources vivent dans `~/Repo/mySuckless`,
**hors de ce dépôt**. Une réinstallation qui saute §1.6 aboutit à une machine
sans environnement graphique.

C'est `suckless-build` qui couvre ce trou, et `suckless.manifest` qui garde la
trace des quatre dépôts. Mais le manifeste ne vaut que si les commits qu'il
épingle **existent sur le serveur** : après avoir patché et poussé, lancer
`suckless-build --pin` puis committer le manifeste. Un `--check` de temps en
temps dit si les deux ont divergé.

### Le segment courrier exige un `dusk` recompilé

`dusk.c` définit `NUM_STATUSES`, la taille du tableau des segments de barre.
Le WM **ignore silencieusement** tout indice au-delà, sans rien journaliser :
`duskc run_command setstatus 11 …` ne renvoie aucune erreur, la barre reste
simplement vide à cet endroit.

Le fork est donc épinglé sur une valeur de `12` (§1.6). Un `dusk` recompilé
depuis une version antérieure du manifeste fera disparaître le segment `✉`
sans le moindre signal.

### Les deux liens de session ne sont pas stowés

`~/.xinitrc` et `~/.xprofile` sont des liens créés à la main (§1.5). Aucun
paquet stow ne les produit, et rien ne signale leur absence : X démarre, mais
sur un écran nu.

### Six scripts sont absents de tout clone

`.gitignore` exclut volontairement les scripts d'infra professionnelle
(`connectAWS_DB`, `connectAWS_PHP`, `connectWeblate`, `exec-commandAWS`,
`launchSymfonyCommand`, `ipad-wifi-dns-change`) : ce dépôt est public et ils
contiennent comptes AWS, identifiants de bastions et endpoints RDS de
production. Ils sont à restaurer depuis une sauvegarde privée, jamais d'ici.

### `bar/shutdown_menu` est cassé

Ce script appelle `rofi`, qui n'est pas installé et n'est pas dans la liste des
paquets. Soit installer `rofi`, soit le réécrire avec `dmenu`, qui est utilisé
partout ailleurs.

### `aliasesrc` appelle `exa`, un paquet qui n'existe plus

Le paquet `exa` a été retiré des dépôts Arch au profit de `eza`. Ça fonctionne
encore uniquement parce que `eza` le remplace officiellement et installe
`/usr/bin/exa` en lien vers `eza`. Le jour où ce lien de compatibilité
disparaîtra, `ls`, `ll` et `la` casseront d'un coup. Corriger les trois alias
de `shell/.config/shell/aliasesrc` pour appeler `eza` directement.

### `dwm` traîne depuis l'AUR

`dwm 6.8-3` est installé en paquet AUR alors que le WM actif est `dusk` et que
`dwmlaunch` existe dans `bin/`. Reliquat, désinstallable sans risque.

### `usbutils` n'est pas installé

Donc pas de `lsusb`. Contournement pour identifier un périphérique USB :

```bash
for d in /sys/bus/usb/devices/*/; do
    [ -f "$d/product" ] && echo "$(cat $d/idVendor):$(cat $d/idProduct) $(cat $d/product)"
done
```

### Deux arborescences non versionnées proprement

- `awesome/.config/awesome/` : `awesome-copycats`, code tiers avec ses propres
  sous-modules, exclu pièce par pièce par `.gitignore`. À reprendre en
  sous-module git.
- `nvim/.config/nvim.back/` : sauvegarde contenant son propre `.git`.
  L'ajouter créerait un gitlink cassé, absent de tout clone.
