<?php
try {
    $pdo = new PDO('pgsql:host=localhost;port=5432;dbname=padron_licencias', 'postgres', 'postgres');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_schema IN ('catastro_gdl', 'public', 'comun')
        AND (table_name ILIKE '%controladora%' OR table_name ILIKE '%propietario%')
        ORDER BY table_schema, table_name
        LIMIT 10
    ");

    while($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo $row['table_schema'] . '.' . $row['table_name'] . PHP_EOL;
    }
} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . PHP_EOL;
}
