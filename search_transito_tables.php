<?php
// Script para buscar tablas relacionadas con tránsito/vehículos

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
        WHERE p.proname = 'recaudadora_drecgo_trans'
        AND n.nspname = 'publico'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($result) {
        echo substr($result['definition'], 0, 1200) . "...\n";
    }

    // Buscar tablas con "transito" o "transm"
    echo "\n\n=== TABLAS CON 'transito' O 'transm' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%transito%' OR table_name ILIKE '%transm%')
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

    // Buscar tablas con "vehiculo", "placa", "tenencia"
    echo "\n\n=== TABLAS CON 'vehiculo', 'placa', 'tenencia' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (
            table_name ILIKE '%vehiculo%'
            OR table_name ILIKE '%placa%'
            OR table_name ILIKE '%tenencia%'
            OR table_name ILIKE '%auto%'
        )
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables2 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables2) > 0) {
        foreach ($tables2 as $table) {
            echo "  - {$table['table_schema']}.{$table['table_name']}\n";
        }
    } else {
        echo "  (No se encontraron tablas)\n";
    }

    // Buscar campos con "placa", "marca", "modelo", "serie"
    echo "\n\n=== TABLAS CON CAMPOS 'placa', 'marca', 'modelo' ===\n";
    $stmt = $pdo->query("
        SELECT DISTINCT table_name, column_name
        FROM information_schema.columns
        WHERE (
            column_name ILIKE '%placa%'
            OR column_name ILIKE '%marca%'
            OR column_name ILIKE '%modelo%'
            OR column_name ILIKE '%serie%'
        )
        AND table_schema IN ('public', 'publico')
        ORDER BY table_name, column_name
        LIMIT 30
    ");
    $campos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($campos) > 0) {
        foreach ($campos as $campo) {
            echo "  - {$campo['table_name']}.{$campo['column_name']}\n";
        }
    } else {
        echo "  (No se encontraron campos)\n";
    }

    // Buscar tablas con "multa" de tránsito
    echo "\n\n=== TABLAS CON 'multa' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name ILIKE '%multa%'
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
        LIMIT 20
    ");
    $tables3 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables3 as $table) {
        echo "  - {$table['table_schema']}.{$table['table_name']}\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
