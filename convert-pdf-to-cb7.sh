#!/bin/bash

# Script pour convertir un PDF en CB7 (images WebP)
# Usage : ./convert-pdf-to-cb7.sh fichier.pdf
# Les pages PDF sont converties en images WebP, puis compressées en CB7

# Pré-requis : `brew install magick poppler sevenzip`

set -e  # Exit on error

MAGICK_PATH="/opt/homebrew/bin/magick"
PDFTOPPM_PATH="/opt/homebrew/bin/pdftoppm"
SEVENZIP_PATH="/opt/homebrew/bin/7zz"

# Vérifier que pdftoppm est installé
if [ ! -f "$PDFTOPPM_PATH" ]; then
  echo "Erreur : pdftoppm n’est pas installé."
  echo "Installez-le avec : brew install poppler"
  exit 1
fi

if [ ! -x "$SEVENZIP_PATH" ]; then
  SEVENZIP_PATH="$(command -v 7zz || command -v 7z || true)"
  if [ -z "$SEVENZIP_PATH" ]; then
    echo "Erreur : 7-Zip n’est pas installé ou absent du PATH."
    echo "Installez-le avec : brew install sevenzip"
    exit 1
  fi
fi

# Vérifier les arguments
if [ $# -eq 0 ]; then
  echo "Usage : $0 <fichier.pdf>"
  exit 1
fi

for input_file in "$@"
do
  # Vérifier que le fichier existe
  if [ ! -f "$input_file" ]; then
    echo "Erreur : Le fichier '$input_file' n’existe pas."
    continue
  fi

  # Extraire le chemin, le nom et l’extension
  dir=$(dirname "$input_file")
  basename=$(basename "$input_file")
  filename="${basename%.*}"
  ext="${basename##*.}"

  # Vérifier que c’est un PDF
  if [[ ! "$ext" =~ ^(pdf|PDF)$ ]]; then
    echo "Attention : '$input_file' n’est pas un PDF (extension : $ext)"
  fi

  # Créer un répertoire temporaire pour les pages
  temp_dir=$(mktemp -d)
  echo "Conversion du PDF '$basename' en images WebP..."

  # Convertir chaque page en PPM avec pdftoppm (plus rapide que ImageMagick pour les PDFs)
  # -r 150 pour 150 DPI
  "$PDFTOPPM_PATH" -r 150 "$input_file" "$temp_dir/page"

  # Vérifier que des images ont été créées
  ppm_count=$(find "$temp_dir" -name "page-*.ppm" | wc -l)
  if [ $ppm_count -eq 0 ]; then
    echo "Erreur : Aucune image n’a pu être créée à partir du PDF."
    rm -rf "$temp_dir"
    continue
  fi

  echo "✓ $ppm_count pages extraites du PDF"
  echo "Conversion des images en WebP..."

  # Convertir chaque PPM en WebP
  find "$temp_dir" -name "page-*.ppm" | sort -V | while read ppm_file
  do
    webp_file="${ppm_file%.ppm}.webp"
    "$MAGICK_PATH" "$ppm_file" -quality 90 "$webp_file"
    rm "$ppm_file"
  done

  echo "✓ Conversion en WebP terminée"

  # Créer l’archive CB7
  output_file="$(cd "$dir" && pwd)/${filename}.cb7"
  echo "Création du CB7 : $(basename "$output_file")..."

  # Vérifier si le fichier de sortie existe déjà
  if [ -f "$output_file" ]; then
    echo "Attention : '$output_file' existe déjà et sera écrasé."
    rm "$output_file"
  fi

  # Créer le CB7 (archive 7z) avec les images
  cd "$temp_dir"
  "$SEVENZIP_PATH" a -t7z -bd "$output_file" page-*.webp
  cd - > /dev/null

  # Nettoyer
  rm -rf "$temp_dir"

  # Comparer les tailles et vérifier la pertinence de l’optimisation
  original_size=$(stat -f%z "$input_file" 2>/dev/null || stat -c%s "$input_file" 2>/dev/null)
  cb7_size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null)

  # Convertir en MB pour l’affichage
  original_mb=$(echo "scale=2; $original_size / 1048576" | bc)
  cb7_mb=$(echo "scale=2; $cb7_size / 1048576" | bc)

  if [ $cb7_size -gt $original_size ]; then
    echo "⚠ Optimisation non pertinente :"
    echo "  Fichier original : ${original_mb} MB"
    echo "  Fichier CB7 :      ${cb7_mb} MB (plus gros de $(echo "scale=2; ($cb7_size - $original_size) / 1048576" | bc) MB)"
    echo "Le CB7 n’a pas été conservé."

    # Supprimer le CB7 et créer un fichier texte explicatif
    rm "$output_file"
    txt_file="$dir/${filename}-conversion-failed.txt"
    cat > "$txt_file" << EOF
Conversion PDF → CB7 non effectuée

Le fichier CB7 résultant (${cb7_mb} MB) était plus volumineux que le PDF original (${original_mb} MB).
Cette conversion n’apporterait pas d’optimisation pertinente.

Fichier original : $basename (${original_mb} MB)
Date : $(date)
EOF
    echo "✓ Fichier créé : $(basename "$txt_file")"
  else
    saving=$(echo "scale=2; ($original_size - $cb7_size) / 1048576" | bc)
    percent=$(echo "scale=1; (100 * ($original_size - $cb7_size)) / $original_size" | bc)
    echo "✓ Optimisation réussie :"
    echo "  Fichier original : ${original_mb} MB"
    echo "  Fichier CB7 :      ${cb7_mb} MB"
    echo "  Économie : ${saving} MB (${percent}%)"
  fi
  echo ""
done

echo "Conversion complète !"
