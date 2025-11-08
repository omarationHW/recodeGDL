<?php
// VERIFICAR TABLAS DE AGENDA DE VISITAS

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\\Contracts\\Console\\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "<pre>";
echo "====================================\n";
echo "VERIFICANDO TABLAS AGENDA VISITAS\n";
echo "====================================\n\n";

try {
    DB::purge('pgsql');
    config(['database.connections.pgsql.database' => 'padron_licencias']);
    DB::reconnect('pgsql');

    echo "Conectado a: " . DB::connection()->getDatabaseName() . "\n";
    echo "Servidor: 192.168.6.146\n\n";

    // Lista de tablas a buscar
    $tablasNecesarias = [
        'tramites_visitas',
        'c_dep_horario',
        'c_dependencias',
        'tramites'
    ];

    foreach ($tablasNecesarias as $tabla) {
        echo "Buscando tabla: {$tabla}...\n";

        $result = DB::select("
            SELECT table_schema, table_name,
                   pg_size_pretty(pg_total_relation_size(quote_ident(table_schema)||'.'||quote_ident(table_name))) AS size
            FROM information_schema.tables
            WHERE table_name = ?
            ORDER BY table_schema
        ", [$tabla]);

        if (count($result) > 0) {
            foreach ($result as $t) {
                echo "  ✓ ENCONTRADA: {$t->table_schema}.{$t->table_name} ({$t->size})\n";

                // Contar registros
                try {
                    $count = DB::select("SELECT COUNT(*) as total FROM {$t->table_schema}.{$t->table_name}");
                    echo "    Registros: " . number_format($count[0]->total) . "\n";
                } catch (Exception $e) {
                    echo "    Error al contar: " . $e->getMessage() . "\n";
                }

                // Mostrar columnas
                $columns = DB::select("
                    SELECT column_name, data_type
                    FROM information_schema.columns
                    WHERE table_schema = ? AND table_name = ?
                    ORDER BY ordinal_position
                    LIMIT 10
                ", [$t->table_schema, $t->table_name]);

                echo "    Columnas principales:\n";
                foreach ($columns as $col) {
                    echo "      - {$col->column_name} ({$col->data_type})\n";
                }
            }
        } else {
            echo "  ✗ NO ENCONTRADA\n";
        }
        echo "\n";
    }

    // Verificar SPs existentes
    echo "------------------------------------\n";
    echo "Verificando SPs existentes...\n\n";

    $sps = [
        'fn_dialetra',
        'sp_get_dependencias',
        'sp_get_agenda_visitas'
    ];

    foreach ($sps as $sp) {
        $result = DB::select("
            SELECT routine_schema, routine_name
            FROM information_schema.routines
            WHERE routine_type = 'FUNCTION'
              AND routine_name = ?
        ", [$sp]);

        if (count($result) > 0) {
            foreach ($result as $r) {
                echo "✓ SP existe: {$r->routine_schema}.{$r->routine_name}\n";
            }
        } else {
            echo "✗ SP NO existe: {$sp}\n";
        }
    }

    echo "\n====================================\n";
    echo "RESUMEN\n";
    echo "====================================\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    echo $e->getTraceAsString();
}

echo "</pre>";
