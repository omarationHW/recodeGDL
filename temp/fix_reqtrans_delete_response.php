<?php

$file = 'C:/recodeGDL/RefactorX/FrontEnd/src/views/modules/multas_reglamentos/ReqTrans.vue';

echo "📋 Corrigiendo procesamiento de respuesta DELETE en ReqTrans.vue...\n\n";

$content = file_get_contents($file);

// Buscar y reemplazar el código de procesamiento de respuesta en confirmDelete()
$oldCode = '    // Procesar respuesta
    let result = null
    if (response?.result && Array.isArray(response.result) && response.result.length > 0) {
      const firstResult = response.result[0]
      if (typeof firstResult === \'string\') {
        result = JSON.parse(firstResult)
      } else {
        result = firstResult
      }
    } else if (response?.success !== undefined) {
      result = response
    }';

$newCode = '    // Procesar respuesta
    let result = null
    if (response?.result && Array.isArray(response.result) && response.result.length > 0) {
      const firstResult = response.result[0]
      if (typeof firstResult === \'string\') {
        result = JSON.parse(firstResult)
      } else if (firstResult.recaudadora_reqtrans_delete) {
        result = JSON.parse(firstResult.recaudadora_reqtrans_delete)
      } else {
        result = firstResult
      }
    } else if (response?.success !== undefined) {
      result = response
    }';

if (strpos($content, $oldCode) !== false) {
    $content = str_replace($oldCode, $newCode, $content);
    file_put_contents($file, $content);

    echo "✅ Código corregido exitosamente\n\n";

    echo "╔════════════════════════════════════════════════════════════╗\n";
    echo "║              🎉 CORRECCIÓN APLICADA 🎉                     ║\n";
    echo "╚════════════════════════════════════════════════════════════╝\n";
    echo "\n";
    echo "📋 CAMBIO REALIZADO:\n";
    echo "   ✅ Agregado soporte para recaudadora_reqtrans_delete\n";
    echo "   ✅ Ahora reconoce respuestas de DELETE\n";
    echo "   ✅ Muestra mensaje de éxito correcto\n";
    echo "\n";
    echo "🎯 RESULTADO:\n";
    echo "   ✅ CREATE mostrará: 'Registro creado correctamente'\n";
    echo "   ✅ UPDATE mostrará: 'Registro actualizado correctamente'\n";
    echo "   ✅ DELETE mostrará: 'Registro eliminado correctamente'\n";
    echo "\n";
    echo "🚀 Ahora puedes probar eliminar un registro\n";
    echo "\n";

} else if (strpos($content, 'recaudadora_reqtrans_delete') !== false && strpos($content, 'confirmDelete') !== false) {
    echo "ℹ️  El código ya está corregido\n";
    echo "✅ No se requieren cambios\n\n";
} else {
    echo "❌ No se encontró el código a reemplazar\n";
    echo "⚠️  Verifica manualmente el archivo\n\n";

    // Buscar la función confirmDelete
    if (strpos($content, 'async function confirmDelete()') !== false) {
        echo "ℹ️  La función confirmDelete() existe\n";

        // Buscar el patrón de procesamiento de respuesta
        if (strpos($content, '// Procesar respuesta') !== false) {
            echo "ℹ️  Se encontró el comentario '// Procesar respuesta'\n";
            echo "⚠️  El patrón de código puede haber cambiado\n";
            echo "⚠️  Revisa manualmente la función confirmDelete()\n";
        }
    }
}
