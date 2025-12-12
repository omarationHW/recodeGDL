<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== PRUEBAS COMPLETAS DE CAPTURA DE DIFERENCIAS ===\n\n";

// Test 1: Inserción válida completa
echo "Test 1: Inserción válida con todos los campos\n";
$json1 = json_encode([
    'axo' => 2025,
    'cvecuenta' => 200001,
    'monto' => 2500.50,
    'status' => 'A'
]);

$stmt = $pdo->prepare("SELECT * FROM public.recaudadora_captura_dif(:p_datos)");
$stmt->execute(['p_datos' => $json1]);
$result = $stmt->fetch(PDO::FETCH_ASSOC);

echo "  ✅ Success: " . ($result['success'] ? 'TRUE' : 'FALSE') . "\n";
echo "  📝 Message: {$result['message']}\n";
if ($result['id_insertado']) {
    echo "  🔢 ID Insertado: {$result['id_insertado']}\n";
}
echo "\n";

// Test 2: Inserción sin status (debe usar 'A' por defecto)
echo "Test 2: Inserción sin status (debe usar 'A' por defecto)\n";
$json2 = json_encode([
    'axo' => 2024,
    'cvecuenta' => 200002,
    'monto' => 1800.00
]);

$stmt = $pdo->prepare("SELECT * FROM public.recaudadora_captura_dif(:p_datos)");
$stmt->execute(['p_datos' => $json2]);
$result = $stmt->fetch(PDO::FETCH_ASSOC);

echo "  ✅ Success: " . ($result['success'] ? 'TRUE' : 'FALSE') . "\n";
echo "  📝 Message: {$result['message']}\n\n";

