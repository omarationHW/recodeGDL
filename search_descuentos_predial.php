<?php
// Script para buscar tablas relacionadas con descuentos prediales

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Ver el stored procedure actual
    echo "=== STORED PROCEDURE ACTUAL ===\n";
    $stmt = $pdo->query("
        SELECT pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'recaudadora_descpredfrm'
        AND n.nspname = 'publico'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($result) {
        echo substr($result['definition'], 0, 1200) . "...\n";
    }

    // Buscar tablas con "desc" y "pred"
    echo "\n\n=== TABLAS CON 'desc' Y 'pred' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%desc%pred%' OR table_name ILIKE '%pred%desc%')
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "  - {$table['table_schema']}.{$table['table_name']}\n";
        }
    } else {
        echo "  (No se encontraron tablas)\n";
    }

    // Buscar tablas con "descuento" solamente
    echo "\n\n=== TABLAS CON 'descuento' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name ILIKE '%descuento%'
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables2 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables2 as $table) {
        echo "  - {$table['table_schema']}.{$table['table_name']}\n";
    }

    // Buscar tablas con "predial"
    echo "\n\n=== TABLAS CON 'predial' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name ILIKE '%predial%'
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables3 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables3 as $table) {
        echo "  - {$table['table_schema']}.{$table['table_name']}\n";
    }

    // Ver estructura de descuentospred si existe
    echo "\n\n=== ESTRUCTURA DE public.descuentospred ===\n";
    try {
        $stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'public'
            AND table_name = 'descuentospred'
            ORDER BY ordinal_position
        ");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($columns) > 0) {
            foreach ($columns as $col) {
                $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
            }

            echo "\nDatos de ejemplo (5 registros):\n";
            $stmt = $pdo->query("SELECT * FROM public.descuentospred LIMIT 5");
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($rows as $i => $row) {
                echo "\n  Registro " . ($i + 1) . ":\n";
                foreach ($row as $key => $val) {
                    $val = is_null($val) ? 'NULL' : (is_string($val) ? substr(trim($val), 0, 40) : $val);
                    echo "    $key: $val\n";
                }
            }

            // Contar registros
            $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.descuentospred");
            $total = $stmt->fetch(PDO::FETCH_ASSOC);
            echo "\nTotal de registros: " . number_format($total['total']) . "\n";
        }
    } catch (Exception $e) {
        echo "  Error: " . $e->getMessage() . "\n";
    }

    // Ver estructura de c_descpred si existe
    echo "\n\n=== ESTRUCTURA DE publico.c_descpred ===\n";
    try {
        $stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'publico'
            AND table_name = 'c_descpred'
            ORDER BY ordinal_position
        ");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($columns) > 0) {
            foreach ($columns as $col) {
                $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                echo "  - {$col['column_name']}: {$col['data_type']}{$length}\n";
            }

            echo "\nDatos de ejemplo:\n";
            $stmt = $pdo->query("SELECT * FROM publico.c_descpred LIMIT 5");
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($rows as $i => $row) {
                echo "\n  Registro " . ($i + 1) . ":\n";
                foreach ($row as $key => $val) {
                    $val = is_null($val) ? 'NULL' : (is_string($val) ? substr(trim($val), 0, 40) : $val);
                    echo "    $key: $val\n";
                }
            }
        }
    } catch (Exception $e) {
        echo "  Error: " . $e->getMessage() . "\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
