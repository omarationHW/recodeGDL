<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== PRUEBAS DE REIMPRESIÓN DE DOCUMENTOS ===\n\n";

// Prueba 1: Buscar por folio específico (multa)
echo "Prueba 1: Buscar multa por folio 415010\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reimpfrm(415010, 'multa', NULL, 'original')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: " . count($rows) . " documento(s)\n";
if (count($rows) > 0) {
    $r = $rows[0];
    echo "  Folio: " . $r["folio"] . " | Tipo: " . $r["tipo_documento"] . "\n";
    echo "  Contribuyente: " . $r["contribuyente"] . "\n";
    echo "  Acta: " . $r["num_acta"] . "/" . $r["axo_acta"] . " | Dep: " . $r["dependencia"] . "\n";
    echo "  Importe: $" . number_format($r["importe"], 2) . " | Estatus: " . $r["estatus"] . "\n\n";
}

// Prueba 2: Buscar todas las multas (sin folio específico)
echo "Prueba 2: Buscar todas las multas\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reimpfrm(NULL, 'multa', NULL, 'original')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: " . count($rows) . " multas encontradas\n";
if (count($rows) > 0) {
    echo "  Primeras 3 multas:\n";
    for ($i = 0; $i < min(3, count($rows)); $i++) {
        $r = $rows[$i];
        echo "    - Folio " . $r["folio"] . ": " . $r["contribuyente"] . " ($" . number_format($r["importe"], 2) . " - " . $r["estatus"] . ")\n";
    }
    echo "\n";
}

// Prueba 3: Buscar todos los recibos
echo "Prueba 3: Buscar todos los recibos de pago\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reimpfrm(NULL, 'recibo', NULL, 'original')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: " . count($rows) . " recibos encontrados\n";
if (count($rows) > 0) {
    echo "  Primeros 3 recibos:\n";
    for ($i = 0; $i < min(3, count($rows)); $i++) {
        $r = $rows[$i];
        echo "    - Folio " . $r["folio"] . ": " . $r["contribuyente"] . " ($" . number_format($r["importe"], 2) . ")\n";
    }
    echo "\n";
}

// Prueba 4: Buscar requerimientos
echo "Prueba 4: Buscar requerimientos de pago\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reimpfrm(NULL, 'requerimiento', NULL, 'original')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: " . count($rows) . " requerimientos encontrados\n";
if (count($rows) > 0) {
    echo "  Primeros 3 requerimientos:\n";
    for ($i = 0; $i < min(3, count($rows)); $i++) {
        $r = $rows[$i];
        echo "    - Folio " . $r["folio"] . ": " . $r["contribuyente"] . " ($" . number_format($r["importe"], 2) . " - " . $r["estatus"] . ")\n";
    }
    echo "\n";
}

// Prueba 5: Buscar actas administrativas
echo "Prueba 5: Buscar actas administrativas\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reimpfrm(NULL, 'acta', NULL, 'original')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: " . count($rows) . " actas encontradas\n";
if (count($rows) > 0) {
    echo "  Primeras 3 actas:\n";
    for ($i = 0; $i < min(3, count($rows)); $i++) {
        $r = $rows[$i];
        echo "    - Folio " . $r["folio"] . ": " . $r["contribuyente"] . " (Acta " . $r["num_acta"] . " - " . $r["estatus"] . ")\n";
    }
    echo "\n";
}

// Prueba 6: Filtrar por dependencia 3 (Tránsito)
echo "Prueba 6: Buscar documentos de Tránsito (Dep. 3)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reimpfrm(NULL, '', 3, 'original')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: " . count($rows) . " documentos de Tránsito\n";
if (count($rows) > 0) {
    // Contar por tipo
    $tipos = [];
    foreach ($rows as $r) {
        $tipo = $r['tipo_documento'];
        if (!isset($tipos[$tipo])) $tipos[$tipo] = 0;
        $tipos[$tipo]++;
    }
    echo "  Distribución por tipo:\n";
    foreach ($tipos as $tipo => $cantidad) {
        echo "    - $tipo: $cantidad documentos\n";
    }
    echo "\n";
}

// Prueba 7: Filtrar por dependencia 7 (Reglamentos)
echo "Prueba 7: Buscar documentos de Reglamentos (Dep. 7)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reimpfrm(NULL, '', 7, 'original')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: " . count($rows) . " documentos de Reglamentos\n";
if (count($rows) > 0) {
    // Contar por tipo
    $tipos = [];
    foreach ($rows as $r) {
        $tipo = $r['tipo_documento'];
        if (!isset($tipos[$tipo])) $tipos[$tipo] = 0;
        $tipos[$tipo]++;
    }
    echo "  Distribución por tipo:\n";
    foreach ($tipos as $tipo => $cantidad) {
        echo "    - $tipo: $cantidad documentos\n";
    }
    echo "\n";
}

// Prueba 8: Buscar multas pendientes de Tránsito
echo "Prueba 8: Buscar multas de Tránsito (filtros combinados)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reimpfrm(NULL, 'multa', 3, 'original')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: " . count($rows) . " multas de Tránsito\n";
if (count($rows) > 0) {
    $pendientes = array_filter($rows, fn($r) => $r['estatus'] === 'PENDIENTE');
    $pagadas = array_filter($rows, fn($r) => $r['estatus'] === 'PAGADO');
    echo "  - Pendientes: " . count($pendientes) . "\n";
    echo "  - Pagadas: " . count($pagadas) . "\n\n";
}

// Estadísticas generales
echo "Estadísticas generales:\n";
$stats = $pdo->query("
    SELECT
        tipo_documento,
        estatus,
        COUNT(*) as cantidad,
        SUM(importe) as total
    FROM publico.documentos_reimprimir
    GROUP BY tipo_documento, estatus
    ORDER BY tipo_documento, estatus
")->fetchAll(PDO::FETCH_ASSOC);

echo "  Distribución por tipo y estatus:\n";
foreach ($stats as $stat) {
    echo "    - {$stat['tipo_documento']} / {$stat['estatus']}: {$stat['cantidad']} docs ($" . number_format($stat['total'], 2) . ")\n";
}

echo "\n✅ Todas las pruebas completadas!\n";
