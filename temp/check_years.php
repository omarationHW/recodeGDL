<?php
try {
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Verificando campo axoadeudo:\n\n";

    $stmt = $pdo->query("
        SELECT
            axoadeudo,
            COUNT(*) as cantidad
        FROM catastro_gdl.controladora
        GROUP BY axoadeudo
        ORDER BY axoadeudo DESC
        LIMIT 20
    ");

    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Valores únicos de axoadeudo:\n";
    foreach ($results as $row) {
        echo "  axoadeudo = " . ($row['axoadeudo'] ?? 'NULL') . ": {$row['cantidad']} registros\n";
    }

    echo "\n\nBuscando otros campos de año en controladora:\n";
    $stmt = $pdo->query("
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'controladora'
        AND (column_name ILIKE '%año%' OR column_name ILIKE '%axo%' OR column_name ILIKE '%year%' OR column_name ILIKE '%ejercicio%')
        ORDER BY column_name
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "Columnas relacionadas con año:\n";
    foreach ($cols as $col) {
        echo "  - $col\n";
    }

    // Buscar en cuentapublica si tiene años
    echo "\n\nBuscando campos de año en cuentapublica:\n";
    $stmt = $pdo->query("
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'cuentapublica'
        AND (column_name ILIKE '%año%' OR column_name ILIKE '%axo%' OR column_name ILIKE '%year%' OR column_name ILIKE '%ejercicio%')
        ORDER BY column_name
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "Columnas relacionadas con año:\n";
    foreach ($cols as $col) {
        echo "  - $col\n";
    }

} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
