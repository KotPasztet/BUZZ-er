#!/bin/bash

# ==========================================
echo "=== WERSJA v1 ==="
# ==========================================

OUTPUT_DIR="$HOME"

echo "=== Rozpoczynanie pobierania obrazów ==="
echo "Katalog docelowy: Katalog domowy ($OUTPUT_DIR)"

# Licznik wszystkich plików do pobrania (61 + 61 + 61 + 5 = 188)
TOTAL=188
CURRENT=0

# Funkcja pobierająca pojedynczy obraz
download_single() {
    local url="$1"
    local prefix="$2"
    
    CURRENT=$((CURRENT + 1))
    percent=$((CURRENT * 100 / TOTAL))
    echo -ne "Pobieranie [$CURRENT/$TOTAL] ($percent%): $prefix\r"
    
    local hf=$(mktemp)
    local tb=$(mktemp)
    
    local code
    code=$(curl -s -D "$hf" -o "$tb" -w "%{http_code}" "$url")
    
    if [ "$code" -eq 200 ]; then
        local ct
        ct=$(grep -i "content-type" "$hf" | tr '[:upper:]' '[:lower:]')
        
        local ext=".jpg"
        if echo "$ct" | grep -q "png"; then
            ext=".png"
        elif echo "$ct" | grep -q "gif"; then
            ext=".gif"
        elif echo "$ct" | grep -q "jpeg" || echo "$ct" | grep -q "jpg"; then
            ext=".jpg"
        fi
        
        local final_path="$OUTPUT_DIR/${prefix}${ext}"
        mv "$tb" "$final_path"
        
        # Otwieranie pliku
        if [[ "$OSTYPE" == "darwin"* ]]; then
            open "$final_path"
        else
            xdg-open "$final_path" 2>/dev/null &
        fi
    else
        rm -f "$tb"
    fi
    rm -f "$hf"
}

# 1. Główne pliki (0-60)
for i in {0..60}; do
    download_single "https://szkola.buz.info.pl/graf/linux$i" "linux_$i"
done

# 2. part1 (0-60)
for i in {0..60}; do
    download_single "https://szkola.buz.info.pl/graf/part1/linux$i" "part1_linux_$i"
done

# 3. part2 (0-60)
for i in {0..60}; do
    download_single "https://szkola.buz.info.pl/graf/part2/linux$i" "part2_linux_$i"
done

# 4. part3 (0-4)
for i in {0..4}; do
    download_single "https://szkola.buz.info.pl/graf/part3/linux$i" "part3_linux_$i"
done

echo -e "\n=== Zakończono! Wszystkie pliki zostały pobrane i otwarte w katalogu domowym. ==="
