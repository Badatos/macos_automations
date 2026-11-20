# 🚀 Quick Start - Utilisez les scripts améliorés

## 3 commandes essentielles

### 1️⃣ Tester avant de convertir

```bash
./convert-image.sh avif ~/Pictures/vacation/ --nodelete --report
```
✓ Voir le résultat sans supprimer les originaux
✓ Affiche le rapport avec économies d'espace

### 2️⃣ Convertir pour de vrai

```bash
./convert-image.sh avif ~/Pictures/vacation/ --report
```
✓ Convertit les images
✓ Supprime les originaux
✓ Affiche le rapport

### 3️⃣ Utiliser depuis Automator (Action rapide)

Voir [AUTOMATOR_SETUP.md](AUTOMATOR_SETUP.md) pour 5 minutes de configuration

---

## 📊 Ce que vous obtenez

| Question | Réponse |
|----------|---------|
| **Traiter un dossier complet ?** | ✅ Oui, passez le dossier en argument |
| **Compte rendu final ?** | ✅ Oui, avec `--report` |
| **Affichage Automator ?** | ✅ Oui, dialogue automatique |
| **Nombre d'images converties ?** | ✅ Oui, dans le rapport |
| **Poids total gagné ?** | ✅ Oui, en MB et % |

---

## 📚 Documentation complète

| Document | Contenu |
|----------|---------|
| **[IMPROVEMENTS_SUMMARY.md](IMPROVEMENTS_SUMMARY.md)** | 📋 Résumé complet des améliorations |
| **[AUTOMATOR_SETUP.md](AUTOMATOR_SETUP.md)** | 🛠️ Configuration étape par étape |
| **[DEMO.md](DEMO.md)** | 🎬 Exemple pratique détaillé |
| **[CHANGELOG.md](CHANGELOG.md)** | 🔄 Historique des changements |
| **[Readme.md](Readme.md)** | 📖 Référence complète |

---

## ⚡ Cas d'usage

```bash
# Mode test simple
./convert-image.sh avif ~/Pictures/ --nodelete

# Mode test avec rapport
./convert-image.sh avif ~/Pictures/ --nodelete --report

# Conversion + rapport
./convert-image.sh avif ~/Pictures/ --report

# Conversion silencieuse
./convert-image.sh avif ~/Pictures/

# Mélanger fichiers et dossiers
./convert-image.sh avif photo.jpg ~/Pictures/ --report

# Convertir en WEBP
./convert-to-webp.sh ~/Pictures/ --report
```

---

**Prêt ?** Lancez votre première commande ! 🎉
