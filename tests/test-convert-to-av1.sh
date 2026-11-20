#!/bin/bash

set -eu

script="$(cd "$(dirname "$0")/.." && pwd)/convert-to-av1.sh"
work=$(mktemp -d "${TMPDIR:-/tmp}/av1-test.XXXXXX")
trap 'rm -f "$work/ffmpeg" "$work/ffprobe" "$work/input.mkv" "$work/args" "$work/log"; rmdir "$work"' EXIT

cat > "$work/ffprobe" <<'EOF'
#!/bin/bash
case " $* " in
  *" -show_packets "*)
    case " $* " in
      *" v:0 "*)
        case " $* " in
          *"sample.mkv "*)
            echo "size=${VIDEO_SAMPLE_SIZE:-800}"
            ;;
          *)
            if [ "${VIDEO_PROBE_FAIL:-0}" = 1 ]; then exit 1; fi
            printf '%s\n' 'pts_time=1.000000|size=500' 'pts_time=2.000000|size=500' \
              'pts_time=20.000000|size=1000' 'pts_time=36.000000|size=1000'
            ;;
        esac
        ;;
      *)
        if [ "${PROBE_FAIL:-0}" = 1 ]; then
          echo "Erreur ffprobe simulée" >&2
          exit 1
        fi
        case " $* " in
      *" a:0 "*) echo 'duration_time=1.000000|size=19999' ;;
      *" a:1 "*) echo 'duration_time=1.000000|size=20000' ;;
      *" a:2 "*) echo 'duration_time=1.000000|size=40000' ;;
      *" a:4 "*) echo 'duration_time=N/A|size=20000' ;;
      *) exit 1 ;;
        esac
        ;;
    esac
    ;;
  *" format=duration,start_time "*)
    printf '%s\n' 'start_time=0.000000' 'duration=45.000000'
    ;;
  *)
    if [ "${NO_AUDIO:-0}" = 1 ]; then exit 0; fi
    if [ "${COPY_AUDIO:-0}" = 1 ]; then
      echo 'channels=2|channel_layout=stereo'
      exit 0
    fi
    printf '%s\n' 'channels=2|channel_layout=stereo' \
      'channels=2|channel_layout=stereo' 'channels=6|channel_layout=5.1' \
      'channels=6|channel_layout=unknown' 'channels=1|channel_layout=mono'
    ;;
esac
EOF

cat > "$work/ffmpeg" <<'EOF'
#!/bin/bash
case " $* " in
  *" -f matroska "*)
    if [ "${SAMPLE_FAIL:-0}" = 1 ]; then exit 1; fi
    ;;
  *) printf '%s\n' "$@" > "$TEST_ARGS" ;;
esac
EOF
chmod +x "$work/ffprobe" "$work/ffmpeg"
touch "$work/input.mkv"
export PATH="$work:$PATH" TEST_ARGS="$work/args"

if ! "$script" "$work/input.mkv" > "$work/log" 2>&1; then
  cat "$work/log" >&2
  exit 1
fi
grep -Fq 'Gain vidéo estimé : 20.00 %.' "$work/log"
grep -Fq 'Piste vidéo : gain estimé suffisant' "$work/log"
awk '$0 == "-c:v" { getline; if ($0 == "libsvtav1") found = 1 } END { exit !found }' "$work/args"
grep -Fq 'Piste audio 0 : débit estimé 159.99 kbit/s ; gain inférieur à 20 %, copie.' "$work/log"
grep -Fq 'Piste audio 1 : débit estimé 160.00 kbit/s ; conversion Opus à 128 kbit/s.' "$work/log"
grep -Fq 'Piste audio 2 : débit estimé 320.00 kbit/s ; conversion Opus à 256 kbit/s.' "$work/log"
grep -Fq 'Piste audio 3 : configuration 6/unknown non prise en charge ; copie.' "$work/log"
grep -Fq 'Piste audio 4 : débit impossible à estimer ; copie.' "$work/log"
grep -Fxq -- '-c:a:1' "$work/args"
grep -Fxq -- '-c:a:2' "$work/args"
grep -Fxq -- '-ch_layout:a:2' "$work/args"
if grep -Fxq -- '-c:a:0' "$work/args" || grep -Fxq -- '-c:a:3' "$work/args" || grep -Fxq -- '-c:a:4' "$work/args"; then
  echo "Erreur : une piste à copier a été réencodée." >&2
  exit 1
fi

VIDEO_SAMPLE_SIZE=801 "$script" "$work/input.mkv" > "$work/log" 2>&1
grep -Fq 'Piste vidéo : gain estimé inférieur à 20 % ; copie.' "$work/log"
awk '$0 == "-c:v" { getline; if ($0 == "copy") found = 1 } END { exit !found }' "$work/args"

rm "$work/args"
VIDEO_SAMPLE_SIZE=801 COPY_AUDIO=1 "$script" "$work/input.mkv" > "$work/log" 2>&1
grep -Fq 'aucun fichier créé' "$work/log"
if [ -e "$work/args" ] || [ -e "$work/input-av1.mkv" ]; then
  echo "Erreur : une sortie a été créée alors qu'aucune piste ne devait être convertie." >&2
  exit 1
fi

VIDEO_SAMPLE_SIZE=801 NO_AUDIO=1 "$script" "$work/input.mkv" > "$work/log" 2>&1
grep -Fq 'aucun fichier créé' "$work/log"
if [ -e "$work/args" ] || [ -e "$work/input-av1.mkv" ]; then
  echo "Erreur : une sortie a été créée pour une vidéo sans piste audio à convertir." >&2
  exit 1
fi

NO_AUDIO=1 "$script" "$work/input.mkv" > "$work/log" 2>&1
awk '$0 == "-c:v" { getline; if ($0 == "libsvtav1") found = 1 } END { exit !found }' "$work/args"
rm "$work/args"

if PROBE_FAIL=1 "$script" "$work/input.mkv" > "$work/log" 2>&1; then
  echo "Erreur : l'échec de ffprobe n'a pas été signalé." >&2
  exit 1
fi
if [ -e "$work/args" ]; then
  echo "Erreur : ffmpeg a été lancé après l'échec de ffprobe." >&2
  exit 1
fi

if SAMPLE_FAIL=1 "$script" "$work/input.mkv" > "$work/log" 2>&1; then
  echo "Erreur : l'échec de l'encodage d'un extrait n'a pas été signalé." >&2
  exit 1
fi
if [ -e "$work/args" ]; then
  echo "Erreur : la conversion a été lancée après l'échec d'un extrait." >&2
  exit 1
fi

if VIDEO_PROBE_FAIL=1 "$script" "$work/input.mkv" > "$work/log" 2>&1; then
  echo "Erreur : l'échec de l'analyse vidéo n'a pas été signalé." >&2
  exit 1
fi
if [ -e "$work/args" ]; then
  echo "Erreur : la conversion a été lancée après l'échec de l'analyse vidéo." >&2
  exit 1
fi

echo "Tests réussis."
