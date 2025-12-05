<?php
/**
 * Script para desplegar el SP recaudadora_listanotificacionesfrm usando Laravel
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== DESPLIEGUE DE SP: recaudadora_listanotificacionesfrm ===\n\n";

// Leer el archivo SQL
$sql_file = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_listanotificacionesfrm.sql';

if (!file_exists($sql_file)) {
    die("❌ Archivo SQL no encontrado: $sql_file\n");
}

$sql = file_get_contents($sql_file);

echo "📄 Archivo SQL: recaudadora_listanotificacionesfrm.sql\n";
echo "📂 Ruta: $sql_file\n";
echo "🎯 Schema: multas_reglamentos\n";
echo "🗄️  Tabla origen: comun.multas\n\n";

try {
    // Conectar a la base de datos
    DB::connection('pgsql')->getPdo();
    echo "✅ Conectado a PostgreSQL\n\n";

    // Ejecutar el SQL
    echo "🚀 Desplegando SP...\n";
    DB::connection('pgsql')->unprepared($sql);
    echo "✅ SP recaudadora_listanotificacionesfrm desplegado exitosamente\n\n";

    // Verificar que el SP existe
    echo "🔍 Verificando existencia del SP...\n";
    $sp_info = DB::connection('pgsql')->select("
        SELECT
            n.nspname as schema,
            p.proname as name,
            pg_catalog.pg_get_function_arguments(p.oid) as arguments
        FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE p.proname = 'recaudadora_listanotificacionesfrm'
          AND n.nspname = 'multas_reglamentos'
    ");

    if (count($sp_info) > 0) {
        $sp = $sp_info[0];
        echo "✅ SP encontrado: {$sp->schema}.{$sp->name}({$sp->arguments})\n\n";
    } else {
        echo "⚠️  SP no encontrado después del despliegue\n\n";
        exit(1);
    }

    // Probar el SP con ejemplos
    echo "🧪 Probando el SP con ejemplos:\n\n";

    // Ejemplo 1: Notificaciones del año 2024, folios 1-100
    echo "=== EJEMPLO 1: Notificaciones año 2024, folios 1-100 ===\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM multas_reglamentos.recaudadora_listanotificacionesfrm(1, 2024, 1, 100, 'N', 'lote')
    ");

    if (count($result) > 0) {
        echo "Total de registros encontrados: " . count($result) . "\n";
        echo "Primeros 5 registros:\n\n";
        foreach (array_slice($result, 0, 5) as $i => $row) {
            $num = $i + 1;
            echo "$num. Dependencia: {$row->abrevia} - ";
            echo "Año: {$row->axo_acta} - ";
            echo "Num Acta: {$row->num_acta} - ";
            echo "Lote: {$row->num_lote} - ";
            echo "Folio Req: {$row->folioreq}\n";
            echo "   Contribuyente: {$row->contribuyente}\n";
            echo "   Total: $" . number_format($row->total, 2) . "\n";
            echo "\n";
        }
    } else {
        echo "No se encontraron registros para este rango\n";
    }

    echo "\n" . str_repeat("=", 80) . "\n\n";

    // Ejemplo 2: Requerimientos del año 2023, folios 1-50
    echo "=== EJEMPLO 2: Requerimientos año 2023, folios 1-50 ===\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM multas_reglamentos.recaudadora_listanotificacionesfrm(1, 2023, 1, 50, 'R', 'vigentes')
    ");

    if (count($result) > 0) {
        echo "Total de registros encontrados: " . count($result) . "\n";
        echo "Primeros 5 registros:\n\n";
        foreach (array_slice($result, 0, 5) as $i => $row) {
            $num = $i + 1;
            echo "$num. {$row->dependencia} - Acta: {$row->num_acta}/{$row->axo_acta} - Folio: {$row->folioreq}\n";
            echo "   Total: $" . number_format($row->total, 2) . "\n";
            echo "\n";
        }
    } else {
        echo "No se encontraron registros para este rango\n";
    }

    echo "\n" . str_repeat("=", 80) . "\n\n";

    // Ejemplo 3: Año 2025, folios amplios
    echo "=== EJEMPLO 3: Año 2025, folios 1-1000 (ordenado por dependencia) ===\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM multas_reglamentos.recaudadora_listanotificacionesfrm(1, 2025, 1, 1000, 'N', 'dependencia')
    ");

    if (count($result) > 0) {
        echo "Total de registros encontrados: " . count($result) . "\n";
        echo "Primeros 5 registros:\n\n";
        foreach (array_slice($result, 0, 5) as $i => $row) {
            $num = $i + 1;
            echo "$num. {$row->dependencia} ({$row->abrevia})\n";
            echo "   Acta: {$row->num_acta}/{$row->axo_acta}\n";
            echo "   Contribuyente: {$row->contribuyente}\n";
            echo "   Domicilio: " . substr($row->domicilio, 0, 40) . "\n";
            echo "   Total: $" . number_format($row->total, 2) . "\n";
            echo "\n";
        }
    } else {
        echo "No se encontraron registros para este rango\n";
    }

    echo "\n✅ Despliegue completado exitosamente\n";
    echo "\n📋 RESUMEN:\n";
    echo "✓ SP: multas_reglamentos.recaudadora_listanotificacionesfrm\n";
    echo "✓ Parámetros: reca, axo, inicio, final, tipo, orden\n";
    echo "✓ Tabla origen: comun.multas\n";
    echo "✓ Funcionalidad: Listado de notificaciones por rango de folios\n";
    echo "\n🎯 PRÓXIMO PASO:\n";
    echo "Abre el formulario en: http://localhost:3000/multas_reglamentos/listanotificacionesfrm\n";
    echo "Y prueba con los ejemplos descritos arriba\n\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\nStack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
?>
