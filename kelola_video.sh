#!/data/data/com.termux/files/usr/bin/bash

VIDEO_FILE="$HOME/telegram-miniapp/videos.json"

if [ ! -f "$VIDEO_FILE" ]; then
    echo "videos.json tidak ditemukan."
    exit 1
fi

python - "$VIDEO_FILE" <<'PY'
import json
import sys

file = sys.argv[1]

with open(file, "r", encoding="utf-8") as f:
    data = json.load(f)

if not data:
    print("Belum ada video.")
    sys.exit(0)

print("")
print("==============================")
print(" DAFTAR VIDEO")
print("==============================")

for i, video in enumerate(data, 1):
    print(f"{i}. {video.get('judul', '(tanpa judul)')}")
    print(f"   {video.get('url', '')}")
    print("")
PY

echo "=============================="
echo " KELOLA VIDEO"
echo "=============================="
echo "0. Kembali"
echo ""

read -r -p "Masukkan nomor video yang ingin dihapus: " NOMOR

if [ "$NOMOR" = "0" ]; then
    exit 0
fi

if ! [[ "$NOMOR" =~ ^[0-9]+$ ]]; then
    echo "Nomor tidak valid."
    exit 1
fi

python - "$VIDEO_FILE" "$NOMOR" <<'PY'
import json
import sys

file = sys.argv[1]
nomor = int(sys.argv[2])

with open(file, "r", encoding="utf-8") as f:
    data = json.load(f)

if nomor < 1 or nomor > len(data):
    print("Nomor video tidak ditemukan.")
    sys.exit(1)

video = data[nomor - 1]

print("")
print("Video yang dipilih:")
print("Judul :", video.get("judul", ""))
print("Link  :", video.get("url", ""))
print("")

jawab = input("Yakin ingin menghapus video ini? (y/n): ").strip().lower()

if jawab != "y":
    print("Penghapusan dibatalkan.")
    sys.exit(0)

data.pop(nomor - 1)

with open(file, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Video berhasil dihapus.")
PY

if [ $? -ne 0 ]; then
    exit 1
fi

echo ""
echo "Mengirim perubahan ke GitHub..."

cd "$HOME/telegram-miniapp" || exit 1

git add videos.json

git commit -m "Hapus video"

if git push origin main; then
    echo ""
    echo "================================"
    echo " PERUBAHAN BERHASIL DIPUBLISH"
    echo "================================"
else
    echo ""
    echo "================================"
    echo " GAGAL PUSH KE GITHUB"
    echo "================================"
    exit 1
fi
