<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2');

echo "=== Probando SP con la única combinación disponible ===\n\n";

$stmt = $pdo->query("SELECT * FROM sp_adeudos_locales(2024, 5, 1)");
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo "Total de registros: " . count($rows) . "\n\n";

if (!empty($rows)) {
    echo "DATOS ENCONTRADOS:\n";
    echo str_repeat('=', 80) . "\n";
    foreach ($rows as $row) {
        echo "Oficina: {$row['oficina']}\n";
        echo "Mercado: {$row['num_mercado']}\n";
        echo "Categoria: {$row['categoria']}\n";
        echo "Seccion: {$row['seccion']}\n";
        echo "Local: {$row['local']}\n";
        echo "Nombre: {$row['nombre']}\n";
        echo "Adeudo: {$row['adeudo']}\n";
        echo str_repeat('-', 80) . "\n";
    }

    echo "\n" . str_repeat('=', 60) . "\n";
    echo "PARAMETROS CORRECTOS:\n";
    echo str_repeat('=', 60) . "\n";
    echo json_encode([
        'eRequest' => [
            'Operacion' => 'sp_adeudos_locales',
            'Base' => 'mercados',
            'Parametros' => [
                ['nombre' => 'p_axo', 'valor' => 2024, 'tipo' => 'integer'],
                ['nombre' => 'p_oficina', 'valor' => 5, 'tipo' => 'integer'],
                ['nombre' => 'p_periodo', 'valor' => 1, 'tipo' => 'integer']
            ]
        ]
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . "\n";
} else {
    echo "No se encontraron datos\n";
}
?>
