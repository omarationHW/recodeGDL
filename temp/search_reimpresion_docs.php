<?php
// Buscar documentos reales para reimpresión
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "=== BUSCANDO DOCUMENTOS PARA REIMPRESIÓN ===\n\n";

// 1. Buscar multas
echo "1. MULTAS (comun.multas):\n";
$stmt1 = $pdo->query("
    SELECT
        id_multa,
        id_dependencia,
        axo_acta,
        num_acta,
        fecha_acta,
        contribuyente,
        folio,
        calificacion
    FROM comun.multas
    WHERE id_multa IS NOT NULL
    ORDER BY fecha_acta DESC
    LIMIT 5
");
$multas = $stmt1->fetchAll(PDO::FETCH_ASSOC);
foreach ($multas as $m) {
    echo "  Folio/ID: {$m['id_multa']} | Contribuyente: {$m['contribuyente']} | Fecha: {$m['fecha_acta']} | Dep: {$m['id_dependencia']}\n";
}

// 2. Buscar en tabla de pagos/recibos
echo "\n2. BUSCANDO TABLAS DE RECIBOS/PAGOS:\n";
$stmt2 = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_schema IN ('comun', 'db_ingresos', 'public')
    AND (table_name LIKE '%pago%' OR table_name LIKE '%recibo%' OR table_name LIKE '%caja%')
    LIMIT 10
");
$tables = $stmt2->fetchAll(PDO::FETCH_ASSOC);
foreach ($tables as $t) {
    echo "  {$t['table_schema']}.{$t['table_name']}\n";
}

// 3. Buscar requerimientos
echo "\n3. BUSCANDO TABLAS DE REQUERIMIENTOS:\n";
$stmt3 = $pdo->query("
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_schema IN ('comun', 'db_ingresos', 'public')
    AND (table_name LIKE '%req%' OR table_name LIKE '%requerimiento%')
    LIMIT 10
");
$reqs = $stmt3->fetchAll(PDO::FETCH_ASSOC);
foreach ($reqs as $r) {
    echo "  {$r['table_schema']}.{$r['table_name']}\n";
}

// 4. Obtener ejemplos específicos de multas con todos los campos
echo "\n\n=== 3 EJEMPLOS REALES DE MULTAS PARA REIMPRIMIR ===\n\n";
$stmt4 = $pdo->query("
    SELECT
        id_multa,
        id_dependencia,
        axo_acta,
        num_acta,
        fecha_acta,
        contribuyente,
        domicilio,
        folio,
        calificacion,
        importe
    FROM comun.multas
    WHERE id_multa IN (
        SELECT id_multa FROM comun.multas WHERE id_multa IS NOT NULL ORDER BY fecha_acta DESC LIMIT 100
    )
    AND contribuyente IS NOT NULL
    ORDER BY fecha_acta DESC
    LIMIT 3
");
$ejemplos = $stmt4->fetchAll(PDO::FETCH_ASSOC);
$i = 1;
foreach ($ejemplos as $e) {
    echo "EJEMPLO {$i}:\n";
    echo json_encode($e, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT) . "\n\n";
    $i++;
}

?>
