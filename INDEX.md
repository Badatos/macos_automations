# 📖 Index - Scripts de Conversion d'Images

Bienvenue! Voici l'index complet de la documentation pour les scripts.

## 🚀 Démarrage rapide

### Je veux juste convertir mes images

👉 **[QUICK_START.md](QUICK_START.md)** - 3 commandes essentielles

```bash
# Tester
./convert-image.sh ~/Pictures/ --nodelete --report

# Convertir
./convert-image.sh ~/Pictures/ --report

# Ou en AVIF
./convert-image.sh avif ~/Pictures/ --report
```

---

## 📚 Documentation par niveau

### Niveau 1: Utilisateur basique
- **[QUICK_START.md](QUICK_START.md)** - Commandes essentielles
- **[Readme.md](Readme.md)** - Vue d'ensemble générale

### Niveau 2: Utilisateur avancé

- **[CONVERT_IMAGE_GUIDE.md](CONVERT_IMAGE_GUIDE.md)** - Guide complet du script de conversion
- **[AUTOMATOR_SETUP.md](AUTOMATOR_SETUP.md)** - Configuration Automator détaillée
- **[DEMO.md](DEMO.md)** - Exemple pratique avec résultats réalistes

### Niveau 3: Développeur/Mainteneur

- **[MIGRATION.md](MIGRATION.md)** - Architecture et changements
- **[CHANGELOG.md](CHANGELOG.md)** - Historique détaillé
- **[TEST_SCRIPT.md](TEST_SCRIPT.md)** - Tests automatisés (🧪 nouveau!)
- **[CI_CD.md](CI_CD.md)** - Pipeline GitHub Actions (🚀 nouveau!)

---

## 🎯 Trouvez ce que vous cherchez

### Par tâche

| Je veux... | Lire |
|---|---|
| **Convertir mes images** | [QUICK_START.md](QUICK_START.md) |
| **Comprendre le script** | [CONVERT_IMAGE_GUIDE.md](CONVERT_IMAGE_GUIDE.md) |
| **Créer une action Automator** | [AUTOMATOR_SETUP.md](AUTOMATOR_SETUP.md) |
| **Voir un exemple complet** | [DEMO.md](DEMO.md) |
| **Tester le code** | [TEST_SCRIPT.md](TEST_SCRIPT.md) 🧪 |
| **Mettre en place la CI** | [CI_CD.md](CI_CD.md) 🚀 |
| **Comprendre les changements** | [MIGRATION.md](MIGRATION.md) |
| **Trouver l'historique** | [CHANGELOG.md](CHANGELOG.md) |

### Par format

**WEBP (défaut, meilleure compatibilité)**
```bash
./convert-image.sh ~/Pictures/ --report
# Ou explicitement
./convert-image.sh webp ~/Pictures/ --report
# Ou l'ancien script
./convert-to-webp.sh ~/Pictures/ --report
```

**AVIF (meilleure compression)**
```bash
./convert-image.sh avif ~/Pictures/ --report
# Ou l'ancien script
./convert-to-avif.sh ~/Pictures/ --report
```

### Par OS/Plateforme

**macOS (tous les scripts)**
- ✅ Tous les scripts fonctionnent sur macOS
- ✅ Utilise ImageMagick via Homebrew

**Linux**
- ⚠️ Peut nécessiter des ajustements de chemin
- Vérifiez la localisation de ImageMagick

---

## 📂 Structure des fichiers

```
macos_automations/
├── convert-image.sh           ✨ Script principal unifié
├── convert-to-avif.sh         ♻️ Wrapper (compatibilité)
├── convert-to-webp.sh         ♻️ Wrapper (compatibilité)
├── convert-to-av1.sh          (Conversion vidéo)
│
├── .github/
│   └── workflows/
│       └── tests.yml          🚀 Pipeline CI/CD GitHub Actions
│
├── tests/
│   ├── test-convert-image.sh  🧪 Tests principaux
│   ├── test-convert-to-av1.sh 🧪 Tests spécialisés AV1
│   └── TEST_SCRIPT.md             🧪 Documentation des tests
│
├── Readme.md                  📝 Vue d'ensemble
├── QUICK_START.md             🚀 Démarrage rapide
├── CONVERT_IMAGE_GUIDE.md     📖 Guide complet
├── AUTOMATOR_SETUP.md         🛠️ Configuration Automator
├── DEMO.md                    🎬 Exemple pratique
├── CI_CD.md                   🚀 Documentation CI/CD
├── MIGRATION.md               🔄 Détails d'architecture
├── UNIFIED_SCRIPTS_SUMMARY.md 📋 Résumé de l'unification
├── CHANGELOG.md               🔍 Historique
├── IMPROVEMENTS_SUMMARY.md    📊 Résumé des améliorations v1.0
└── INDEX.md                   📖 Ce fichier
```

