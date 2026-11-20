#!/bin/bash

# Usage : ./convert-to-av1.sh video.mp4 [video2.mkv ...]
# Pré-requis : ffmpeg avec libsvtav1 et libopus, et ffprobe (brew install ffmpeg)

export PATH="${PATH:+$PATH:}/opt/homebrew/bin:/usr/local/bin"

if [ "$#" -eq 0 ]; then
  echo "Usage : $0 video.mp4 [video2.mkv ...]" >&2
  exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "Erreur : ffmpeg est introuvable. Installez-le avec : brew install ffmpeg" >&2
  exit 1
fi

if ! command -v ffprobe >/dev/null 2>&1; then
  echo "Erreur : ffprobe est introuvable. Installez-le avec : brew install ffmpeg" >&2
  exit 1
fi

set -o pipefail
export LC_ALL=C

estimate_video() (
  local input="$1" timing duration start_time intervals source_sizes
  local sample_dir sample_file interval start length source_size encoded_size
  local source_total=0 encoded_total=0 i=0
  local -a samples sizes

  if ! timing=$(ffprobe -v error -show_entries format=duration,start_time \
    -of default=noprint_wrappers=1 -i "$input"); then
    echo "Erreur : impossible de lire la durée de '$input'." >&2
    return 1
  fi
  duration=$(printf '%s\n' "$timing" | awk -F= '$1 == "duration" { print $2 }')
  start_time=$(printf '%s\n' "$timing" | awk -F= '$1 == "start_time" { print $2 }')
  if ! intervals=$(awk -v d="$duration" -v start="$start_time" '
    BEGIN {
      if (d !~ /^[0-9]+([.][0-9]+)?$/ || d <= 0 ||
          start !~ /^-?[0-9]+([.][0-9]+)?$/) exit 1
      if (d <= 30) {
        printf "0|%.6f\n", d
      } else {
        printf "0|10,%.6f|10,%.6f|10\n", (d - 10) / 2, d - 10
      }
    }'); then
    echo "Erreur : durée ou début de vidéo indisponible pour '$input'." >&2
    return 1
  fi

  if ! source_sizes=$(ffprobe -v error -select_streams v:0 -show_packets \
    -show_entries packet=pts_time,size -of compact=p=0:nk=0 -i "$input" |
    awk -F '|' -v intervals="$intervals" -v origin="$start_time" '
      BEGIN {
        count = split(intervals, lines, ",")
        for (i = 1; i <= count; i++) {
          split(lines[i], part, "|")
          begin[i] = origin + part[1]
          end[i] = begin[i] + part[2]
        }
      }
      {
        pts = ""; size = ""
        for (i = 1; i <= NF; i++) {
          if ($i ~ /^pts_time=/) pts = substr($i, 10)
          if ($i ~ /^size=/) size = substr($i, 6)
        }
        if (pts !~ /^-?[0-9]+([.][0-9]+)?$/ || size !~ /^[0-9]+$/) {
          invalid = 1
        } else {
          pts += 0
          for (i = 1; i <= count; i++)
            if (pts >= begin[i] && pts < end[i]) bytes[i] += size
        }
      }
      END {
        for (i = 1; i <= count; i++) if (bytes[i] <= 0) invalid = 1
        if (invalid) exit 1
        for (i = 1; i <= count; i++) printf "%.0f%s", bytes[i], (i == count ? "\n" : " ")
      }'); then
    echo "Erreur : impossible de mesurer les extraits vidéo de '$input'." >&2
    return 1
  fi
  IFS=',' read -r -a samples <<< "$intervals"
  read -r -a sizes <<< "$source_sizes"

  if ! sample_dir=$(mktemp -d "${TMPDIR:-/tmp}/av1-sample.XXXXXX"); then
    echo "Erreur : impossible de créer le dossier temporaire." >&2
    return 1
  fi
  sample_file="$sample_dir/sample.mkv"
  trap 'rm -f "$sample_file"; rmdir "$sample_dir"' EXIT

  for interval in "${samples[@]}"; do
    start="${interval%|*}"
    length="${interval#*|}"
    source_size="${sizes[$i]}"
    echo "Test vidéo : extrait $((i + 1))/${#samples[@]} à ${start} s (${length} s)..." >&2
    if ! ffmpeg -v error -nostdin -y -ss "$start" -i "$input" -t "$length" \
      -map 0:v:0 -an -sn -c:v libsvtav1 -crf 30 -preset 6 \
      -pix_fmt yuv420p10le -f matroska "$sample_file"; then
      echo "Erreur : impossible d'encoder l'extrait vidéo $((i + 1))." >&2
      return 1
    fi
    if ! encoded_size=$(ffprobe -v error -select_streams v:0 -show_packets \
      -show_entries packet=size -of compact=p=0:nk=0 -i "$sample_file" |
      awk -F '|' '
        {
          size = ""
          for (i = 1; i <= NF; i++) if ($i ~ /^size=/) size = substr($i, 6)
          if (size !~ /^[0-9]+$/) invalid = 1
          else total += size
        }
        END {
          if (invalid || total <= 0) exit 1
          printf "%.0f\n", total
        }'); then
      echo "Erreur : impossible de mesurer l'extrait AV1 $((i + 1))." >&2
      return 1
    fi
    source_total=$((source_total + source_size))
    encoded_total=$((encoded_total + encoded_size))
    i=$((i + 1))
  done

  awk -v source="$source_total" -v encoded="$encoded_total" '
    BEGIN {
      gain = 100 * (source - encoded) / source
      printf "Gain vidéo estimé : %.2f %%.\n", gain > "/dev/stderr"
      print (encoded * 100 <= source * 80 ? "encode" : "copy")
    }'
)

status=0
for input_file in "$@"; do
  if [ ! -f "$input_file" ]; then
    echo "Erreur : le fichier '$input_file' n'existe pas." >&2
    status=1
    continue
  fi

  dir=$(dirname "$input_file")
  filename=$(basename "$input_file")
  case "$filename" in
    *.*) filename="${filename%.*}" ;;
  esac
  output_file="$dir/${filename}-av1.mkv"

  if [ -e "$output_file" ]; then
    echo "Erreur : '$output_file' existe déjà ; il ne sera pas écrasé." >&2
    status=1
    continue
  fi

  if ! video_decision=$(estimate_video "$input_file"); then
    echo "Erreur : estimation du gain vidéo impossible pour '$input_file'." >&2
    status=1
    continue
  fi
  if [ "$video_decision" = "encode" ]; then
    echo "Piste vidéo : gain estimé suffisant ; conversion en AV1."
    video_options=(-c:v libsvtav1 -crf 30 -preset 6 -pix_fmt yuv420p10le)
  else
    echo "Piste vidéo : gain estimé inférieur à 20 % ; copie."
    video_options=(-c:v copy)
  fi

  if ! audio_streams=$(ffprobe -v error -select_streams a \
    -show_entries stream=channels,channel_layout -of compact=p=0:nk=0 -i "$input_file"); then
    echo "Erreur : impossible d'analyser les pistes audio de '$input_file'." >&2
    status=1
    continue
  fi

  audio_options=(-c:a copy)
  audio_index=0
  audio_conversion=false
  analysis_failed=false
  while IFS='|' read -r channels_field layout_field; do
    [ -n "$channels_field" ] || continue
    channels="${channels_field#channels=}"
    layout="${layout_field#channel_layout=}"

    case "$channels:$layout" in
      1:*) target=64 ;;
      2:*) target=128 ;;
      6:5.1|6:5.1\(side\)) target=256 ;;
      *)
        echo "Piste audio $audio_index : configuration $channels/$layout non prise en charge ; copie."
        audio_index=$((audio_index + 1))
        continue
        ;;
    esac

    if ! estimate=$(ffprobe -v error -select_streams "a:$audio_index" \
      -show_packets -show_entries packet=size,duration_time -of compact=p=0:nk=0 -i "$input_file" |
      awk -F '|' -v target="$target" '
        {
          duration = ""; size = ""
          for (i = 1; i <= NF; i++) {
            if ($i ~ /^duration_time=/) { duration = substr($i, 15) }
            if ($i ~ /^size=/) { size = substr($i, 6) }
          }
          if (duration !~ /^[0-9]+([.][0-9]+)?$/ || duration <= 0 ||
              size !~ /^[0-9]+$/) {
            invalid = 1
          } else {
            total_duration += duration
            total_size += size
          }
        }
        END {
          if (NR == 0 || invalid || total_duration <= 0 || total_size <= 0) {
            print "unknown"
          } else {
            bitrate = total_size * 8 / total_duration
            printf "%.2f|%s\n", bitrate / 1000, \
              (target * 1000 * total_duration * 100 <= total_size * 8 * 80) ? "encode" : "copy"
          }
        }'); then
      echo "Erreur : impossible d'analyser la piste audio $audio_index de '$input_file'." >&2
      analysis_failed=true
      break
    fi

    if [ "$estimate" = "unknown" ]; then
      echo "Piste audio $audio_index : débit impossible à estimer ; copie."
    else
      bitrate="${estimate%|*}"
      decision="${estimate#*|}"
      if [ "$decision" = "encode" ]; then
        echo "Piste audio $audio_index : débit estimé ${bitrate} kbit/s ; conversion Opus à ${target} kbit/s."
        audio_conversion=true
        audio_options+=("-c:a:$audio_index" libopus "-b:a:$audio_index" "${target}k")
        if [ "$channels" = 6 ]; then
          audio_options+=("-ch_layout:a:$audio_index" 5.1)
        fi
      else
        echo "Piste audio $audio_index : débit estimé ${bitrate} kbit/s ; gain inférieur à 20 %, copie."
      fi
    fi
    audio_index=$((audio_index + 1))
  done <<< "$audio_streams"

  if [ "$analysis_failed" = true ]; then
    status=1
    continue
  fi

  if [ "$video_decision" = "copy" ] && [ "$audio_conversion" = false ]; then
    echo "Aucune piste à convertir pour '$input_file' ; aucun fichier créé."
    continue
  fi

  echo "Conversion de '$input_file' vers '$output_file'..."
  if ffmpeg -nostdin -n -i "$input_file" \
    -map 0:v:0 -map 0:a? -map 0:s? \
    "${video_options[@]}" \
    "${audio_options[@]}" -c:s copy "$output_file"; then
    echo "Conversion terminée : '$output_file'. Original conservé."
  else
    echo "Erreur lors de la conversion de '$input_file'. Un fichier de sortie incomplet peut subsister : '$output_file'." >&2
    status=1
  fi
done

exit "$status"
