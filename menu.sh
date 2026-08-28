#!/data/data/com.termux/files/usr/bin/bash

BASE="$HOME/telegram-miniapp"

while true; do
    clear

    echo "=============================="
    echo "      TELEGRAM MINI APP"
    echo "=============================="
    echo ""
    echo "1. Tambah video"
    echo "2. Lihat / hapus video"
    echo "3. Lihat jumlah video"
    echo "0. Keluar"
    echo ""

    read -r -p "Pilih menu: " PILIHAN

    case "$PILIHAN" in
        1)
            bash "$BASE/tambah_video.sh"
            echo ""
            read -r -p "Tekan Enter untuk kembali..."
            ;;
        2)
            bash "$BASE/kelola_video.sh"
            echo ""
            read -r -p "Tekan Enter untuk kembali..."
            ;;
        3)
            python - "$BASE/videos.json" <<'PY'
import json
import sys

file = sys.argv[1]

try:
    with open(file, "r", encoding="utf-8") as f:
        data = json.load(f)

    print("")
    print("==============================")
    print(f" TOTAL VIDEO: {len(data)}")
    print("==============================")
except Exception as e:
    print("Gagal membaca videos.json:", e)
PY
            echo ""
            read -r -p "Tekan Enter untuk kembali..."
            ;;
        0)
            echo "Keluar..."
            exit 0
            ;;
        *)
            echo ""
            echo "Pilihan tidak valid."
            sleep 1
            ;;
    esac
done	
