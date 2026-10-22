#!/bin/bash

OUTPUT_DIR="$HOME"

echo "=== Rozpoczynanie wielowątkowego pobierania obrazów ==="
echo "Katalog docelowy: Katalog domowy ($OUTPUT_DIR)"

# Lista zadań (URL + prefiks)
# Tworzymy tablicę wszystkich linków do pobrania
declare -a TASKS

# 1. Główne pliki (0-60)
for i in {0..60}; do
    TASKS+=("https://szkola.buz.info.pl/graf/linux$i|linux_$i")
done

# 2. part1 (0-60)
for i in {0..60}; do
    TASKS+=("https://szkola.buz.info.pl/graf/part1/linux$i|part1_linux_$i")
done

# 3. part2 (0-60)
for i in {0..60}; do
    TASKS+=("https://szkola.buz.info.pl/graf/part2/linux$i|part2_linux_$i")
done

# 4. part3 (0-4)
for i in {0..4}; do
    TASKS+=("https://szkola.buz.info.pl/graf/part3/linux$i|part3_linux_$i")
done

TOTAL=${#TASKS[@]}
CURRENT=0
LOCKFILE=$(mktemp)

# Funkcja pobierająca pojedynczy plik
download_one() {
    local item="$1"
    IFS='|' read -r url prefix <<< "$item"
    
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

export -f download_one
export OUTPUT_DIR

echo "Pobieranie $TOTAL plików w tle..."

# Uruchamianie równoległe z paskiem postępu (zastępuje xargs i poprawnie działa w strumieniu)
for item in "${TASKS[@]}"; do
    download_one "$item" &
    
    # Ograniczenie liczby równoległych zadań do 15
    while [ $(jobs -r -p | wc -l) -ge 15 ]; do
        sleep 0.1
    done
done

# Czekaj na zakończenie wszystkich procesów w tle
wait

rm -f "$LOCKFILE"
echo -e "\n=== Zakończono! Wszystkie pliki zostały pobrane i otwarte w katalogu domowym. ==="
