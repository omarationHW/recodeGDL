<?php
// Check ta_11_descderechos table structure

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== SEARCHING FOR DESCUENTOS MERCADO TABLES ===\n\n";

    // Search for tables with "descuento" or "mercado"
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name LIKE '%descuento%' OR table_name LIKE '%merc%')
        AND table_schema IN ('catastro_gdl', 'comun', 'comunX', 'multas_reglamentos')
        ORDER BY table_schema, table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Found " . count($tables) . " tables:\n\n";
    foreach ($tables as $table) {
        echo "{$table['table_schema']}.{$table['table_name']}\n";
    }

    // Check specifically for ta_11_descderechos
    echo "\n=== CHECKING comun.ta_11_descderechos TABLE ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'ta_11_descderechos'
        ORDER BY ordinal_position
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($cols) > 0) {
        foreach ($cols as $col) {
            $type = $col['data_type'];
            if ($col['character_maximum_length']) {
                $type .= "({$col['character_maximum_length']})";
            }
            echo "{$col['column_name']}: {$type}\n";
        }

        echo "\n=== SAMPLE FROM ta_11_descderechos ===\n\n";

        $stmt = $pdo->query("
            SELECT *
            FROM comun.ta_11_descderechos
            WHERE estado = 'V'
            LIMIT 3
        ");

        $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($samples as $i => $row) {
            echo "Registro " . ($i + 1) . ":\n";
            foreach ($row as $key => $value) {
                echo "  $key: " . ($value ?? 'NULL') . "\n";
            }
            echo "\n";
        }
    } else {
        echo "Table not found in comun schema\n";
    }

    // Also check catastro_gdl schema
    echo "\n=== CHECKING catastro_gdl.ta_11_descderechos ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'ta_11_descderechos'
        ORDER BY ordinal_position
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($cols) > 0) {
        foreach ($cols as $col) {
            echo "{$col['column_name']}: {$col['data_type']}\n";
        }

        echo "\n=== SAMPLE FROM catastro_gdl.ta_11_descderechos ===\n\n";

        $stmt = $pdo->query("
            SELECT
                d.id_descuento,
                d.id_local,
                d.axoini,
                d.mesini,
                d.axofin,
                d.mesfin,
                d.porcentaje,
                d.estado,
                d.fecha_alta
            FROM catastro_gdl.ta_11_descderechos d
            WHERE d.estado = 'V'
            LIMIT 5
        ");

        $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "Found " . count($samples) . " active records\n\n";

        foreach ($samples as $i => $row) {
            echo "Registro " . ($i + 1) . ":\n";
            foreach ($row as $key => $value) {
                echo "  $key: " . ($value ?? 'NULL') . "\n";
            }
            echo "\n";
        }
    } else {
        echo "Table not found in catastro_gdl schema\n";
    }

    // Check for locales_mercado or mercados table
    echo "\n=== CHECKING FOR MERCADOS/LOCALES TABLES ===\n\n";

    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name LIKE '%local%' OR table_name LIKE '%merc%')
        AND table_schema IN ('catastro_gdl', 'comun')
        ORDER BY table_schema, table_name
        LIMIT 20
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "{$table['table_schema']}.{$table['table_name']}\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
