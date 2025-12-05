<?php

$file = 'C:/recodeGDL/RefactorX/FrontEnd/src/views/modules/multas_reglamentos/RequerimientosDM.vue';

echo "📋 Corrigiendo procesamiento de respuesta en RequerimientosDM.vue...\n\n";

$content = file_get_contents($file);

// Buscar y reemplazar la función reload()
$oldReload = <<<'OLD'
// Función para recargar datos
async function reload() {
  // IMPORTANTE: Usar formato español (nombre, tipo, valor)
  const params = [
    { nombre: 'clave_cuenta', tipo: 'C', valor: String(filters.value.cuenta || '') },
    { nombre: 'ejercicio', tipo: 'I', valor: Number(filters.value.ejercicio || 0) }
  ]

  try {
    const data = await execute(OP_LIST, BASE_DB, params)
    const arr = Array.isArray(data?.rows) ? data.rows : Array.isArray(data) ? data : []
    rows.value = arr
    currentPage.value = 1 // Resetear a primera página
  } catch (e) {
    console.error('Error al cargar requerimientos:', e)
    rows.value = []
  }
}
OLD;

$newReload = <<<'NEW'
// Función para recargar datos
async function reload() {
  // IMPORTANTE: Usar formato español (nombre, tipo, valor)
  const params = [
    { nombre: 'clave_cuenta', tipo: 'C', valor: String(filters.value.cuenta || '') },
    { nombre: 'ejercicio', tipo: 'I', valor: Number(filters.value.ejercicio || 0) }
  ]

  try {
    const response = await execute(OP_LIST, BASE_DB, params)
    console.log('Respuesta completa:', response)

    // Procesar la respuesta según la estructura de la API
    let arr = []

    // La API puede retornar diferentes estructuras
    if (response?.eResponse?.data?.result && Array.isArray(response.eResponse.data.result)) {
      arr = response.eResponse.data.result
    } else if (response?.data?.result && Array.isArray(response.data.result)) {
      arr = response.data.result
    } else if (response?.result && Array.isArray(response.result)) {
      arr = response.result
    } else if (response?.rows && Array.isArray(response.rows)) {
      arr = response.rows
    } else if (Array.isArray(response)) {
      arr = response
    }

    console.log('Registros extraídos:', arr.length, arr)
    rows.value = arr
    currentPage.value = 1 // Resetear a primera página
  } catch (e) {
    console.error('Error al cargar requerimientos:', e)
    rows.value = []
  }
}
NEW;

if (strpos($content, $oldReload) !== false) {
    $content = str_replace($oldReload, $newReload, $content);
    file_put_contents($file, $content);

    echo "✅ Código corregido exitosamente\n\n";

    echo "╔════════════════════════════════════════════════════════════╗\n";
    echo "║              🎉 CORRECCIÓN APLICADA 🎉                     ║\n";
    echo "╚════════════════════════════════════════════════════════════╝\n";
    echo "\n";
    echo "📋 CAMBIO REALIZADO:\n";
    echo "   ✅ Procesamiento de respuesta actualizado\n";
    echo "   ✅ Soporte para estructura eResponse.data.result\n";
    echo "   ✅ Múltiples formatos de respuesta compatibles\n";
    echo "   ✅ Console.log para debugging agregado\n";
    echo "\n";
    echo "🎯 AHORA LA TABLA MOSTRARÁ LOS DATOS:\n";
    echo "   ✅ Busca en eResponse.data.result (formato actual)\n";
    echo "   ✅ Busca en data.result (formato alternativo)\n";
    echo "   ✅ Busca en result (formato directo)\n";
    echo "   ✅ Busca en rows (formato legacy)\n";
    echo "   ✅ Busca en array directo\n";
    echo "\n";
    echo "🚀 La paginación de 10 en 10 YA está implementada\n";
    echo "🚀 Ahora recarga la página y haz clic en Buscar\n";
    echo "\n";

} else {
    echo "⚠️  No se encontró el código exacto a reemplazar\n";
    echo "ℹ️  Verificando si ya está corregido...\n\n";

    if (strpos($content, 'eResponse?.data?.result') !== false) {
        echo "✅ El código ya está corregido\n";
        echo "✅ La paginación ya está implementada\n";
        echo "✅ No se requieren cambios\n\n";
        echo "🔍 Si aún no se muestran los datos:\n";
        echo "   1. Recarga la página (Ctrl+F5)\n";
        echo "   2. Abre la consola del navegador (F12)\n";
        echo "   3. Haz clic en Buscar\n";
        echo "   4. Revisa los logs de 'Respuesta completa' y 'Registros extraídos'\n";
        echo "\n";
    } else {
        echo "❌ El código no coincide\n";
        echo "⚠️  Puede que el archivo tenga una estructura diferente\n\n";

        // Buscar si existe la función reload
        if (strpos($content, 'async function reload()') !== false) {
            echo "ℹ️  La función reload() existe\n";
            echo "⚠️  Pero el contenido es diferente al esperado\n";
            echo "⚠️  Revisa manualmente el archivo\n";
        }
    }
}
