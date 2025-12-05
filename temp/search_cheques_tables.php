<?php

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== BÚSQUEDA DE TABLAS DE CHEQUES ===\n\n";

try {
    DB::connection('pgsql')->getPdo();
    echo "✅ Conectado a PostgreSQL\n\n";

    // Buscar tablas relacionadas con cheques
    echo "Buscando tablas con 'cheque', 'chq', 'pago'...\n";
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
            tablename ILIKE '%cheq%'
            OR tablename ILIKE '%chq%'
            OR tablename ILIKE '%pago%'
            OR tablename ILIKE '%cobr%'
        )
        ORDER BY schemaname, tablename
    ");

    foreach ($tables as $table) {
        echo "📊 {$table->schemaname}.{$table->tablename} ({$table->num_columns} columnas)\n";

        // Obtener columnas
        $columns = DB::connection('pgsql')->select("
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = '{$table->schemaname}'
            AND table_name = '{$table->tablename}'
            ORDER BY ordinal_position
            LIMIT 10
        ");

        echo "   Columnas: ";
        $cols = array_map(fn($c) => $c->column_name, $columns);
        echo implode(", ", $cols) . "\n";

        // Contar registros
        $count = DB::connection('pgsql')->selectOne("
            SELECT COUNT(*) as total
            FROM {$table->schemaname}.{$table->tablename}
        ");
        echo "   Registros: " . number_format($count->total) . "\n\n";
    }

    // Buscar en la tabla de multas si tiene información de cheques
    echo "\n" . str_repeat("=", 80) . "\n";
    echo "Revisando tabla comun.multas para información de cheques/pagos...\n";
    echo str_repeat("=", 80) . "\n\n";

    $multas_cols = DB::connection('pgsql')->select("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'multas'
        AND (
            column_name ILIKE '%pag%'
            OR column_name ILIKE '%cheq%'
            OR column_name ILIKE '%cobr%'
            OR column_name ILIKE '%forma%'
        )
        ORDER BY ordinal_position
    ");

    if (count($multas_cols) > 0) {
        echo "Columnas relacionadas con pagos en comun.multas:\n";
        foreach ($multas_cols as $col) {
            echo "  - {$col->column_name} ({$col->data_type})\n";
        }
    }

    // Obtener ejemplos de multas pagadas
    echo "\n" . str_repeat("=", 80) . "\n";
    echo "EJEMPLOS DE MULTAS PAGADAS (con información de pago):\n";
    echo str_repeat("=", 80) . "\n\n";

    $pagadas = DB::connection('pgsql')->select("
        SELECT
            id_multa,
            num_acta,
            axo_acta,
            contribuyente,
            total,
            cvepago,
            fecha_pago
        FROM comun.multas
        WHERE cvepago IS NOT NULL
        AND total > 0
        ORDER BY fecha_pago DESC
        LIMIT 10
    ");

    foreach ($pagadas as $i => $p) {
        $num = $i + 1;
        echo "$num. ID: {$p->id_multa} | Acta: {$p->num_acta}/{$p->axo_acta}\n";
        echo "   Contribuyente: {$p->contribuyente}\n";
        echo "   Total: $" . number_format($p->total, 2) . "\n";
        echo "   Cve Pago: {$p->cvepago}\n";
        echo "   Fecha Pago: {$p->fecha_pago}\n\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
