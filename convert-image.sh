#!/bin/bash

# Script universel pour convertir des images
# Usage: ./convert-image.sh [format] [--nodelete] [--report] fichier.jpg dossier/ ...
# Format: avif|webp (défaut: webp)
# Options:
#   --nodelete : Ne pas supprimer les fichiers originaux après conversion réussie
#   --report   : Afficher/sauvegarder un rapport détaillé à la fin

# Pré-requis : `brew install magick`

MAGICK_PATH="/opt/homebrew/bin/magick"
FORMAT="webp"
DELETE_ORIGINAL=true
SHOW_REPORT=false
REPORT_FILE=""

# Statistiques globales
declare -i TOTAL_IMAGES=0
declare -i IMAGES_CONVERTED=0
declare -i IMAGES_FAILED=0
declare -i IMAGES_SKIPPED=0
declare -i TOTAL_ORIGINAL_SIZE=0
declare -i TOTAL_OUTPUT_SIZE=0

# Traiter les options et fichiers de manière flexible
# Accepte les options avant ou après les fichiers
declare -a FILES
while [ $# -gt 0 ]; do
  case "$1" in
    avif|webp)
      FORMAT="$1"
      shift
      ;;
    --nodelete)
      DELETE_ORIGINAL=false
      shift
      ;;
    --report)
      SHOW_REPORT=true
      shift
      ;;
    --*)
      echo "Option inconnue: $1"
      shift
      ;;
    *)
      # C'est un fichier ou dossier
      FILES+=("$1")
      shift
      ;;
  esac
done

# Valider le format
if [[ ! "$FORMAT" =~ ^(avif|webp)$ ]]; then
  echo "Erreur: Format non supporté '$FORMAT'"
  echo "Formats supportés: avif, webp"
  exit 1
fi

FORMAT_UPPER=$(echo "$FORMAT" | tr '[:lower:]' '[:upper:]')

# Fonction pour formater les tailles avec l'unité appropriée
format_size() {
  local bytes=${1:-0}
  
  # Vérifier que c'est un nombre valide
  if ! [[ "$bytes" =~ ^[0-9]+$ ]]; then
    bytes=0
  fi
  
  if [ "$bytes" -lt 1048576 ]; then
    # Afficher en Ko
    echo "scale=1; $bytes / 1024" | bc | awk '{printf "%.1f Ko", $0}'
  else
    # Afficher en Mo
    echo "scale=2; $bytes / 1048576" | bc | awk '{printf "%.2f Mo", $0}'
  fi
}

echo "Using magick for $FORMAT_UPPER conversion."
[ "$DELETE_ORIGINAL" = false ] && echo "Mode test: les fichiers originaux ne seront pas supprimés"
[ "$SHOW_REPORT" = true ] && echo "Rapport détaillé activé"
echo ""

# Fonction pour traiter un fichier
process_image() {
  local f="$1"

  # Vérifier que le fichier existe
  if [ ! -f "$f" ]; then
    echo "Erreur: Le fichier '$f' n'existe pas."
    return
  fi

  # Filtrer les images (extensions courantes)
  if ! [[ "$f" =~ \.(jpg|jpeg|png|gif|bmp|webp|tiff|heic|heif|avif)$ ]]; then
    return
  fi

  ((TOTAL_IMAGES++))
  output="${f%.*}.$FORMAT"

  # Vérifier si le fichier de sortie existe déjà
  if [ -f "$output" ]; then
    echo "Attention: '$output' existe déjà, passage au suivant."
    ((IMAGES_SKIPPED++))
    return
  fi

  echo "Conversion: $(basename "$f") → $(basename "$output")"
  "$MAGICK_PATH" "$f" "$output"

  # Vérifier que le fichier de sortie a bien été créé
  if [ ! -f "$output" ]; then
    echo "⚠ Erreur: Le fichier $FORMAT n'a pas pu être créé."
    ((IMAGES_FAILED++))
    echo ""
    return
  fi

  # Comparer les tailles et vérifier la pertinence de l'optimisation
  original_size=$(stat -f%z "$f" 2>/dev/null || stat -c%s "$f" 2>/dev/null)
  output_size=$(stat -f%z "$output" 2>/dev/null || stat -c%s "$output" 2>/dev/null)

  original_display=$(format_size $original_size)
  output_display=$(format_size $output_size)

  if [ $output_size -gt $original_size ]; then
    echo "⚠ Optimisation non pertinente:"
    echo "  Fichier original: $original_display"
    echo "  Fichier $FORMAT_UPPER:     $output_display (plus gros de $(format_size $((output_size - original_size))))"

    # Supprimer le fichier de sortie et créer un fichier texte explicatif
    rm "$output"
    base="${f%.*}"
    txt_file="${base}-conversion-failed.txt"
    cat > "$txt_file" << EOF
Conversion en $FORMAT_UPPER non effectuée

Le fichier $FORMAT_UPPER résultant ($output_display) était plus volumineux que l'image originale ($original_display).
Cette conversion n'apporterait pas d'optimisation pertinente.

Fichier original: $(basename "$f") ($original_display)
Date: $(date)
EOF
    echo "✓ Fichier créé: $(basename "$txt_file")"
    ((IMAGES_FAILED++))
  else
    saving=$((original_size - output_size))
    saving_display=$(format_size $saving)
    percent=$(echo "scale=1; (100 * ($original_size - $output_size)) / $original_size" | bc)
    echo "✓ Optimisation réussie:"
    echo "  Fichier original: $original_display"
    echo "  Fichier $FORMAT_UPPER:     $output_display"
    echo "  Économie: $saving_display ($percent%)"

    # Mettre à jour les statistiques
    ((IMAGES_CONVERTED++))
    ((TOTAL_ORIGINAL_SIZE += original_size))
    ((TOTAL_OUTPUT_SIZE += output_size))

    # Supprimer l'original si activé
    if [ "$DELETE_ORIGINAL" = true ]; then
      rm "$f"
      echo "✓ Fichier original supprimé"
    else
      echo "  (Mode test: fichier original conservé)"
    fi
  fi
  echo ""
}

