#!/bin/bash

# Vérifiez si le dossier a été fourni en argument
if [ -z "$1" ]; then
	echo "Usage: $0 <dossier>"
	exit 1
fi

# Vérifiez si le dossier existe
if [ ! -d "$1" ]; then
	echo "Le dossier spécifié n'existe pas : $1"
	exit 1
fi

# Demander à l'utilisateur la racine du nom des images
read -p "Entrez la racine du futur nom des images : " NAME_ROOT

IMAGE_DIR="$1"

# Répertoire cible
TARGET_DIR="$IMAGE_DIR/resized"
# Vérifiez si le dossier existe
if [ ! -d "$TARGET_DIR" ]; then
	echo "Le dossier spécifié n'existe pas : $TARGET_DIR"
	mkdir $TARGET_DIR
	echo "Le dossier $TARGET_DIR a été créé"
fi

# Index pour le nommage des fichiers
INDEX=1
shopt -s nocaseglob
# Parcourt tous les fichiers d'image dans le dossier
for IMAGE in "$IMAGE_DIR"/*.{jpg,jpeg,png,gif}; do
	# Vérifiez si le fichier existe pour éviter des erreurs en cas d'absence de fichiers correspondants
	if [ -f "$IMAGE" ]; then
		# Détermine l'extension du fichier
		EXT="${IMAGE##*.}"
		# Nouveau nom de fichier avec racine et index
		NEW_NAME="${TARGET_DIR}/${NAME_ROOT}_${INDEX}.${EXT}"

		echo "Redimensionnement de l'image : $IMAGE -> $NEW_NAME"

		# Redimensionne et renomme l'image
		convert "$IMAGE" -resize 50% "$NEW_NAME"

		# Incrémente l'index
		INDEX=$((INDEX + 1))
	fi
done
shopt -u nocaseglob
echo "Redimensionnement et renommage terminés."
