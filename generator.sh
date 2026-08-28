#!/data/data/com.termux/files/usr/bin/bash

JUDUL_FILE="$HOME/telegram-miniapp/daftar_judul.txt"
USED_FILE="$HOME/telegram-miniapp/judul_terpakai.txt"

touch "$USED_FILE"

if [ ! -f "$JUDUL_FILE" ]; then
    echo "File daftar_judul.txt tidak ditemukan."
    exit 1
fi

mapfile -t JUDUL_TERSEDIA < <(
    while IFS= read -r JUDUL; do
        [ -z "$JUDUL" ] && continue

        if ! grep -Fxq "$JUDUL" "$USED_FILE"; then
            echo "$JUDUL"
        fi
    done < "$JUDUL_FILE"
)

if [ ${#JUDUL_TERSEDIA[@]} -eq 0 ]; then
    echo "ERROR: Semua judul sudah digunakan." >&2
    exit 1
fi

INDEX=$((RANDOM % ${#JUDUL_TERSEDIA[@]}))
HASIL="${JUDUL_TERSEDIA[$INDEX]}"

echo "$HASIL" >> "$USED_FILE"

# Hanya cetak judul.
echo "$HASIL"
