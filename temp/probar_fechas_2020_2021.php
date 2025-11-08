<?php
// Probar SP con las fechas por defecto del componente (2020-01-01 a 2021-12-31)

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== PROBAR SP CON FECHAS POR DEFECTO DEL COMPONENTE ===\n\n";

    // Probar con fechas 2020-01-01 a 2021-12-31 (las nuevas por defecto)
    echo "🧪 Probando SP con fechas 2020-01-01 a 2021-12-31:\n";
    echo str_repeat("-", 80) . "\n";

    $fechaInicio = '2020-01-01 00:00:00';
    $fechaFin = '2021-12-31 23:59:59';

    echo "📅 Fecha inicio: $fechaInicio\n";
    echo "📅 Fecha fin: $fechaFin\n\n";

    $stmt = $db->prepare("SELECT * FROM comun.sp_fechaseg_list(:fecha_inicio, :fecha_fin) LIMIT 10");
    $stmt->execute([
        'fecha_inicio' => $fechaInicio,
        'fecha_fin' => $fechaFin
    ]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "📊 Total registros obtenidos: " . count($results) . "\n\n";

    if (count($results) > 0) {
        echo "✅ EL SP RETORNA DATOS CON LAS FECHAS POR DEFECTO\n\n";

        echo "Primeros 5 registros:\n";
        echo str_repeat("-", 80) . "\n";
        foreach ($results as $i => $row) {
            if ($i < 5) {
                $fecha = $row['fec_seg'] ?? 'NULL';
                $obs = substr($row['observacion'] ?? 'Sin observación', 0, 40);
                echo ($i + 1) . ". ID: {$row['id']} - Fecha: {$fecha} - Obs: {$obs}\n";
            }
        }
        echo str_repeat("-", 80) . "\n\n";

        // Contar total en ese rango
        $stmt2 = $db->prepare("SELECT COUNT(*) as total FROM comun.sp_fechaseg_list(:fecha_inicio, :fecha_fin)");
        $stmt2->execute([
            'fecha_inicio' => $fechaInicio,
            'fecha_fin' => $fechaFin
        ]);
        $total = $stmt2->fetch(PDO::FETCH_ASSOC)['total'];
        echo "📊 Total en rango 2020-2021: " . number_format($total) . " registros\n\n";

        echo "✅ TODO CORRECTO - El componente mostrará datos al cargar\n";
    } else {
        echo "❌ NO HAY DATOS EN EL RANGO 2020-2021\n";
        echo "Necesitas ajustar las fechas por defecto a otro rango\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
