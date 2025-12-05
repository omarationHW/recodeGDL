<?php
// Desplegar y probar SP: recaudadora_pruebacalcas
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLEGANDO SP: recaudadora_pruebacalcas ===\n\n";

    // Leer y ejecutar el SQL
    $sqlFile = __DIR__ . '/recaudadora_pruebacalcas.sql';
    $sql = file_get_contents($sqlFile);
    $pdo->exec($sql);

    echo "✅ Stored Procedure desplegado exitosamente\n\n";

    // ===== EJEMPLO 1: Cálculo simple sin mora ni descuento =====
    echo "=== EJEMPLO 1: Importe $1,000 sin mora ni descuento ===\n";
    echo "Parámetros: {\"p_importe_base\": 1000, \"p_meses_mora\": 0, \"p_porc_descuento\": 0}\n\n";

    $sql1 = "SELECT * FROM public.recaudadora_pruebacalcas(1000, 0, 0)";
    $stmt1 = $pdo->query($sql1);
    $result1 = $stmt1->fetchAll(PDO::FETCH_ASSOC);

    foreach ($result1 as $row) {
        echo str_pad($row['concepto'], 25) . " | ";
        echo str_pad(substr($row['descripcion'], 0, 40), 42) . " | ";
        echo str_pad('$' . number_format($row['valor'], 2), 15, ' ', STR_PAD_LEFT) . " | ";
        echo str_pad($row['porcentaje'] . '%', 8, ' ', STR_PAD_LEFT) . "\n";
    }

    // ===== EJEMPLO 2: Con recargos por mora =====
    echo "\n\n=== EJEMPLO 2: Importe $5,000 con 6 meses de mora ===\n";
    echo "Parámetros: {\"p_importe_base\": 5000, \"p_meses_mora\": 6, \"p_porc_descuento\": 0}\n\n";

    $sql2 = "SELECT * FROM public.recaudadora_pruebacalcas(5000, 6, 0)";
    $stmt2 = $pdo->query($sql2);
    $result2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    foreach ($result2 as $row) {
        echo str_pad($row['concepto'], 25) . " | ";
        echo str_pad(substr($row['descripcion'], 0, 40), 42) . " | ";
        echo str_pad('$' . number_format($row['valor'], 2), 15, ' ', STR_PAD_LEFT) . " | ";
        echo str_pad($row['porcentaje'] . '%', 8, ' ', STR_PAD_LEFT) . "\n";
    }

    // ===== EJEMPLO 3: Con descuento =====
    echo "\n\n=== EJEMPLO 3: Importe $10,000 con 12 meses de mora y 20% de descuento ===\n";
    echo "Parámetros: {\"p_importe_base\": 10000, \"p_meses_mora\": 12, \"p_porc_descuento\": 20}\n\n";

    $sql3 = "SELECT * FROM public.recaudadora_pruebacalcas(10000, 12, 20)";
    $stmt3 = $pdo->query($sql3);
    $result3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    foreach ($result3 as $row) {
        echo str_pad($row['concepto'], 25) . " | ";
        echo str_pad(substr($row['descripcion'], 0, 40), 42) . " | ";
        echo str_pad('$' . number_format($row['valor'], 2), 15, ' ', STR_PAD_LEFT) . " | ";
        echo str_pad($row['porcentaje'] . '%', 8, ' ', STR_PAD_LEFT) . "\n";
    }

    echo "\n\n✅ SP FUNCIONANDO CORRECTAMENTE\n";
    echo "\nEJEMPLOS PARA COPIAR EN EL FORMULARIO:\n\n";
    echo "1. Sin mora ni descuento:\n";
    echo '   {"p_importe_base": 1000, "p_meses_mora": 0, "p_porc_descuento": 0}' . "\n\n";

    echo "2. Con 6 meses de mora:\n";
    echo '   {"p_importe_base": 5000, "p_meses_mora": 6, "p_porc_descuento": 0}' . "\n\n";

    echo "3. Con mora y descuento:\n";
    echo '   {"p_importe_base": 10000, "p_meses_mora": 12, "p_porc_descuento": 20}' . "\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
