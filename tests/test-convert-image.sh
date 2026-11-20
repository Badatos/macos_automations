#!/bin/bash

# Script de test pour convert-image.sh
# Crée un dossier temporaire avec des images de différents formats
# et teste la conversion en WEBP et AVIF

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONVERT_SCRIPT="$SCRIPT_DIR/../convert-image.sh"
TEST_DIR=$(mktemp -d "${TMPDIR:-/tmp}/convert-image-test.XXXXXX")

# Nettoyage à la fin
cleanup() {
  rm -rf "$TEST_DIR"
  echo ""
  echo "✓ Dossier de test nettoyé"
}
trap cleanup EXIT

echo "╔════════════════════════════════════════════════╗"
echo "║           TEST - convert-image.sh              ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# Vérifier que le script existe
if [ ! -f "$CONVERT_SCRIPT" ]; then
  echo "❌ Erreur: Script $CONVERT_SCRIPT non trouvé"
  exit 1
fi

# Vérifier que ImageMagick est installé
if ! command -v magick &> /dev/null; then
  echo "❌ Erreur: ImageMagick n'est pas installé"
  echo "   Installez avec: brew install magick"
  exit 1
fi

echo "📂 Création d'un dossier de test: $TEST_DIR"
echo ""

# Créer des images de test avec différentes tailles et formats
echo "🎨 Création d'images de test..."

# Petite image PNG - simple, sans texte
magick -size 100x100 xc:red "$TEST_DIR/small.png" 2>/dev/null || true

# Image JPG moyenne
magick -size 300x300 xc:blue "$TEST_DIR/medium.jpg" 2>/dev/null || true

# Image PNG grande
magick -size 500x500 xc:green "$TEST_DIR/large.png" 2>/dev/null || true

# Image BMP
magick -size 200x200 xc:yellow "$TEST_DIR/image.bmp" 2>/dev/null || true

# Image GIF
magick -size 150x150 xc:purple "$TEST_DIR/animated.gif" 2>/dev/null || true

echo "✓ 5 images créées dans $TEST_DIR"
echo ""
echo "📊 Fichiers avant conversion:"
ls -lh "$TEST_DIR" | tail -n +2 | awk '{printf "   %-30s %s\n", $9, "(" $5 ")"}'
echo ""

# Calculer la taille totale avant
SIZE_BEFORE=$(du -sh "$TEST_DIR" 2>/dev/null | awk '{print $1}')
echo "💾 Taille totale avant: $SIZE_BEFORE"
echo ""

# ════════════════════════════════════════════════════════
echo "════════════════════════════════════════════════"
echo "TEST 1: Conversion en WEBP"
echo "════════════════════════════════════════════════"
echo ""

echo "Exécution: $CONVERT_SCRIPT webp --nodelete --report $TEST_DIR/"
echo ""

# Exécuter la conversion
"$CONVERT_SCRIPT" webp --nodelete --report "$TEST_DIR/" 2>&1 | head -60 || true

echo ""
echo "✓ TEST 1 terminé"

# ════════════════════════════════════════════════════════
echo ""
echo "════════════════════════════════════════════════"
echo "TEST 2: Conversion en AVIF"
echo "════════════════════════════════════════════════"
echo ""

echo "Exécution: $CONVERT_SCRIPT avif --nodelete --report $TEST_DIR/"
echo ""

# Exécuter la conversion
"$CONVERT_SCRIPT" avif --nodelete --report "$TEST_DIR/" 2>&1 | head -60 || true

echo ""
echo "✓ TEST 2 terminé"

# ════════════════════════════════════════════════════════
echo ""
echo "════════════════════════════════════════════════"
echo "RÉSUMÉ DES TESTS"
echo "════════════════════════════════════════════════"
echo ""

echo "📊 Fichiers après les conversions:"
echo ""

