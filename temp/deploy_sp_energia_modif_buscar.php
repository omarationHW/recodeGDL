<?php
/**
 * Script de despliegue: sp_energia_modif_buscar
 * Fecha: 2025-12-05
 */

chdir(__DIR__ . '/../RefactorX/BackEnd');
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "==============================================\n";
echo "DESPLIEGUE: sp_energia_modif_buscar\n";
echo "==============================================\n\n";

try {
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/EnergiaModif_sp_energia_modif_buscar.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("No se encuentra el archivo SQL: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);
    $connection = 'pgsql';

    echo "1. Conectando a la base de datos mercados...\n";
    DB::connection($connection)->getPdo();
    echo "   ✓ Conexión establecida\n\n";

    echo "2. Desplegando SP...\n";
    DB::connection($connection)->unprepared($sql);
    echo "   ✓ SP desplegado correctamente\n\n";

    // Verificar
    echo "3. Verificando el SP...\n";
    $verify = DB::connection($connection)->select("
        SELECT
            p.proname AS nombre_funcion,
            pg_get_function_arguments(p.oid) AS parametros
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
          AND p.proname = 'sp_energia_modif_buscar'
        ORDER BY p.oid DESC
        LIMIT 1;
    ");

    if (!empty($verify)) {
        echo "   ✓ Función: " . $verify[0]->nombre_funcion . "\n";
        echo "   ✓ Parámetros: " . $verify[0]->parametros . "\n\n";
    }

    // Probar el SP
    echo "4. Probando el SP...\n";
    $testData = DB::connection($connection)->select("
        SELECT l.oficina, l.num_mercado, l.categoria, l.seccion, l.local,
               l.letra_local, l.bloque, e.id_energia
        FROM publico.ta_11_locales l
        INNER JOIN publico.ta_11_energia e ON l.id_local = e.id_local
        WHERE l.oficina IS NOT NULL
          AND l.num_mercado IS NOT NULL
          AND l.categoria IS NOT NULL
          AND l.seccion IS NOT NULL
          AND l.local IS NOT NULL
        LIMIT 1
    ");

    if (!empty($testData)) {
        $data = $testData[0];
        echo "   Datos de prueba encontrados:\n";
        echo "   - Oficina: {$data->oficina}\n";
        echo "   - Mercado: {$data->num_mercado}\n";
        echo "   - Local: {$data->local}\n";
        echo "   - ID Energía: {$data->id_energia}\n\n";

        $letra = $data->letra_local ? "'{$data->letra_local}'::VARCHAR" : "NULL";
        $bloque = $data->bloque ? "'{$data->bloque}'::VARCHAR" : "NULL";

        $result = DB::connection($connection)->select("
            SELECT * FROM sp_energia_modif_buscar(
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
            echo "   ✓ Registro de energía encontrado:\n";
            $energia = $result[0];
            echo "     - id_energia: {$energia->id_energia}\n";
            echo "     - cve_consumo: {$energia->cve_consumo}\n";
            echo "     - cantidad: {$energia->cantidad}\n";
            echo "     - vigencia: {$energia->vigencia}\n\n";
        } else {
            echo "   ⚠ No se encontró el registro de energía\n\n";
        }
    } else {
        echo "   ⚠ No hay datos de prueba disponibles\n\n";
    }

    echo "==============================================\n";
    echo "✓ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
    echo "==============================================\n";
    echo "\nEl SP acepta 7 parámetros:\n";
    echo "  - p_oficina, p_num_mercado, p_categoria\n";
    echo "  - p_seccion, p_local, p_letra_local, p_bloque\n";
    echo "\nRecarga el navegador en EnergiaModif.vue\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    echo "Traza: " . $e->getTraceAsString() . "\n";
    exit(1);
}
?>
