<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "🔍 Buscando tablas de adeudos y pagos:\n\n";

$tables = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE (table_name LIKE 'ta_11_adeudo%' OR table_name LIKE 'ta_11_pagos%' OR table_name LIKE 'ta_11_mercado%')
      AND table_schema NOT IN ('pg_catalog', 'information_schema')
    ORDER BY table_name, table_schema
")->fetchAll(PDO::FETCH_ASSOC);

foreach ($tables as $t) {
    echo "✅ {$t['table_schema']}.{$t['table_name']}\n";
}
