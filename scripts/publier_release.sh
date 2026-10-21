#!/usr/bin/env bash
# Publie l'APK release sur GitHub sous un nom fixe, pour que le lien de
# téléchargement ne change jamais :
#   https://github.com/Vaillantval/MaketLakay_Version_Mobile_Tr/releases/latest/download/MaketLakay.apk
#
# Crée la release v<version de pubspec.yaml>, y dépose l'APK sous le nom
# MaketLakay.apk, puis supprime les APK des releases précédentes (les notes
# de version restent).
#
# Usage : scripts/publier_release.sh notes.md
#   (APK universel à construire avant : flutter build apk --release ;
#   un seul fichier pour tous les appareils, 32 et 64 bits)
set -euo pipefail

REPO="Vaillantval/MaketLakay_Version_Mobile_Tr"
NOM_APK="MaketLakay.apk"
APK="build/app/outputs/flutter-apk/app-release.apk"
NOTES="${1:?Usage : $0 notes.md}"

VERSION=$(sed -n 's/^version: *\([0-9.]*\)+.*/\1/p' pubspec.yaml)
TAG="v$VERSION"
[ -f "$APK" ] || { echo "APK introuvable : $APK (flutter build apk --release)"; exit 1; }

TOKEN=$(printf "protocol=https\nhost=github.com\n\n" | git credential fill | sed -n 's/^password=//p')
[ -n "$TOKEN" ] || { echo "Jeton GitHub introuvable (git credential)"; exit 1; }
API="https://api.github.com/repos/$REPO"
auth=(-H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json")

# 1. Release
CORPS=$(python -c "import json,sys;print(json.dumps({'tag_name':sys.argv[1],'target_commitish':'main','name':'MaketLakay '+sys.argv[2],'body':open(sys.argv[3],encoding='utf-8').read(),'make_latest':'true'}))" "$TAG" "$VERSION" "$NOTES")
ID=$(curl -sf "${auth[@]}" -X POST "$API/releases" -d "$CORPS" | python -c "import json,sys;print(json.load(sys.stdin)['id'])")
echo "Release $TAG créée ($ID)"

# 2. APK sous le nom fixe
deposer() {
  curl -sf "${auth[@]}" -H "Content-Type: application/vnd.android.package-archive" \
    --data-binary @"$1" "https://uploads.github.com/repos/$REPO/releases/$ID/assets?name=$2" >/dev/null
  echo "APK déposé : $2"
}
deposer "$APK" "$NOM_APK"

# 3. Supprimer les APK des autres releases
curl -sf "${auth[@]}" "$API/releases?per_page=100" | python -c "
import json,sys
for r in json.load(sys.stdin):
    if r['id'] == int(sys.argv[1]): continue
    for a in r['assets']:
        if a['name'].endswith('.apk'): print(a['id'], r['tag_name'], a['name'])
" "$ID" | while read -r ASSET TAG_ANCIEN NOM; do
  curl -sf "${auth[@]}" -X DELETE "$API/releases/assets/$ASSET" >/dev/null
  echo "Supprimé : $NOM ($TAG_ANCIEN)"
done

echo "Lien permanent : https://github.com/$REPO/releases/latest/download/$NOM_APK"
