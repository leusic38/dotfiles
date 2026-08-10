#!/bin/bash
# Script pour supprimer des règles du firewall

set -e

# Fonction d'aide
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Supprime des règles du firewall"
    echo ""
    echo "Options:"
    echo "  -n, --number NUM          Supprimer la règle par son numéro"
    echo "  -p, --port PORT           Supprimer la règle pour ce port"
    echo "  -s, --service SERVICE     Supprimer la règle pour ce service"
    echo "  -i, --ip IP               Supprimer uniquement pour cette IP"
    echo "  -P, --proto PROTO         Protocole (tcp/udp, défaut: tcp)"
    echo "  -l, --list                Lister les règles avec leurs numéros"
    echo "  -h, --help                Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0 -l                     # Lister toutes les règles"
    echo "  $0 -n 3                   # Supprimer la règle numéro 3"
    echo "  $0 -p 22                  # Supprimer la règle pour le port 22"
    echo "  $0 -s ssh                 # Supprimer la règle pour SSH"
    echo "  $0 -p 22 -i 192.168.1.50  # Supprimer SSH depuis 192.168.1.50"
}

NUMBER=""
PORT=""
SERVICE=""
IP=""
PROTO="tcp"
LIST=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--number)
            NUMBER="$2"
            shift 2
            ;;
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
        -l|--list)
            LIST=true
            shift
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

# Si --list, afficher les règles et quitter
if [ "$LIST" = true ]; then
    echo "📋 Règles actuelles du firewall:"
    sudo ufw status numbered
    exit 0
fi

# Supprimer par numéro (le plus simple)
if [ -n "$NUMBER" ]; then
    echo "🗑️  Suppression de la règle numéro $NUMBER..."
    echo "y" | sudo ufw delete $NUMBER
    echo ""
    echo "✅ Règle supprimée!"
    echo ""
    echo "📋 Règles restantes:"
    sudo ufw status numbered
    exit 0
fi

# Supprimer par port/service
if [ -z "$PORT" ] && [ -z "$SERVICE" ]; then
    echo "❌ Erreur: vous devez spécifier un numéro (-n), un port (-p) ou un service (-s)"
    echo ""
    show_help
    exit 1
fi

# Construire la commande de suppression
CMD="sudo ufw delete allow"

if [ -n "$IP" ]; then
    CMD="$CMD from $IP"
fi

if [ -n "$SERVICE" ]; then
    CMD="$CMD $SERVICE"
elif [ -n "$PORT" ]; then
    CMD="$CMD $PORT/$PROTO"
fi

# Afficher et exécuter la commande
echo "🗑️  Suppression de la règle..."
echo "   Commande: $CMD"
$CMD

echo ""
echo "✅ Règle supprimée avec succès!"
echo ""
echo "📋 Règles restantes:"
sudo ufw status numbered
