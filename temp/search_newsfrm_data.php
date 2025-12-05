<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "=== EXPLORANDO DATOS DE NOVEDADES DE MULTAS ===\n\n";

    // Obtener multas más recientes
    $sql = "
        SELECT
            id_multa,
            num_acta,
            axo_acta,
            fecha_acta,
            fecha_recepcion,
            contribuyente,
            domicilio,
            total,
            tipo,
            fecha_cancelacion
        FROM comun.multas
        ORDER BY fecha_acta DESC NULLS LAST
        LIMIT 10
    ";

    $stmt = $pdo->query($sql);
    $recientes = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "MULTAS MÁS RECIENTES (por fecha_acta):\n";
    echo "========================================\n\n";

    foreach ($recientes as $i => $m) {
        $num = $i + 1;
        echo "EJEMPLO $num:\n";
        echo "  ID: {$m['id_multa']}\n";
        echo "  Folio: {$m['num_acta']}\n";
        echo "  Año: {$m['axo_acta']}\n";
        echo "  Fecha Acta: {$m['fecha_acta']}\n";
        echo "  Fecha Recepción: {$m['fecha_recepcion']}\n";
        echo "  Contribuyente: {$m['contribuyente']}\n";
        echo "  Domicilio: {$m['domicilio']}\n";
        echo "  Total: \${$m['total']}\n";
        echo "  Tipo: {$m['tipo']}\n";
        echo "  Estado: " . ($m['fecha_cancelacion'] ? 'CANCELADA' : 'ACTIVA') . "\n";
        echo "\n";
    }

    // Obtener rango de años disponibles
    echo "\n=== RANGO DE AÑOS DISPONIBLES ===\n\n";

    $sqlYears = "
        SELECT
            MIN(axo_acta) as primer_anio,
            MAX(axo_acta) as ultimo_anio,
            COUNT(DISTINCT axo_acta) as total_anios
        FROM comun.multas
        WHERE axo_acta IS NOT NULL AND axo_acta > 0
    ";

    $stmt = $pdo->query($sqlYears);
    $years = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "Primer año: {$years['primer_anio']}\n";
    echo "Último año: {$years['ultimo_anio']}\n";
    echo "Total de años: {$years['total_anios']}\n";

    // Obtener multas por año (últimos años)
    echo "\n\n=== DISTRIBUCIÓN POR AÑO (Últimos años) ===\n\n";

    $sqlByYear = "
        SELECT
            axo_acta,
            COUNT(*) as total_multas,
            SUM(total) as suma_total
        FROM comun.multas
        WHERE axo_acta >= 2020
        GROUP BY axo_acta
        ORDER BY axo_acta DESC
    ";

    $stmt = $pdo->query($sqlByYear);
    $byYear = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($byYear as $year) {
        echo "Año {$year['axo_acta']}: {$year['total_multas']} multas, Total: \${$year['suma_total']}\n";
    }

    // Buscar multas con filtro de texto
    echo "\n\n=== BÚSQUEDA POR FILTRO DE TEXTO ===\n\n";

    // Ejemplo 1: Buscar por contribuyente
    $sql1 = "
        SELECT
            id_multa,
            num_acta,
            axo_acta,
            contribuyente,
            total
        FROM comun.multas
        WHERE contribuyente ILIKE '%GARCIA%'
        ORDER BY fecha_acta DESC NULLS LAST
        LIMIT 3
    ";

    $stmt1 = $pdo->query($sql1);
    $garcia = $stmt1->fetchAll(PDO::FETCH_ASSOC);

    echo "Búsqueda: 'GARCIA'\n";
    foreach ($garcia as $m) {
        echo "  - Folio: {$m['num_acta']}, Año: {$m['axo_acta']}, {$m['contribuyente']}, Total: \${$m['total']}\n";
    }

    // Ejemplo 2: Buscar por año
    $sql2 = "
        SELECT
            id_multa,
            num_acta,
            axo_acta,
            contribuyente,
            total
        FROM comun.multas
        WHERE axo_acta = 2024
        ORDER BY fecha_acta DESC NULLS LAST
        LIMIT 3
    ";

    $stmt2 = $pdo->query($sql2);
    $year2024 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    echo "\nBúsqueda: Año 2024\n";
    if (count($year2024) > 0) {
        foreach ($year2024 as $m) {
            echo "  - Folio: {$m['num_acta']}, {$m['contribuyente']}, Total: \${$m['total']}\n";
        }
    } else {
        echo "  No hay multas del año 2024\n";
    }

    // Ejemplo 3: Buscar por folio
    $sql3 = "
        SELECT
            id_multa,
            num_acta,
            axo_acta,
            contribuyente,
            total
        FROM comun.multas
        WHERE num_acta = 1000
        LIMIT 3
    ";

    $stmt3 = $pdo->query($sql3);
    $folio1000 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    echo "\nBúsqueda: Folio 1000\n";
    foreach ($folio1000 as $m) {
        echo "  - Año: {$m['axo_acta']}, {$m['contribuyente']}, Total: \${$m['total']}\n";
    }

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
    exit(1);
}
