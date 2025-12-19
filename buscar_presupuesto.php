<?php
// Script para buscar tablas relacionadas con presupuesto

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas con 'presupuesto' o 'presup'
    echo "=== BUSCANDO TABLAS CON 'PRESUPUESTO' O 'PRESUP' ===\n\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND (tablename ILIKE '%presupuesto%' OR tablename ILIKE '%presup%')
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

    // Buscar tablas con 'ejercicio' o 'ingreso'
    echo "\n\n=== BUSCANDO TABLAS CON 'EJERCICIO' O 'INGRESO' ===\n\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND (tablename ILIKE '%ejercicio%' OR tablename ILIKE '%ingreso%')
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

    // Buscar tablas con campo 'ejercicio'
    echo "\n\n=== BUSCANDO TABLAS CON CAMPO 'ejercicio' ===\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT table_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND column_name = 'ejercicio'
        ORDER BY table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.{$table['table_name']}");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            if ($count['total'] > 0 && $count['total'] < 100000) {
                echo "  ✓ {$table['table_name']} (" . number_format($count['total']) . " registros)\n";
            }
        } catch (PDOException $e) {
            // Ignorar
        }
    }

    // Buscar tablas con campos de meses (enero, febrero, etc.)
    echo "\n\n=== BUSCANDO TABLAS CON CAMPOS DE MESES ===\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT table_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND column_name IN ('enero', 'febrero', 'marzo')
        ORDER BY table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            try {
                $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.{$table['table_name']}");
                $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
                echo "  ✓ {$table['table_name']} (" . number_format($count['total']) . " registros)\n";
            } catch (PDOException $e) {
                echo "  ✗ {$table['table_name']} (error)\n";
            }
        }
    } else {
        echo "  No se encontraron tablas con campos de meses.\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
