<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== BÚSQUEDA DE TABLAS DE MULTAS 400 ===\n\n";

try {
    DB::connection('pgsql')->getPdo();
    echo "✅ Conectado a PostgreSQL\n\n";

    // Buscar tablas relacionadas con multas y artículo 400
    echo "Buscando tablas con '400', 'multa'...\n";
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
            tablename ILIKE '%400%'
            OR tablename ILIKE '%req%400%'
            OR tablename ILIKE '%multa%'
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
            LIMIT 15
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

    // Buscar en tabla de multas columnas relacionadas con artículo 400
    echo "\n" . str_repeat("=", 80) . "\n";
    echo "Buscando columnas en comun.multas relacionadas con artículo 400...\n";
    echo str_repeat("=", 80) . "\n\n";

    $multas_cols = DB::connection('pgsql')->select("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'multas'
        ORDER BY ordinal_position
    ");

    echo "Columnas en comun.multas:\n";
    foreach ($multas_cols as $col) {
        echo "  - {$col->column_name} ({$col->data_type})\n";
    }

    // Obtener ejemplos de multas
    echo "\n" . str_repeat("=", 80) . "\n";
    echo "EJEMPLOS DE MULTAS:\n";
    echo str_repeat("=", 80) . "\n\n";

    $ejemplos = DB::connection('pgsql')->select("
        SELECT
            id_multa,
            num_acta,
            axo_acta,
            contribuyente,
            total,
            multa,
            gastos,
            fecha_acta,
            id_dependencia,
            expediente
        FROM comun.multas
        WHERE total > 0
        ORDER BY fecha_acta DESC
        LIMIT 10
    ");

    if (count($ejemplos) > 0) {
        foreach ($ejemplos as $i => $m) {
            $num = $i + 1;
            echo "$num. ID: {$m->id_multa} | Acta: {$m->num_acta}/{$m->axo_acta}\n";
            echo "   Contribuyente: {$m->contribuyente}\n";
            echo "   Multa: $" . number_format($m->multa, 2) . "\n";
            echo "   Gastos: $" . number_format($m->gastos, 2) . "\n";
            echo "   Total: $" . number_format($m->total, 2) . "\n";
            echo "   Dependencia: {$m->id_dependencia} | Expediente: {$m->expediente}\n";
            echo "   Fecha: {$m->fecha_acta}\n\n";
        }
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
