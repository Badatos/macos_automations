# 🎬 Démonstration - Conversion d'images par dossier

## Exemple pratique

Supposons que vous ayez un dossier de vacances avec 42 photos :

```txt
~/Pictures/Vacation2024/
├── IMG_001.jpg
├── IMG_002.jpg
├── IMG_003.png
├── ...
└── IMG_042.heic
```

## Étape 1 : Test sans supprimer les originaux

```bash
./convert-image.sh avif ~/Pictures/Vacation2024/ --nodelete --report
```

**Résultat :**

```txt
Using magick for Avif conversion.
Mode test: les fichiers originaux ne seront pas supprimés
Rapport détaillé activé

📁 Traitement du dossier: ~/Pictures/Vacation2024/

Conversion: IMG_001.jpg → IMG_001.avif
✓ Optimisation réussie:
  Fichier original: 3.50 MB
  Fichier AVIF:     1.20 MB
  Économie: 2.30 MB (65.7%)
  (Mode test: fichier original conservé)

Conversion: IMG_002.jpg → IMG_002.avif
✓ Optimisation réussie:
  Fichier original: 4.80 MB
  Fichier AVIF:     1.95 MB
  Économie: 2.85 MB (59.4%)
  (Mode test: fichier original conservé)

... (40 images restantes)

╔════════════════════════════════════════════════════════════╗
║           RAPPORT DE CONVERSION EN AVIF                    ║
╚════════════════════════════════════════════════════════════╝

📊 RÉSUMÉ GLOBAL
───────────────────────────────────────────────────────────
  Total d'images trouvées:  42
  Images converties:        40 ✓
  Images échouées:          2 ✗
  Images déjà présentes:    0 ⊘

💾 ÉCONOMIE D'ESPACE
───────────────────────────────────────────────────────────
  Taille originale:  128.50 MB
  Taille AVIF:       45.23 MB
  Économie totale:   83.27 MB (64.8%)

📋 DÉTAILS DES CONVERSIONS
───────────────────────────────────────────────────────────
  • IMG_001.jpg
    Avant: 3.50 MB | Après: 1.20 MB | Gain: 2.30 MB (65.7%)
  • IMG_002.jpg
    Avant: 4.80 MB | Après: 1.95 MB | Gain: 2.85 MB (59.4%)
  ... (38 images)
```

**Interprétation :**

- 40 images converties avec succès
- 2 images échouées (probablement trop petites, le fichier AVIF était plus volumineux)
- Économie totale de **83.27 MB (64.8%)**

## Étape 2 : Conversion définitive

Satisfait du résultat ? Lancez sans `--nodelete` :

```bash
./convert-image.sh avif ~/Pictures/Vacation2024/ --report
```

**Résultat :**

- Les 40 images converties suppriment leur original
- Le rapport s'affiche toujours
- Les 2 images qui n'ont pas pu être converties sont conservées

## Étape 3 : Depuis Automator (Action rapide)

1. Créez l'action rapide selon [AUTOMATOR_SETUP.md](AUTOMATOR_SETUP.md)
2. Dans le Finder, clic droit sur le dossier → Services → "Convertir en AVIF"
3. Le rapport s'affiche en tant que fenêtre de dialogue

## Résultats

**Avant :**

```txt
Vacation2024/ (128.50 MB)
├── IMG_001.jpg (3.50 MB)
├── IMG_002.jpg (4.80 MB)
├── IMG_003.jpg (5.20 MB)
└── ...
```

**Après :**

```txt
Vacation2024/ (45.23 MB)
├── IMG_001.avif (1.20 MB)      ✓ 65.7% gain
├── IMG_002.avif (1.95 MB)      ✓ 59.4% gain
├── IMG_003.avif (1.88 MB)      ✓ 63.8% gain
├── IMG_004.jpg (5.50 MB)       ⚠ Non optimisé (conservé)
└── ...
```

## Gains d'espace

- 🎞️ 42 photos
- 💾 128.50 MB → 45.23 MB
- 📊 83.27 MB économisés (64.8%)

---

## Autres utilisations

### Mélanger fichiers et dossiers

```bash
./convert-image.sh avif \
  ~/Pictures/Vacation2024/ \
  ~/Pictures/Family/photo.jpg \
  ~/Downloads/screenshot.png \
  --report
```

### Conversion WEBP

```bash
./convert-to-webp.sh ~/Pictures/Vacation2024/ --report
```

### Mode batch (plusieurs formats)

```bash
# D'abord en AVIF
./convert-image.sh avif ~/Pictures/Vacation2024/ --report

# Puis les fichiers non convertis en WEBP
./convert-to-webp.sh ~/Pictures/Vacation2024/*.jpg --report
```

---

**Économies estimées sur votre Mac:**

| Format | Compression moyenne | Cas d'usage |
|--------|-------------------|------------|
| AVIF | 60-70% | Photos modernes, haute qualité |
| WEBP | 50-65% | Web, compatibilité |

