<?php

$file = 'C:/recodeGDL/RefactorX/FrontEnd/src/views/modules/multas_reglamentos/ReqTrans.vue';

echo "📋 Corrigiendo procesamiento de respuesta CREATE en ReqTrans.vue...\n\n";

$content = file_get_contents($file);

// Buscar y reemplazar el código de procesamiento de respuesta en save()
$oldCode = '      } else if (firstResult.recaudadora_reqtrans_update) {
        result = JSON.parse(firstResult.recaudadora_reqtrans_update)
      } else {
        result = firstResult
      }';

$newCode = '      } else if (firstResult.recaudadora_reqtrans_update) {
        result = JSON.parse(firstResult.recaudadora_reqtrans_update)
      } else if (firstResult.recaudadora_reqtrans_create) {
        result = JSON.parse(firstResult.recaudadora_reqtrans_create)
      } else {
        result = firstResult
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
    echo "   ✅ Agregado soporte para recaudadora_reqtrans_create\n";
    echo "   ✅ Ahora reconoce respuestas de CREATE\n";
    echo "   ✅ Muestra mensaje de éxito correcto\n";
    echo "\n";
    echo "🎯 RESULTADO:\n";
    echo "   ✅ CREATE mostrará: 'Registro creado correctamente'\n";
    echo "   ✅ UPDATE mostrará: 'Registro actualizado correctamente'\n";
    echo "   ✅ DELETE mostrará: 'Registro eliminado correctamente'\n";
    echo "\n";
    echo "🚀 Ahora puedes probar crear un nuevo registro\n";
    echo "\n";

} else if (strpos($content, 'recaudadora_reqtrans_create') !== false) {
    echo "ℹ️  El código ya está corregido\n";
    echo "✅ No se requieren cambios\n\n";
} else {
    echo "❌ No se encontró el código a reemplazar\n";
    echo "⚠️  Verifica manualmente el archivo\n\n";
}
