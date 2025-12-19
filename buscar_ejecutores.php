<?php
// Script para buscar tablas relacionadas con ejecutores

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas con 'ejecutor'
    echo "=== BUSCANDO TABLAS CON 'ejecutor' ===\n\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename ILIKE '%ejecutor%'
        ORDER BY tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            try {
                $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.{$table['tablename']}");
                $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
                echo "  ✓ {$table['tablename']} ({$count['total']} registros)\n";
            } catch (PDOException $e) {
                echo "  ✗ {$table['tablename']} (error al contar)\n";
            }
        }
    } else {
        echo "  No se encontraron tablas.\n";
    }

    // Buscar tablas con campos relevantes
    echo "\n\n=== TABLAS CON CAMPOS DE RFC, NOMBRE, CATEGORIA ===\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT table_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND (
            column_name ILIKE '%rfc%'
            OR column_name ILIKE '%categoria%'
            OR column_name ILIKE '%vigencia%'
        )
        ORDER BY table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.{$table['table_name']}");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            if ($count['total'] > 0 && $count['total'] < 100000) {
                // Ver columnas relevantes
                $stmt2 = $pdo->query("
                    SELECT column_name
                    FROM information_schema.columns
                    WHERE table_schema = 'public'
                    AND table_name = '{$table['table_name']}'
                    AND (
                        column_name ILIKE '%rfc%'
                        OR column_name ILIKE '%nombre%'
                        OR column_name ILIKE '%categoria%'
                        OR column_name ILIKE '%vigencia%'
                        OR column_name ILIKE '%cve%'
                    )
                    ORDER BY ordinal_position
                ");
                $cols = $stmt2->fetchAll(PDO::FETCH_ASSOC);

                if (count($cols) > 2) {
                    echo "  ✓ {$table['table_name']} (" . number_format($count['total']) . " registros)\n";
                    echo "    Campos relevantes: " . implode(', ', array_column($cols, 'column_name')) . "\n\n";
                }
            }
        } catch (PDOException $e) {
            // Ignorar
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
