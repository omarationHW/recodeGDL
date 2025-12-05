<?php
// Check multas table structure

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CHECKING MULTAS TABLE STRUCTURE ===\n\n";

    // Check which schemas have multas table
    $stmt = $pdo->query("
        SELECT table_schema
        FROM information_schema.tables
        WHERE table_name = 'multas'
        ORDER BY table_schema
    ");

    $schemas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($schemas as $schema) {
        $schemaName = $schema['table_schema'];
        echo "Schema: {$schemaName}\n\n";

        // Get columns
        $stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = '{$schemaName}'
            AND table_name = 'multas'
            ORDER BY ordinal_position
        ");

        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "Columns:\n";
        foreach ($columns as $col) {
            $len = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            echo "  - {$col['column_name']}: {$col['data_type']}{$len}\n";
        }

        // Get sample data
        echo "\nSample data (with descmultampal):\n";
        $stmt = $pdo->query("
            SELECT
                m.id_multa,
                m.folio,
                m.cvemultado,
                m.clavemul,
                d.tipo_descto,
                d.valor,
                d.estado as estado_desc,
                d.feccap,
                d.observacion
            FROM {$schemaName}.multas m
            LEFT JOIN catastro_gdl.descmultampal d ON m.id_multa = d.id_multa
            WHERE d.id_multa IS NOT NULL
            LIMIT 3
        ");

        $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);
        foreach ($samples as $i => $row) {
            echo "\nRow " . ($i + 1) . ":\n";
            foreach ($row as $key => $value) {
                echo "  {$key}: " . ($value ?? 'NULL') . "\n";
            }
        }
        echo "\n" . str_repeat("=", 60) . "\n\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
