# 🧪 Script de Test - test-convert-image.sh

## Description

Le script `test-convert-image.sh` teste automatiquement les fonctionnalités complètes de `convert-image.sh`.

### Qu'est-ce qu'il fait?

1. **Crée un dossier temporaire**
2. **Génère 5 images de test** dans différents formats:
   - PNG (petite et grande)
   - JPG (moyenne)
   - BMP (moins courant)
   - GIF
3. **Teste la conversion en WEBP** avec `--nodelete` et `--report`
4. **Teste la conversion en AVIF** avec `--nodelete` et `--report`
5. **Affiche un rapport complet** avec statistiques
6. **Nettoie automatiquement** le dossier temporaire

---

## 🚀 Utilisation

```bash
./test-convert-image.sh
```

**Le script s'exécute complètement en autonomie - aucune intervention requise.**

---

## 📊 Exemple de sortie

```txt
╔═══════════════════════════════════════════════╗
║           TEST - convert-image.sh             ║
╚═══════════════════════════════════════════════╝

📂 Création d'un dossier de test: /tmp/convert-image-test.xxx

🎨 Création d'images de test...
✓ 5 images créées

📊 Fichiers avant conversion:
   animated.gif                   (227B)
   image.bmp                      (117K)
   large.png                      (338B)
   medium.jpg                     (1.3K)
   small.png                      (305B)

💾 Taille totale avant: 136K

═════════════════════════════════════════════════
TEST 1: Conversion en WEBP
═════════════════════════════════════════════════
...
╔═══════════════════════════════════════════════╗
║      RAPPORT DE CONVERSION EN WEBP            ║
╚═══════════════════════════════════════════════╝

📊 RÉSUMÉ GLOBAL
─────────────────────────────────────────────────
  Total d'images trouvées:  5
  Images converties:        4 ✓
  Images échouées:          1 ✗
  Images déjà présentes:    0 ⊘

💾 ÉCONOMIE D'ESPACE
─────────────────────────────────────────────────
  Taille originale:  .11 MB
  Taille WEBP:       0 MB
  Économie totale:   .11 MB (99.4%)
...

═════════════════════════════════════════════════
TEST 2: Conversion en AVIF
═════════════════════════════════════════════════
...

═════════════════════════════════════════════════
RÉSUMÉ DES TESTS
═════════════════════════════════════════════════

📊 Fichiers après les conversions:

Format PNG (originaux):
  large.png (338B)
  small.png (305B)

Format WEBP (converti):
  animated.webp (124B)
  image.webp (158B)
  medium.webp (252B)
  small.webp (122B)

Format AVIF (converti):
  image.avif (314B)
  large.avif (330B)
  medium.avif (332B)
  small.avif (303B)

📈 Statistiques:
  Fichiers totaux:        17
  Fichiers originaux:      5
  Fichiers WEBP créés:     4
  Fichiers AVIF créés:     4

✅ TESTS RÉUSSIS!

   ✓ Dossier traité avec succès
   ✓ Conversions WEBP effectuées (4 fichiers)
   ✓ Conversions AVIF effectuées (4 fichiers)
   ✓ Rapports affichés correctement

✅ Tests terminés!

(Le dossier de test sera supprimé automatiquement)
```

---

## ✅ Ce qui est testé

| Aspect | Détail |
|--------|--------|
| **Support des dossiers** | ✓ Le script traite tous les fichiers du dossier |
| **Formats d'entrée** | ✓ PNG, JPG, BMP, GIF (5+ formats) |
| **Conversion WEBP** | ✓ Génère correctement les fichiers .webp |
| **Conversion AVIF** | ✓ Génère correctement les fichiers .avif |
| **Vérification d'optimisation** | ✓ Détecte les conversions non pertinentes |
| **Rapports détaillés** | ✓ Affiche les statistiques complètes |
| **Mode test** | ✓ Préserve les fichiers originaux |
| **Comptage des fichiers** | ✓ Reporte correctement les conversions |

---

## 🔍 Résultats attendus

**Après l'exécution, vous devriez voir:**

✅ 5 fichiers d'entrée (PNG, JPG, BMP, GIF)
✅ 4+ fichiers WEBP convertis
✅ 4+ fichiers AVIF convertis
✅ Quelques fichiers avec `.txt` (conversions non pertinentes)
✅ Deux rapports complets affichés
✅ Statistiques précises

