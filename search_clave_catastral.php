<?php
// Script para buscar tablas con clave catastral

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Buscar columnas con clave catastral
    echo "=== COLUMNAS CON CLAVE CATASTRAL ===\n\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name, column_name
        FROM information_schema.columns
        WHERE table_schema IN ('public', 'publico')
        AND (
            column_name ILIKE '%cvecat%' OR
            column_name ILIKE '%catastral%' OR
            column_name ILIKE '%clave_cat%'
        )
        ORDER BY table_name, column_name
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        echo "  {$col['table_schema']}.{$col['table_name']}.{$col['column_name']}\n";
    }

    // 2. Ver datos de req_400
    echo "\n\n=== TABLA req_400 (usado actualmente) ===\n";
    $stmt = $pdo->query("SELECT * FROM req_400 LIMIT 2");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($rows) > 0) {
        echo "Estructura de req_400:\n";
        foreach (array_keys($rows[0]) as $key) {
            echo "  - $key\n";
        }

        echo "\nPrimeros 2 registros:\n";
        foreach ($rows as $i => $row) {
            echo "\nRegistro " . ($i + 1) . ":\n";
            $count = 0;
            foreach ($row as $key => $val) {
                if ($count >= 15) break;
                $val = is_null($val) ? 'NULL' : (is_string($val) ? substr(trim($val), 0, 40) : $val);
                echo "  $key: $val\n";
                $count++;
            }
        }
    }

    // 3. Buscar tablas con datos de predios
    echo "\n\n=== BUSCANDO TABLAS DE PREDIOS ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_schema IN ('public', 'publico')
        AND table_type = 'BASE TABLE'
        AND table_name ILIKE '%predio%'
        ORDER BY table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $t) {
        echo "\n{$t['table_schema']}.{$t['table_name']}:\n";
        try {
            $stmt2 = $pdo->query("SELECT COUNT(*) as cnt FROM {$t['table_schema']}.{$t['table_name']}");
            $cnt = $stmt2->fetch(PDO::FETCH_ASSOC);
            echo "  Total: " . number_format($cnt['cnt']) . " registros\n";
        } catch (Exception $e) {
            echo "  Error: " . $e->getMessage() . "\n";
        }
    }

    echo "\n✅ Búsqueda completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
