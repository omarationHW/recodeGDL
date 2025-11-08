<?php
// Analizar en detalle la tabla comun.observ

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== ANÁLISIS DETALLADO DE comun.observ ===\n\n";

    // Estadísticas generales
    echo "📊 Estadísticas generales:\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $db->query("
        SELECT
            COUNT(*) as total_registros,
            COUNT(DISTINCT folio) as folios_unicos,
            COUNT(DISTINCT axofol) as axofol_unicos,
            MIN(fecha) as fecha_min,
            MAX(fecha) as fecha_max
        FROM comun.observ
    ");
    $stats = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total registros: " . number_format($stats['total_registros']) . "\n";
    echo "Folios únicos: " . number_format($stats['folios_unicos']) . "\n";
    echo "Axofol únicos: {$stats['axofol_unicos']}\n";
    echo "Fecha mínima: {$stats['fecha_min']}\n";
    echo "Fecha máxima: {$stats['fecha_max']}\n\n";

    // Muestra de registros
    echo "📝 Muestra de 10 registros recientes:\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $db->query("
        SELECT * FROM comun.observ
        ORDER BY fecha DESC NULLS LAST, folio DESC
        LIMIT 10
    ");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($rows as $i => $row) {
        echo ($i + 1) . ". ";
        echo "Folio: {$row['folio']}, ";
        echo "Axofol: {$row['axofol']}, ";
        echo "Cve: {$row['cve']}, ";
        echo "Observ: " . trim($row['observ']) . ", ";
        echo "Fecha: {$row['fecha']}, ";
        echo "Capturo: " . trim($row['capturo']) . "\n";
    }
    echo "\n";

    // Distribución por cve
    echo "📈 Distribución por 'cve':\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $db->query("
        SELECT cve, COUNT(*) as total
        FROM comun.observ
        GROUP BY cve
        ORDER BY total DESC
        LIMIT 10
    ");
    $cves = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($cves as $cve) {
        echo "Cve {$cve['cve']}: " . number_format($cve['total']) . " registros\n";
    }
    echo "\n";

    // Verificar si folio se relaciona con trámites
    echo "🔍 Verificando relación con trámites:\n";
    echo str_repeat("-", 80) . "\n";

    // Buscar si existe tabla de trámites
    $stmt = $db->query("
        SELECT tablename FROM pg_tables
        WHERE (schemaname = 'public' OR schemaname = 'comun')
          AND (tablename LIKE '%tramite%' OR tablename LIKE '%licencia%')
        LIMIT 10
    ");
    $tramites_tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Tablas de trámites/licencias encontradas:\n";
    foreach ($tramites_tables as $t) {
        echo "  - {$t['tablename']}\n";
    }

    echo "\n✅ ANÁLISIS COMPLETO\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
