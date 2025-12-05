<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "=== BUSCANDO DATOS PARA RELACIÓN MENSUAL ===\n\n";

// Buscar multas por mes y año
echo "1. MULTAS POR MES Y AÑO:\n";
$stmt1 = $pdo->query("
    SELECT
        EXTRACT(YEAR FROM fecha_acta) as anio,
        EXTRACT(MONTH FROM fecha_acta) as mes,
        COUNT(*) as total_multas,
        SUM(total) as monto_total
    FROM comun.multas
    WHERE fecha_acta IS NOT NULL
    GROUP BY EXTRACT(YEAR FROM fecha_acta), EXTRACT(MONTH FROM fecha_acta)
    HAVING COUNT(*) > 10
    ORDER BY anio DESC, mes DESC
    LIMIT 10
");
$multas_mes = $stmt1->fetchAll(PDO::FETCH_ASSOC);
foreach ($multas_mes as $m) {
    echo "  Año: {$m['anio']} | Mes: {$m['mes']} | Multas: {$m['total_multas']} | Total: \${$m['monto_total']}\n";
}

// Buscar años disponibles
echo "\n\n2. AÑOS DISPONIBLES CON DATOS:\n";
$stmt2 = $pdo->query("
    SELECT DISTINCT
        EXTRACT(YEAR FROM fecha_acta) as anio,
        COUNT(*) as registros
    FROM comun.multas
    WHERE fecha_acta IS NOT NULL
    GROUP BY EXTRACT(YEAR FROM fecha_acta)
    ORDER BY anio DESC
    LIMIT 10
");
$anios = $stmt2->fetchAll(PDO::FETCH_ASSOC);
foreach ($anios as $a) {
    echo "  Año: {$a['anio']} - {$a['registros']} registros\n";
}

// Obtener detalles de un mes específico
echo "\n\n3. DETALLE DE UN MES ESPECÍFICO (Año 2004, Mes 12):\n";
$stmt3 = $pdo->query("
    SELECT
        id_dependencia,
        COUNT(*) as cantidad_multas,
        SUM(multa) as total_multa,
        SUM(gastos) as total_gastos,
        SUM(total) as total
    FROM comun.multas
    WHERE EXTRACT(YEAR FROM fecha_acta) = 2004
    AND EXTRACT(MONTH FROM fecha_acta) = 12
    GROUP BY id_dependencia
    ORDER BY id_dependencia
    LIMIT 10
");
$detalle = $stmt3->fetchAll(PDO::FETCH_ASSOC);
foreach ($detalle as $d) {
    echo "  Dep: {$d['id_dependencia']} | Multas: {$d['cantidad_multas']} | Total Multa: \${$d['total_multa']} | Total: \${$d['total']}\n";
}

// Ejemplos específicos para el formulario
echo "\n\n=== 3 EJEMPLOS PARA EL FORMULARIO ===\n\n";
$ejemplo1 = $pdo->query("
    SELECT
        EXTRACT(YEAR FROM fecha_acta) as anio,
        EXTRACT(MONTH FROM fecha_acta) as mes
    FROM comun.multas
    WHERE fecha_acta IS NOT NULL
    GROUP BY EXTRACT(YEAR FROM fecha_acta), EXTRACT(MONTH FROM fecha_acta)
    HAVING COUNT(*) > 100
    ORDER BY anio DESC, mes DESC
    LIMIT 3
")->fetchAll(PDO::FETCH_ASSOC);

$i = 1;
foreach ($ejemplo1 as $e) {
    echo "EJEMPLO {$i}:\n";
    echo "  Mes: " . intval($e['mes']) . "\n";
    echo "  Año: " . intval($e['anio']) . "\n\n";
    $i++;
}

?>
