<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Buscando tablas con clave catastral...\n\n";

try {
    // Buscar tablas con columnas relacionadas con clave catastral
    echo "📊 Buscando columnas con 'clave' y 'catastral'...\n\n";

    $tables = DB::connection('pgsql')->select("
        SELECT DISTINCT
            t.table_schema,
            t.table_name,
            string_agg(c.column_name, ', ') as columns
        FROM information_schema.tables t
        JOIN information_schema.columns c ON c.table_schema = t.table_schema AND c.table_name = t.table_name
        WHERE t.table_schema IN ('catastro_gdl', 'comun', 'comunX', 'public')
        AND t.table_type = 'BASE TABLE'
        AND (
            c.column_name ILIKE '%cvecat%'
            OR c.column_name ILIKE '%clave%catastral%'
            OR c.column_name ILIKE '%clavecat%'
            OR t.table_name IN ('predios', 'predio', 'h_reqpredial', 'req_400')
        )
        GROUP BY t.table_schema, t.table_name
        ORDER BY t.table_schema, t.table_name
        LIMIT 30
    ");

    foreach ($tables as $table) {
        echo "✓ {$table->table_schema}.{$table->table_name}\n";
        echo "  Columnas: {$table->columns}\n";

        // Contar registros
        try {
            $count = DB::connection('pgsql')->selectOne("
                SELECT COUNT(*) as total FROM {$table->table_schema}.{$table->table_name}
            ");
            echo "  Registros: {$count->total}\n";
        } catch (Exception $e) {
            echo "  Registros: Error\n";
        }
        echo "\n";
    }

    // Buscar en req_400 específicamente (tabla de requerimientos del 400)
    echo "\n📋 Verificando tabla catastro_gdl.req_400...\n\n";

    try {
        $req400Cols = DB::connection('pgsql')->select("
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = 'catastro_gdl'
            AND table_name = 'req_400'
            ORDER BY ordinal_position
            LIMIT 20
        ");

        if (count($req400Cols) > 0) {
            echo "Columnas de req_400:\n";
            foreach ($req400Cols as $col) {
                echo "  - {$col->column_name} ({$col->data_type})\n";
            }

            // Obtener ejemplos
            echo "\n📝 Ejemplos de req_400:\n\n";
            $samples = DB::connection('pgsql')->select("
                SELECT * FROM catastro_gdl.req_400
                ORDER BY cvereq DESC
                LIMIT 3
            ");

            foreach ($samples as $i => $sample) {
                echo "Ejemplo " . ($i + 1) . ":\n";
                $data = (array)$sample;
                $count = 0;
                foreach ($data as $key => $value) {
                    if ($count >= 10) break;
                    $displayValue = $value ?? 'NULL';
                    if (strlen($displayValue) > 50) {
                        $displayValue = substr($displayValue, 0, 50) . '...';
                    }
                    echo "  {$key}: {$displayValue}\n";
                    $count++;
                }
                echo "\n";
            }
        }
    } catch (Exception $e) {
        echo "❌ Error al consultar req_400: " . $e->getMessage() . "\n";
    }

    // Buscar tabla de predios
    echo "\n🏠 Buscando tablas de predios...\n\n";

    $predioTables = DB::connection('pgsql')->select("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname IN ('catastro_gdl', 'comun', 'public')
        AND (tablename ILIKE '%predio%' OR tablename ILIKE '%catastral%' OR tablename ILIKE '%padrn%')
        ORDER BY schemaname, tablename
        LIMIT 20
    ");

    foreach ($predioTables as $table) {
        echo "✓ {$table->schemaname}.{$table->tablename}\n";

        // Ver estructura
        $cols = DB::connection('pgsql')->select("
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = ? AND table_name = ?
            ORDER BY ordinal_position
            LIMIT 15
        ", [$table->schemaname, $table->tablename]);

        $colNames = array_map(fn($c) => $c->column_name, $cols);
        echo "  Columnas: " . implode(', ', $colNames) . "\n\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
