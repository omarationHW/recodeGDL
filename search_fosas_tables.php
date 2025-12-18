<?php
// Script para buscar tablas relacionadas con fosas/cementerios

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
        WHERE p.proname = 'recaudadora_drecgo_fosa'
        AND n.nspname = 'publico'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($result) {
        echo substr($result['definition'], 0, 1200) . "...\n";
    }

    // Buscar tablas con "fosa"
    echo "\n\n=== TABLAS CON 'fosa' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name ILIKE '%fosa%'
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
        echo "  (No se encontraron tablas con 'fosa')\n";
    }

    // Buscar tablas con "cementerio", "panteon", "sepultura"
    echo "\n\n=== TABLAS CON 'cementerio', 'panteon', 'sepultura' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (
            table_name ILIKE '%cementerio%'
            OR table_name ILIKE '%panteon%'
            OR table_name ILIKE '%sepultura%'
            OR table_name ILIKE '%tumba%'
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

    // Buscar campos con "fosa", "cementerio", "seccion", "linea"
    echo "\n\n=== TABLAS CON CAMPOS 'fosa', 'cementerio', 'seccion' ===\n";
    $stmt = $pdo->query("
        SELECT DISTINCT table_name, column_name
        FROM information_schema.columns
        WHERE (
            column_name ILIKE '%fosa%'
            OR column_name ILIKE '%cementerio%'
            OR column_name ILIKE '%panteon%'
        )
        AND table_schema IN ('public', 'publico')
        ORDER BY table_name, column_name
        LIMIT 20
    ");
    $campos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($campos) > 0) {
        foreach ($campos as $campo) {
            echo "  - {$campo['table_name']}.{$campo['column_name']}\n";
        }
    } else {
        echo "  (No se encontraron campos)\n";
    }

    // Buscar tablas con "derecho" y alguna referencia a cementerios
    echo "\n\n=== TABLAS CON 'derecho' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name ILIKE '%derecho%'
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
        LIMIT 15
    ");
    $tables3 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables3 as $table) {
        echo "  - {$table['table_schema']}.{$table['table_name']}\n";
    }

    // Si existe alguna tabla de control o registros
    echo "\n\n=== TABLAS CON 'control' O 'registro' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%control%' OR table_name ILIKE '%registro%')
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
        LIMIT 20
    ");
    $tables4 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables4 as $table) {
        echo "  - {$table['table_schema']}.{$table['table_name']}\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
