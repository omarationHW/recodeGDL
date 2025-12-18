<?php
// Verificar tabla de multas y hacer JOIN con descmultampal

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICACIÓN DE TABLAS MULTAS ===\n\n";

    // 1. Buscar tabla de multas
    echo "1. Buscando tabla de multas...\n";
    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname IN ('public', 'publico')
        AND tablename ILIKE '%multa%'
        AND tablename NOT ILIKE '%desc%'
        ORDER BY tablename
    ");
    $tablas_multas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tablas_multas as $tm) {
        echo "   - {$tm['tablename']}\n";
    }

    // 2. Ver estructura de publico.multas
    echo "\n2. Estructura de publico.multas:\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'publico' AND table_name = 'multas'
        ORDER BY ordinal_position
        LIMIT 20
    ");
    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($cols as $col) {
        echo "   - {$col['column_name']} ({$col['data_type']})\n";
    }

    // 3. Ver más columnas de multas
    echo "\n3. Ver todas las columnas de publico.multas:\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'publico' AND table_name = 'multas'
        ORDER BY ordinal_position
    ");
    $all_cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($all_cols as $col) {
        echo "   - {$col['column_name']} ({$col['data_type']})\n";
    }

    // 4. Verificar JOIN entre descmultampal y multas (sin importe)
    echo "\n4. Verificar JOIN entre descmultampal y multas:\n";
    $stmt = $pdo->query("
        SELECT
            d.id_multa,
            d.tipo_descto,
            d.valor,
            d.feccap,
            d.estado,
            d.folio,
            d.observacion,
            m.num_acta,
            m.axo_acta,
            m.contribuyente,
            m.calificacion
        FROM publico.descmultampal d
        LEFT JOIN publico.multas m ON d.id_multa = m.id_multa
        WHERE d.estado = 'V'
        LIMIT 5
    ");
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Registros encontrados: " . count($ejemplos) . "\n\n";

    if (count($ejemplos) > 0) {
        echo "   Ejemplos:\n";
        foreach ($ejemplos as $ej) {
            echo "   -------------------------\n";
            echo "   ID Multa: {$ej['id_multa']}\n";
            echo "   Num Acta: {$ej['num_acta']}\n";
            echo "   Año Acta: {$ej['axo_acta']}\n";
            echo "   Contribuyente: " . substr($ej['contribuyente'], 0, 40) . "\n";
            echo "   Tipo Descto: {$ej['tipo_descto']}\n";
            echo "   Valor Descto: {$ej['valor']}\n";
            echo "   Calificación: {$ej['calificacion']}\n";
            echo "   Fecha: {$ej['feccap']}\n";
            echo "   Estado: {$ej['estado']}\n";
            echo "   Folio: {$ej['folio']}\n";
        }
    }

    // 5. Contar descuentos vigentes
    echo "\n\n5. Estadísticas:\n";
    $stmt = $pdo->query("
        SELECT
            estado,
            COUNT(*) as total
        FROM publico.descmultampal
        GROUP BY estado
        ORDER BY total DESC
    ");
    $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($stats as $stat) {
        $estado_txt = $stat['estado'] == 'V' ? 'Vigente' : ($stat['estado'] == 'C' ? 'Cancelado' : 'Otro');
        echo "   {$estado_txt} ({$stat['estado']}): " . number_format($stat['total']) . "\n";
    }

    // 6. Verificar tipos de descuento
    echo "\n6. Tipos de descuento:\n";
    $stmt = $pdo->query("
        SELECT
            tipo_descto,
            COUNT(*) as total
        FROM publico.descmultampal
        WHERE estado = 'V'
        GROUP BY tipo_descto
        ORDER BY total DESC
        LIMIT 10
    ");
    $tipos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tipos as $tipo) {
        echo "   Tipo '{$tipo['tipo_descto']}': " . number_format($tipo['total']) . "\n";
    }

    echo "\n✅ Verificación completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
