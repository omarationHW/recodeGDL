<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "📋 Estructura de public.ta_11_adeudo_energ:\n\n";

$stmt = $pdo->query("
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'ta_11_adeudo_energ'
    ORDER BY ordinal_position
");

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "  • {$row['column_name']}: {$row['data_type']}\n";
}

echo "\n📋 Estructura de public.ta_11_energia:\n\n";

$stmt = $pdo->query("
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'ta_11_energia'
    ORDER BY ordinal_position
");

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "  • {$row['column_name']}: {$row['data_type']}\n";
}

echo "\n📋 Estructura de public.ta_11_kilowhatts:\n\n";

$stmt = $pdo->query("
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'ta_11_kilowhatts'
    ORDER BY ordinal_position
");

if ($stmt->rowCount() > 0) {
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  • {$row['column_name']}: {$row['data_type']}\n";
    }
} else {
    echo "  ❌ Tabla no existe\n";
}
?>
