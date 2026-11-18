#!/bin/bash

# Script pour convertir toutes les images d'un CBZ/CBR en WebP
# Usage: ./convert-cbz-to-webp.sh fichier.cbz
# ou: ./convert-cbz-to-webp.sh fichier.cbr

# Pré-requis : `brew install unar`

set -e  # Exit on error

MAGICK_PATH="/opt/homebrew/bin/magick"

# Vérifier les arguments
if [ $# -eq 0 ]; then
  echo "Usage: $0 <fichier.cbz|fichier.cbr>"
  exit 1
fi

for input_file in "$@"
do
  # Vérifier que le fichier existe
  if [ ! -f "$input_file" ]; then
    echo "Erreur: Le fichier '$input_file' n'existe pas."
    continue
  fi

  # Extraire le chemin, le nom et l'extension
  dir=$(dirname "$input_file")
  basename=$(basename "$input_file")
  filename="${basename%.*}"
  ext="${basename##*.}"

  # Vérifier que c'est un CBZ ou CBR
  if [[ ! "$ext" =~ ^(cbz|cbr|zip|rar)$ ]]; then
    echo "Attention: '$input_file' n'est pas un CBZ/CBR reconnu (extension: $ext)"
  fi

  # Créer un répertoire pour l'extraction "plate" des images
  images_dir=$(mktemp -d)
  echo "Décompression de '$basename'..."

  # Décompresser en mode "flat" (sans structure de dossiers)
  if command -v unar &> /dev/null; then
    # unar extrait tous les fichiers à la racine avec l'option -k
    unar -k skip -o "$images_dir" "$input_file" > /dev/null 2>&1 || {
      echo "Erreur lors de la décompression."
      rm -rf "$temp_dir" "$images_dir"
      continue
    }
  else
    # unzip avec les options pour l'encodage UTF-8
    LANG=fr_FR.UTF-8 unzip -q -a "$input_file" -d "$images_dir" 2>/dev/null || {
      echo "Erreur lors de la décompression."
      rm -rf "$temp_dir" "$images_dir"
      continue
    }
  fi

  # Trouver tous les fichiers image et les convertir
  echo "Conversion des images en WebP..."

  # Créer un répertoire pour les images converties
  converted_dir=$(mktemp -d)
  image_count=0

  # Trouver et convertir toutes les images, peu importe le dossier
  # Utiliser -print0 pour gérer correctement les espaces et caractères spéciaux
  find "$images_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.tiff" \) -print0 | sort -z | while IFS= read -r -d '' image_path
  do
    # Créer un nom de sortie simple
    image_count=$((image_count + 1))
    output_file="$converted_dir/image_$(printf "%04d" $image_count).webp"

    echo "  Conversion: Image $image_count"
    # Supprimer les warnings d'autorisation
    "$MAGICK_PATH" "$image_path" "$output_file" 2>&1 | grep -v "not authorized" || true
  done

  # Créer un répertoire temporaire pour le zip final
  temp_dir=$(mktemp -d)

  # Renommer les fichiers WebP avec numérotation simple pour le CBZ
  converted_count=0
  find "$converted_dir" -name "*.webp" -print0 | sort -z | while IFS= read -r -d '' webp_file
  do
    converted_count=$((converted_count + 1))
    new_name=$(printf "page_%04d.webp" $converted_count)
    cp "$webp_file" "$temp_dir/$new_name"
  done

  # Nettoyer les répertoires d'extraction
  rm -rf "$images_dir" "$converted_dir"

  # Créer l'archive de sortie (toujours en ZIP/CBZ)
  output_file="$dir/${filename}-webp.cbz"
  # Utiliser un chemin absolu pour éviter les problèmes avec cd
  output_file=$(cd "$dir" 2>/dev/null && pwd)/"${filename}-webp.cbz" || "$dir/${filename}-webp.cbz"

  echo "Création de l'archive: $(basename "$output_file")..."

  # Vérifier si le fichier de sortie existe déjà
  if [ -f "$output_file" ]; then
    echo "Attention: '$output_file' existe déjà et sera écrasé."
    rm "$output_file"
  fi

  # Créer le CBZ (archive ZIP) en restant dans le répertoire temporaire
  cd "$temp_dir"
  zip -r -q "$output_file" . 2>/dev/null || true
  cd - > /dev/null

  # Vérifier que le fichier a bien été créé
  if [ ! -f "$output_file" ]; then
    echo "Erreur: Le fichier CBZ n'a pas pu être créé."
    rm -rf "$temp_dir"
    continue
  fi

  # Nettoyer
  rm -rf "$temp_dir"

  # Comparer les tailles et vérifier la pertinence de l'optimisation
  original_size=$(stat -f%z "$input_file" 2>/dev/null || stat -c%s "$input_file" 2>/dev/null)
  cbz_size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null)

  # Convertir en MB pour l'affichage
  original_mb=$(echo "scale=2; $original_size / 1048576" | bc)
  cbz_mb=$(echo "scale=2; $cbz_size / 1048576" | bc)

  if [ $cbz_size -gt $original_size ]; then
    echo "⚠ Optimisation non pertinente:"
    echo "  Fichier original: ${original_mb} MB"
    echo "  Fichier WebP:     ${cbz_mb} MB (plus gros de $(echo "scale=2; ($cbz_size - $original_size) / 1048576" | bc) MB)"
    echo "Le CBZ n'a pas été conservé."

    # Supprimer le CBZ et créer un fichier texte explicatif
    rm "$output_file"
    txt_file="$dir/${filename}-conversion-failed.txt"
    cat > "$txt_file" << EOF
Conversion CBZ/CBR → WebP non effectuée

Le fichier WebP résultant (${cbz_mb} MB) était plus volumineux que l'archive originale (${original_mb} MB).
Cette conversion n'apporterait pas d'optimisation pertinente.

Fichier original: $basename (${original_mb} MB)
Date: $(date)
EOF
    echo "✓ Fichier créé: $(basename "$txt_file")"
  else
    saving=$(echo "scale=2; ($original_size - $cbz_size) / 1048576" | bc)
    percent=$(echo "scale=1; (100 * ($original_size - $cbz_size)) / $original_size" | bc)
    echo "✓ Optimisation réussie:"
    echo "  Fichier original: ${original_mb} MB"
    echo "  Fichier WebP:     ${cbz_mb} MB"
    echo "  Économie: ${saving} MB (${percent}%)"
  fi
  echo ""
done

echo "Conversion complète !"
