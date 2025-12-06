<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "🔍 Buscando tabla ta_12_recargos:\n\n";

$stmt = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name LIKE '%recargos%'
    ORDER BY table_schema, table_name
");

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
    echo "  • {$row['table_schema']}.{$row['table_name']}\n";
}

echo "\n📋 Estructura de la tabla ta_12_recargos si existe:\n\n";

$schemas = ['public', 'publico', 'comun'];
foreach ($schemas as $schema) {
    try {
        $stmt = $pdo->query("SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = '$schema' AND table_name = 'ta_12_recargos' ORDER BY ordinal_position");
        if ($stmt->rowCount() > 0) {
            echo "Encontrada en schema: $schema\n";
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                echo "  • {$row['column_name']}: {$row['data_type']}\n";
            }
            break;
        }
    } catch (Exception $e) {
        // Skip
    }
}
?>
