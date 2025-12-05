<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Explorando tablas relacionadas con Requerimientos DM...\n\n";

try {
    // Buscar tablas con 'req' o 'requerimiento' en el nombre
    $tables = DB::connection('pgsql')->select("
        SELECT
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
        FROM pg_tables
        WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
        AND (
            tablename ILIKE '%req%'
            OR tablename ILIKE '%requerimiento%'
            OR tablename ILIKE '%dm%'
        )
        ORDER BY schemaname, tablename
        LIMIT 50
    ");

    echo "📊 Tablas encontradas relacionadas con requerimientos:\n\n";

    foreach ($tables as $table) {
        echo "  {$table->schemaname}.{$table->tablename} ({$table->size})\n";
    }

    echo "\n\n";

    // Buscar específicamente en esquemas comunes
    $schemas = ['catastro_gdl', 'comun', 'comunX', 'db_ingresos', 'multas_reglamentos'];

    foreach ($schemas as $schema) {
        echo "🔎 Buscando en schema: $schema\n";

        $schemaTables = DB::connection('pgsql')->select("
            SELECT tablename
            FROM pg_tables
            WHERE schemaname = ?
            AND (
                tablename ILIKE '%req%'
                OR tablename ILIKE '%dm%'
            )
            ORDER BY tablename
        ", [$schema]);

        if (count($schemaTables) > 0) {
            foreach ($schemaTables as $t) {
                echo "  ✓ $schema.{$t->tablename}\n";

                // Obtener estructura y algunos datos
                $columns = DB::connection('pgsql')->select("
                    SELECT column_name, data_type
                    FROM information_schema.columns
                    WHERE table_schema = ? AND table_name = ?
                    ORDER BY ordinal_position
                    LIMIT 10
                ", [$schema, $t->tablename]);

                echo "    Columnas: ";
                $colNames = array_map(fn($c) => $c->column_name, $columns);
                echo implode(', ', $colNames) . "\n";

                // Contar registros
                try {
                    $count = DB::connection('pgsql')->select("
                        SELECT COUNT(*) as total
                        FROM $schema.{$t->tablename}
                    ");
                    echo "    Registros: " . $count[0]->total . "\n";
                } catch (Exception $e) {
                    echo "    Registros: Error al contar\n";
                }

                echo "\n";
            }
        }
    }

    // Buscar tablas que tengan columnas relacionadas con cuenta y ejercicio
    echo "\n🎯 Buscando tablas con columnas 'cuenta' y 'ejercicio'...\n\n";

    $tablesWithCuenta = DB::connection('pgsql')->select("
        SELECT DISTINCT
            t.table_schema,
            t.table_name,
            string_agg(c.column_name, ', ') as columns
        FROM information_schema.tables t
        JOIN information_schema.columns c ON c.table_schema = t.table_schema AND c.table_name = t.table_name
        WHERE t.table_schema NOT IN ('pg_catalog', 'information_schema')
        AND t.table_type = 'BASE TABLE'
        AND (
            c.column_name ILIKE '%cuenta%'
            OR c.column_name ILIKE '%ejercicio%'
            OR c.column_name ILIKE '%axo%'
        )
        AND (
            t.table_name ILIKE '%req%'
            OR t.table_name ILIKE '%dm%'
        )
        GROUP BY t.table_schema, t.table_name
        ORDER BY t.table_schema, t.table_name
        LIMIT 20
    ");

    foreach ($tablesWithCuenta as $table) {
        echo "  {$table->table_schema}.{$table->table_name}\n";
        echo "    Columnas relevantes: {$table->columns}\n";

        // Obtener algunos datos de ejemplo
        try {
            $samples = DB::connection('pgsql')->select("
                SELECT *
                FROM {$table->table_schema}.{$table->table_name}
                LIMIT 3
            ");

            if (count($samples) > 0) {
                echo "    Ejemplos:\n";
                foreach ($samples as $i => $sample) {
                    echo "      " . ($i+1) . ". ";
                    $sampleData = (array)$sample;
                    $preview = [];
                    $count = 0;
                    foreach ($sampleData as $key => $value) {
                        if ($count >= 5) break;
                        $preview[] = "$key=$value";
                        $count++;
                    }
                    echo implode(', ', $preview) . "\n";
                }
            }
        } catch (Exception $e) {
            // Ignorar errores de acceso
        }

        echo "\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
