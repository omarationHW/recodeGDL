<?php
try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== ESTRUCTURA DE TABLA PAGO_DIVERSOS ===\n\n";

    // Obtener columnas de catastro_gdl.pago_diversos
    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'pago_diversos'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($columns) {
        echo "Columnas en catastro_gdl.pago_diversos:\n";
        foreach ($columns as $col) {
            echo "- {$col['column_name']} ({$col['data_type']})\n";
        }
    }

    echo "\n=== DATOS DE EJEMPLO ===\n\n";

    // Obtener algunos registros de ejemplo
    $stmt = $pdo->query("
        SELECT *
        FROM catastro_gdl.pago_diversos
        LIMIT 3
    ");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($rows) {
        foreach ($rows as $i => $row) {
            echo "Registro " . ($i + 1) . ":\n";
            foreach ($row as $key => $value) {
                echo "  $key: $value\n";
            }
            echo "\n";
        }
    }

} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
