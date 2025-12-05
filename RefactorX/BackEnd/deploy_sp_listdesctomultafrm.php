<?php
/**
 * Script para desplegar el SP recaudadora_listdesctomultafrm usando Laravel
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== DESPLIEGUE DE SP: recaudadora_listdesctomultafrm ===\n\n";

$sql_file = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_listdesctomultafrm.sql';

if (!file_exists($sql_file)) {
    die("❌ Archivo SQL no encontrado: $sql_file\n");
}

$sql = file_get_contents($sql_file);

echo "📄 Archivo SQL: recaudadora_listdesctomultafrm.sql\n";
echo "🎯 Schema: multas_reglamentos\n";
echo "🗄️  Tabla origen: comun.h_descmultampal (101,794 registros)\n";
echo "🔗 JOIN: comun.multas\n\n";

try {
    DB::connection('pgsql')->getPdo();
    echo "✅ Conectado a PostgreSQL\n\n";

    echo "🚀 Desplegando SP...\n";
    DB::connection('pgsql')->unprepared($sql);
    echo "✅ SP desplegado exitosamente\n\n";

    echo "🔍 Verificando existencia del SP...\n";
    $sp_info = DB::connection('pgsql')->select("
        SELECT
            n.nspname as schema,
            p.proname as name,
            pg_catalog.pg_get_function_arguments(p.oid) as arguments
        FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE p.proname = 'recaudadora_listdesctomultafrm'
          AND n.nspname = 'multas_reglamentos'
    ");

    if (count($sp_info) > 0) {
        $sp = $sp_info[0];
        echo "✅ SP encontrado: {$sp->schema}.{$sp->name}({$sp->arguments})\n\n";
    } else {
        echo "⚠️  SP no encontrado\n\n";
        exit(1);
    }

    echo "🧪 Probando SP con DATOS REALES:\n\n";

    // Ejemplo 1: Sin filtro
    echo "=== EJEMPLO 1: Sin filtro (descuentos más recientes) ===\n";
    $result = DB::connection('pgsql')->select("
        SELECT * FROM multas_reglamentos.recaudadora_listdesctomultafrm('')
        LIMIT 5
    ");

    if (count($result) > 0) {
        echo "Descuentos encontrados: " . count($result) . "\n\n";
        foreach ($result as $i => $row) {
            $num = $i + 1;
            echo "Descuento #$num:\n";
            echo "  ID Multa: {$row->id_multa}\n";
            echo "  Acta: {$row->num_acta}/{$row->axo_acta}\n";
            echo "  Contribuyente: {$row->contribuyente}\n";
            echo "  Tipo Descuento: {$row->tipo_descto}\n";
            echo "  Valor Descuento: $" . number_format($row->valor_descto, 2) . "\n";
            echo "  Porcentaje: {$row->porcentaje}\n";
            echo "  Total Original: $" . number_format($row->total_original, 2) . "\n";
            echo "  Total con Descto: $" . number_format($row->total_con_descto, 2) . "\n";
            echo "  Estado: {$row->estado}\n";
            echo "  Folio: {$row->folio}\n";
            echo "  Fecha: {$row->fecha_movto}\n";
            echo "\n";
        }
    }

    echo "\n" . str_repeat("=", 80) . "\n\n";

    // Ejemplo 2: Buscar por ID de multa específico
    if (count($result) > 0) {
        $id_ejemplo = $result[0]->id_multa;
        echo "=== EJEMPLO 2: Buscar por ID Multa: {$id_ejemplo} ===\n";
        $result2 = DB::connection('pgsql')->select("
            SELECT * FROM multas_reglamentos.recaudadora_listdesctomultafrm(?)
            LIMIT 3
        ", [$id_ejemplo]);

        if (count($result2) > 0) {
            foreach ($result2 as $i => $row) {
                $num = $i + 1;
                echo "$num. Multa: {$row->id_multa} | Descuento: \$" . number_format($row->valor_descto, 2) . " | Estado: {$row->estado}\n";
            }
        }
    }

    echo "\n" . str_repeat("=", 80) . "\n\n";

    echo "✅ Despliegue completado exitosamente\n";
    echo "\n📋 RESUMEN:\n";
    echo "✓ SP: multas_reglamentos.recaudadora_listdesctomultafrm\n";
    echo "✓ Tabla: comun.h_descmultampal (101,794 registros)\n";
    echo "✓ Funcionalidad: Listado de descuentos de multas\n";
    echo "\n🎯 PRÓXIMO PASO:\n";
    echo "Abre: http://localhost:3000/multas_reglamentos/listdesctomultafrm\n\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\nStack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
?>
