#!/bin/bash
# Script d'initialisation du firewall
# Bloque toutes les connexions externes sauf celles spécifiées

set -e

echo "🔒 Initialisation du firewall avec politique restrictive..."

# Activer UFW s'il n'est pas déjà actif
if ! sudo ufw status | grep -q "Status: active"; then
    echo "📋 Configuration des règles par défaut..."

    # Politique par défaut : bloquer tout le trafic entrant
    sudo ufw default deny incoming

    # Autoriser le trafic sortant (pour que vous puissiez accéder à Internet)
    sudo ufw default allow outgoing

    # Autoriser le trafic en loopback (nécessaire pour les applications locales)
    sudo ufw allow in on lo
    sudo ufw allow out on lo

    # Activer UFW (confirmation automatique)
    echo "✅ Activation du firewall..."
    sudo ufw --force enable

    # Activer le service au démarrage
    sudo systemctl enable ufw
else
    echo "✅ UFW est déjà actif"
fi

echo ""
echo "🎯 État actuel du firewall:"
sudo ufw status verbose

echo ""
echo "✅ Firewall configuré avec succès!"
echo "   - Tout le trafic entrant est BLOQUÉ par défaut"
echo "   - Le trafic sortant est AUTORISÉ"
echo "   - Utilisez les scripts fw-allow.sh et fw-remove.sh pour gérer les exceptions"
