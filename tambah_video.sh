#!/data/data/com.termux/files/usr/bin/bash

VIDEO_FILE="$HOME/telegram-miniapp/videos.json"
GENERATOR="$HOME/telegram-miniapp/generator.sh"

echo ""
echo "=============================="
echo " TAMBAH VIDEO"
echo "=============================="
echo ""
echo "1. Tambah 1 video"
echo "2. Tambah banyak video"
echo "0. Keluar"
echo ""

read -r -p "Pilih menu: " PILIHAN

if [ "$PILIHAN" = "0" ]; then
    exit 0
fi

if [ "$PILIHAN" != "1" ] && [ "$PILIHAN" != "2" ]; then
    echo "Pilihan tidak valid."
    exit 1
fi

if [ ! -f "$VIDEO_FILE" ]; then
    echo "[]" > "$VIDEO_FILE"
fi

if [ ! -f "$GENERATOR" ]; then
    echo "generator.sh tidak ditemukan."
    exit 1
fi

if [ "$PILIHAN" = "1" ]; then
    read -r -p "Masukkan link video: " LINK

    if [ -z "$LINK" ]; then
        echo "Link tidak boleh kosong."
        exit 1
    fi

    HASIL=$("$GENERATOR")

    if [ $? -ne 0 ] || [ -z "$HASIL" ]; then
        echo "Gagal mendapatkan judul."
        exit 1
    fi

    echo ""
    echo "Judul otomatis:"
    echo "$HASIL"
    echo ""

    python - "$VIDEO_FILE" "$HASIL" "$LINK" <<'PY'
import json
import sys

file = sys.argv[1]
judul = sys.argv[2]
link = sys.argv[3]

with open(file, "r", encoding="utf-8") as f:
    data = json.load(f)

data.append({
    "judul": judul,
    "url": link
})

with open(file, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
PY

    echo "Video berhasil ditambahkan."

else
    echo ""
    echo "Masukkan link satu per satu."
    echo "Ketik SELESAI jika sudah selesai."
    echo ""

    JUMLAH=0

    while true; do
        read -r -p "Link video: " LINK

        if [ "$LINK" = "SELESAI" ] || [ "$LINK" = "selesai" ]; then
            break
        fi

        if [ -z "$LINK" ]; then
            echo "Link tidak boleh kosong."
            continue
        fi

        HASIL=$("$GENERATOR")

        if [ $? -ne 0 ] || [ -z "$HASIL" ]; then
            echo "Gagal mendapatkan judul. Proses dihentikan."
            exit 1
        fi

        python - "$VIDEO_FILE" "$HASIL" "$LINK" <<'PY'
import json
import sys

file = sys.argv[1]
judul = sys.argv[2]
link = sys.argv[3]

with open(file, "r", encoding="utf-8") as f:
    data = json.load(f)

data.append({
    "judul": judul,
    "url": link
})

with open(file, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
PY

        JUMLAH=$((JUMLAH + 1))

        echo "✓ $JUMLAH video ditambahkan: $HASIL"
        echo ""
    done

    if [ "$JUMLAH" -eq 0 ]; then
        echo "Tidak ada video yang ditambahkan."
        exit 0
    fi

    echo ""
    echo "Total video baru: $JUMLAH"
fi

echo ""
echo "Mengirim perubahan ke GitHub..."

cd "$HOME/telegram-miniapp" || exit 1

git add videos.json judul_terpakai.txt

git commit -m "Tambah video baru"

if git push origin main; then
    echo ""
    echo "================================"
    echo " VIDEO BERHASIL DIPUBLISH"
    echo "================================"
else
    echo ""
    echo "================================"
    echo " GAGAL PUSH KE GITHUB"
    echo "================================"
    exit 1
fi
