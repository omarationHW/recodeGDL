<?php
/**
 * Prueba los 4 SPs corregidos
 */

$pdo = new PDO(
    "pgsql:host=192.168.6.146;port=5432;dbname=mercados",
    "refact",
    "FF)-BQk2",
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);

echo "🧪 Probando 4 SPs corregidos:\n\n";

// Test 1: RptPagosCaja
echo "1️⃣ sp_rpt_pagos_caja...\n";
try {
    $stmt = $pdo->query("SELECT * FROM public.sp_rpt_pagos_caja(1, '2024-01-01', '2024-12-31', NULL) LIMIT 5");
    $count = $stmt->rowCount();
    echo "   ✅ OK - $count registros encontrados\n\n";
} catch (PDOException $e) {
    echo "   ❌ ERROR: " . substr($e->getMessage(), 0, 100) . "...\n\n";
}

// Test 2: RptIngresos
echo "2️⃣ sp_rpt_ingresos_locales...\n";
try {
    $stmt = $pdo->query("SELECT * FROM public.sp_rpt_ingresos_locales(1, 2024, NULL, NULL) LIMIT 5");
    $count = $stmt->rowCount();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✅ OK - $count registros encontrados\n";
    if ($count > 0) {
        echo "   📌 Seccion ejemplo: '{$rows[0]['seccion']}' (tipo: " . gettype($rows[0]['seccion']) . ")\n";
    }
    echo "\n";
} catch (PDOException $e) {
    echo "   ❌ ERROR: " . substr($e->getMessage(), 0, 100) . "...\n\n";
}

// Test 3: RptPagosDetalle
echo "3️⃣ sp_rpt_pagos_detalle...\n";
try {
    $stmt = $pdo->query("SELECT * FROM public.sp_rpt_pagos_detalle(1, 1, '2024-01-01', '2024-12-31') LIMIT 5");
    $count = $stmt->rowCount();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✅ OK - $count registros encontrados\n";
    if ($count > 0) {
        echo "   📌 Usuario ejemplo: '{$rows[0]['usuario']}'\n";
    }
    echo "\n";
} catch (PDOException $e) {
    echo "   ❌ ERROR: " . substr($e->getMessage(), 0, 100) . "...\n\n";
}

// Test 4: RptPagosGrl
echo "4️⃣ sp_rpt_pagos_grl...\n";
try {
    $stmt = $pdo->query("SELECT * FROM public.sp_rpt_pagos_grl(1, 2024, NULL, NULL) LIMIT 5");
    $count = $stmt->rowCount();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✅ OK - $count registros encontrados\n";
    if ($count > 0) {
        echo "   📌 Seccion ejemplo: '{$rows[0]['seccion']}' (tipo: " . gettype($rows[0]['seccion']) . ")\n";
    }
    echo "\n";
} catch (PDOException $e) {
    echo "   ❌ ERROR: " . substr($e->getMessage(), 0, 100) . "...\n\n";
}

echo "✅ Pruebas completadas\n";
?>