// Verificar que se insertó con status 'A'
if ($result['id_insertado']) {
    $check = $pdo->query("
        SELECT status
        FROM public.diferencias_prediales
        WHERE id = {$result['id_insertado']}
    ")->fetch(PDO::FETCH_ASSOC);
    echo "  ✅ Verificación: Status insertado = '{$check['status']}'\n\n";
}

// Test 3: Inserción con status 'I' (Inactivo)
echo "Test 3: Inserción con status 'I' (Inactivo)\n";
$json3 = json_encode([
    'axo' => 2025,
    'cvecuenta' => 200003,
    'monto' => 950.25,
    'status' => 'I'
]);

$stmt = $pdo->prepare("SELECT * FROM public.recaudadora_captura_dif(:p_datos)");
$stmt->execute(['p_datos' => $json3]);
$result = $stmt->fetch(PDO::FETCH_ASSOC);

echo "  ✅ Success: " . ($result['success'] ? 'TRUE' : 'FALSE') . "\n";
echo "  📝 Message: {$result['message']}\n\n";

// Test 4: Falta campo requerido (axo)
echo "Test 4: Error - Falta campo requerido 'axo'\n";
$json4 = json_encode([
    'cvecuenta' => 200004,
    'monto' => 1500.00
]);

$stmt = $pdo->prepare("SELECT * FROM public.recaudadora_captura_dif(:p_datos)");
$stmt->execute(['p_datos' => $json4]);
$result = $stmt->fetch(PDO::FETCH_ASSOC);

echo "  ❌ Success: " . ($result['success'] ? 'TRUE' : 'FALSE') . "\n";
echo "  📝 Message: {$result['message']}\n\n";

// Test 5: Falta campo requerido (cvecuenta)
echo "Test 5: Error - Falta campo requerido 'cvecuenta'\n";
$json5 = json_encode([
    'axo' => 2025,
    'monto' => 1500.00
]);

$stmt = $pdo->prepare("SELECT * FROM public.recaudadora_captura_dif(:p_datos)");
$stmt->execute(['p_datos' => $json5]);
$result = $stmt->fetch(PDO::FETCH_ASSOC);

echo "  ❌ Success: " . ($result['success'] ? 'TRUE' : 'FALSE') . "\n";
echo "  📝 Message: {$result['message']}\n\n";

// Test 6: Falta campo requerido (monto)
echo "Test 6: Error - Falta campo requerido 'monto'\n";
$json6 = json_encode([
    'axo' => 2025,
    'cvecuenta' => 200005
]);

$stmt = $pdo->prepare("SELECT * FROM public.recaudadora_captura_dif(:p_datos)");
$stmt->execute(['p_datos' => $json6]);
$result = $stmt->fetch(PDO::FETCH_ASSOC);

echo "  ❌ Success: " . ($result['success'] ? 'TRUE' : 'FALSE') . "\n";
echo "  📝 Message: {$result['message']}\n\n";

// Test 7: Año fuera de rango (muy antiguo)
echo "Test 7: Error - Año fuera de rango (1999)\n";
$json7 = json_encode([
    'axo' => 1999,
    'cvecuenta' => 200006,
    'monto' => 1000.00
]);

$stmt = $pdo->prepare("SELECT * FROM public.recaudadora_captura_dif(:p_datos)");
$stmt->execute(['p_datos' => $json7]);
$result = $stmt->fetch(PDO::FETCH_ASSOC);

echo "  ❌ Success: " . ($result['success'] ? 'TRUE' : 'FALSE') . "\n";
echo "  📝 Message: {$result['message']}\n\n";

// Test 8: Año fuera de rango (muy futuro)
echo "Test 8: Error - Año fuera de rango (2051)\n";
$json8 = json_encode([
    'axo' => 2051,
    'cvecuenta' => 200007,
    'monto' => 1000.00
]);

$stmt = $pdo->prepare("SELECT * FROM public.recaudadora_captura_dif(:p_datos)");
$stmt->execute(['p_datos' => $json8]);
$result = $stmt->fetch(PDO::FETCH_ASSOC);

echo "  ❌ Success: " . ($result['success'] ? 'TRUE' : 'FALSE') . "\n";
echo "  📝 Message: {$result['message']}\n\n";

// Test 9: Monto negativo
echo "Test 9: Error - Monto negativo\n";
$json9 = json_encode([
    'axo' => 2025,
    'cvecuenta' => 200008,
    'monto' => -500.00
]);

$stmt = $pdo->prepare("SELECT * FROM public.recaudadora_captura_dif(:p_datos)");
$stmt->execute(['p_datos' => $json9]);
$result = $stmt->fetch(PDO::FETCH_ASSOC);

echo "  ❌ Success: " . ($result['success'] ? 'TRUE' : 'FALSE') . "\n";
echo "  📝 Message: {$result['message']}\n\n";

// Test 10: Monto cero
echo "Test 10: Error - Monto cero\n";
$json10 = json_encode([
    'axo' => 2025,
    'cvecuenta' => 200009,
    'monto' => 0
]);

$stmt = $pdo->prepare("SELECT * FROM public.recaudadora_captura_dif(:p_datos)");
$stmt->execute(['p_datos' => $json10]);
$result = $stmt->fetch(PDO::FETCH_ASSOC);

echo "  ❌ Success: " . ($result['success'] ? 'TRUE' : 'FALSE') . "\n";
echo "  📝 Message: {$result['message']}\n\n";

// Test 11: Status inválido
echo "Test 11: Error - Status inválido ('X')\n";
$json11 = json_encode([
    'axo' => 2025,
    'cvecuenta' => 200010,
    'monto' => 1500.00,
    'status' => 'X'
]);

$stmt = $pdo->prepare("SELECT * FROM public.recaudadora_captura_dif(:p_datos)");
$stmt->execute(['p_datos' => $json11]);
$result = $stmt->fetch(PDO::FETCH_ASSOC);

echo "  ❌ Success: " . ($result['success'] ? 'TRUE' : 'FALSE') . "\n";
echo "  📝 Message: {$result['message']}\n\n";

// Test 12: JSON mal formado
echo "Test 12: Error - JSON mal formado\n";
$json12 = '{axo: 2025, cvecuenta: 200011}'; // Sin comillas en las claves

$stmt = $pdo->prepare("SELECT * FROM public.recaudadora_captura_dif(:p_datos)");
$stmt->execute(['p_datos' => $json12]);
$result = $stmt->fetch(PDO::FETCH_ASSOC);

echo "  ❌ Success: " . ($result['success'] ? 'TRUE' : 'FALSE') . "\n";
echo "  📝 Message: {$result['message']}\n\n";

// Mostrar estadísticas finales
echo "=== ESTADÍSTICAS FINALES ===\n\n";

$stats = $pdo->query("
    SELECT
        COUNT(*) as total,
        COUNT(CASE WHEN status = 'A' THEN 1 END) as activos,
        COUNT(CASE WHEN status = 'I' THEN 1 END) as inactivos,
        MIN(axo) as anio_minimo,
        MAX(axo) as anio_maximo,
        SUM(monto) as monto_total,
        AVG(monto) as monto_promedio
    FROM public.diferencias_prediales
")->fetch(PDO::FETCH_ASSOC);

echo "📊 Total de registros: {$stats['total']}\n";
echo "✅ Activos: {$stats['activos']}\n";
echo "⛔ Inactivos: {$stats['inactivos']}\n";
echo "📅 Rango de años: {$stats['anio_minimo']} - {$stats['anio_maximo']}\n";
echo "💰 Monto total: $" . number_format($stats['monto_total'], 2) . "\n";
echo "📈 Monto promedio: $" . number_format($stats['monto_promedio'], 2) . "\n\n";

// Desglose por año
echo "📅 Desglose por año:\n";
$breakdown = $pdo->query("
    SELECT
        axo,
        COUNT(*) as cantidad,
        SUM(monto) as total,
        COUNT(CASE WHEN status = 'A' THEN 1 END) as activos
    FROM public.diferencias_prediales
    GROUP BY axo
    ORDER BY axo
");

while ($row = $breakdown->fetch(PDO::FETCH_ASSOC)) {
    echo "  {$row['axo']}: {$row['cantidad']} registros | ";
    echo "$" . number_format($row['total'], 2) . " | ";
    echo "{$row['activos']} activos\n";
}

echo "\n✅ Todas las pruebas completadas!\n";