**En cas d'erreur:**
- ❌ Aucun fichier généré → ImageMagick n'est pas installé
- ❌ Script non trouvé → `convert-image.sh` manquant
- ⚠️ Résultats partiels → Vérifier ImageMagick fonctionne

---

## 🛠️ Prérequis

```bash
brew install magick    # ImageMagick obligatoire
```

---

## 📝 Fichiers créés pendant le test

Le test crée un dossier temporaire avec:

```
/tmp/convert-image-test.XXXXXX/
├── small.png              (original)
├── large.png              (original)
├── medium.jpg             (original)
├── image.bmp              (original)
├── animated.gif           (original)
├── small.webp             (converti)
├── small.avif             (converti)
├── medium.webp            (converti)
├── medium.avif            (converti)
├── image.webp             (converti)
├── image.avif             (converti)
├── large.webp             (converti)
├── large.avif             (converti)
├── animated.webp          (converti)
├── animated.avif          (converti)
└── *-conversion-failed.txt (fichiers d'info)
```

**Tous ces fichiers sont automatiquement supprimés après le test.**

---

## 🧪 Interprétation des résultats

### ✅ Succès complet

```
✅ TESTS RÉUSSIS!

   ✓ Dossier traité avec succès
   ✓ Conversions WEBP effectuées (4 fichiers)
   ✓ Conversions AVIF effectuées (4 fichiers)
   ✓ Rapports affichés correctement
```

Cela signifie que:
- Le script traite correctement les dossiers
- Les deux formats de conversion fonctionnent
- Les rapports s'affichent bien
- Pas d'erreur de lancement

### ⚠️ Résultats partiels

```
⚠️ RÉSULTATS PARTIELS

   ✓ Conversions WEBP OK (4 fichiers)
   ⚠️ Aucune conversion AVIF
```

Cela peut indiquer:
- Un problème avec ImageMagick
- Une incompatibilité de format
- Un problème temporaire

**Solutions:** Réexécutez le script ou vérifiez ImageMagick.

### ❌ Échec complet

```
❌ Erreur: ImageMagick n'est pas installé
   Installez avec: brew install magick
```

**Solution:** Installer ImageMagick via Homebrew

---

## 📊 Cas particuliers

### Conversions non pertinentes

Certaines petites images ne se convertissent pas si:
- Le fichier converti serait plus volumineux
- La conversion n'apporte pas d'économie

Le script crée alors un fichier `.txt` explicatif:
```
large-conversion-failed.txt
animated-conversion-failed.txt
```

**C'est normal** - c'est une protection pour ne pas augmenter l'espace disque.

### Fichiers déjà convertis

Lors du deuxième test (TEST 2), certains fichiers ont déjà la forme convertie (from TEST 1):

```
Attention: '/tmp/.../medium.avif' existe déjà, passage au suivant.
```

**C'est normal** - le script ignore intelligemment les fichiers existants.

---

## 🚀 Lancer régulièrement

Le test peut être lancé autant de fois qu'on le souhaite:

```bash
# Une fois
./test-convert-image.sh

# Plusieurs fois de suite (rafales de test)
for i in {1..3}; do ./test-convert-image.sh; done

# Chaque jour
# Ajouter à cron ou au calendrier
```

---

## 🔧 Troubleshooting

| Problème | Solution |
|----------|----------|
| Script non trouvé | `chmod +x test-convert-image.sh` |
| ImageMagick absent | `brew install magick` |
| Pas de fichiers .webp | Vérifier que `magick` fonctionne: `magick -version` |
| Pas de fichiers .avif | Idem, vérifier ImageMagick |
| Dossier temporaire reste | Nettoyer manuellement `/tmp/convert-image-test.*` |

---

## 📚 Liens

- **[QUICK_START.md](QUICK_START.md)** - Démarrage rapide
- **[CONVERT_IMAGE_GUIDE.md](CONVERT_IMAGE_GUIDE.md)** - Guide complet
- **[INDEX.md](INDEX.md)** - Navigation complète

---

**Statut:** ✅ Production-ready
**Dernière mise à jour:** 2026-11-20
