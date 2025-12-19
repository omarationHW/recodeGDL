<?php
// Script para buscar tablas relacionadas con proyectos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas con 'proyecto'
    echo "=== BUSCANDO TABLAS CON 'PROYECTO' ===\n\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename ILIKE '%proyecto%'
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
        echo "  No se encontraron tablas con 'proyecto'.\n";
    }

    // Buscar tablas con campos relevantes para proyectos
    echo "\n\n=== BUSCANDO TABLAS CON CAMPOS DE PROYECTOS ===\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT table_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND (
            column_name ILIKE '%responsable%'
            OR column_name ILIKE '%presupuesto%'
            OR column_name ILIKE '%avance%'
            OR column_name ILIKE '%departamento%'
            OR column_name ILIKE '%prioridad%'
        )
        ORDER BY table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.{$table['table_name']}");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            if ($count['total'] > 0 && $count['total'] < 10000000) {
                // Ver columnas relevantes
                $stmt2 = $pdo->query("
                    SELECT column_name
                    FROM information_schema.columns
                    WHERE table_schema = 'public'
                    AND table_name = '{$table['table_name']}'
                    AND (
                        column_name ILIKE '%responsable%'
                        OR column_name ILIKE '%presupuesto%'
                        OR column_name ILIKE '%avance%'
                        OR column_name ILIKE '%departamento%'
                        OR column_name ILIKE '%prioridad%'
                        OR column_name ILIKE '%fecha%'
                        OR column_name ILIKE '%estado%'
                        OR column_name ILIKE '%nombre%'
                        OR column_name ILIKE '%descripcion%'
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

    // Buscar tablas con campos de obra/trabajo
    echo "\n\n=== BUSCANDO TABLAS CON 'OBRA' O 'TRABAJO' ===\n\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND (
            tablename ILIKE '%obra%'
            OR tablename ILIKE '%trabajo%'
            OR tablename ILIKE '%solicitud%'
            OR tablename ILIKE '%programa%'
        )
        ORDER BY tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.{$table['tablename']}");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            if ($count['total'] > 0 && $count['total'] < 1000000) {
                echo "  ✓ {$table['tablename']} (" . number_format($count['total']) . " registros)\n";
            }
        } catch (PDOException $e) {
            // Ignorar
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
