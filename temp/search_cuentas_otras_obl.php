<?php
// Buscar tablas de cuentas y contribuyentes
try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;dbname=padron_licencias",
        "refact",
        "FF)-BQk2",
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    echo "=== BUSCANDO TABLAS DE CUENTAS Y CONTRIBUYENTES ===\n\n";

    $schemas = ['comun', 'comunX', 'db_ingresos', 'public', 'catastro_gdl'];

    // Buscar tablas de cuentas
    echo "--- TABLAS CON 'CUENTA' ---\n";
    foreach ($schemas as $schema) {
        $sql = "
            SELECT table_name, table_schema
            FROM information_schema.tables
            WHERE table_schema = :schema
            AND table_name LIKE '%cuenta%'
            ORDER BY table_name
            LIMIT 10
        ";

        $stmt = $pdo->prepare($sql);
        $stmt->execute(['schema' => $schema]);
        $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($tables as $table) {
            echo "  {$table['table_schema']}.{$table['table_name']}\n";
        }
    }

    // Buscar SPs relacionados
    echo "\n=== SPs RELACIONADOS CON DRECGO ===\n";
    $sql = "
        SELECT
            n.nspname as schema_name,
            p.proname as sp_name
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname LIKE '%drecgo%'
        ORDER BY p.proname
    ";

    $stmt = $pdo->query($sql);
    $sps = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($sps) > 0) {
        foreach ($sps as $sp) {
            echo "  {$sp['schema_name']}.{$sp['sp_name']}\n";
        }
    } else {
        echo "  (no hay SPs con 'drecgo')\n";
    }

    // Ver un ejemplo de la tabla ta_11_descderechos
    echo "\n=== ESTRUCTURA DE db_ingresos.ta_11_descderechos ===\n";
    $sql = "
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'db_ingresos'
        AND table_name = 'ta_11_descderechos'
        ORDER BY ordinal_position
    ";

    $stmt = $pdo->query($sql);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  {$col['column_name']}: {$col['data_type']}{$length}\n";
    }

    // Buscar datos de ejemplo
    echo "\n=== DATOS DE EJEMPLO EN ta_11_descderechos ===\n";
    $sql = "SELECT * FROM db_ingresos.ta_11_descderechos LIMIT 5";
    $stmt = $pdo->query($sql);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($rows as $i => $row) {
        echo "\nRegistro " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  $key: $value\n";
        }
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
