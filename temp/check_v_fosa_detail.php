<?php
// Check v_fosa detail

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CHECKING V_FOSA STRUCTURE ===\n\n";

    // Get columns
    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'v_fosa'
        ORDER BY ordinal_position
    ");

    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Columns:\n";
    foreach ($columns as $col) {
        $len = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  - {$col['column_name']}: {$col['data_type']}{$len}\n";
    }

    // Get sample data
    echo "\n=== SAMPLE DATA ===\n\n";
    $stmt = $pdo->query("SELECT * FROM catastro_gdl.v_fosa LIMIT 10");
    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Found " . count($samples) . " records\n\n";

    foreach ($samples as $i => $row) {
        echo "═══════════════════════════════════════════════════════════\n";
        echo "Muestra " . ($i + 1) . ":\n";
        echo "═══════════════════════════════════════════════════════════\n";
        foreach ($row as $key => $value) {
            echo "  {$key}: " . ($value ?? 'NULL') . "\n";
        }
        echo "\n";
    }

    // Get distinct folios for testing
    echo "=== FOLIOS FOR TESTING ===\n\n";

    $stmt = $pdo->query("
        SELECT folio, nombre, cuenta
        FROM catastro_gdl.v_fosa
        WHERE folio IS NOT NULL AND folio > 0
        ORDER BY folio
        LIMIT 10
    ");

    $folios = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Primeros 10 folios:\n\n";
    foreach ($folios as $i => $row) {
        echo ($i + 1) . ". Folio: {$row['folio']}";
        if ($row['nombre']) {
            echo " - {$row['nombre']}";
        }
        if ($row['cuenta']) {
            echo " (Cuenta: {$row['cuenta']})";
        }
        echo "\n";
    }

    // Count total
    echo "\n=== STATISTICS ===\n\n";

    $stmt = $pdo->query("SELECT COUNT(*) as total FROM catastro_gdl.v_fosa");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total de fosas: {$total['total']}\n";

    $stmt = $pdo->query("SELECT COUNT(DISTINCT folio) as total_folios FROM catastro_gdl.v_fosa WHERE folio IS NOT NULL");
    $total_folios = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total de folios distintos: {$total_folios['total_folios']}\n";

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
