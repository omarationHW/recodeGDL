<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "Buscando tabla usuarios:\n\n";
$tables = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name ILIKE '%usuario%'
      AND table_schema NOT IN ('pg_catalog', 'information_schema')
    ORDER BY table_name
")->fetchAll(PDO::FETCH_ASSOC);

foreach ($tables as $t) {
    echo "✅ {$t['table_schema']}.{$t['table_name']}\n";
    $cols = $pdo->query("
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = '{$t['table_schema']}'
          AND table_name = '{$t['table_name']}'
        ORDER BY ordinal_position
        LIMIT 5
    ")->fetchAll(PDO::FETCH_COLUMN);
    echo "   Primeras columnas: " . implode(', ', $cols) . "\n\n";
}
