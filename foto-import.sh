#!/bin/bash
# ════════════════════════════════════════════════════
# FOTO-IMPORT – Komprimieren, umbenennen, verschieben
# Aufruf: ./foto-import.sh deckchair
# ════════════════════════════════════════════════════

REPO=~/Desktop/umzugsflohmarkt
NEU=$REPO/fotos/neu
ZIEL=$REPO/fotos

# Prüfen ob ein Basisname übergeben wurde
if [ -z "$1" ]; then
  echo "Fehler: Bitte einen Basisnamen angeben."
  echo "Beispiel: ./foto-import.sh deckchair"
  exit 1
fi

BASIS="$1"

# Prüfen ob Dateien im Eingangsordner liegen
if [ -z "$(ls $NEU/*.{jpg,jpeg,JPG,JPEG,png,PNG,heic,HEIC} 2>/dev/null)" ]; then
  echo "Keine Bilddateien in $NEU gefunden."
  exit 1
fi

# Schritt 1: Komprimieren mit sips (macOS-Bordmittel, kein Install nötig)
echo "Komprimiere Fotos..."
for f in $NEU/*.{jpg,jpeg,JPG,JPEG,png,PNG,heic,HEIC}; do
  [ -f "$f" ] || continue
  sips -s format jpeg -s formatOptions 75 "$f" --out "$f.compressed.jpg" > /dev/null
  mv "$f.compressed.jpg" "$f"
done

# Schritt 2: Umbenennen und in fotos/ verschieben
echo "Benenne um und verschiebe..."
i=1
for f in $(ls $NEU/*.{jpg,jpeg,JPG,JPEG,png,PNG,heic,HEIC} 2>/dev/null | sort); do
  [ -f "$f" ] || continue
  NEUER_NAME="${BASIS}_${i}.jpg"
  mv "$f" "$ZIEL/$NEUER_NAME"
  echo "  → $NEUER_NAME"
  i=$((i+1))
done

echo ""
echo "Fertig! ${i-1} Fotos importiert."
echo ""
echo "Nicht vergessen: photos-Feld in umzugsflohmarkt.html aktualisieren."
echo ""

# Schritt 3: Auf GitHub hochladen
cd $REPO
git add fotos/
git commit -m "Neue Fotos: $BASIS"
git push

