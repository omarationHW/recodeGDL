<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "🔍 Buscando tablas relacionadas con adeudos cancelados/condonados...\n\n";

echo "1️⃣ Tablas que contienen 'canc':\n\n";
$tables = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
      AND table_name ILIKE '%canc%'
    ORDER BY table_name
")->fetchAll(PDO::FETCH_ASSOC);

foreach ($tables as $t) {
    echo "   ✅ {$t['table_schema']}.{$t['table_name']}\n";
}

echo "\n2️⃣ Tablas que contienen 'condon':\n\n";
$tables2 = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
      AND table_name ILIKE '%condon%'
    ORDER BY table_name
")->fetchAll(PDO::FETCH_ASSOC);

foreach ($tables2 as $t) {
    echo "   ✅ {$t['table_schema']}.{$t['table_name']}\n";
}

if (count($tables2) == 0) {
    echo "   ⚠️  No se encontraron tablas con 'condon'\n";
}

echo "\n3️⃣ Todas las tablas ta_11_adeudo*:\n\n";
$tables3 = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
      AND table_name LIKE 'ta_11_adeudo%'
    ORDER BY table_name
")->fetchAll(PDO::FETCH_ASSOC);

foreach ($tables3 as $t) {
    echo "   ✅ {$t['table_schema']}.{$t['table_name']}\n";

    // Ver cantidad de registros
    $count = $pdo->query("SELECT COUNT(*) as total FROM {$t['table_schema']}.{$t['table_name']}")->fetch(PDO::FETCH_ASSOC);
    echo "      Registros: {$count['total']}\n";
}

// Buscar en archivos SQL
echo "\n\n4️⃣ Buscando en archivos SQL...\n\n";
$sqlFiles = glob(__DIR__ . '/../RefactorX/Base/mercados/database/database/*adeudo*canc*.sql');
foreach ($sqlFiles as $file) {
    echo "   📄 " . basename($file) . "\n";
}

if (count($sqlFiles) == 0) {
    echo "   ⚠️  No se encontraron archivos SQL con ese patrón\n";
}
