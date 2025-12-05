<?php

$sourceFile = 'C:/recodeGDL/RefactorX/FrontEnd/src/views/modules/multas_reglamentos/reqmultas400frm.vue';
$targetFile = 'C:/recodeGDL/RefactorX/FrontEnd/src/views/modules/multas_reglamentos/ReqPromocion.vue';

// Read the source template
$content = file_get_contents($sourceFile);

// 1. Change icon
$content = str_replace('icon="file-invoice"', 'icon="badge-percent"', $content);

// 2. Change title
$content = str_replace('<h1>Requerimientos Multas 400</h1>', '<h1>Requerimiento Promoción</h1>', $content);

// 3. Remove "Tipo de Multa" section (lines 16-29)
$content = preg_replace(
    '/<!-- Tipo de Multa -->.*?<\/div>\s*<\/div>/s',
    '',
    $content,
    1
);

// 4. Change labels
$content = str_replace(
    '<label class="municipal-form-label">Cuenta / Folio</label>',
    '<label class="municipal-form-label">Cuenta / ID Descuento</label>',
    $content
);

$content = str_replace(
    'placeholder="Ingrese cuenta o folio"',
    'placeholder="Ingrese ID de descuento"',
    $content
);

// 5. Add Año field after Cuenta field
$searchPattern = '/(<input[^>]*v-model="filters\.cuenta"[^>]*>)\s*(<\/div>)\s*(<div class="button-wrapper">)/s';
$replacement = '$1$2' . "\n" . '              <div class="form-group">
                <label class="municipal-form-label">Año</label>
                <input
                  class="municipal-form-control"
                  type="number"
                  v-model.number="filters.ejercicio"
                  placeholder="Año (opcional)"
                  @keyup.enter="buscarGeneral"
                />
              </div>' . "\n" . '              $3';
$content = preg_replace($searchPattern, $replacement, $content);

// 6. Change SP name
$content = str_replace("'RECAUDADORA_REQMULTAS400FRM'", "'RECAUDADORA_REQ_PROMOCION'", $content);

// 7. Update filters to include ejercicio
$content = str_replace(
    "const filters = ref({\n  cuenta: '',\n  tipo: '6' // Default: Federal\n})",
    "const filters = ref({\n  cuenta: '',\n  ejercicio: null\n})",
    $content
);

// 8. Update parameters to include ejercicio
$oldParams = "const data = await execute('RECAUDADORA_REQ_PROMOCION', BASE_DB, [
      {
        nombre: 'p_clave_cuenta',
        tipo: 'string',
        valor: String(filters.value.cuenta || '')
      }
    ])";

$newParams = "const data = await execute('RECAUDADORA_REQ_PROMOCION', BASE_DB, [
      {
        nombre: 'p_clave_cuenta',
        tipo: 'string',
        valor: String(filters.value.cuenta || '')
      },
      {
        nombre: 'p_ejercicio',
        tipo: 'integer',
        valor: filters.value.ejercicio || null
      }
    ])";

$content = str_replace($oldParams, $newParams, $content);

// 9. Update formatColumnName function
$oldFormatColumnName = "function formatColumnName(col) {
  const columnNames = {
    cvelet: 'Clave Letra',
    cvenum: 'Año Acta',
    ctarfc: 'Núm. Acta',
    cveapl: 'Tipo',
    axoreq: 'Año Req',
    folreq: 'Folio Req',
    fecreq: 'Fecha Req',
    impcuo: 'Importe',
    observr: 'Observaciones',
    vigreq: 'Vigencia',
    actreq: 'Activación',
    tipo_multa: 'Tipo Multa'
  }
  return columnNames[col] || col.toUpperCase()
}";

$newFormatColumnName = "function formatColumnName(col) {
  const columnNames = {
    cvedescuento: 'ID Descuento',
    descripcion: 'Descripción',
    importe: 'Importe'
  }
  return columnNames[col] || col.toUpperCase()
}";

$content = str_replace($oldFormatColumnName, $newFormatColumnName, $content);

// 10. Update formatValue function - change impcuo to importe and remove date formatting
$oldFormatValue = "function formatValue(value, column) {
  if (value === null || value === undefined || value === '') return '-'

  // Formato de importe
  if (column === 'impcuo' && !isNaN(value)) {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(value)
  }

  // Formato de fecha (YYYYMMDD -> DD/MM/YYYY)
  if ((column === 'fecreq' || column === 'actreq') && value && value !== '0') {
    const str = String(value).padStart(8, '0')
    if (str.length === 8) {
      const year = str.substring(0, 4)
      const month = str.substring(4, 6)
      const day = str.substring(6, 8)
      return `\${day}/\${month}/\${year}`
    }
  }

  return value
}";

$newFormatValue = "function formatValue(value, column) {
  if (value === null || value === undefined || value === '') return '-'

  // Formato de importe
  if (column === 'importe' && !isNaN(value)) {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(value)
  }

  return value
}";

$content = str_replace($oldFormatValue, $newFormatValue, $content);

// 11. Remove .mb-3, .radio-group, and .radio-label CSS rules (no longer needed)
$content = preg_replace('/\.mb-3 \{[^}]+\}/s', '', $content);
$content = preg_replace('/\.radio-group \{[^}]+\}/s', '', $content);
$content = preg_replace('/\.radio-label \{[^}]+\}/s', '', $content);
$content = preg_replace('/\.radio-label input\[type=[\'"]radio[\'"]\] \{[^}]+\}/s', '', $content);

// 12. Update search-section CSS to remove border-top and padding-top
$content = str_replace(
    ".search-section {\n  margin-top: 1.5rem;\n  padding-top: 1.5rem;\n  border-top: 1px solid #e0e0e0;\n}",
    ".search-section {\n  margin-top: 1rem;\n}",
    $content
);

// Write the updated content
file_put_contents($targetFile, $content);

echo "✅ Archivo ReqPromocion.vue actualizado exitosamente\n";
echo "Ubicación: $targetFile\n";
