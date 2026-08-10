#!/bin/bash
# Script pour afficher l'état du firewall

echo "🔍 État du firewall UFW"
echo "========================"
echo ""

# Vérifier si UFW est actif
if sudo ufw status | grep -q "Status: active"; then
    echo "✅ Firewall: ACTIF"
else
    echo "⚠️  Firewall: INACTIF"
fi

echo ""
echo "📊 Configuration détaillée:"
sudo ufw status verbose

echo ""
echo "📋 Règles numérotées:"
sudo ufw status numbered

echo ""
echo "🌐 Ports en écoute sur le système:"
sudo ss -tlnp | head -1
sudo ss -tlnp | grep LISTEN || echo "Aucun port en écoute"
