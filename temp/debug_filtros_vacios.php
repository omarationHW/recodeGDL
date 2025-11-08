<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "DEBUG: String vacío vs NULL en SP\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Test 1: Pasar string vacío literal
    echo "Test 1: tipo = '' (string vacío)\n";
    echo "========================================\n";
    try {
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM comun.buscagiro_list(NULL, '', 'V')");
        $stmt->execute();
        $count = $stmt->fetchColumn();
        echo "  ✓ Resultados: " . number_format($count) . "\n\n";
    } catch (Exception $e) {
        echo "  ✗ Error: " . $e->getMessage() . "\n\n";
    }

    // Test 2: Pasar NULL
    echo "Test 2: tipo = NULL\n";
    echo "========================================\n";
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM comun.buscagiro_list(NULL, NULL, 'V')");
    $stmt->execute();
    $count = $stmt->fetchColumn();
    echo "  ✓ Resultados: " . number_format($count) . "\n\n";

    // Test 3: Usando PDO bind con string vacío
    echo "Test 3: PDO bind con string vacío ''\n";
    echo "========================================\n";
    $tipo = '';
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM comun.buscagiro_list(NULL, :tipo, 'V')");
    $stmt->bindValue(':tipo', $tipo);
    $stmt->execute();
    $count = $stmt->fetchColumn();
    echo "  ✓ Resultados: " . number_format($count) . "\n\n";

    // Test 4: Conversión PHP de '' a NULL
    echo "Test 4: Convertir '' a NULL en PHP\n";
    echo "========================================\n";
    $tipo = '' ?: null; // Convertir string vacío a null
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM comun.buscagiro_list(NULL, :tipo, 'V')");
    $stmt->bindValue(':tipo', $tipo, PDO::PARAM_NULL);
    $stmt->execute();
    $count = $stmt->fetchColumn();
    echo "  ✓ Resultados: " . number_format($count) . "\n\n";

    echo "✅ Tests completados\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
