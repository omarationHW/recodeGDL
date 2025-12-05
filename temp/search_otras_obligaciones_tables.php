<?php
// Buscar tablas relacionadas con otras obligaciones
try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;dbname=padron_licencias",
        "refact",
        "FF)-BQk2",
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    echo "=== BUSCANDO TABLAS RELACIONADAS CON OTRAS OBLIGACIONES ===\n\n";

    // Buscar tablas que contengan "obligacion" en diferentes schemas
    $schemas = ['comun', 'comunX', 'db_ingresos', 'public'];

    foreach ($schemas as $schema) {
        echo "--- Schema: $schema ---\n";
        $sql = "
            SELECT table_name, table_schema
            FROM information_schema.tables
            WHERE table_schema = :schema
            AND (
                table_name LIKE '%obligacion%'
                OR table_name LIKE '%otras%'
                OR table_name LIKE '%drecgo%'
            )
            ORDER BY table_name
        ";

        $stmt = $pdo->prepare($sql);
        $stmt->execute(['schema' => $schema]);
        $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($tables) > 0) {
            foreach ($tables as $table) {
                echo "  - {$table['table_schema']}.{$table['table_name']}\n";
            }
        } else {
            echo "  (sin tablas relacionadas)\n";
        }
        echo "\n";
    }

    // Buscar también tablas de derechos
    echo "\n=== BUSCANDO TABLAS DE DERECHOS ===\n\n";
    foreach ($schemas as $schema) {
        echo "--- Schema: $schema ---\n";
        $sql = "
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = :schema
            AND table_name LIKE '%derec%'
            ORDER BY table_name
            LIMIT 20
        ";

        $stmt = $pdo->prepare($sql);
        $stmt->execute(['schema' => $schema]);
        $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($tables) > 0) {
            foreach ($tables as $table) {
                echo "  - {$schema}.{$table['table_name']}\n";
            }
        } else {
            echo "  (sin tablas de derechos)\n";
        }
        echo "\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
