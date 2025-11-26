<?php
/**
 * Script para probar el SP recaudadora_autdescto con datos reales
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Probando SP recaudadora_autdescto ===\n\n";

    // Primero, obtener una cuenta que tenga descuentos
    echo "Buscando una cuenta con descuentos...\n";
    $sql = "SELECT DISTINCT cvecuenta FROM catastro_gdl.descpred LIMIT 5";
    $stmt = $pdo->query($sql);
    $cuentas = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (empty($cuentas)) {
        echo "❌ No se encontraron cuentas con descuentos\n";
        exit(1);
    }

    echo "Cuentas encontradas: " . implode(", ", $cuentas) . "\n\n";

    // Probar con la primera cuenta
    $cuenta = $cuentas[0];
    echo "Probando con cuenta: $cuenta\n";
    echo str_repeat("-", 80) . "\n";

    $stmt = $pdo->prepare("SELECT * FROM recaudadora_autdescto(:cuenta)");
    $stmt->execute(['cuenta' => $cuenta]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "✅ SP ejecutado correctamente\n";
    echo "Resultados: " . count($results) . " registros\n\n";

    if (count($results) > 0) {
        echo "Primeros 3 resultados:\n";
        foreach (array_slice($results, 0, 3) as $idx => $row) {
            echo "\nRegistro " . ($idx + 1) . ":\n";
            foreach ($row as $key => $value) {
                $value = trim($value ?? '');
                if ($value !== '') {
                    echo "  $key: $value\n";
                }
            }
        }
    } else {
        echo "No se encontraron resultados para esta cuenta\n";
    }

    // Probar con cuenta inexistente
    echo "\n" . str_repeat("=", 80) . "\n";
    echo "Probando con cuenta inexistente (99999):\n";
    $stmt = $pdo->prepare("SELECT * FROM recaudadora_autdescto('99999')");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "✅ SP ejecutado correctamente\n";
    echo "Resultados: " . count($results) . " registros (esperado: 0)\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
