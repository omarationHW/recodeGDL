<?php
// Script para buscar tablas relacionadas con registro histórico

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas con 'acta'
    echo "=== BUSCANDO TABLAS CON CAMPOS DE ACTAS ===\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT table_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND (
            column_name ILIKE '%acta%'
            OR column_name ILIKE '%num_acta%'
            OR column_name ILIKE '%noacta%'
        )
        ORDER BY table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.{$table['table_name']}");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            if ($count['total'] > 0) {
                echo "  ✓ {$table['table_name']} (" . number_format($count['total']) . " registros)\n";

                // Ver columnas con acta
                $stmt2 = $pdo->query("
                    SELECT column_name
                    FROM information_schema.columns
                    WHERE table_schema = 'public'
                    AND table_name = '{$table['table_name']}'
                    AND (
                        column_name ILIKE '%acta%'
                        OR column_name ILIKE '%contribuyente%'
                        OR column_name ILIKE '%domicilio%'
                        OR column_name ILIKE '%licencia%'
                        OR column_name ILIKE '%giro%'
                        OR column_name ILIKE '%calif%'
                        OR column_name ILIKE '%dependencia%'
                    )
                    ORDER BY ordinal_position
                ");
                $cols = $stmt2->fetchAll(PDO::FETCH_ASSOC);

                if (count($cols) > 0) {
                    echo "    Campos relevantes: " . implode(', ', array_column($cols, 'column_name')) . "\n\n";
                }
            }
        } catch (PDOException $e) {
            // Ignorar
        }
    }

    // Buscar tablas con 'contribuyente' y 'giro'
    echo "\n=== TABLAS CON 'contribuyente' Y 'giro' ===\n\n";

    $stmt = $pdo->query("
        SELECT t1.table_name
        FROM information_schema.columns t1
        INNER JOIN information_schema.columns t2
            ON t1.table_name = t2.table_name
            AND t1.table_schema = t2.table_schema
        WHERE t1.table_schema = 'public'
        AND t1.column_name ILIKE '%contribuyente%'
        AND t2.column_name ILIKE '%giro%'
        GROUP BY t1.table_name
        ORDER BY t1.table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.{$table['table_name']}");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            if ($count['total'] > 0 && $count['total'] < 5000000) {
                echo "  ✓ {$table['table_name']} (" . number_format($count['total']) . " registros)\n";
            }
        } catch (PDOException $e) {
            // Ignorar
        }
    }

    // Revisar tablas conocidas de multas que podrían tener histórico
    echo "\n\n=== ANALIZANDO TABLAS CONOCIDAS DE MULTAS ===\n\n";

    $tablas_multas = [
        'h_multasnvo',
        'multas_mpal_400',
        'multas_fed_400',
        'req_mul_400'
    ];

    foreach ($tablas_multas as $tabla) {
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.$tabla");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            echo "  ✓ $tabla (" . number_format($count['total']) . " registros)\n";

            // Ver estructura
            $stmt = $pdo->query("
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = 'public'
                AND table_name = '$tabla'
                ORDER BY ordinal_position
                LIMIT 15
            ");
            $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($cols as $col) {
                echo "    - {$col['column_name']}: {$col['data_type']}\n";
            }
            echo "\n";
        } catch (PDOException $e) {
            // Ignorar
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
