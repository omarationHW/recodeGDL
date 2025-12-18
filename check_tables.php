<?php
// Script para verificar qué tablas existen en la base de datos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Listar esquemas
    echo "=== ESQUEMAS DISPONIBLES ===\n";
    $stmt = $pdo->query("SELECT schema_name FROM information_schema.schemata ORDER BY schema_name");
    $schemas = $stmt->fetchAll(PDO::FETCH_COLUMN);
    foreach ($schemas as $schema) {
        echo "  - $schema\n";
    }

    // Listar tablas del esquema publico
    echo "\n=== TABLAS EN ESQUEMA 'publico' ===\n";
    $stmt = $pdo->query("
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'publico'
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "  - publico.$table\n";
        }
    } else {
        echo "  (No hay tablas en este esquema)\n";
    }

    // Listar tablas del esquema public
    echo "\n=== TABLAS EN ESQUEMA 'public' ===\n";
    $stmt = $pdo->query("
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_type = 'BASE TABLE'
        ORDER BY table_name
        LIMIT 20
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "  - public.$table\n";
        }
    } else {
        echo "  (No hay tablas en este esquema)\n";
    }

    // Buscar tablas relacionadas con descuentos
    echo "\n=== TABLAS RELACIONADAS CON 'DESCUENTO' O 'DESCTO' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%descuento%' OR table_name ILIKE '%descto%')
        AND table_type = 'BASE TABLE'
        ORDER BY table_schema, table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "  - {$table['table_schema']}.{$table['table_name']}\n";
        }
    } else {
        echo "  (No se encontraron tablas relacionadas)\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
