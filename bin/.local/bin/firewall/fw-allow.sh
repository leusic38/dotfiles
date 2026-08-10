#!/bin/bash
# Script pour autoriser des connexions spécifiques

set -e

# Fonction d'aide
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Autorise des connexions entrantes à travers le firewall"
    echo ""
    echo "Options:"
    echo "  -p, --port PORT           Port à autoriser (ex: 22, 80, 443)"
    echo "  -s, --service SERVICE     Service à autoriser (ex: ssh, http, https)"
    echo "  -i, --ip IP               Autoriser uniquement depuis cette IP"
    echo "  -P, --proto PROTO         Protocole (tcp/udp, défaut: tcp)"
    echo "  -h, --help                Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0 -p 22                  # Autoriser SSH depuis n'importe où"
    echo "  $0 -s ssh                 # Autoriser SSH (équivalent)"
    echo "  $0 -p 22 -i 192.168.1.50  # Autoriser SSH uniquement depuis 192.168.1.50"
    echo "  $0 -p 8080 -P tcp         # Autoriser port 8080 en TCP"
    echo "  $0 -p 3000-3010           # Autoriser une plage de ports"
}

PORT=""
SERVICE=""
IP=""
PROTO="tcp"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -s|--service)
            SERVICE="$2"
            shift 2
            ;;
        -i|--ip)
            IP="$2"
            shift 2
            ;;
        -P|--proto)
            PROTO="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "❌ Option inconnue: $1"
            show_help
            exit 1
            ;;
    esac
done

# Vérifier qu'au moins un port ou service est spécifié
if [ -z "$PORT" ] && [ -z "$SERVICE" ]; then
    echo "❌ Erreur: vous devez spécifier un port (-p) ou un service (-s)"
    echo ""
    show_help
    exit 1
fi

# Construire la commande UFW
CMD="sudo ufw allow"

if [ -n "$IP" ]; then
    CMD="$CMD from $IP"
fi

if [ -n "$SERVICE" ]; then
    CMD="$CMD $SERVICE"
elif [ -n "$PORT" ]; then
    CMD="$CMD $PORT/$PROTO"
fi

# Afficher et exécuter la commande
echo "🔓 Autorisation de la connexion..."
echo "   Commande: $CMD"
$CMD

echo ""
echo "✅ Règle ajoutée avec succès!"
echo ""
echo "📋 Règles actuelles:"
sudo ufw status numbered
