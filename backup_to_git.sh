#!/bin/bash

EXT_DIR="/opt/genieacs/ext"
DB_NAME="genieacs"

# Pastikan direktori tujuan tersedia
mkdir -p "$EXT_DIR/provisions" "$EXT_DIR/presets" "$EXT_DIR/virtual_parameters" \
         "$EXT_DIR/index_fields" "$EXT_DIR/config" "$EXT_DIR/permissions" \
         "$EXT_DIR/users" "$EXT_DIR/files"

cd "$EXT_DIR" || exit

# 1. Export Seluruh Koleksi Database GenieACS
mongoexport --db=$DB_NAME --collection=provisions --out="$EXT_DIR/provisions/provisions_backup.json" --jsonArray --quiet
mongoexport --db=$DB_NAME --collection=presets --out="$EXT_DIR/presets/presets_backup.json" --jsonArray --quiet
mongoexport --db=$DB_NAME --collection=virtualParameters --out="$EXT_DIR/virtual_parameters/vp_backup.json" --jsonArray --quiet
mongoexport --db=$DB_NAME --collection=indexFields --out="$EXT_DIR/index_fields/index_fields_backup.json" --jsonArray --quiet
mongoexport --db=$DB_NAME --collection=config --out="$EXT_DIR/config/config_backup.json" --jsonArray --quiet
mongoexport --db=$DB_NAME --collection=permissions --out="$EXT_DIR/permissions/permissions_backup.json" --jsonArray --quiet
mongoexport --db=$DB_NAME --collection=users --out="$EXT_DIR/users/users_backup.json" --jsonArray --quiet

# Export GridFS (Skrip / Firmware File)
mongoexport --db=$DB_NAME --collection=fs.files --out="$EXT_DIR/files/fs_files_backup.json" --jsonArray --quiet
mongoexport --db=$DB_NAME --collection=fs.chunks --out="$EXT_DIR/files/fs_chunks_backup.json" --jsonArray --quiet

# 2. Sinkronisasi Git & Push ke Remote
git add -A
git pull origin main --rebase --autostash --quiet

if [ -n "$(git status --porcelain)" ]; then
  git add .
  git commit -m "Full backup GenieACS: $(date +'%Y-%m-%d %H:%M:%S')"
  git push origin main
  echo "FULL BACKUP KE GIT SUKSES!"
else
  echo "Tidak ada perubahan data."
fi
