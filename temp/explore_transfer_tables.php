<?php
// Explorar tablas de transferencias/tránsito
try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;dbname=padron_licencias",
        "refact",
        "FF)-BQk2",
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    echo "=== ESTRUCTURA DE comun.ta_transfer ===\n\n";

    $sql = "
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'ta_transfer'
        ORDER BY ordinal_position
        LIMIT 20
    ";

    $stmt = $pdo->query($sql);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  {$col['column_name']}: {$col['data_type']}{$length}\n";
    }

    // Obtener ejemplos
    echo "\n=== EJEMPLOS DE comun.ta_transfer ===\n";
    $sql = "SELECT * FROM comun.ta_transfer LIMIT 5";
    $stmt = $pdo->query($sql);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($rows) > 0) {
        foreach ($rows as $i => $row) {
            echo "\nRegistro " . ($i + 1) . ":\n";
            $count = 0;
            foreach ($row as $key => $value) {
                if ($value !== null && $count < 10) {
                    echo "  $key: $value\n";
                    $count++;
                }
            }
        }
    } else {
        echo "No hay datos en ta_transfer\n";
    }

    // Buscar si hay campo de cuenta
    echo "\n=== BUSCANDO CAMPO DE CUENTA/CLAVE ===\n";
    $sql = "
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'ta_transfer'
        AND (
            column_name LIKE '%cuenta%'
            OR column_name LIKE '%cve%'
            OR column_name LIKE '%folio%'
            OR column_name LIKE '%id%'
        )
    ";

    $stmt = $pdo->query($sql);
    $campos = $stmt->fetchAll(PDO::FETCH_COLUMN);

    foreach ($campos as $campo) {
        echo "  - $campo\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
