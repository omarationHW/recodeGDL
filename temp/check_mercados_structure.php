<?php
echo "==============================================\n";
echo "BUSCAR: ta_11_locales en padron_licencias\n";
echo "==============================================\n\n";

try {
    echo "1. Buscando tabla ta_11_locales...\n";
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    $result = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name = 'ta_11_locales'
        ORDER BY table_schema
    ")->fetchAll(PDO::FETCH_ASSOC);

    if (count($result) > 0) {
        echo "   ✓ ta_11_locales encontrada:\n";
        foreach ($result as $r) {
            echo "     - {$r['table_schema']}.{$r['table_name']}\n";
        }
    } else {
        echo "   ✗ ta_11_locales NO encontrada en padron_licencias\n";
    }

    echo "\n2. Buscando schemas disponibles...\n";
    $schemas = $pdo->query("
        SELECT schema_name
        FROM information_schema.schemata
        WHERE schema_name NOT IN ('pg_catalog', 'information_schema')
        ORDER BY schema_name
    ")->fetchAll(PDO::FETCH_ASSOC);

    echo "   Schemas disponibles:\n";
    foreach ($schemas as $s) {
        echo "     - {$s['schema_name']}\n";
    }

    echo "\n3. Buscando tablas ta_11_* en todos los schemas...\n";
    $tables = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name LIKE 'ta_11_%'
        ORDER BY table_schema, table_name
        LIMIT 20
    ")->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        echo "   Tablas ta_11_* encontradas:\n";
        foreach ($tables as $t) {
            echo "     - {$t['table_schema']}.{$t['table_name']}\n";
        }
    } else {
        echo "   ✗ No se encontraron tablas ta_11_*\n";
    }

} catch (Exception $e) {
    echo "   ✗ Error: " . $e->getMessage() . "\n";
}
?>
