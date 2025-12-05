<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Explorando tablas para RequerxCvecat...\n\n";

try {
    // Verificar si h_reqpredial tiene cvecat
    echo "📊 Verificando columnas de catastro_gdl.h_reqpredial...\n\n";

    $columns = DB::connection('pgsql')->select("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'h_reqpredial'
        AND column_name ILIKE '%cvecat%'
        ORDER BY ordinal_position
    ");

    if (count($columns) > 0) {
        echo "✅ Columnas con 'cvecat' encontradas:\n";
        foreach ($columns as $col) {
            echo "  - {$col->column_name} ({$col->data_type})\n";
        }
    } else {
        echo "❌ No se encontró columna 'cvecat'\n";
    }

    echo "\n📝 Obteniendo ejemplos de la tabla h_reqpredial...\n\n";

    // Obtener algunos registros de ejemplo
    $samples = DB::connection('pgsql')->select("
        SELECT *
        FROM catastro_gdl.h_reqpredial
        ORDER BY cvereq DESC
        LIMIT 3
    ");

    foreach ($samples as $i => $sample) {
        echo "═════════════════════════════════════════════════════════════\n";
        echo "EJEMPLO " . ($i + 1) . ":\n";
        echo "═════════════════════════════════════════════════════════════\n";

        $data = (array)$sample;
        foreach ($data as $key => $value) {
            if (strlen($key) <= 20) {  // Solo mostrar nombres de columna cortos
                $displayValue = $value ?? 'NULL';
                if (strlen($displayValue) > 50) {
                    $displayValue = substr($displayValue, 0, 50) . '...';
                }
                echo "  {$key}: {$displayValue}\n";
            }
        }
        echo "\n";
    }

    // Buscar otras tablas con cvecat
    echo "\n🔎 Buscando otras tablas con columna 'cvecat'...\n\n";

    $tablesWithCvecat = DB::connection('pgsql')->select("
        SELECT DISTINCT
            t.table_schema,
            t.table_name,
            c.column_name
        FROM information_schema.tables t
        JOIN information_schema.columns c ON c.table_schema = t.table_schema AND c.table_name = t.table_name
        WHERE t.table_schema IN ('catastro_gdl', 'comun', 'comunX', 'db_ingresos', 'multas_reglamentos', 'public')
        AND t.table_type = 'BASE TABLE'
        AND c.column_name ILIKE '%cvecat%'
        AND (t.table_name ILIKE '%req%' OR t.table_name ILIKE '%requer%')
        ORDER BY t.table_schema, t.table_name
        LIMIT 20
    ");

    if (count($tablesWithCvecat) > 0) {
        foreach ($tablesWithCvecat as $table) {
            echo "  ✓ {$table->table_schema}.{$table->table_name} → columna: {$table->column_name}\n";

            // Obtener un registro de ejemplo
            try {
                $sample = DB::connection('pgsql')->select("
                    SELECT * FROM {$table->table_schema}.{$table->table_name}
                    WHERE {$table->column_name} IS NOT NULL
                    LIMIT 1
                ");

                if (count($sample) > 0) {
                    $sampleData = (array)$sample[0];
                    echo "    Ejemplo: ";
                    $preview = [];
                    $count = 0;
                    foreach ($sampleData as $key => $value) {
                        if ($count >= 5) break;
                        $preview[] = "$key=" . (strlen($value) > 20 ? substr($value, 0, 20) . '...' : $value);
                        $count++;
                    }
                    echo implode(', ', $preview) . "\n";
                }
            } catch (Exception $e) {
                // Ignorar errores
            }
            echo "\n";
        }
    } else {
        echo "  No se encontraron otras tablas con 'cvecat' en requerimientos\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
