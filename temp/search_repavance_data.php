<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "=== BUSCANDO DATOS PARA REPORTE DE AVANCE ===\n\n";

// Buscar rangos de fechas con datos
echo "1. FECHAS CON MAYOR ACTIVIDAD:\n";
$stmt1 = $pdo->query("
    SELECT
        DATE(fecha_acta) as fecha,
        COUNT(*) as total_multas,
        SUM(total) as monto_total,
        COUNT(DISTINCT id_dependencia) as num_dependencias
    FROM comun.multas
    WHERE fecha_acta IS NOT NULL
    AND fecha_acta >= '2024-01-01'
    GROUP BY DATE(fecha_acta)
    HAVING COUNT(*) > 10
    ORDER BY fecha DESC
    LIMIT 10
");
$fechas = $stmt1->fetchAll(PDO::FETCH_ASSOC);
foreach ($fechas as $f) {
    echo "  Fecha: {$f['fecha']} | Multas: {$f['total_multas']} | Monto: \${$f['monto_total']} | Deps: {$f['num_dependencias']}\n";
}

// Buscar rango mensual
echo "\n\n2. DATOS POR MES (últimos meses):\n";
$stmt2 = $pdo->query("
    SELECT
        TO_CHAR(fecha_acta, 'YYYY-MM') as mes,
        COUNT(*) as total_multas,
        SUM(total) as monto_total,
        MIN(fecha_acta) as fecha_inicio,
        MAX(fecha_acta) as fecha_fin
    FROM comun.multas
    WHERE fecha_acta IS NOT NULL
    AND fecha_acta >= '2024-01-01'
    GROUP BY TO_CHAR(fecha_acta, 'YYYY-MM')
    ORDER BY mes DESC
    LIMIT 10
");
$meses = $stmt2->fetchAll(PDO::FETCH_ASSOC);
foreach ($meses as $m) {
    echo "  Mes: {$m['mes']} | Multas: {$m['total_multas']} | Monto: \${$m['monto_total']}\n";
    echo "    Rango: {$m['fecha_inicio']} a {$m['fecha_fin']}\n";
}

// Obtener estadísticas por dependencia en un rango
echo "\n\n3. EJEMPLO DE RANGO DE FECHAS (últimos 30 días con datos):\n";
$stmt3 = $pdo->query("
    SELECT
        id_dependencia,
        COUNT(*) as cantidad_multas,
        SUM(multa) as total_multas,
        SUM(gastos) as total_gastos,
        SUM(total) as total_general,
        MIN(fecha_acta) as fecha_min,
        MAX(fecha_acta) as fecha_max
    FROM comun.multas
    WHERE fecha_acta >= (SELECT MAX(fecha_acta) - INTERVAL '30 days' FROM comun.multas WHERE fecha_acta IS NOT NULL)
    AND fecha_acta IS NOT NULL
    GROUP BY id_dependencia
    ORDER BY cantidad_multas DESC
    LIMIT 10
");
$detalle = $stmt3->fetchAll(PDO::FETCH_ASSOC);
echo "  Rango: {$detalle[0]['fecha_min']} a {$detalle[0]['fecha_max']}\n\n";
foreach ($detalle as $d) {
    echo "  Dep: {$d['id_dependencia']} | Multas: {$d['cantidad_multas']} | Total: \${$d['total_general']}\n";
}

// Generar 3 ejemplos para el formulario
echo "\n\n=== 3 EJEMPLOS PARA EL FORMULARIO ===\n\n";

// Ejemplo 1: Rango reciente
$ej1 = $pdo->query("
    SELECT
        MIN(fecha_acta) as desde,
        MAX(fecha_acta) as hasta,
        COUNT(*) as total
    FROM comun.multas
    WHERE fecha_acta >= (SELECT MAX(fecha_acta) - INTERVAL '7 days' FROM comun.multas WHERE fecha_acta IS NOT NULL)
    AND fecha_acta IS NOT NULL
")->fetch(PDO::FETCH_ASSOC);

echo "EJEMPLO 1: Última semana con datos\n";
echo "  Desde: " . date('Y-m-d', strtotime($ej1['desde'])) . "\n";
echo "  Hasta: " . date('Y-m-d', strtotime($ej1['hasta'])) . "\n";
echo "  Total multas esperadas: {$ej1['total']}\n\n";

// Ejemplo 2: Mes específico
$ej2 = $pdo->query("
    SELECT
        MIN(fecha_acta) as desde,
        MAX(fecha_acta) as hasta,
        COUNT(*) as total
    FROM comun.multas
    WHERE TO_CHAR(fecha_acta, 'YYYY-MM') = (
        SELECT TO_CHAR(MAX(fecha_acta), 'YYYY-MM')
        FROM comun.multas
        WHERE fecha_acta IS NOT NULL
    )
    AND fecha_acta IS NOT NULL
")->fetch(PDO::FETCH_ASSOC);

echo "EJEMPLO 2: Mes completo más reciente\n";
echo "  Desde: " . date('Y-m-d', strtotime($ej2['desde'])) . "\n";
echo "  Hasta: " . date('Y-m-d', strtotime($ej2['hasta'])) . "\n";
echo "  Total multas esperadas: {$ej2['total']}\n\n";

// Ejemplo 3: Rango de 15 días
$ej3 = $pdo->query("
    SELECT
        MIN(fecha_acta) as desde,
        MAX(fecha_acta) as hasta,
        COUNT(*) as total
    FROM comun.multas
    WHERE fecha_acta >= (SELECT MAX(fecha_acta) - INTERVAL '15 days' FROM comun.multas WHERE fecha_acta IS NOT NULL)
    AND fecha_acta IS NOT NULL
")->fetch(PDO::FETCH_ASSOC);

echo "EJEMPLO 3: Últimos 15 días con datos\n";
echo "  Desde: " . date('Y-m-d', strtotime($ej3['desde'])) . "\n";
echo "  Hasta: " . date('Y-m-d', strtotime($ej3['hasta'])) . "\n";
echo "  Total multas esperadas: {$ej3['total']}\n\n";
?>
