<?php
// Buscar tablas relacionadas con tránsito
try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;dbname=padron_licencias",
        "refact",
        "FF)-BQk2",
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    echo "=== BUSCANDO TABLAS RELACIONADAS CON TRÁNSITO/TRANSPORTE ===\n\n";

    $schemas = ['comun', 'comunX', 'db_ingresos', 'public', 'catastro_gdl'];

    foreach ($schemas as $schema) {
        $sql = "
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = :schema
            AND (
                table_name LIKE '%trans%'
                OR table_name LIKE '%vehi%'
                OR table_name LIKE '%auto%'
                OR table_name LIKE '%placa%'
            )
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

    // Buscar tablas de permisos/licencias de transporte
    echo "\n=== BUSCANDO TABLAS DE PERMISOS/LICENCIAS ===\n\n";
    foreach ($schemas as $schema) {
        $sql = "
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = :schema
            AND (
                table_name LIKE '%permiso%'
                OR table_name LIKE '%lic%'
            )
            ORDER BY table_name
            LIMIT 10
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
