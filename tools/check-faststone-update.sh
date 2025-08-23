#!/bin/bash
# Script per verificare aggiornamenti FastStone Image Viewer

CURRENT_VERSION="8.1"  # Aggiorna questa versione manualmente
CHECK_URL="https://www.faststone.org/FSIVDownload.htm"
EMAIL="tua-email@example.com"  # Inserisci la tua email
CACHE_FILE="/tmp/faststone_version_cache.txt"

# Scarica la pagina e estrai la versione
WEBPAGE=$(curl -s "$CHECK_URL")
NEW_VERSION=$(echo "$WEBPAGE" | grep -oP 'FastStone Image Viewer \K[0-9]+\.[0-9]+' | head -1)

# Leggi versione precedente dal cache
if [ -f "$CACHE_FILE" ]; then
    CACHED_VERSION=$(cat "$CACHE_FILE")
else
    CACHED_VERSION="$CURRENT_VERSION"
    echo "$CURRENT_VERSION" > "$CACHE_FILE"
fi

# Confronta versioni
if [ "$NEW_VERSION" != "$CACHED_VERSION" ] && [ -n "$NEW_VERSION" ]; then
    echo "Nuova versione disponibile: $NEW_VERSION (precedente: $CACHED_VERSION)"
    
    # Invia email di notifica
    SUBJECT="FastStone Image Viewer - Nuova versione $NEW_VERSION disponibile"
    BODY="FastStone Image Viewer è stato aggiornato dalla versione $CACHED_VERSION alla versione $NEW_VERSION.

Visita: $CHECK_URL

Per aggiornare il pacchetto Chocolatey:
cd /mnt/s/Commesse/60-69_Miei/61_Miei/61.01_Miei/chocolatey
./tools/update-package.ps1 -package_name 'faststone-image-viewer' -new_version '$NEW_VERSION'
"
    
    # Invia email (richiede configurazione mail)
    echo "$BODY" | mail -s "$SUBJECT" "$EMAIL"
    
    # Aggiorna cache
    echo "$NEW_VERSION" > "$CACHE_FILE"
    
    # Log
    echo "[$(date)] Aggiornamento rilevato: v$CACHED_VERSION → v$NEW_VERSION" >> ~/faststone_updates.log
else
    echo "Nessun aggiornamento. Versione attuale: $CACHED_VERSION"
fi