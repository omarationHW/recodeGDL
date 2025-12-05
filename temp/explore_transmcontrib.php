<?php
// Explorar tabla transmcontrib
try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;dbname=padron_licencias",
        "refact",
        "FF)-BQk2",
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    echo "=== ESTRUCTURA DE comun.transmcontrib ===\n\n";

    $sql = "
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema IN ('comun', 'comunX', 'catastro_gdl')
        AND table_name = 'transmcontrib'
        ORDER BY table_schema, ordinal_position
        LIMIT 30
    ";

    $stmt = $pdo->query($sql);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  {$col['column_name']}: {$col['data_type']}{$length}\n";
    }

    // Obtener ejemplos
    echo "\n=== EJEMPLOS DE comunX.transmcontrib ===\n";
    $sql = "SELECT * FROM comunX.transmcontrib WHERE cvecont IS NOT NULL LIMIT 5";
    $stmt = $pdo->query($sql);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($rows) > 0) {
        foreach ($rows as $i => $row) {
            echo "\nRegistro " . ($i + 1) . ":\n";
            foreach ($row as $key => $value) {
                if ($value !== null) {
                    echo "  $key: $value\n";
                }
            }
            if ($i >= 2) break; // Solo 3 ejemplos
        }
    } else {
        echo "No hay datos\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
