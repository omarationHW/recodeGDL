<?php
/**
 * Script para desplegar el SP recaudadora_listana usando Laravel
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== DESPLIEGUE DE SP: recaudadora_listana ===\n\n";

// Leer el archivo SQL
$sql_file = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_listana.sql';

if (!file_exists($sql_file)) {
    die("❌ Archivo SQL no encontrado: $sql_file\n");
}

$sql = file_get_contents($sql_file);

echo "📄 Archivo SQL: recaudadora_listana.sql\n";
echo "📂 Ruta: $sql_file\n";
echo "🎯 Schema: db_ingresos\n";
echo "🗄️  Tabla origen: comun.multas\n\n";

try {
    // Conectar a la base de datos
    DB::connection('pgsql')->getPdo();
    echo "✅ Conectado a PostgreSQL\n\n";

    // Ejecutar el SQL
    echo "🚀 Desplegando SP...\n";
    DB::connection('pgsql')->unprepared($sql);
    echo "✅ SP recaudadora_listana desplegado exitosamente\n\n";

    // Verificar que el SP existe
    echo "🔍 Verificando existencia del SP...\n";
    $sp_info = DB::connection('pgsql')->select("
        SELECT
            n.nspname as schema,
            p.proname as name,
            pg_catalog.pg_get_function_arguments(p.oid) as arguments
        FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE p.proname = 'recaudadora_listana'
          AND n.nspname = 'db_ingresos'
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

    // Ejemplo 1: Sin filtro
    echo "=== EJEMPLO 1: Sin filtro (primeros 5 registros) ===\n";
    $result = DB::connection('pgsql')->select("SELECT * FROM db_ingresos.recaudadora_listana('', 0, 5)");

    if (count($result) > 0) {
        $total = $result[0]->total_count;
        echo "Total de registros en BD: " . number_format($total) . "\n";
        echo "Primeros registros:\n";
        foreach ($result as $i => $row) {
            $num = $i + 1;
            echo "\n$num. {$row->folio}\n";
            echo "   Fecha: {$row->fecha_acta}\n";
            echo "   Contribuyente: {$row->contribuyente}\n";
            echo "   Domicilio: {$row->domicilio}\n";
            echo "   Dependencia: {$row->dependencia}\n";
            echo "   Total: $" . number_format($row->total, 2) . "\n";
            echo "   Estado: {$row->estado}\n";
        }
    } else {
        echo "No hay registros\n";
    }

    echo "\n\n=== EJEMPLO 2: Buscar por año (filtro: '2024') ===\n";
    $result = DB::connection('pgsql')->select("SELECT * FROM db_ingresos.recaudadora_listana('2024', 0, 5)");

    if (count($result) > 0) {
        $total = $result[0]->total_count;
        echo "Total que coinciden con '2024': " . number_format($total) . "\n";
        echo "Registros encontrados:\n";
        foreach ($result as $i => $row) {
            $num = $i + 1;
            echo "\n$num. {$row->folio}\n";
            echo "   Contribuyente: {$row->contribuyente}\n";
            echo "   Dependencia: {$row->dependencia}\n";
            echo "   Total: $" . number_format($row->total, 2) . "\n";
            echo "   Estado: {$row->estado}\n";
        }
    } else {
        echo "No hay registros con ese filtro\n";
    }

    echo "\n\n=== EJEMPLO 3: Buscar por nombre (filtro: 'MARIA') ===\n";
    $result = DB::connection('pgsql')->select("SELECT * FROM db_ingresos.recaudadora_listana('MARIA', 0, 5)");

    if (count($result) > 0) {
        $total = $result[0]->total_count;
        echo "Total que coinciden con 'MARIA': " . number_format($total) . "\n";
        echo "Registros encontrados:\n";
        foreach ($result as $i => $row) {
            $num = $i + 1;
            echo "\n$num. {$row->folio}\n";
            echo "   Contribuyente: {$row->contribuyente}\n";
            echo "   Domicilio: " . substr($row->domicilio, 0, 40) . "\n";
            echo "   Dependencia: {$row->dependencia}\n";
            echo "   Zona/Subzona: {$row->zona_subzona}\n";
            echo "   Total: $" . number_format($row->total, 2) . "\n";
            echo "   Tipo: {$row->tipo}\n";
            echo "   Estado: {$row->estado}\n";
        }
    } else {
        echo "No hay registros con ese filtro\n";
    }

    echo "\n\n✅ Despliegue completado exitosamente\n";
    echo "\n📋 RESUMEN:\n";
    echo "✓ SP: db_ingresos.recaudadora_listana\n";
    echo "✓ Parámetros: p_filtro (VARCHAR), p_offset (INTEGER), p_limit (INTEGER)\n";
    echo "✓ Tabla origen: comun.multas\n";
    echo "✓ Funcionalidad: Listado analítico con paginación server-side\n";
    echo "\n🎯 PRÓXIMO PASO:\n";
    echo "Abre el formulario en: http://localhost:5173/multas_reglamentos/ListAna\n";
    echo "Y prueba con los filtros mencionados arriba\n\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\nStack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
?>