---

## ✨ Fonctionnalités principales

✅ **Support des dossiers entiers**
- Passez un dossier, traite toutes les images

✅ **Rapports détaillés**
- Nombre d'images, économies d'espace, statistiques

✅ **Affichage Automator**
- Dialogue automatique avec le rapport

✅ **Mode test**
- Vérifiez sans supprimer les originaux

✅ **Format flexible**
- WEBP ou AVIF au choix

✅ **Vérification d'optimisation**
- Ne convertit que si c'est pertinent

---

## 🔧 Prérequis

```bash
brew install magick    # ImageMagick
```

Optionnel pour les vidéos:
```bash
brew install ffmpeg    # Pour convert-to-av1.sh
```

---

## 💡 Quelques exemples

### Convertir un dossier en WEBP avec rapport
```bash
./convert-image.sh ~/Pictures/vacation/ --report
```

### Convertir en AVIF, mode test
```bash
./convert-image.sh avif ~/Pictures/vacation/ --nodelete --report
```

### Convertir plusieurs dossiers
```bash
./convert-image.sh ~/Pictures/ ~/Documents/screenshots/ --report
```

### Mélanger fichiers et dossiers
```bash
./convert-image.sh avif photo.jpg ~/Pictures/ ~/Desktop/ --report
```

---

## ❓ Questions?

1. **Je ne sais pas par où commencer:**
   👉 [QUICK_START.md](QUICK_START.md)

2. **Je veux configurer Automator:**
   👉 [AUTOMATOR_SETUP.md](AUTOMATOR_SETUP.md)

3. **Je veux comprendre comment ça marche:**
   👉 [CONVERT_IMAGE_GUIDE.md](CONVERT_IMAGE_GUIDE.md)

4. **Qu'est-ce qui a changé?**
   👉 [MIGRATION.md](MIGRATION.md)

5. **Je veux un exemple réaliste:**
   👉 [DEMO.md](DEMO.md)

---

## 🎓 Apprentissage progressif

### Jour 1: Découverte
- Lire [QUICK_START.md](QUICK_START.md)
- Tester une simple conversion

### Jour 2: Configuration Automator
- Lire [AUTOMATOR_SETUP.md](AUTOMATOR_SETUP.md)
- Créer votre première action rapide

### Jour 3: Tests
- Lire [TEST_SCRIPT.md](TEST_SCRIPT.md)
- Lancer le script de test: `./test-convert-image.sh`

### Jour 4: Déploiement
- Lire [CI_CD.md](CI_CD.md)
- Mettre en place GitHub Actions

### Jour 5+: Expertise
- Explorer [CONVERT_IMAGE_GUIDE.md](CONVERT_IMAGE_GUIDE.md)
- Lire [DEMO.md](DEMO.md) pour les cas avancés
- Consulter [CHANGELOG.md](CHANGELOG.md) pour l'historique

---

## 📊 Statistiques

- **Formats supportés:** WEBP, AVIF (extensible)
- **Formats d'entrée:** 10+ (jpg, png, gif, webp, bmp, tiff, heic, heif, avif)
- **Documentation:** 10+ fichiers
- **Code dupliqué:** 0% (après unification)
- **Compatibilité:** 100% (rétroactive)

---

## 🚀 Prêt?

Choisissez votre point d'entrée:

- 🏃 **Pressé** → [QUICK_START.md](QUICK_START.md)
- 🛠️ **Setup Automator** → [AUTOMATOR_SETUP.md](AUTOMATOR_SETUP.md)
- 🧪 **Tester le code** → [TEST_SCRIPT.md](TEST_SCRIPT.md)
- 🚀 **Mettre en place CI/CD** → [CI_CD.md](CI_CD.md)
- 📚 **Tout savoir** → [CONVERT_IMAGE_GUIDE.md](CONVERT_IMAGE_GUIDE.md)
- 🎬 **Un exemple** → [DEMO.md](DEMO.md)
