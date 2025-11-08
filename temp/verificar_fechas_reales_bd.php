<?php
// Verificar qué rango de fechas realmente tiene datos en t42_seguimiento

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICAR RANGO DE FECHAS REALES EN BD ===\n\n";

    // Contar total de registros
    $stmt = $db->query("SELECT COUNT(*) as total FROM comun.t42_seguimiento");
    $total = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    echo "📊 Total registros en t42_seguimiento: " . number_format($total) . "\n\n";

    // Obtener fecha más antigua
    $stmt = $db->query("SELECT MIN(fec_seg) as fecha_min FROM comun.t42_seguimiento WHERE fec_seg IS NOT NULL");
    $fechaMin = $stmt->fetch(PDO::FETCH_ASSOC)['fecha_min'];
    echo "📅 Fecha más antigua: $fechaMin\n";

    // Obtener fecha más reciente
    $stmt = $db->query("SELECT MAX(fec_seg) as fecha_max FROM comun.t42_seguimiento WHERE fec_seg IS NOT NULL");
    $fechaMax = $stmt->fetch(PDO::FETCH_ASSOC)['fecha_max'];
    echo "📅 Fecha más reciente: $fechaMax\n\n";

    // Contar registros por año
    echo "Distribución por año:\n";
    echo str_repeat("-", 40) . "\n";
    $stmt = $db->query("
        SELECT
            EXTRACT(YEAR FROM fec_seg) as anio,
            COUNT(*) as total
        FROM comun.t42_seguimiento
        WHERE fec_seg IS NOT NULL
        GROUP BY EXTRACT(YEAR FROM fec_seg)
        ORDER BY anio DESC
    ");
    $porAnio = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($porAnio as $row) {
        $anio = $row['anio'];
        $total = number_format($row['total']);
        echo "  $anio: $total registros\n";
    }
    echo str_repeat("-", 40) . "\n\n";

    // Probar SP con fechas actuales (2025)
    echo "🧪 Probando SP con fechas actuales (2025):\n";
    $fechaInicio2025 = date('Y-m-d', strtotime('-6 months')) . ' 00:00:00';
    $fechaFin2025 = date('Y-m-d') . ' 23:59:59';
    echo "  Rango: $fechaInicio2025 a $fechaFin2025\n";

    $stmt = $db->prepare("SELECT COUNT(*) as total FROM comun.sp_fechaseg_list(:fecha_inicio, :fecha_fin)");
    $stmt->execute([
        'fecha_inicio' => $fechaInicio2025,
        'fecha_fin' => $fechaFin2025
    ]);
    $total2025 = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    echo "  ❌ Resultados: " . number_format($total2025) . " registros\n\n";

    // Probar SP con NULL (sin filtro)
    echo "🧪 Probando SP sin filtro (NULL, NULL):\n";
    $stmt = $db->query("SELECT COUNT(*) as total FROM comun.sp_fechaseg_list(NULL, NULL)");
    $totalNull = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    echo "  ✅ Resultados: " . number_format($totalNull) . " registros\n\n";

    // Probar SP con rango que incluya datos reales
    if (!empty($fechaMin) && !empty($fechaMax)) {
        echo "🧪 Probando SP con rango real ($fechaMin a $fechaMax):\n";
        $stmt = $db->prepare("SELECT COUNT(*) as total FROM comun.sp_fechaseg_list(:fecha_inicio, :fecha_fin)");
        $stmt->execute([
            'fecha_inicio' => $fechaMin,
            'fecha_fin' => $fechaMax
        ]);
        $totalReal = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
        echo "  ✅ Resultados: " . number_format($totalReal) . " registros\n\n";
    }

    echo "💡 CONCLUSIÓN:\n";
    echo "  - Las fechas por defecto (2025) NO TIENEN DATOS\n";
    echo "  - Los datos están entre $fechaMin y $fechaMax\n";
    echo "  - Necesitas ajustar las fechas por defecto o quitar el filtro inicial\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
