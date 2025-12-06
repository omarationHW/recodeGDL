<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "📊 ANÁLISIS ADICIONAL DE ta_11_ade_loc_canc\n";
echo "==========================================\n\n";

// Estadísticas generales
$dates = $pdo->query("
    SELECT
        MIN(fecha_alta) as min_fecha,
        MAX(fecha_alta) as max_fecha,
        COUNT(DISTINCT id_local) as locales,
        SUM(importe) as total_importe
    FROM publico.ta_11_ade_loc_canc
")->fetch(PDO::FETCH_ASSOC);

echo "📅 Rango de fechas:\n";
echo "   Fecha más antigua: {$dates['min_fecha']}\n";
echo "   Fecha más reciente: {$dates['max_fecha']}\n";
echo "   Locales distintos: {$dates['locales']}\n";
echo "   Total cancelado: $" . number_format($dates['total_importe'], 2) . "\n\n";

// Distribución por clave
echo "🔑 Distribución por clave de cancelación:\n\n";
$claves = $pdo->query("
    SELECT
        clave_canc,
        COUNT(*) as total,
        SUM(importe) as importe_total
    FROM publico.ta_11_ade_loc_canc
    GROUP BY clave_canc
    ORDER BY total DESC
")->fetchAll(PDO::FETCH_ASSOC);

foreach ($claves as $c) {
    echo "   Clave [{$c['clave_canc']}]: {$c['total']} registros | $" . number_format($c['importe_total'], 2) . "\n";
}

// Buscar relación con ta_11_locales
echo "\n\n🔗 Verificando relación con ta_11_locales:\n\n";
$rel = $pdo->query("
    SELECT
        COUNT(DISTINCT c.id_local) as cancelados,
        (SELECT COUNT(*) FROM publico.ta_11_locales) as total_locales
    FROM publico.ta_11_ade_loc_canc c
")->fetch(PDO::FETCH_ASSOC);

echo "   Locales con cancelaciones: {$rel['cancelados']}\n";
echo "   Total de locales: {$rel['total_locales']}\n";
echo "   % con cancelaciones: " . round(($rel['cancelados'] / $rel['total_locales']) * 100, 2) . "%\n";

// Buscar en archivos SQL
echo "\n\n📄 Archivos SQL relacionados:\n\n";
$patterns = ['*RepAdeud*', '*Cond*', '*Prescr*', '*Canc*'];
$found = [];

foreach ($patterns as $pattern) {
    $files = glob(__DIR__ . '/../RefactorX/Base/mercados/database/database/' . $pattern . '.sql');
    foreach ($files as $file) {
        $found[] = basename($file);
    }
}

$found = array_unique($found);
sort($found);

foreach ($found as $file) {
    echo "   - $file\n";
}

if (count($found) == 0) {
    echo "   ⚠️  No se encontraron archivos SQL relacionados\n";
}
