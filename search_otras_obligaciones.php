<?php
// Script para buscar tablas relacionadas con otras obligaciones

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
        WHERE p.proname = 'recaudadora_drecgootrasobligaciones'
        AND n.nspname = 'publico'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($result) {
        echo substr($result['definition'], 0, 1200) . "...\n";
    }

    // Buscar tablas con "obligacion"
    echo "\n\n=== TABLAS CON 'obligacion' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name ILIKE '%obligacion%'
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
        echo "  (No se encontraron tablas con 'obligacion')\n";
    }

    // Buscar tablas con "pago", "adeudo", "cargo"
    echo "\n\n=== TABLAS CON 'pago', 'adeudo', 'cargo' O 'concepto' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (
            table_name ILIKE '%pago%'
            OR table_name ILIKE '%adeudo%'
            OR table_name ILIKE '%cargo%'
            OR table_name ILIKE '%concepto%'
            OR table_name ILIKE '%otras%'
        )
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
        LIMIT 30
    ");
    $tables2 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables2 as $table) {
        echo "  - {$table['table_schema']}.{$table['table_name']}\n";
    }

    // Buscar tablas que puedan contener cargos o conceptos diversos
    echo "\n\n=== TABLAS CON 'recaud' O 'cobro' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%recaud%' OR table_name ILIKE '%cobro%')
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
        LIMIT 20
    ");
    $tables3 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables3 as $table) {
        echo "  - {$table['table_schema']}.{$table['table_name']}\n";
    }

    // Buscar tablas relacionadas con norequerible o cuentas
    echo "\n\n=== TABLAS CON 'norequerible' O 'cuenta' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%norequerible%' OR table_name ILIKE '%cuentas%')
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
        LIMIT 15
    ");
    $tables4 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables4 as $table) {
        echo "  - {$table['table_schema']}.{$table['table_name']}\n";
    }

    // Ver si hay alguna tabla de "diversos" o "varios"
    echo "\n\n=== TABLAS CON 'diversos', 'varios' O 'otros' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (
            table_name ILIKE '%diversos%'
            OR table_name ILIKE '%varios%'
            OR table_name ILIKE '%otros%'
        )
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables5 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables5) > 0) {
        foreach ($tables5 as $table) {
            echo "  - {$table['table_schema']}.{$table['table_name']}\n";
        }
    } else {
        echo "  (No se encontraron tablas)\n";
    }

    // Buscar tablas con campos "clave_cuenta"
    echo "\n\n=== TABLAS CON CAMPO 'clave_cuenta' ===\n";
    $stmt = $pdo->query("
        SELECT DISTINCT table_name
        FROM information_schema.columns
        WHERE column_name ILIKE '%clave%cuenta%'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_name
        LIMIT 20
    ");
    $tablesCveCuenta = $stmt->fetchAll(PDO::FETCH_COLUMN);

    foreach ($tablesCveCuenta as $table) {
        echo "  - $table\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
