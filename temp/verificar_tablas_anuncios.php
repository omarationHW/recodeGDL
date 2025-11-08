<?php
// VERIFICAR TABLAS DE GRUPOS DE ANUNCIOS

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\\Contracts\\Console\\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "<pre>";
echo "====================================\n";
echo "VERIFICANDO TABLAS DE ANUNCIOS\n";
echo "====================================\n\n";

try {
    DB::purge('pgsql');
    config(['database.connections.pgsql.database' => 'padron_licencias']);
    DB::reconnect('pgsql');

    echo "Conectado a: " . DB::connection()->getDatabaseName() . "\n\n";

    // Buscar tablas con 'anun' o 'grupo'
    echo "Buscando tablas relacionadas con grupos de anuncios...\n\n";

    $tables = DB::select("
        SELECT table_schema, table_name,
               pg_size_pretty(pg_total_relation_size(quote_ident(table_schema)||'.'||quote_ident(table_name))) AS size
        FROM information_schema.tables
        WHERE table_schema IN ('public', 'comun', 'publicX', 'comunX')
          AND (table_name LIKE '%anun%grupo%' OR table_name LIKE '%grupo%anun%')
        ORDER BY table_schema, table_name
    ");

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "✓ {$table->table_schema}.{$table->table_name} ({$table->size})\n";

            // Contar registros
            try {
                $count = DB::select("SELECT COUNT(*) as total FROM {$table->table_schema}.{$table->table_name}");
                echo "  Registros: " . number_format($count[0]->total) . "\n";

                // Mostrar estructura
                $columns = DB::select("
                    SELECT column_name, data_type
                    FROM information_schema.columns
                    WHERE table_schema = ? AND table_name = ?
                    ORDER BY ordinal_position
                ", [$table->table_schema, $table->table_name]);

                echo "  Columnas:\n";
                foreach ($columns as $col) {
                    echo "    - {$col->column_name} ({$col->data_type})\n";
                }
                echo "\n";
            } catch (Exception $e) {
                echo "  Error: " . $e->getMessage() . "\n\n";
            }
        }
    } else {
        echo "⚠️ NO se encontraron tablas con 'anun' y 'grupo'\n\n";
    }

    // Buscar tabla anuncios
    echo "------------------------------------\n";
    echo "Verificando tabla 'anuncios'...\n\n";

    $anuncios = DB::select("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name = 'anuncios'
        ORDER BY table_schema
    ");

    foreach ($anuncios as $t) {
        echo "✓ {$t->table_schema}.{$t->table_name}\n";
        $count = DB::select("SELECT COUNT(*) as total FROM {$t->table_schema}.{$t->table_name}");
        echo "  Registros: " . number_format($count[0]->total) . "\n\n";
    }

    // Buscar SPs existentes
    echo "------------------------------------\n";
    echo "Verificando SPs de grupos de anuncios...\n\n";

    $sps = DB::select("
        SELECT routine_schema, routine_name
        FROM information_schema.routines
        WHERE routine_type = 'FUNCTION'
          AND (LOWER(routine_name) LIKE '%anun%grupo%' OR LOWER(routine_name) LIKE '%grupo%anun%')
        ORDER BY routine_schema, routine_name
    ");

    if (count($sps) > 0) {
        foreach ($sps as $sp) {
            echo "✓ {$sp->routine_schema}.{$sp->routine_name}\n";
        }
    } else {
        echo "⚠️ NO se encontraron SPs de grupos de anuncios\n";
    }

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
}

echo "</pre>";
