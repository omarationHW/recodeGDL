<?php
// Verificar estructura de multas con calificación para multasfrmcalif.vue

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICACIÓN DE MULTAS CON CALIFICACIÓN ===\n\n";

    // Ver estructura completa de publico.multas
    echo "1. Tabla: publico.multas (416,928 registros)\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'publico' AND table_name = 'multas'
        ORDER BY ordinal_position
    ");

    echo "Estructura completa:\n";
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $col) {
        $len = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  - {$col['column_name']}: {$col['data_type']}$len\n";
    }

    // Ver ejemplos de multas con calificación
    echo "\n\nEjemplos de multas con calificación:\n";
    $stmt = $pdo->query("
        SELECT
            id_multa,
            num_acta,
            axo_acta,
            contribuyente,
            domicilio,
            multa,
            gastos,
            total,
            calificacion,
            fecha_cancelacion
        FROM publico.multas
        WHERE calificacion IS NOT NULL
        ORDER BY id_multa DESC
        LIMIT 5
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $i => $row) {
        echo "\n  " . ($i + 1) . ". ID Multa: {$row['id_multa']}\n";
        echo "     Acta: {$row['num_acta']}/{$row['axo_acta']}\n";
        echo "     Contribuyente: {$row['contribuyente']}\n";
        echo "     Domicilio: {$row['domicilio']}\n";
        echo "     Multa: $" . number_format($row['multa'], 2) . "\n";
        echo "     Total: $" . number_format($row['total'], 2) . "\n";
        echo "     Calificación: {$row['calificacion']}\n";
        echo "     Estado: " . ($row['fecha_cancelacion'] ? 'Cancelada' : 'Activa') . "\n";
    }

    // Ver JOIN con tipo_calificacion_multa
    echo "\n\n2. JOIN con tipo_calificacion_multa:\n\n";
    $stmt = $pdo->query("
        SELECT
            m.id_multa,
            m.num_acta,
            m.axo_acta,
            m.contribuyente,
            m.calificacion,
            tc.tipo_calificacion,
            tc.usuario,
            tc.fecha_actual
        FROM publico.multas m
        INNER JOIN publico.tipo_calificacion_multa tc ON m.id_multa = tc.id_multa
        ORDER BY tc.fecha_actual DESC
        LIMIT 5
    ");

    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Registros con JOIN: " . count($result) . "\n";

    foreach ($result as $i => $row) {
        echo "\n  " . ($i + 1) . ". Acta: {$row['num_acta']}/{$row['axo_acta']}\n";
        echo "     Contribuyente: {$row['contribuyente']}\n";
        echo "     Calificación (multas): {$row['calificacion']}\n";
        echo "     Tipo Calificación: {$row['tipo_calificacion']}\n";
        echo "     Usuario: {$row['usuario']}\n";
        echo "     Fecha: {$row['fecha_actual']}\n";
    }

    // Ver distribución de calificaciones en multas
    echo "\n\n3. Distribución de calificaciones en multas:\n";
    $stmt = $pdo->query("
        SELECT
            CASE
                WHEN calificacion IS NULL THEN 'Sin calificación'
                WHEN calificacion = 0 THEN 'Cero'
                WHEN calificacion > 0 AND calificacion <= 50000 THEN 'Baja (<= 50k)'
                WHEN calificacion > 50000 AND calificacion <= 100000 THEN 'Media (50k-100k)'
                WHEN calificacion > 100000 THEN 'Alta (> 100k)'
                ELSE 'Otra'
            END as rango,
            COUNT(*) as total
        FROM publico.multas
        GROUP BY rango
        ORDER BY total DESC
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        echo "  {$row['rango']}: " . number_format($row['total']) . "\n";
    }

    // Ver distribución por tipo en tipo_calificacion_multa
    echo "\n\n4. Tipos de calificación disponibles:\n";
    $stmt = $pdo->query("
        SELECT
            tipo_calificacion,
            CASE tipo_calificacion
                WHEN 'O' THEN 'Oficial'
                WHEN 'M' THEN 'Manual'
                ELSE 'Otro'
            END as descripcion,
            COUNT(*) as total
        FROM publico.tipo_calificacion_multa
        GROUP BY tipo_calificacion
        ORDER BY total DESC
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        echo "  {$row['tipo_calificacion']} ({$row['descripcion']}): " . number_format($row['total']) . "\n";
    }

    // Ver cuántas multas tienen tipo_calificacion
    echo "\n\n5. Estadísticas de relación:\n";

    $stmt = $pdo->query("SELECT COUNT(*) as total FROM publico.multas");
    $total_multas = $stmt->fetch(PDO::FETCH_ASSOC)['total'];

    $stmt = $pdo->query("
        SELECT COUNT(DISTINCT m.id_multa) as total
        FROM publico.multas m
        INNER JOIN publico.tipo_calificacion_multa tc ON m.id_multa = tc.id_multa
    ");
    $multas_con_tipo = $stmt->fetch(PDO::FETCH_ASSOC)['total'];

    echo "  Total multas: " . number_format($total_multas) . "\n";
    echo "  Multas con tipo_calificacion: " . number_format($multas_con_tipo) . "\n";
    echo "  Porcentaje: " . number_format(($multas_con_tipo / $total_multas) * 100, 2) . "%\n";

    // Mapeo propuesto
    echo "\n\n" . str_repeat("=", 70) . "\n\n";
    echo "6. MAPEO PROPUESTO PARA multasfrmcalif:\n\n";
    echo "Usar: publico.multas (416,928 registros)\n";
    echo "JOIN: publico.tipo_calificacion_multa (opcional, 12,326 registros)\n\n";
    echo "Campos a mapear:\n";
    echo "  clave_cuenta → num_acta || '/' || axo_acta (identificador único)\n";
    echo "  folio → num_acta\n";
    echo "  contribuyente → contribuyente\n";
    echo "  domicilio → domicilio\n";
    echo "  multa → multa\n";
    echo "  gastos → gastos\n";
    echo "  total → total\n";
    echo "  calificacion → calificacion (NUMERIC de multas)\n";
    echo "  tipo_calificacion → tipo_calificacion (CHARACTER de tipo_calificacion_multa)\n";
    echo "  estado → CASE WHEN fecha_cancelacion IS NOT NULL THEN 'Cancelada' ELSE 'Activa' END\n";

    echo "\n✅ Verificación completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
