# 🚀 CI/CD - GitHub Actions

## Configuration

La CI est configurée dans le fichier `.github/workflows/tests.yml` et s'exécute automatiquement sur GitHub.

---

## 🎯 Qu'est-ce que la CI exécute?

### 1. **Syntaxe Bash** ✓

- Vérifie que tous les scripts `.sh` ont une syntaxe valide
- Détecte les erreurs de syntaxe avant la production

### 2. **Tests d'image** ✓
- Lance le test principal: `tests/test-convert-image.sh`
- Teste les conversions WEBP et AVIF
- Génère un rapport complet

### 3. **Tests spécialisés** ✓
- Lance les tests AV1: `tests/test-convert-to-av1.sh`
- Continue même si un test échoue (n'arrête pas la CI)

### 4. **Permissions** ✓

- Vérifie que tous les scripts sont exécutables
- Corrige les permissions automatiquement

---

## 🔄 Quand s'exécute-t-elle?

La CI s'exécute **automatiquement** dans ces cas:

```txt
✓ Push sur main ou develop
✓ Pull request vers main ou develop
✓ Modification de fichiers .sh
✓ Modification du dossier tests/
✓ Modification du fichier .github/workflows/tests.yml
✓ Lancement manuel (workflow_dispatch)
```

---

## 📋 Étapes du workflow

```mermaid
graph LR
    A["📦 Checkout"] --> B["🛠️ Install"]
    B --> C["📋 List tests"]
    C --> D["🧪 Main test"]
    D --> E["🧪 AV1 test"]
    E --> F["🔐 Permissions"]
    F --> G["🔍 Syntax check"]
    G --> H["📊 Summary"]

    style A fill:#90EE90
    style B fill:#87CEEB
    style D fill:#FFB6C1
    style E fill:#FFB6C1
    style H fill:#FFD700
```

---

## ✅ Comment lire les résultats

### ✅ Succès complet

```txt
✅ All tests passed
✅ Workflow completed successfully
```

**Cela signifie:**

- ✓ Tous les scripts ont une syntaxe valide
- ✓ Tous les tests se sont exécutés
- ✓ Aucune erreur critique

### ⚠️ Résultats partiels

```txt
⚠️ Some tests failed
⚠️ Continue on error enabled
```

**Cela signifie:**

- Un ou plusieurs tests n'ont pas réussi
- Mais la CI ne s'arrête pas (continue-on-error: true)
- À investiguer dans les logs

### ❌ Échec complet

```txt
❌ Workflow failed
❌ Syntax error in script
```

**Cela signifie:**

- Un problème grave détecté
- La CI s'arrête immédiatement
- Action requise avant merge

---

## 🔗 Voir les résultats

### Sur GitHub

1. Allez à votre dépôt
2. Cliquez sur **"Actions"** en haut
3. Sélectionnez le workflow **"🧪 Tests CI"**
4. Cliquez sur le run pour voir les détails

### Badges dans README

Vous pouvez ajouter un badge pour afficher le statut:

```markdown
[![Tests](https://github.com/Badatos/macos_automations/actions/workflows/tests.yml/badge.svg)](https://github.com/Badatos/macos_automations/actions/workflows/tests.yml)
```

Résultat:
[![Tests](https://github.com/Badatos/macos_automations/actions/workflows/tests.yml/badge.svg)](https://github.com/Badatos/macos_automations/actions/workflows/tests.yml)

---

## 🛠️ Configuration avancée

### Modifier les branches testées

Dans `.github/workflows/tests.yml`:

```yaml
on:
  push:
    branches: [ main, develop ]  # ← Modifier ici
```

### Ajouter d'autres tests

```yaml
      - name: 🧪 My new test
        run: |
          chmod +x ./my-test.sh
          ./my-test.sh
        continue-on-error: true  # Optionnel
```

---

## 🔧 Troubleshooting

| Problème | Solution |
| -------- | -------- |
| **Syntax error** | Exécutez `bash -n script.sh` localement |
| **ImageMagick not found** | C'est normal sur GitHub (testez localement) |
| **Test timeout** | Augmentez le timeout ou optimisez le test |
| **Permission denied** | Le `chmod +x` est appliqué automatiquement |

---

## 📊 Logs

Les logs complets sont disponibles dans GitHub Actions:

**URL type:**

```txt
https://github.com/Badatos/macos_automations/actions/runs/XXXXXXXXXXXX
```

**Chaque step affiche:**

- Heure d'exécution
- Sortie du script
- Code d'erreur
- Duplication estimée

---

## 💡 Bonnes pratiques

### ✅ Faire passer la CI

1. Testez localement avant de pusher
2. Vérifiez la syntaxe: `bash -n script.sh`
3. Vérifiez les permissions: `chmod +x script.sh`
4. Lancez `./tests/test-convert-image.sh` pour tout tester

### ❌ Éviter les échecs CI

- ❌ Ne pas modifier directement sur GitHub
- ❌ Ne pas pusher sans tester localement
- ❌ Ne pas supprimer les fichiers de test
- ❌ Ne pas pusher avec des erreurs de syntaxe

---

## 📚 Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [macOS runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#supported-runners-and-hardware-resources)

