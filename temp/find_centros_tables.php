<?php
try {
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Buscando tablas relacionadas con 'centros' ===\n\n";

    // Buscar tablas con "centro" en el nombre
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_schema IN ('catastro_gdl', 'public', 'comun', 'db_ingresos')
        AND (table_name ILIKE '%centro%' OR table_name ILIKE '%centros%')
        ORDER BY table_schema, table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        $schema = $table['table_schema'];
        $name = $table['table_name'];

        echo "$schema.$name\n";

        // Ver columnas
        $stmt2 = $pdo->query("
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = '$schema'
            AND table_name = '$name'
            ORDER BY ordinal_position
            LIMIT 15
        ");

        $cols = $stmt2->fetchAll(PDO::FETCH_ASSOC);
        foreach ($cols as $col) {
            echo "  - {$col['column_name']} ({$col['data_type']})\n";
        }

        // Contar registros
        $stmt3 = $pdo->query("SELECT COUNT(*) as cnt FROM $schema.$name");
        $count = $stmt3->fetch(PDO::FETCH_ASSOC);
        echo "  Total registros: {$count['cnt']}\n";

        // Muestra de datos
        $stmt4 = $pdo->query("SELECT * FROM $schema.$name LIMIT 3");
        $samples = $stmt4->fetchAll(PDO::FETCH_ASSOC);

        if (count($samples) > 0) {
            echo "  Muestra de datos:\n";
            foreach ($samples as $i => $row) {
                echo "    Registro " . ($i+1) . ":\n";
                foreach (array_slice($row, 0, 5) as $key => $value) {
                    if ($value !== null && $value !== '') {
                        echo "      $key: " . substr($value, 0, 40) . "\n";
                    }
                }
            }
        }

        echo "\n";
    }

} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
