<?php
try {
    $db = new PDO("pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias", "refact", "FF)-BQk2");
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Tablas en public/comun:\n\n";
    $stmt = $db->query("SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema IN ('public', 'comun') AND (table_name LIKE '%licencia%' OR table_name LIKE '%anuncio%' OR table_name LIKE '%tramite%' OR table_name = 'bloqueo') ORDER BY table_schema, table_name");
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $t) { echo "{$t['table_schema']}.{$t['table_name']}\n"; }
} catch (PDOException $e) { echo "Error: " . $e->getMessage() . "\n"; }
