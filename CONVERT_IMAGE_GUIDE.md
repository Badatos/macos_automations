# 🎯 convert-image.sh - Script de conversion d'images

## Vue d'ensemble

**convert-image.sh** convertit des images en **AVIF** ou **WEBP** avec vérification d'optimisation.

```bash
./convert-image.sh [format] [--nodelete] [--report] fichier.jpg dossier/ ...
```

---

## 📋 Options

| Option | Défaut | Description |
| ------ | ------ | ----------- |
| `format` | `webp` | Format de sortie: `webp` ou `avif` |
| `--nodelete` | ✗ | Conserve les fichiers originaux (mode test) |
| `--report` | ✗ | Affiche rapport détaillé + alerte Automator |

---

## 🚀 Utilisation rapide

### Convertir en WEBP (défaut)

```bash
# Dossier complet
./convert-image.sh ~/Pictures/vacation/

# Avec rapport
./convert-image.sh ~/Pictures/vacation/ --report

# Mode test
./convert-image.sh ~/Pictures/vacation/ --nodelete --report
```

### Convertir en AVIF

```bash
# Dossier complet
./convert-image.sh avif ~/Pictures/vacation/

# Avec rapport
./convert-image.sh avif ~/Pictures/vacation/ --report

# Mode test
./convert-image.sh avif ~/Pictures/vacation/ --nodelete --report
```

### Mélanger fichiers et dossiers

```bash
./convert-image.sh webp \
  photo.jpg \
  ~/Pictures/vacation/ \
  ~/Downloads/screenshot.png \
  --report
```

---

## 💡 Syntaxe flexible

Les arguments peuvent être dans n'importe quel ordre:

```bash
# Toutes ces commandes sont valides:
./convert-image.sh avif ~/Pictures/ --nodelete --report
./convert-image.sh --report avif ~/Pictures/ --nodelete
./convert-image.sh ~/Pictures/ avif --report --nodelete
```

**Règle:** Format et options peuvent être placés n'importe où, l'ordre n'importe pas.

---

## 📊 Résultat

### Sortie standard

```txt
Using magick for WEBP conversion.
Mode test: les fichiers originaux ne seront pas supprimés
Rapport détaillé activé

📁 Traitement du dossier: ~/Pictures/vacation/

Conversion: IMG_001.jpg → IMG_001.webp
✓ Optimisation réussie:
  Fichier original: 3.50 MB
  Fichier WEBP:     1.20 MB
  Économie: 2.30 MB (65.7%)
  (Mode test: fichier original conservé)

... (autres images)

╔══════════════════════════════════════════════════╗
║           RAPPORT DE CONVERSION EN WEBP          ║
╚══════════════════════════════════════════════════╝

📊 RÉSUMÉ GLOBAL
────────────────────────────────────────────────────
  Total d'images trouvées:  42
  Images converties:        40 ✓
  Images échouées:          2 ✗
  Images déjà présentes:    0 ⊘

💾 ÉCONOMIE D'ESPACE
────────────────────────────────────────────────────
  Taille originale:  128.50 MB
  Taille WEBP:       45.23 MB
  Économie totale:   83.27 MB (64.8%)
```

### Avec `--report` et Automator

Une fenêtre de dialogue affiche le rapport complet dans Automator.

---

## 🔄 Comparaison avec les anciens scripts

| Aspect | Avant | Maintenant |
|--------|-------|-----------|
| Scripts | 2 (`convert-to-avif.sh`, `convert-to-webp.sh`) | 1 principal (`convert-image.sh`) |
| Code | Dupliqué | Centralisé |
| Format | Figé | Paramétrable |
| Maintenance | Complexe | Simplifiée |
| Compatibilité | - | 100% (wrappers fournis) |

**Les anciens scripts continuent de fonctionner** via des wrappers qui redirigent vers `convert-image.sh`.

---

## 🛠️ Configuration Automator

### Action rapide "Convertir en WEBP"

```bash
"/chemin/vers/convert-image.sh" webp "$@" --report
```

### Action rapide "Convertir en AVIF"

```bash
"/chemin/vers/convert-image.sh" avif "$@" --report
```

### Plusieurs actions rapides

Créez autant d'actions que nécessaire:
- Convertir en WEBP
- Convertir en AVIF
- Convertir en WEBP (sans supprimer)
- Convertir en AVIF (sans supprimer)
- ...

---

## 📈 Cas d'usage avancés

### Batch processing

```bash
# Convertir tous les PNG en WEBP
./convert-image.sh webp ~/Pictures/**/*.png --report

# Convertir tous les JPG en AVIF
./convert-image.sh avif ~/Pictures/**/*.jpg --report
```

### Workflow multicouche

```bash
# 1. Tester en WEBP
./convert-image.sh webp ~/Pictures/ --nodelete --report

# 2. Si satisfait, convertir pour de vrai
./convert-image.sh webp ~/Pictures/ --report

# 3. Optionnel: Convertir les non-convertis en AVIF
./convert-image.sh avif ~/Pictures/*.jpg --report
```

### Sélectionner les images

```bash
# Seulement certains formats
./convert-image.sh webp ~/Pictures/*.jpg ~/Pictures/*.jpeg --report

# Exclure certaines
./convert-image.sh webp ~/Pictures/ --nodelete --report
# Supprimer manuellement les fichiers .webp non pertinents
# Puis relancer sans --nodelete
./convert-image.sh webp ~/Pictures/ --report
```

---

## 🔍 Détails techniques

### Formats supportés en entrée

`.jpg`, `.jpeg`, `.png`, `.gif`, `.bmp`, `.webp`, `.tiff`, `.heic`, `.heif`, `.avif`

### Formats supportés en sortie

- **WEBP** : compression supérieure à JPEG/PNG
- **AVIF** : compression encore supérieure (codec plus récent)

### Vérification d'optimisation

Le script ne convertit une image que si:
1. ✓ La conversion réussit
2. ✓ Le fichier de sortie est **plus petit** que l'original

Si la conversion rend le fichier plus volumineux, elle est annulée et un fichier `.txt` explicatif est créé.

### Gestion des fichiers

- ✓ Ne remplace jamais un fichier existant
- ✓ Crée des fichiers `.txt` pour les échecs
- ✓ Option `--nodelete` pour tester sans risque
- ✓ Affiche toujours la progression

---

## 📖 Voir aussi

- **[AUTOMATOR_SETUP.md](AUTOMATOR_SETUP.md)** - Configuration détaillée des actions rapides
- **[QUICK_START.md](QUICK_START.md)** - Guide rapide de démarrage
- **[Readme.md](Readme.md)** - Documentation générale

---

## ⚙️ Prérequis

```bash
brew install magick
```

ImageMagick doit être installé et disponible à `/opt/homebrew/bin/magick`.

---

## 💬 Questions fréquentes

**Q: Quel format choisir, WEBP ou AVIF?**
A: AVIF est généralement meilleur en compression (5-10% d'économie supplémentaire) mais moins compatible. WEBP est un bon compromis.

**Q: Puis-je convertir de WEBP en AVIF?**
A: Oui, le script traite tous les formats en entrée. `./convert-image.sh avif ~/Pictures/*.webp`

**Q: Comment savoir combien d'espace j'économise?**
A: Utilisez `--report` pour voir l'économie totale en MB et en pourcentage.

**Q: Que faire si l'optimisation n'est pas pertinente?**
A: Le script crée un fichier `.txt` explicatif et ne supprime rien. L'original est conservé.
