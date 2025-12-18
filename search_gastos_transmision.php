<?php
// Script para buscar tablas relacionadas con gastos de transmision

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Buscar tablas con patrones relacionados a gastos transmision
    echo "=== BUSCANDO TABLAS RELACIONADAS CON GASTOS TRANSMISION ===\n\n";

    $patterns = [
        '%gasto%',
        '%transmision%',
        '%transm%'
    ];

    $found_tables = [];
    foreach ($patterns as $pattern) {
        $stmt = $pdo->prepare("
            SELECT table_schema, table_name,
                   (SELECT COUNT(*) FROM information_schema.columns
                    WHERE table_schema = t.table_schema
                    AND table_name = t.table_name) as num_columns
            FROM information_schema.tables t
            WHERE table_schema IN ('public', 'publico')
            AND table_type = 'BASE TABLE'
            AND table_name ILIKE ?
            ORDER BY table_name
        ");
        $stmt->execute([$pattern]);
        $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($tables as $t) {
            $key = "{$t['table_schema']}.{$t['table_name']}";
            if (!isset($found_tables[$key])) {
                $found_tables[$key] = $t;
            }
        }
    }

    echo "Tablas encontradas:\n";
    foreach ($found_tables as $t) {
        echo "  ✓ {$t['table_schema']}.{$t['table_name']} ({$t['num_columns']} columnas)\n";

        // Ver cuántos registros
        try {
            $stmt2 = $pdo->query("SELECT COUNT(*) as total FROM {$t['table_schema']}.{$t['table_name']}");
            $count = $stmt2->fetch(PDO::FETCH_ASSOC);
            echo "    Total: " . number_format($count['total']) . " registros\n";
        } catch (Exception $e) {
            echo "    Error: " . $e->getMessage() . "\n";
        }
    }

    // 2. Ver la estructura de las tablas más prometedoras
    echo "\n\n=== EXPLORANDO TABLAS CANDIDATAS ===\n";

    $tablas_check = ['public.reqtransm', 'publico.reqtransm', 'public.reqdiftransmision', 'publico.reqdiftransmision'];

    foreach ($tablas_check as $tabla_check) {
        list($schema, $table) = explode('.', $tabla_check);

        echo "\n--- Verificando {$tabla_check} ---\n";
        try {
            // Ver estructura
            $stmt = $pdo->query("
                SELECT column_name, data_type, character_maximum_length
                FROM information_schema.columns
                WHERE table_schema = '$schema'
                AND table_name = '$table'
                ORDER BY ordinal_position
            ");
            $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($columns) > 0) {
                echo "Estructura (". count($columns) . " columnas):\n";
                foreach ($columns as $col) {
                    $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                    echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
                }

                // Contar registros
                $stmt = $pdo->query("SELECT COUNT(*) as total FROM {$schema}.{$table}");
                $total = $stmt->fetch(PDO::FETCH_ASSOC);
                echo "Total registros: " . number_format($total['total']) . "\n";

                // Muestra
                if ($total['total'] > 0) {
                    $stmt = $pdo->query("SELECT * FROM {$schema}.{$table} LIMIT 2");
                    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

                    echo "\nMuestra de datos:\n";
                    foreach ($rows as $i => $row) {
                        echo "  Registro " . ($i + 1) . ":\n";
                        foreach ($row as $key => $val) {
                            $val = is_null($val) ? 'NULL' : (is_string($val) ? substr(trim($val), 0, 40) : $val);
                            echo "    $key: $val\n";
                        }
                        echo "\n";
                    }
                }
            }
        } catch (Exception $e) {
            echo "  No existe o error: " . $e->getMessage() . "\n";
        }
    }

    // 3. Ver el stored procedure actual
    echo "\n\n=== STORED PROCEDURE ACTUAL ===\n";
    $stmt = $pdo->query("
        SELECT pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'publico'
        AND p.proname = 'recaudadora_gastos_transmision'
    ");
    $sp = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp) {
        echo $sp['definition'];
    } else {
        echo "No se encontró el stored procedure\n";
    }

    echo "\n✅ Búsqueda completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
