# Configuration des Scripts avec Automator

Ce guide vous explique comment configurer les scripts de conversion d'images avec Automator pour en faire des "Actions rapides" (Quick Actions) directement accessibles dans le Finder.

## Concepts clés

- ✅ **Traitement de dossiers entiers** : Passez un dossier en paramètre pour convertir toutes les images
- ✅ **Rapports détaillés** : Option `--report` pour afficher les statistiques
- ✅ **Alerte visuelle** : Le rapport s'affiche dans une fenêtre de dialogue (macOS)
- ✅ **Mode test** : Option `--nodelete` pour tester sans supprimer les originaux

## Création d'une Action Rapide AVIF

### Étape 1 : Ouvrir Automator

1. Lancez **Automator** (Applications → Automator)
2. Créez un nouveau document : **Fichier → Nouveau**
3. Type de document : **Action rapide** (Quick Action)
4. Cliquez sur **Créer**

### Étape 2 : Configurer les entrées

1. En haut du workflow, configurez:
   - **Le flux reçoit l'entrée actuelle**: `fichiers ou dossiers`
   - **Dans**: `Finder`

### Étape 3 : Ajouter l'action "Exécuter un script shell"

1. Dans la bibliothèque de gauche, recherchez **"Exécuter un script shell"**
2. Faites-le glisser dans le workflow
3. Configurez-le:
   - **Options du shell**: `/bin/bash`
   - **Passer l'entrée**: `en tant qu'arguments`

### Étape 4 : Ajouter le script

Collez ce contenu dans la zone de texte du script shell:

```bash
"/chemin/vers/convert-image.sh" avif "$@" --report
```

**Important**: Remplacez `/chemin/vers/` par le chemin absolu réel. Exemple :

```bash
"/Users/prenom/GIT/macos_automations/convert-image.sh" avif "$@" --report
```

Pour trouver le chemin :

1. Ouvrez le Terminal
2. Tapez: `pwd` dans le répertoire des scripts
3. Copiez le résultat

### Étape 5: Sauvegarder

1. **Fichier → Enregistrer**
2. Donnez un nom à votre action: `Convertir en AVIF`
3. Validez

### Résultat

Vous pouvez maintenant :

1. Sélectionner une image ou un dossier dans le Finder
2. Clic droit → Services → **Convertir en AVIF**
3. Le rapport s'affichera dans une fenêtre de dialogue (macOS)
4. Cliquez sur **OK** pour fermer

**📋 Exemple de dialog:**
```
╔════════════════════════════╗
║ Conversion AVIF - Rapport  ║
╠════════════════════════════╣
║                            ║
║ RAPPORT DE CONVERSION EN   ║
║ AVIF                       ║
║                            ║
║ Total d'images trouvées: 5 ║
║ Images converties: 4 ✓     ║
║ Images échouées: 1 ✗       ║
║                            ║
║ Économie totale: 2.5 Mo    ║
║                            ║
╠════════════════════════════╣
║           [OK]             ║
╚════════════════════════════╝
```

## Variantes

### Version WebP

Remplacez simplement le script par:

```bash
"/chemin/vers/convert-image.sh" webp "$@" --report
```

### Version sans rapport (silencieuse)

```bash
"/chemin/vers/convert-image.sh" avif "$@"
```

### Version de test (conserve les originaux)

```bash
"/chemin/vers/convert-image.sh" avif "$@" --nodelete --report
```

## Localisation

Les actions rapides sont stockées dans `~/Library/Services/`.
Vous y trouverez des dossiers `.workflow` pour chaque action créée.

## Dépannage

### Le script ne s'exécute pas

- ✓ Vérifiez que le chemin est correct
- ✓ Assurez-vous que le script est exécutable : `chmod +x script.sh`

### Le rapport ne s'affiche pas

- ✓ Vérifiez que `osascript` est disponible (utilise l'interface graphique macOS)
- ✓ Essayez sans l'option `--report` pour voir si le problème vient du rapport

### Les images ne se convertissent pas

- ✓ Vérifiez que ImageMagick est installé : `brew install magick`
- ✓ Testez le script en ligne de commande d'abord

## Options de personnalisation

Le rapport affiche :

- 📊 Nombre total d'images trouvées
- ✓ Nombre d'images converties avec succès
- ✗ Nombre d'images échouées (fichier trop volumineux, erreur)
- ⊘ Nombre d'images ignorées (fichier de sortie déjà présent)
- 💾 Économies d'espace totales et en pourcentage
- 📋 Détails pour chaque image (si activé)

## Trucs & Astuces

### Convertir par lot

Sélectionnez plusieurs fichiers/dossiers dans le Finder et lancez l'action rapide.

### Workflow combiné

Vous pouvez créer un workflow qui convertit en AVIF, puis en WEBP, puis affiche le rapport global.

### Notifications

Pour une notification plus discrète, remplacez l'alerte par :

```bash
osascript -e 'display notification "Conversion terminée!" with title "AVIF"'
```

## Pour l'aide

```bash
./convert-image.sh --help
```

Affiche l'usage complet.
