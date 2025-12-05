<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== BÚSQUEDA DE TABLAS DE REQUERIMIENTOS ===\n\n";

try {
    DB::connection('pgsql')->getPdo();
    echo "✅ Conectado a PostgreSQL\n\n";

    // Buscar tablas relacionadas con requerimientos
    echo "Buscando tablas con 'req', 'requer'...\n";
    echo str_repeat("=", 80) . "\n\n";

    $tables = DB::connection('pgsql')->select("
        SELECT
            schemaname,
            tablename,
            (SELECT COUNT(*) FROM information_schema.columns
             WHERE table_schema = schemaname
             AND table_name = tablename) as num_columns
        FROM pg_tables
        WHERE schemaname IN ('comun', 'comunX', 'db_ingresos', 'multas_reglamentos', 'public')
        AND (
            tablename ILIKE '%req%'
            OR tablename ILIKE '%requer%'
        )
        ORDER BY schemaname, tablename
    ");

    foreach ($tables as $table) {
        echo "📊 {$table->schemaname}.{$table->tablename} ({$table->num_columns} columnas)\n";

        // Obtener columnas clave
        $columns = DB::connection('pgsql')->select("
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = '{$table->schemaname}'
            AND table_name = '{$table->tablename}'
            ORDER BY ordinal_position
            LIMIT 20
        ");

        echo "   Columnas: ";
        $cols = array_map(fn($c) => $c->column_name, $columns);
        echo implode(", ", $cols) . "\n";

        // Contar registros
        try {
            $count = DB::connection('pgsql')->selectOne("
                SELECT COUNT(*) as total
                FROM {$table->schemaname}.{$table->tablename}
            ");
            echo "   Registros: " . number_format($count->total) . "\n\n";
        } catch (Exception $e) {
            echo "   Registros: Error al contar\n\n";
        }
    }

    // Buscar ejemplo de requerimiento
    echo "\n" . str_repeat("=", 80) . "\n";
    echo "EJEMPLOS DE REQUERIMIENTOS:\n";
    echo str_repeat("=", 80) . "\n\n";

    // Intentar varias tablas comunes
    $possible_tables = [
        'comun.requerimientos',
        'comun.ta_requerimientos',
        'db_ingresos.requerimientos',
        'multas_reglamentos.requerimientos'
    ];

    foreach ($possible_tables as $table_name) {
        try {
            echo "Intentando: {$table_name}...\n";
            $ejemplos = DB::connection('pgsql')->select("
                SELECT * FROM {$table_name}
                LIMIT 3
            ");

            if (count($ejemplos) > 0) {
                echo "✅ Tabla encontrada!\n\n";
                foreach ($ejemplos as $i => $ej) {
                    $num = $i + 1;
                    echo "Ejemplo $num:\n";
                    print_r($ej);
                    echo "\n";
                }
                break;
            }
        } catch (Exception $e) {
            echo "❌ No existe\n\n";
        }
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
