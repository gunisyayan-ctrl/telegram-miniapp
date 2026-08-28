#!/data/data/com.termux/files/usr/bin/bash

VIDEO_FILE="$HOME/telegram-miniapp/videos.json"
GENERATOR="$HOME/telegram-miniapp/generator.sh"

echo ""
echo "=============================="
echo " TAMBAH VIDEO"
echo "=============================="
echo ""

read -r -p "Masukkan link video: " LINK

if [ -z "$LINK" ]; then
    echo "Link tidak boleh kosong."
    exit 1
fi

# Ambil satu judul baru
HASIL=$("$GENERATOR")

if [ $? -ne 0 ] || [ -z "$HASIL" ]; then
    echo "Gagal mendapatkan judul."
    exit 1
fi

echo ""
echo "Judul otomatis:"
echo "$HASIL"
echo ""

# Buat videos.json jika belum ada
if [ ! -f "$VIDEO_FILE" ]; then
    echo "[]" > "$VIDEO_FILE"
fi

python - "$VIDEO_FILE" "$HASIL" "$LINK" <<'PY'
import json
import sys

file = sys.argv[1]
judul = sys.argv[2]
link = sys.argv[3]

try:
    with open(file, "r", encoding="utf-8") as f:
        data = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    data = []

data.append({
    "judul": judul,
    "url": link
})

with open(file, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Video berhasil ditambahkan.")
PY
