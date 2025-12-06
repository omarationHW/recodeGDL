<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "🔍 Buscando tabla recaudadoras:\n\n";

// Buscar en publico
$stmt = $pdo->query("
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'publico'
    AND table_name LIKE '%recauda%'
");

echo "En schema 'publico':\n";
while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "  ✓ {$row['table_name']}\n";
}

// Buscar en public
$stmt = $pdo->query("
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_name LIKE '%recauda%'
");

echo "\nEn schema 'public':\n";
while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "  ✓ {$row['table_name']}\n";
}

// Ver estructura de ta_11_mercados (que tiene info de recaudadoras)
echo "\n📋 Campos de ta_11_mercados:\n";
$stmt = $pdo->query("
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'publico' AND table_name = 'ta_11_mercados'
    ORDER BY ordinal_position
");

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "  • {$row['column_name']}: {$row['data_type']}\n";
}
?>
