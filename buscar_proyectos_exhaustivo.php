<?php
// Script para búsqueda exhaustiva de tablas que puedan servir para proyectos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas con fecha_inicio o fecha_fin
    echo "=== TABLAS CON 'fecha_inicio' O 'fecha_fin' ===\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT table_name
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND (
            column_name ILIKE '%fecha_inicio%'
            OR column_name ILIKE '%fecha_fin%'
            OR column_name ILIKE '%fechaini%'
            OR column_name ILIKE '%fechafin%'
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

                // Ver estructura completa
                $stmt2 = $pdo->query("
                    SELECT column_name, data_type
                    FROM information_schema.columns
                    WHERE table_schema = 'public'
                    AND table_name = '{$table['table_name']}'
                    ORDER BY ordinal_position
                    LIMIT 15
                ");
                $cols = $stmt2->fetchAll(PDO::FETCH_ASSOC);

                foreach ($cols as $col) {
                    echo "    - {$col['column_name']}: {$col['data_type']}\n";
                }
                echo "\n";
            }
        } catch (PDOException $e) {
            // Ignorar
        }
    }

    // Buscar tablas con "nombre" y "descripcion"
    echo "\n=== TABLAS CON 'nombre' Y 'descripcion' ===\n\n";

    $stmt = $pdo->query("
        SELECT t1.table_name
        FROM information_schema.columns t1
        INNER JOIN information_schema.columns t2
            ON t1.table_name = t2.table_name
            AND t1.table_schema = t2.table_schema
        WHERE t1.table_schema = 'public'
        AND t1.column_name ILIKE '%nombre%'
        AND t2.column_name ILIKE '%descripcion%'
        GROUP BY t1.table_name
        ORDER BY t1.table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.{$table['table_name']}");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            if ($count['total'] > 0 && $count['total'] < 500000) {
                echo "  ✓ {$table['table_name']} (" . number_format($count['total']) . " registros)\n";

                // Ver primeros 10 campos
                $stmt2 = $pdo->query("
                    SELECT column_name, data_type
                    FROM information_schema.columns
                    WHERE table_schema = 'public'
                    AND table_name = '{$table['table_name']}'
                    ORDER BY ordinal_position
                    LIMIT 10
                ");
                $cols = $stmt2->fetchAll(PDO::FETCH_ASSOC);

                foreach ($cols as $col) {
                    echo "    - {$col['column_name']}: {$col['data_type']}\n";
                }
                echo "\n";
            }
        } catch (PDOException $e) {
            // Ignorar
        }
    }

    // Ver todas las tablas para tener contexto
    echo "\n=== RESUMEN: TODAS LAS TABLAS PUBLIC (con registros) ===\n\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename
    ");

    $all_tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $count_with_data = 0;

    foreach ($all_tables as $table) {
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM public.{$table['tablename']}");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            if ($count['total'] > 0) {
                $count_with_data++;
                if ($count['total'] < 1000000) {
                    echo "  {$table['tablename']}: " . number_format($count['total']) . " registros\n";
                }
            }
        } catch (PDOException $e) {
            // Ignorar
        }
    }

    echo "\n\nTotal tablas con datos: $count_with_data\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
