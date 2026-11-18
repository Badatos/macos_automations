#!/bin/bash

# Script pour convertir des images en WEBP avec vérification d'optimisation
# Usage: ./convert-to-webp.sh [--nodelete] image.jpg image.png ...
# Options:
#   --nodelete : Ne pas supprimer les fichiers originaux après conversion réussie

# Pré-requis : `brew install magick`

MAGICK_PATH="/opt/homebrew/bin/magick"
DELETE_ORIGINAL=true

echo "Using magick for Avif conversion."

# Vérifier l'option --nodelete
if [[ "$1" == "--nodelete" ]]; then
  DELETE_ORIGINAL=false
  shift
  echo "Mode test: les fichiers originaux ne seront pas supprimés"
  echo ""
fi

for f in "$@"
do
  # Vérifier que le fichier existe
  if [ ! -f "$f" ]; then
    echo "Erreur: Le fichier '$f' n'existe pas."
    continue
  fi

  output="${f%.*}.webp"

  # Vérifier si le fichier de sortie existe déjà
  if [ -f "$output" ]; then
    echo "Attention: '$output' existe déjà, passage au suivant."
    continue
  fi

  echo "Conversion: $(basename "$f") → $(basename "$output")"
  "$MAGICK_PATH" "$f" "$output"

  # Vérifier que le fichier WEBP a bien été créé
  if [ ! -f "$output" ]; then
    echo "⚠ Erreur: Le fichier WEBP n'a pas pu être créé."
    echo ""
    continue
  fi

  # Comparer les tailles et vérifier la pertinence de l'optimisation
  original_size=$(stat -f%z "$f" 2>/dev/null || stat -c%s "$f" 2>/dev/null)
  webp_size=$(stat -f%z "$output" 2>/dev/null || stat -c%s "$output" 2>/dev/null)

  # Convertir en MB pour l'affichage
  original_mb=$(echo "scale=2; $original_size / 1048576" | bc)
  webp_mb=$(echo "scale=2; $webp_size / 1048576" | bc)

  if [ $webp_size -gt $original_size ]; then
    echo "⚠ Optimisation non pertinente:"
    echo "  Fichier original: ${original_mb} MB"
    echo "  Fichier WEBP:     ${webp_mb} MB (plus gros de $(echo "scale=2; ($webp_size - $original_size) / 1048576" | bc) MB)"

    # Supprimer le fichier WEBP et créer un fichier texte explicatif
    rm "$output"
    base="${f%.*}"
    txt_file="${base}-conversion-failed.txt"
    cat > "$txt_file" << EOF
Conversion en WEBP non effectuée

Le fichier WEBP résultant (${webp_mb} MB) était plus volumineux que l'image originale (${original_mb} MB).
Cette conversion n'apporterait pas d'optimisation pertinente.

Fichier original: $(basename "$f") (${original_mb} MB)
Date: $(date)
EOF
    echo "✓ Fichier créé: $(basename "$txt_file")"
  else
    saving=$(echo "scale=2; ($original_size - $webp_size) / 1048576" | bc)
    percent=$(echo "scale=1; (100 * ($original_size - $webp_size)) / $original_size" | bc)
    echo "✓ Optimisation réussie:"
    echo "  Fichier original: ${original_mb} MB"
    echo "  Fichier WEBP:     ${webp_mb} MB"
    echo "  Économie: ${saving} MB (${percent}%)"

    # Supprimer l'original si activé
    if [ "$DELETE_ORIGINAL" = true ]; then
      rm "$f"
      echo "✓ Fichier original supprimé"
    else
      echo "  (Mode test: fichier original conservé)"
    fi
  fi
  echo ""
done

echo "Conversion complète !"