# Traiter les fichiers et dossiers
for arg in "${FILES[@]}"; do
  if [ -d "$arg" ]; then
    # C'est un dossier : traiter toutes les images
    echo "📁 Traitement du dossier: $arg"
    echo ""
    while IFS= read -r -d '' file; do
      process_image "$file"
    done < <(find "$arg" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.webp" -o -iname "*.tiff" -o -iname "*.heic" -o -iname "*.heif" -o -iname "*.avif" \) -print0)
  else
    # C'est un fichier
    process_image "$arg"
  fi
done

# Génération du rapport
generate_report() {
  local total_saving_percent="0.0"

  if [ $TOTAL_ORIGINAL_SIZE -gt 0 ]; then
    total_saving=$(echo "$TOTAL_ORIGINAL_SIZE - $TOTAL_OUTPUT_SIZE" | bc)
    total_saving_percent=$(echo "scale=1; (100 * ($TOTAL_ORIGINAL_SIZE - $TOTAL_OUTPUT_SIZE)) / $TOTAL_ORIGINAL_SIZE" | bc)
  fi

  local report=""
  report+="══════════════════════"$'\n'
  report+=" RAPPORT DE CONVERSION EN ${FORMAT_UPPER}"$'\n'
  report+="══════════════════════"$'\n'
  report+=$'\n'
  report+="📊 RÉSUMÉ GLOBAL"$'\n'
  report+="───────────────────────"$'\n'
  report+="  Total d'images trouvées:  $TOTAL_IMAGES"$'\n'
  report+="  Images converties:        $IMAGES_CONVERTED ✓"$'\n'
  report+="  Images échouées:          $IMAGES_FAILED ✗"$'\n'
  report+="  Images déjà présentes:    $IMAGES_SKIPPED ⊘"$'\n'
  report+=$'\n'
  report+="💾 ÉCONOMIE D'ESPACE"$'\n'
report+="───────────────────────"$'\n'

  local total_original_display="0 Mo"
  local total_output_display="0 Mo"
  local total_saving_display="0 Mo"

  if [ $TOTAL_ORIGINAL_SIZE -gt 0 ]; then
    total_original_display=$(format_size $TOTAL_ORIGINAL_SIZE)
    total_output_display=$(format_size $TOTAL_OUTPUT_SIZE)
    total_saving_display=$(format_size $total_saving)
  fi

  report+="  Taille originale:  $total_original_display"$'\n'
  report+="  Taille $FORMAT_UPPER:       $total_output_display"$'\n'
  report+="  Économie totale:   $total_saving_display (${total_saving_percent}%)"$'\n'
  report+=$'\n'

  report+="Conversion complète à $(date '+%Y-%m-%d %H:%M:%S')"$'\n'

  echo -e "$report"

  # Optionnel: Sauvegarder le rapport dans un fichier
  if [ "$SHOW_REPORT" = true ]; then
    REPORT_FILE="/tmp/${FORMAT}-conversion-report-$(date +%s).txt"
    echo -e "$report" > "$REPORT_FILE"
  fi
}

generate_report

# Si rapport avec Automator, afficher via osascript
if [ "$SHOW_REPORT" = true ] && [ -n "$REPORT_FILE" ]; then
  if command -v osascript &> /dev/null; then
    osascript <<EOF
tell app "System Events"
  display dialog (read POSIX file "$REPORT_FILE" as «class utf8») with title "Conversion $FORMAT_UPPER - Rapport" buttons {"OK"} default button 1
end tell
EOF
  fi
fi
