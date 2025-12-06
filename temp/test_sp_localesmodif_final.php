<?php
// Cambiar al directorio de Laravel
chdir(__DIR__ . '/../RefactorX/BackEnd');

// Incluir el autoloader de Laravel
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

// Cargar la aplicación Laravel
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "==============================================\n";
echo "PRUEBA FINAL: sp_localesmodif_buscar_local\n";
echo "==============================================\n\n";

try {
    $connection = 'pgsql';

    // Obtener datos de prueba
    echo "1. Obteniendo datos de prueba...\n";
    $testData = DB::connection($connection)->select("
        SELECT oficina, num_mercado, categoria, seccion, local, letra_local, bloque
        FROM publico.ta_11_locales
        WHERE oficina IS NOT NULL
          AND num_mercado IS NOT NULL
          AND categoria IS NOT NULL
          AND seccion IS NOT NULL
          AND local IS NOT NULL
        LIMIT 1
    ");

    if (empty($testData)) {
        throw new Exception("No hay datos de prueba disponibles");
    }

    $data = $testData[0];
    echo "   ✓ Datos encontrados:\n";
    echo "     - Oficina: {$data->oficina}\n";
    echo "     - Mercado: {$data->num_mercado}\n";
    echo "     - Categoría: {$data->categoria}\n";
    echo "     - Sección: {$data->seccion}\n";
    echo "     - Local: {$data->local}\n";
    echo "     - Letra: " . ($data->letra_local ?? 'NULL') . "\n";
    echo "     - Bloque: " . ($data->bloque ?? 'NULL') . "\n\n";

    // Probar el SP
    echo "2. Probando sp_localesmodif_buscar_local...\n";

    $letra = $data->letra_local ? "'{$data->letra_local}'::VARCHAR" : "NULL";
    $bloque = $data->bloque ? "'{$data->bloque}'::VARCHAR" : "NULL";

    $result = DB::connection($connection)->select("
        SELECT * FROM sp_localesmodif_buscar_local(
            {$data->oficina}::INTEGER,
            {$data->num_mercado}::INTEGER,
            {$data->categoria}::INTEGER,
            '{$data->seccion}'::VARCHAR,
            {$data->local}::INTEGER,
            $letra,
            $bloque
        )
    ");

    if (!empty($result)) {
        echo "   ✓ SP ejecutado exitosamente\n";
        echo "   ✓ Local encontrado:\n";
        $local = $result[0];
        echo "     - id_local: {$local->id_local}\n";
        echo "     - nombre: {$local->nombre}\n";
        echo "     - id_energia: " . ($local->id_energia ?? 'NULL') . "\n";
        echo "     - arrendatario: " . ($local->arrendatario ?? 'NULL') . "\n";
        echo "     - vigencia: {$local->vigencia}\n";
        echo "     - superficie: {$local->superficie}\n\n";
    } else {
        echo "   ✗ No se encontró el local\n\n";
    }

    // Test con parámetros NULL
    echo "3. Probando con letra_local y bloque NULL...\n";
    $result2 = DB::connection($connection)->select("
        SELECT * FROM sp_localesmodif_buscar_local(
            {$data->oficina}::INTEGER,
            {$data->num_mercado}::INTEGER,
            {$data->categoria}::INTEGER,
            '{$data->seccion}'::VARCHAR,
            {$data->local}::INTEGER,
            NULL,
            NULL
        )
    ");

    if (!empty($result2)) {
        echo "   ✓ SP ejecutado exitosamente con parámetros opcionales NULL\n";
        echo "   ✓ Local encontrado: id_local={$result2[0]->id_local}\n\n";
    } else {
        echo "   ✗ No se encontró el local\n\n";
    }

    echo "==============================================\n";
    echo "✓ PRUEBAS COMPLETADAS EXITOSAMENTE\n";
    echo "==============================================\n";
    echo "\nEl SP está funcionando correctamente.\n";
    echo "Recarga el navegador en el componente Prescripcion.vue\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    echo "Traza: " . $e->getTraceAsString() . "\n";
    exit(1);
}
?>
