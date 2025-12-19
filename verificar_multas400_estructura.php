<?php
// Verificar estructura de tablas multas_400 para multas400frm.vue

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICACIÓN DE TABLAS MULTAS 400 ===\n\n";

    // Verificar multas_mpal_400 (municipales)
    echo "1. Tabla: publico.multas_mpal_400 (273,247 registros)\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'publico' AND table_name = 'multas_mpal_400'
        ORDER BY ordinal_position
    ");

    echo "Campos:\n";
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $col) {
        $len = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  - {$col['column_name']}: {$col['data_type']}$len\n";
    }

    // Ver ejemplos de multas municipales
    echo "\n\nEjemplos de multas municipales (activas):\n";
    $stmt = $pdo->query("
        SELECT
            depen,
            axoacta,
            numacta,
            nombre,
            domici,
            impmul,
            cvevig,
            numlote
        FROM publico.multas_mpal_400
        WHERE cvevig = 'V'
        ORDER BY numacta DESC
        LIMIT 5
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $i => $row) {
        echo "\n  " . ($i + 1) . ". Acta: {$row['numacta']}/{$row['axoacta']}\n";
        echo "     Dependencia: {$row['depen']}\n";
        echo "     Contribuyente: " . trim($row['nombre']) . "\n";
        echo "     Domicilio: " . trim($row['domici']) . "\n";
        echo "     Multa: $" . number_format($row['impmul'], 2) . "\n";
        echo "     Estado: " . ($row['cvevig'] == 'V' ? 'Vigente' : 'Cancelada') . "\n";
        echo "     Lote: {$row['numlote']}\n";
    }

    // Ver distribución por vigencia
    echo "\n\n2. Distribución por vigencia (multas_mpal_400):\n";
    $stmt = $pdo->query("
        SELECT
            cvevig,
            COUNT(*) as total
        FROM publico.multas_mpal_400
        GROUP BY cvevig
        ORDER BY total DESC
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $estado = $row['cvevig'] == 'V' ? 'Vigente' :
                 ($row['cvevig'] == 'C' ? 'Cancelada' : $row['cvevig']);
        echo "   {$estado} ({$row['cvevig']}): " . number_format($row['total']) . "\n";
    }

    // Verificar multas_fed_400 (federales)
    echo "\n\n" . str_repeat("=", 70) . "\n\n";
    echo "3. Tabla: publico.multas_fed_400 (20,685 registros)\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'publico' AND table_name = 'multas_fed_400'
        ORDER BY ordinal_position
    ");

    echo "Campos:\n";
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $col) {
        $len = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  - {$col['column_name']}: {$col['data_type']}$len\n";
    }

    // Ver ejemplos de multas federales
    echo "\n\nEjemplos de multas federales (activas):\n";
    $stmt = $pdo->query("
        SELECT
            depfed,
            axofed,
            numacta,
            nombre,
            domici,
            impfed,
            cvevig,
            lote
        FROM publico.multas_fed_400
        WHERE cvevig = 'V'
        ORDER BY numacta DESC
        LIMIT 5
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $i => $row) {
        echo "\n  " . ($i + 1) . ". Acta: {$row['numacta']}/{$row['axofed']}\n";
        echo "     Dependencia: {$row['depfed']}\n";
        echo "     Contribuyente: " . trim($row['nombre']) . "\n";
        echo "     Domicilio: " . trim($row['domici']) . "\n";
        echo "     Multa: $" . number_format($row['impfed'], 2) . "\n";
        echo "     Estado: " . ($row['cvevig'] == 'V' ? 'Vigente' : 'Cancelada') . "\n";
        echo "     Lote: {$row['lote']}\n";
    }

    // Ver distribución por vigencia
    echo "\n\n4. Distribución por vigencia (multas_fed_400):\n";
    $stmt = $pdo->query("
        SELECT
            cvevig,
            COUNT(*) as total
        FROM publico.multas_fed_400
        GROUP BY cvevig
        ORDER BY total DESC
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $estado = $row['cvevig'] == 'V' ? 'Vigente' :
                 ($row['cvevig'] == 'C' ? 'Cancelada' : $row['cvevig']);
        echo "   {$estado} ({$row['cvevig']}): " . number_format($row['total']) . "\n";
    }

    // Mapeo propuesto
    echo "\n\n" . str_repeat("=", 70) . "\n\n";
    echo "5. MAPEO PROPUESTO PARA multas400frm:\n\n";
    echo "Usar: publico.multas_mpal_400 (273,247 registros - más común)\n\n";
    echo "Campos a mapear:\n";
    echo "  id_multa → numacta (número de acta)\n";
    echo "  num_acta → numacta\n";
    echo "  axo_acta → axoacta\n";
    echo "  fecha_acta → fecalt (fecha alta convertida)\n";
    echo "  contribuyente → nombre\n";
    echo "  domicilio → domici\n";
    echo "  id_dependencia → depen\n";
    echo "  expediente → (no disponible directamente)\n";
    echo "  multa → impmul\n";
    echo "  gastos → (calcular si existe)\n";
    echo "  total → impmul + impini (multa + importe inicial)\n";
    echo "  cvepago → (no disponible)\n";
    echo "  fecha_recepcion → fecrec (si existe, convertir)\n";
    echo "  observacion → (no disponible)\n";
    echo "  vigencia → cvevig (V=Vigente, C=Cancelada)\n";

    echo "\n✅ Verificación completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
