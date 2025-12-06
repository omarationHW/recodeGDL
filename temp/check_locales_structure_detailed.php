<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "📋 Estructura de publico.ta_11_locales:\n\n";

$stmt = $pdo->query("
    SELECT column_name, data_type, character_maximum_length, numeric_precision, numeric_scale
    FROM information_schema.columns
    WHERE table_schema = 'publico' AND table_name = 'ta_11_locales'
    ORDER BY ordinal_position
");

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    $details = $row['data_type'];
    if ($row['character_maximum_length']) {
        $details .= "({$row['character_maximum_length']})";
    } elseif ($row['numeric_precision']) {
        $details .= "({$row['numeric_precision']},{$row['numeric_scale']})";
    }
    echo "  • {$row['column_name']}: $details\n";
}

echo "\n📊 Verificando valores máximos en campos numéricos:\n\n";

// Check local field max value
$stmt = $pdo->query("SELECT MAX(local) as max_local, MIN(local) as min_local FROM publico.ta_11_locales");
$row = $stmt->fetch(PDO::FETCH_ASSOC);
echo "  • local: MIN={$row['min_local']}, MAX={$row['max_local']} (SMALLINT range: -32768 to 32767)\n";

// Check categoria field max value
$stmt = $pdo->query("SELECT MAX(categoria) as max_cat, MIN(categoria) as min_cat FROM publico.ta_11_locales");
$row = $stmt->fetch(PDO::FETCH_ASSOC);
echo "  • categoria: MIN={$row['min_cat']}, MAX={$row['max_cat']} (SMALLINT range: -32768 to 32767)\n";

// Check num_mercado field max value
$stmt = $pdo->query("SELECT MAX(num_mercado) as max_merc, MIN(num_mercado) as min_merc FROM publico.ta_11_locales");
$row = $stmt->fetch(PDO::FETCH_ASSOC);
echo "  • num_mercado: MIN={$row['min_merc']}, MAX={$row['max_merc']} (SMALLINT range: -32768 to 32767)\n";
?>
