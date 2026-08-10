# 🔒 Gestion du Firewall

Ce dossier contient des scripts pour gérer facilement votre firewall UFW.

## 📋 Configuration actuelle

Par défaut, le firewall est configuré pour:
- ✅ **AUTORISER** tout le trafic sortant (vous pouvez accéder à Internet)
- ❌ **BLOQUER** tout le trafic entrant (protection maximale)
- ✅ Autoriser les connexions loopback (localhost)

## 🚀 Scripts disponibles

### 1. `fw-init.sh` - Initialiser le firewall
Active le firewall avec une configuration restrictive par défaut.

```bash
fw-init.sh
```

### 2. `fw-allow.sh` - Autoriser des connexions
Permet d'ajouter des exceptions pour autoriser des connexions spécifiques.

**Exemples d'utilisation:**

```bash
# Autoriser SSH depuis n'importe où
fw-allow.sh -p 22

# Autoriser HTTP et HTTPS
fw-allow.sh -s http
fw-allow.sh -s https

# Autoriser SSH uniquement depuis une IP spécifique
fw-allow.sh -p 22 -i 192.168.1.100

# Autoriser un port personnalisé (ex: serveur web sur 8080)
fw-allow.sh -p 8080

# Autoriser une plage de ports
fw-allow.sh -p 3000-3010

# Autoriser un port UDP
fw-allow.sh -p 5353 -P udp
```

### 3. `fw-remove.sh` - Supprimer des règles
Permet de retirer des règles autorisées.

**Exemples d'utilisation:**

```bash
# Lister toutes les règles avec leurs numéros
fw-remove.sh -l

# Supprimer une règle par son numéro (le plus simple)
fw-remove.sh -n 3

# Supprimer la règle pour SSH
fw-remove.sh -s ssh

# Supprimer la règle pour le port 8080
fw-remove.sh -p 8080

# Supprimer la règle pour une IP spécifique
fw-remove.sh -p 22 -i 192.168.1.100
```

### 4. `fw-status.sh` - Vérifier l'état
Affiche l'état du firewall et toutes les règles actives.

```bash
fw-status.sh
```

### 5. `fw-stop.sh` - Désactiver le firewall
Désactive complètement le firewall (utiliser avec précaution).

```bash
fw-stop.sh
```

## 🔧 Services courants

Voici quelques services que vous pourriez vouloir autoriser:

| Service | Port | Commande |
|---------|------|----------|
| SSH | 22 | `fw-allow.sh -s ssh` |
| HTTP | 80 | `fw-allow.sh -s http` |
| HTTPS | 443 | `fw-allow.sh -s https` |
| FTP | 21 | `fw-allow.sh -p 21` |
| SMTP | 25 | `fw-allow.sh -p 25` |
| DNS | 53 | `fw-allow.sh -p 53 -P udp` |
| MySQL | 3306 | `fw-allow.sh -p 3306` |
| PostgreSQL | 5432 | `fw-allow.sh -p 5432` |
| MongoDB | 27017 | `fw-allow.sh -p 27017` |
| Redis | 6379 | `fw-allow.sh -p 6379` |

## 🎯 Workflows typiques

### Premier démarrage
```bash
# 1. Initialiser le firewall
fw-init.sh

# 2. Autoriser SSH pour ne pas perdre l'accès distant
fw-allow.sh -s ssh

# 3. Vérifier l'état
fw-status.sh
```

### Ouvrir un nouveau service
```bash
# 1. Démarrer votre service (ex: serveur web sur port 8080)
# 2. Autoriser le port
fw-allow.sh -p 8080

# 3. Vérifier que la règle est ajoutée
fw-status.sh
```

### Nettoyer les règles inutiles
```bash
# 1. Lister les règles
fw-remove.sh -l

# 2. Noter les numéros à supprimer
# 3. Supprimer par numéro (attention: les numéros changent après chaque suppression)
fw-remove.sh -n 5
```

### Sécurité maximale pour un serveur web
```bash
# Autoriser uniquement HTTP, HTTPS et SSH depuis une IP admin spécifique
fw-init.sh
fw-allow.sh -s http
fw-allow.sh -s https
fw-allow.sh -s ssh -i 203.0.113.50  # Remplacer par votre IP
```

## ⚠️ Notes importantes

1. **Sudo requis**: Tous les scripts nécessitent les droits administrateur (sudo)

2. **SSH**: Si vous gérez un serveur distant via SSH, assurez-vous d'autoriser SSH **AVANT** d'activer le firewall, sinon vous perdrez l'accès!

3. **Persistance**: Les règles UFW sont automatiquement sauvegardées et restaurées au redémarrage

4. **Logs**: UFW enregistre les tentatives de connexion bloquées dans `/var/log/ufw.log`

5. **IPv6**: UFW gère aussi l'IPv6 automatiquement

## 🔍 Commandes UFW directes

Si vous préférez utiliser UFW directement:

```bash
# Activer/désactiver
sudo ufw enable
sudo ufw disable

# Voir l'état
sudo ufw status verbose
sudo ufw status numbered

# Ajouter des règles
sudo ufw allow 22/tcp
sudo ufw allow from 192.168.1.0/24 to any port 22

# Supprimer des règles
sudo ufw delete allow 22/tcp
sudo ufw delete 3  # par numéro

# Réinitialiser (supprimer toutes les règles)
sudo ufw reset
```

## 📚 Ressources

- Documentation UFW: `man ufw`
- Logs: `sudo tail -f /var/log/ufw.log`
- Configuration: `/etc/ufw/`

## 🆘 Dépannage

### Je suis bloqué hors de mon serveur SSH
Si vous avez un accès physique ou console:
```bash
sudo ufw allow ssh
sudo ufw reload
```

### Le firewall ne démarre pas au boot
```bash
sudo systemctl enable ufw
sudo systemctl start ufw
```

### Voir les connexions bloquées
```bash
sudo tail -f /var/log/ufw.log | grep BLOCK
```

### Réinitialiser complètement
```bash
sudo ufw --force reset
fw-init.sh
```
