#!/bin/bash
# Script pour désactiver temporairement le firewall

echo "⚠️  ATTENTION: Ce script va désactiver le firewall!"
echo "   Votre machine sera exposée sans protection."
echo ""
read -p "Êtes-vous sûr de vouloir continuer? (oui/non): " confirm

if [ "$confirm" != "oui" ]; then
    echo "❌ Opération annulée"
    exit 0
fi

echo ""
echo "🔓 Désactivation du firewall..."
sudo ufw disable

echo ""
echo "✅ Firewall désactivé"
echo "   Pour le réactiver: fw-init.sh ou: sudo ufw enable"