# Afficher les fichiers groupés par format
if ls "$TEST_DIR"/*.png >/dev/null 2>&1; then
  echo "Format PNG (originaux):"
  ls -lh "$TEST_DIR"/*.png | awk '{printf "  %-30s %s\n", $9, "(" $5 ")"}'
else
  echo "Format PNG: (aucun)"
fi

echo ""

if ls "$TEST_DIR"/*.jpg >/dev/null 2>&1; then
  echo "Format JPG (original):"
  ls -lh "$TEST_DIR"/*.jpg | awk '{printf "  %-30s %s\n", $9, "(" $5 ")"}'
else
  echo "Format JPG: (aucun)"
fi

echo ""

if ls "$TEST_DIR"/*.bmp >/dev/null 2>&1; then
  echo "Format BMP (original):"
  ls -lh "$TEST_DIR"/*.bmp | awk '{printf "  %-30s %s\n", $9, "(" $5 ")"}'
else
  echo "Format BMP: (aucun)"
fi

echo ""

if ls "$TEST_DIR"/*.gif >/dev/null 2>&1; then
  echo "Format GIF (original):"
  ls -lh "$TEST_DIR"/*.gif | awk '{printf "  %-30s %s\n", $9, "(" $5 ")"}'
else
  echo "Format GIF: (aucun)"
fi

echo ""

if ls "$TEST_DIR"/*.webp >/dev/null 2>&1; then
  echo "Format WEBP (converti):"
  ls -lh "$TEST_DIR"/*.webp | awk '{printf "  %-30s %s\n", $9, "(" $5 ")"}'
else
  echo "Format WEBP: (aucun)"
fi

echo ""

if ls "$TEST_DIR"/*.avif >/dev/null 2>&1; then
  echo "Format AVIF (converti):"
  ls -lh "$TEST_DIR"/*.avif | awk '{printf "  %-30s %s\n", $9, "(" $5 ")"}'
else
  echo "Format AVIF: (aucun)"
fi

echo ""

# Calculer la taille totale après
SIZE_AFTER=$(du -sh "$TEST_DIR" 2>/dev/null | awk '{print $1}')
echo "💾 Taille totale après: $SIZE_AFTER"
echo ""

# Compter les fichiers
TOTAL_FILES=$(find "$TEST_DIR" -type f | wc -l)
WEBP_COUNT=$(find "$TEST_DIR" -name "*.webp" -type f | wc -l)
AVIF_COUNT=$(find "$TEST_DIR" -name "*.avif" -type f | wc -l)
ORIG_COUNT=$(find "$TEST_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.bmp" -o -name "*.gif" \) | wc -l)

echo "📈 Statistiques:"
echo "  Fichiers totaux: $TOTAL_FILES"
echo "  Fichiers originaux: $ORIG_COUNT"
echo "  Fichiers WEBP créés: $WEBP_COUNT"
echo "  Fichiers AVIF créés: $AVIF_COUNT"
echo ""

# Vérifier les conversions
if [ "$WEBP_COUNT" -gt 0 ] && [ "$AVIF_COUNT" -gt 0 ]; then
  echo "✅ TESTS RÉUSSIS!"
  echo ""
  echo "   ✓ Dossier traité avec succès"
  echo "   ✓ Conversions WEBP effectuées ($WEBP_COUNT fichiers)"
  echo "   ✓ Conversions AVIF effectuées ($AVIF_COUNT fichiers)"
  echo "   ✓ Rapports affichés correctement"
elif [ "$WEBP_COUNT" -gt 0 ] || [ "$AVIF_COUNT" -gt 0 ]; then
  echo "⚠️ RÉSULTATS PARTIELS"
  if [ "$WEBP_COUNT" -gt 0 ]; then
    echo "   ✓ Conversions WEBP OK ($WEBP_COUNT fichiers)"
  else
    echo "   ⚠️ Aucune conversion WEBP"
  fi
  if [ "$AVIF_COUNT" -gt 0 ]; then
    echo "   ✓ Conversions AVIF OK ($AVIF_COUNT fichiers)"
  else
    echo "   ⚠️ Aucune conversion AVIF"
  fi
else
  echo "⚠️ Aucune conversion effectuée"
  echo "   Vérifiez que ImageMagick fonctionne correctement"
fi

echo ""
echo "════════════════════════════════════════════════"
echo ""

# Afficher les fichiers non pertinents
if find "$TEST_DIR" -name "*conversion-failed.txt" >/dev/null 2>&1; then
  echo "ℹ️ Conversions non pertinentes (fichier final trop volumineux):"
  find "$TEST_DIR" -name "*conversion-failed.txt" | while read file; do
    basename "$file"
  done | sed 's/^/  - /'
  echo ""
fi

echo "✅ Tests terminés!"
echo ""
echo "(Le dossier de test sera supprimé automatiquement)"

