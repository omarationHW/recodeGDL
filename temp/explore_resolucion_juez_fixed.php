<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Explorando tablas relacionadas con Resolución de Juez...\n\n";

try {
    // Primero obtener los schemas existentes
    echo "📂 Schemas disponibles:\n";
    $schemas = DB::connection('pgsql')->select("
        SELECT schema_name
        FROM information_schema.schemata
        WHERE schema_name NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
        ORDER BY schema_name
    ");

    $schemaList = [];
    foreach ($schemas as $schema) {
        echo "  - {$schema->schema_name}\n";
        $schemaList[] = $schema->schema_name;
    }

    // Usar solo schemas que existen
    $validSchemas = ['catastro_gdl', 'comun', 'db_ingresos', 'multas_reglamentos', 'public'];

    echo "\n📊 Buscando tablas con 'resolucion' o 'juez'...\n\n";

    foreach ($validSchemas as $schema) {
        $tables = DB::connection('pgsql')->select("
            SELECT tablename
            FROM pg_tables
            WHERE schemaname = ?
            AND (
                tablename ILIKE '%resolucion%'
                OR tablename ILIKE '%juez%'
                OR tablename ILIKE '%resol%'
            )
            ORDER BY tablename
        ", [$schema]);

        if (count($tables) > 0) {
            echo "✓ Schema: $schema\n";
            foreach ($tables as $table) {
                echo "  - {$table->tablename}\n";

                // Ver estructura
                $cols = DB::connection('pgsql')->select("
                    SELECT column_name, data_type
                    FROM information_schema.columns
                    WHERE table_schema = ? AND table_name = ?
                    ORDER BY ordinal_position
                    LIMIT 10
                ", [$schema, $table->tablename]);

                $colNames = array_map(fn($c) => $c->column_name, $cols);
                echo "    Columnas: " . implode(', ', $colNames) . "\n";

                // Contar registros
                try {
                    $count = DB::connection('pgsql')->selectOne("
                        SELECT COUNT(*) as total FROM $schema.{$table->tablename}
                    ");
                    echo "    Registros: {$count->total}\n";

                    if ($count->total > 0 && $count->total < 1000) {
                        $samples = DB::connection('pgsql')->select("
                            SELECT * FROM $schema.{$table->tablename} LIMIT 2
                        ");

                        foreach ($samples as $i => $sample) {
                            $data = (array)$sample;
                            $preview = [];
                            $c = 0;
                            foreach ($data as $key => $value) {
                                if ($c >= 4) break;
                                $val = $value ?? 'NULL';
                                if (strlen($val) > 25) $val = substr($val, 0, 25) . '...';
                                $preview[] = "$key=$val";
                                $c++;
                            }
                            echo "      Ej" . ($i+1) . ": " . implode(', ', $preview) . "\n";
                        }
                    }
                } catch (Exception $e) {
                    echo "    Registros: Error\n";
                }

                echo "\n";
            }
        }
    }

    // Buscar en tablas de multas con columnas relacionadas
    echo "\n🔎 Buscando columnas 'resol' o 'juez' en tablas de multas...\n\n";

    $multasColumns = DB::connection('pgsql')->select("
        SELECT DISTINCT
            t.table_schema,
            t.table_name,
            c.column_name
        FROM information_schema.tables t
        JOIN information_schema.columns c ON c.table_schema = t.table_schema AND c.table_name = t.table_name
        WHERE t.table_schema IN ('catastro_gdl', 'comun', 'multas_reglamentos', 'public')
        AND t.table_type = 'BASE TABLE'
        AND t.table_name ILIKE '%multa%'
        AND (
            c.column_name ILIKE '%resol%'
            OR c.column_name ILIKE '%juez%'
        )
        ORDER BY t.table_schema, t.table_name, c.column_name
        LIMIT 30
    ");

    if (count($multasColumns) > 0) {
        $currentTable = '';
        foreach ($multasColumns as $col) {
            $tableKey = "{$col->table_schema}.{$col->table_name}";
            if ($tableKey !== $currentTable) {
                if ($currentTable !== '') echo "\n";
                echo "✓ {$tableKey}:\n";
                $currentTable = $tableKey;
            }
            echo "  - {$col->column_name}\n";
        }
    } else {
        echo "❌ No se encontraron columnas\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
