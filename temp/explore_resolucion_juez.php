<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Explorando tablas relacionadas con Resolución de Juez...\n\n";

try {
    // Buscar tablas con 'resolucion' o 'juez'
    echo "📊 Buscando tablas con 'resolucion' o 'juez'...\n\n";

    $tables = DB::connection('pgsql')->select("
        SELECT
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
        FROM pg_tables
        WHERE schemaname IN ('catastro_gdl', 'comun', 'comunX', 'db_ingresos', 'multas_reglamentos', 'public')
        AND (
            tablename ILIKE '%resolucion%'
            OR tablename ILIKE '%juez%'
            OR tablename ILIKE '%resol%'
        )
        ORDER BY schemaname, tablename
        LIMIT 30
    ");

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "✓ {$table->schemaname}.{$table->tablename} ({$table->size})\n";

            // Ver estructura
            $cols = DB::connection('pgsql')->select("
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = ? AND table_name = ?
                ORDER BY ordinal_position
                LIMIT 15
            ", [$table->schemaname, $table->tablename]);

            $colNames = array_map(fn($c) => "{$c->column_name} ({$c->data_type})", $cols);
            echo "  Columnas: " . implode(', ', $colNames) . "\n";

            // Contar registros
            try {
                $count = DB::connection('pgsql')->selectOne("
                    SELECT COUNT(*) as total FROM {$table->schemaname}.{$table->tablename}
                ");
                echo "  Registros: {$count->total}\n";

                // Si tiene registros, obtener ejemplos
                if ($count->total > 0) {
                    $samples = DB::connection('pgsql')->select("
                        SELECT * FROM {$table->schemaname}.{$table->tablename}
                        LIMIT 2
                    ");

                    if (count($samples) > 0) {
                        echo "  Ejemplos:\n";
                        foreach ($samples as $i => $sample) {
                            $data = (array)$sample;
                            $preview = [];
                            $count = 0;
                            foreach ($data as $key => $value) {
                                if ($count >= 5) break;
                                $displayValue = $value ?? 'NULL';
                                if (strlen($displayValue) > 30) {
                                    $displayValue = substr($displayValue, 0, 30) . '...';
                                }
                                $preview[] = "$key=$displayValue";
                                $count++;
                            }
                            echo "    " . ($i+1) . ". " . implode(', ', $preview) . "\n";
                        }
                    }
                }
            } catch (Exception $e) {
                echo "  Registros: Error al consultar\n";
            }

            echo "\n";
        }
    } else {
        echo "❌ No se encontraron tablas\n\n";
    }

    // Buscar en tablas de multas que puedan tener resoluciones
    echo "\n🔎 Buscando en tablas de multas con columnas relacionadas...\n\n";

    $multasTables = DB::connection('pgsql')->select("
        SELECT DISTINCT
            t.table_schema,
            t.table_name,
            string_agg(c.column_name, ', ') as columns
        FROM information_schema.tables t
        JOIN information_schema.columns c ON c.table_schema = t.table_schema AND c.table_name = t.table_name
        WHERE t.table_schema IN ('catastro_gdl', 'comun', 'multas_reglamentos', 'public')
        AND t.table_type = 'BASE TABLE'
        AND (
            t.table_name ILIKE '%multa%'
            OR t.table_name ILIKE '%req%'
        )
        AND (
            c.column_name ILIKE '%resol%'
            OR c.column_name ILIKE '%juez%'
            OR c.column_name ILIKE '%folio%'
        )
        GROUP BY t.table_schema, t.table_name
        ORDER BY t.table_schema, t.table_name
        LIMIT 20
    ");

    if (count($multasTables) > 0) {
        foreach ($multasTables as $table) {
            echo "✓ {$table->table_schema}.{$table->table_name}\n";
            echo "  Columnas relevantes: {$table->columns}\n";

            // Obtener un ejemplo
            try {
                $sample = DB::connection('pgsql')->select("
                    SELECT * FROM {$table->table_schema}.{$table->table_name}
                    LIMIT 1
                ");

                if (count($sample) > 0) {
                    $data = (array)$sample[0];
                    echo "  Ejemplo:\n";
                    $count = 0;
                    foreach ($data as $key => $value) {
                        if ($count >= 8) break;
                        $displayValue = $value ?? 'NULL';
                        if (strlen($displayValue) > 40) {
                            $displayValue = substr($displayValue, 0, 40) . '...';
                        }
                        echo "    {$key}: {$displayValue}\n";
                        $count++;
                    }
                }
            } catch (Exception $e) {
                // Ignorar errores
            }

            echo "\n";
        }
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
