<?php
// Explorar estructura de tablas contrib
try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;dbname=padron_licencias",
        "refact",
        "FF)-BQk2",
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    echo "=== ESTRUCTURA DE comun.contrib ===\n\n";

    $sql = "
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'contrib'
        ORDER BY ordinal_position
    ";

    $stmt = $pdo->query($sql);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  {$col['column_name']}: {$col['data_type']}{$length}\n";
    }

    // Buscar datos de ejemplo
    echo "\n=== DATOS DE EJEMPLO EN comun.contrib ===\n";
    $sql = "SELECT * FROM comun.contrib WHERE cvecont IS NOT NULL LIMIT 5";
    $stmt = $pdo->query($sql);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($rows as $i => $row) {
        echo "\nRegistro " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            if ($value !== null) {
                echo "  $key: $value\n";
            }
        }
    }

    // Ver si hay una tabla específica de otras obligaciones
    echo "\n\n=== BUSCANDO TABLAS DE RUBROS ===\n\n";

    $schemas = ['comun', 'comunX', 'db_ingresos', 'public'];

    foreach ($schemas as $schema) {
        $sql = "
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = :schema
            AND table_name LIKE '%rubro%'
            ORDER BY table_name
        ";

        $stmt = $pdo->prepare($sql);
        $stmt->execute(['schema' => $schema]);
        $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($tables) > 0) {
            echo "Schema: $schema\n";
            foreach ($tables as $table) {
                echo "  - {$table['table_name']}\n";
            }
            echo "\n";
        }
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
