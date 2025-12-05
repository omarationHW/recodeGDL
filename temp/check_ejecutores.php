<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "=== TABLA: comun.ta_15_ejecutores ===\n\n";

// Ver estructura
$stmt = $pdo->query("
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'comun'
    AND table_name = 'ta_15_ejecutores'
    ORDER BY ordinal_position
");

$cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "Columnas:\n";
foreach ($cols as $c) {
    echo "  - {$c['column_name']}: {$c['data_type']}\n";
}

// Contar registros
$count = $pdo->query("SELECT COUNT(*) FROM comun.ta_15_ejecutores")->fetchColumn();
echo "\nTotal registros: $count\n";

// Obtener ejemplos
echo "\n\n=== EJEMPLOS DE EJECUTORES ===\n\n";
$stmt2 = $pdo->query("
    SELECT *
    FROM comun.ta_15_ejecutores
    LIMIT 10
");

$ejemplos = $stmt2->fetchAll(PDO::FETCH_ASSOC);
foreach ($ejemplos as $e) {
    echo "Ejemplo: " . json_encode($e, JSON_UNESCAPED_UNICODE) . "\n";
}
?>
