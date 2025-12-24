#!/bin/bash

# Files that still need conversion
files=(
  "Adeudos_OpcMult.vue"
  "Contratos_Cons_Dom.vue"
  "Contratos_EstGral.vue"
  "Contratos_Upd_Und.vue"
  "Ctrol_Imp_Cat.vue"
  "EstGral2.vue"
  "index.vue"
  "Ins_b.vue"
  "Rep_PadronContratos.vue"
  "Rep_Zonas.vue"
  "Upd_01.vue"
  "Upd_IniObl.vue"
  "Upd_UndC.vue"
  "UpdxCont.vue"
)

echo "Converting remaining 14 files..."

for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    # Check if file has any execute calls with old format
    if grep -q "execute.*{[[:space:]]*$" "$file" 2>/dev/null || grep -q "execute.*{[[:space:]]*p_" "$file" 2>/dev/null; then
      echo "Processing: $file"
      # Simple conversion: { } → [ ]
      sed -i 's/{[[:space:]]*$/[\n      /g' "$file"
      sed -i 's/^      }/    ]/g' "$file"
      echo "✓ Converted: $file"
    else
      echo "- Skipped (no old format): $file"
    fi
  fi
done

echo "Done!"
