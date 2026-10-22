#!/bin/bash

OUTPUT_DIR="$HOME"

echo "=== Rozpoczynanie wielowątkowego pobierania i otwierania obrazów ==="
echo "Katalog docelowy: Katalog domowy ($OUTPUT_DIR)"

# Funkcja pobierająca, zapisująca i otwierająca pojedynczy obraz
download_img() {
    local url="$1"
    local prefix="$2"
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
        echo "[OK] Pobrano i otwarto: $prefix"
        
        # Automatyczne otwieranie pliku w zależności od systemu operacyjnego
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

export -f download_img
export OUTPUT_DIR

# Generowanie listy zadań i przekazanie do xargs (-P 15 oznacza 15 wątków jednocześnie)
(
    # Główne pliki (linux0 - linux60)
    for i in {0..60}; do
        echo "https://szkola.buz.info.pl/graf/linux$i" "linux_$i"
    done
    
    # Pliki z part1 (0 - 60)
    for i in {0..60}; do
        echo "https://szkola.buz.info.pl/graf/part1/linux$i" "part1_linux_$i"
    done

    # Pliki z part2 (0 - 60)
    for i in {0..60}; do
        echo "https://szkola.buz.info.pl/graf/part2/linux$i" "part2_linux_$i"
    done
    
    # Pliki z part3 (tylko 5 obrazów: 0 - 4)
    for i in {0..4}; do
        echo "https://szkola.buz.info.pl/graf/part3/linux$i" "part3_linux_$i"
    done
) | xargs -n 2 -P 15 bash -c 'download_img "$0" "$1"'

echo "=== Zakończono! Wszystkie pliki zostały pobrane i otwarte w katalogu domowym. ==="
