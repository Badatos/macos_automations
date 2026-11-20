# Scripts QoL

Vous trouverez ici quelques script dont je me sers pour optimiser certains usages sur mon Mac.

Il sont tous utilisables directement via commande terminal, ou en les inclauant dans une "Action rapide" via Automator.

📖 **[Guide Automator →](AUTOMATOR_SETUP.md)** | **[Conversion d’images →](CONVERT_IMAGE_GUIDE.md)**

nb : Les actions rapides Automator sont généralement stockées dans `~/Library/Services/`

## Convertir une ou plusieurs images

Installez ImageMagick avec `brew install magick`, puis utilisez le script **convert-image** :

```bash
./convert-image.sh [format] [--nodelete] [--report] fichier.jpg dossier/ ...
```

**Format:** `avif` ou `webp` (défaut: webp)

**Exemples:**

```bash
# Convertir un dossier en WEBP (défaut)
./convert-image.sh ~/Pictures/vacation/ --report

# Convertir en AVIF avec rapport
./convert-image.sh avif ~/Pictures/vacation/ --report

# Mode test (conserve les originaux)
./convert-image.sh webp ~/Pictures/vacation/ --nodelete --report

# Mélanger fichiers et dossiers
./convert-image.sh avif photo.jpg ~/Pictures/ --report
```

Le script :

- Détecte automatiquement les fichiers image (jpg, png, gif, webp, etc.)
- Compare les tailles avant/après
- **N'effectue la conversion que si elle est pertinente** (gain d'espace significatif)
- Génère un rapport avec le nombre total d'images converties et l'espace économisé
- Affiche une alerte visuelle si lancé via Automator (avec `--report`)

**📖 Documentation complète:** [CONVERT_IMAGE_GUIDE.md](CONVERT_IMAGE_GUIDE.md)

### Depuis Automator (Action rapide)

Choisissez « Passer l'entrée : comme arguments » et appelez le script :

**Pour WEBP :**

```bash
"/chemin/vers/convert-image.sh" webp "$@" --report
```

**Pour AVIF :**

```bash
"/chemin/vers/convert-image.sh" avif "$@" --report
```

Cette commande affichera un dialogue avec le rapport à la fin de la conversion.

**📖 Voir [AUTOMATOR_SETUP.md](AUTOMATOR_SETUP.md) pour le guide complet**

### Exemple de rapport

```txt
╔════════════════════════════════════════════════════════════╗
║           RAPPORT DE CONVERSION EN WEBP                    ║
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
  Taille WEBP:       45.23 MB
  Économie totale:   83.27 MB (64.8%)
```

## Convertir une vidéo en AV1

Installez FFmpeg avec `brew install ffmpeg` (la version utilisée doit inclure `ffprobe` et les encodeurs `libsvtav1` et `libopus`), puis lancez :

```sh
./convert-to-av1.sh video.mp4 [autre-video.mkv ...]
```

Dans Automator, choisissez « Passer l'entrée : comme arguments » et appelez le script par son chemin absolu, sans copier son contenu :

```sh
"/chemin/vers/convert-to-av1.sh" "$@"
```

Le script recherche aussi FFmpeg dans les dossiers Homebrew habituels, y compris lorsque le `PATH` d'Automator est limité.

Le script crée un fichier `video-av1.mkv` à côté de chaque original, qu'il conserve. Pour la première piste vidéo, il compare la taille des paquets originaux à celle de versions AV1 10 bits (`CRF 30`, preset `6`) encodées sur trois extraits de 10 secondes, au début, au milieu et à la fin. Pour une vidéo de 30 secondes ou moins, il utilise toute la durée. Si le gain estimé atteint au moins 20 %, il encode la piste entière en AV1 ; sinon, il la copie, même si le nom du fichier contient `-av1`. Cette estimation n'est pas une garantie : le gain réel dépend de l'ensemble de la vidéo. L'analyse nécessite de lire les paquets vidéo et d'encoder les extraits avant la conversion.

Les sous-titres sont copiés ; les autres pistes vidéo et les pièces jointes ne sont pas conservées.

Pour chaque piste audio, le script estime le débit à partir des paquets du fichier. Si le gain estimé atteint au moins 20 %, il la réencode en Opus : 64 kbit/s en mono, 128 kbit/s en stéréo ou 256 kbit/s en 5.1. Les pistes 5.1 latérales sont converties vers la disposition 5.1 arrière utilisée par Opus. Sinon, ou si le débit ne peut pas être estimé ou la configuration n'est pas prise en charge, la piste est copiée. L'analyse lit les paquets audio avant la conversion ; le débit Opus étant variable, le gain réel peut différer de l'estimation. Le réencodage audio est avec perte et peut supprimer des informations audio avancées.

Si aucune piste vidéo ou audio ne doit être réencodée, le script ne crée pas de fichier de sortie et conserve l'original inchangé.

Si une piste ne peut pas être copiée dans un MKV, la conversion échoue et un fichier incomplet peut subsister. Un fichier de sortie existant n'est jamais écrasé.

Le réencodage est avec perte et peut être long ; le fichier obtenu n'est pas nécessairement plus petit que l'original.

Installez FFmpeg avec `brew install ffmpeg` (la version utilisée doit inclure `ffprobe` et les encodeurs `libsvtav1` et `libopus`), puis lancez :

```sh
./convert-to-av1.sh video.mp4 [autre-video.mkv ...]
```

Dans Automator, choisissez « Passer l'entrée : comme arguments » et appelez le script par son chemin absolu, sans copier son contenu :

```sh
"/chemin/vers/convert-to-av1.sh" "$@"
```

Le script recherche aussi FFmpeg dans les dossiers Homebrew habituels, y compris lorsque le `PATH` d'Automator est limité.

Le script crée un fichier `video-av1.mkv` à côté de chaque original, qu'il conserve. Pour la première piste vidéo, il compare la taille des paquets originaux à celle de versions AV1 10 bits (`CRF 30`, preset `6`) encodées sur trois extraits de 10 secondes, au début, au milieu et à la fin. Pour une vidéo de 30 secondes ou moins, il utilise toute la durée. Si le gain estimé atteint au moins 20 %, il encode la piste entière en AV1 ; sinon, il la copie, même si le nom du fichier contient `-av1`. Cette estimation n'est pas une garantie : le gain réel dépend de l'ensemble de la vidéo. L'analyse nécessite de lire les paquets vidéo et d'encoder les extraits avant la conversion.

Les sous-titres sont copiés ; les autres pistes vidéo et les pièces jointes ne sont pas conservées.

Pour chaque piste audio, le script estime le débit à partir des paquets du fichier. Si le gain estimé atteint au moins 20 %, il la réencode en Opus : 64 kbit/s en mono, 128 kbit/s en stéréo ou 256 kbit/s en 5.1. Les pistes 5.1 latérales sont converties vers la disposition 5.1 arrière utilisée par Opus. Sinon, ou si le débit ne peut pas être estimé ou la configuration n'est pas prise en charge, la piste est copiée. L'analyse lit les paquets audio avant la conversion ; le débit Opus étant variable, le gain réel peut différer de l'estimation. Le réencodage audio est avec perte et peut supprimer des informations audio avancées.

Si aucune piste vidéo ou audio ne doit être réencodée, le script ne crée pas de fichier de sortie et conserve l'original inchangé.

Si une piste ne peut pas être copiée dans un MKV, la conversion échoue et un fichier incomplet peut subsister. Un fichier de sortie existant n'est jamais écrasé.

Le réencodage est avec perte et peut être long ; le fichier obtenu n'est pas nécessairement plus petit que l'original.
