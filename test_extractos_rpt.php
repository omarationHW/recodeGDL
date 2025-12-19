<?php
// Script para probar el stored procedure recaudadora_extractos_rpt

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Primero, obtener algunos expedientes reales para probar
    echo "1. Obteniendo expedientes de muestra de la tabla h_multasnvo...\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT
            TRIM(expediente) as expediente,
            COUNT(*) as cant_multas,
            SUM(total) as total_adeudo
        FROM public.h_multasnvo
        WHERE expediente IS NOT NULL
        AND expediente <> ''
        AND expediente <> '.'
        AND fecha_cancelacion IS NULL
        GROUP BY TRIM(expediente)
        HAVING COUNT(*) > 0
        ORDER BY cant_multas DESC
        LIMIT 5
    ");

    $expedientes = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Expedientes encontrados:\n";
    echo "   Expediente    | Multas | Total Adeudo\n";
    echo "   " . str_repeat("-", 50) . "\n";
    foreach ($expedientes as $exp) {
        printf("   %-13s | %6d | $%12.2f\n",
            $exp['expediente'],
            $exp['cant_multas'],
            $exp['total_adeudo']
        );
    }

    // Probar el stored procedure con diferentes cuentas
    echo "\n\n2. Probando stored procedure con diferentes cuentas...\n\n";

    // Usar el primer expediente para prueba
    if (count($expedientes) > 0) {
        $test_expediente = $expedientes[0]['expediente'];

        echo "   === PRUEBA 1: Búsqueda por expediente ($test_expediente) ===\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_extractos_rpt(?)");
        $stmt->execute([$test_expediente]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            echo "   Success: " . ($result['success'] ? '✓' : '✗') . "\n";
            echo "   Message: " . $result['message'] . "\n";
            echo "   Cuenta: " . $result['cuenta'] . "\n";
            echo "   Clave Catastral: " . $result['clave_catastral'] . "\n";
            echo "   Total Adeudo: $" . number_format($result['total_adeudo'], 2) . "\n";
            echo "   Fecha Extracto: " . $result['fecha_extracto'] . "\n";
            echo "   Cantidad Multas: " . $result['cantidad_multas'] . "\n";
            echo "   Contribuyente: " . $result['contribuyente'] . "\n";
            echo "   Domicilio: " . $result['domicilio'] . "\n\n";
        }
    }

    // Prueba con número de acta
    echo "   === PRUEBA 2: Búsqueda por número de acta ===\n";
    $stmt = $pdo->query("
        SELECT num_acta, contribuyente, total
        FROM public.h_multasnvo
        WHERE num_acta IS NOT NULL
        AND num_acta > 0
        AND fecha_cancelacion IS NULL
        LIMIT 1
    ");
    $acta = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($acta) {
        $num_acta = $acta['num_acta'];
        echo "   Buscando acta: $num_acta\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_extractos_rpt(?)");
        $stmt->execute([(string)$num_acta]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            echo "   Success: " . ($result['success'] ? '✓' : '✗') . "\n";
            echo "   Message: " . $result['message'] . "\n";
            echo "   Cuenta: " . $result['cuenta'] . "\n";
            echo "   Total Adeudo: $" . number_format($result['total_adeudo'], 2) . "\n";
            echo "   Cantidad Multas: " . $result['cantidad_multas'] . "\n";
            echo "   Contribuyente: " . $result['contribuyente'] . "\n\n";
        }
    }

    // Prueba con ID de multa
    echo "   === PRUEBA 3: Búsqueda por ID de multa ===\n";
    $stmt = $pdo->query("
        SELECT id_multa, contribuyente, total
        FROM public.h_multasnvo
        WHERE id_multa IS NOT NULL
        AND fecha_cancelacion IS NULL
        LIMIT 1
    ");
    $multa = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($multa) {
        $id_multa = $multa['id_multa'];
        echo "   Buscando multa ID: $id_multa\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_extractos_rpt(?)");
        $stmt->execute([(string)$id_multa]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            echo "   Success: " . ($result['success'] ? '✓' : '✗') . "\n";
            echo "   Message: " . $result['message'] . "\n";
            echo "   Cuenta: " . $result['cuenta'] . "\n";
            echo "   Total Adeudo: $" . number_format($result['total_adeudo'], 2) . "\n";
            echo "   Cantidad Multas: " . $result['cantidad_multas'] . "\n";
            echo "   Contribuyente: " . $result['contribuyente'] . "\n\n";
        }
    }

    // Prueba con cuenta inexistente
    echo "   === PRUEBA 4: Búsqueda con cuenta inexistente ===\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_extractos_rpt(?)");
    $stmt->execute(['99999999']);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "   Success: " . ($result['success'] ? '✓' : '✗') . "\n";
        echo "   Message: " . $result['message'] . "\n";
        echo "   Total Adeudo: $" . number_format($result['total_adeudo'], 2) . "\n\n";
    }

    // Prueba con cuenta vacía
    echo "   === PRUEBA 5: Búsqueda con cuenta vacía ===\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_extractos_rpt(?)");
    $stmt->execute(['']);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "   Success: " . ($result['success'] ? '✓' : '✗') . "\n";
        echo "   Message: " . $result['message'] . "\n\n";
    }

    // Resumen de estadísticas
    echo "\n3. Estadísticas generales de la tabla h_multasnvo...\n\n";

    $stmt = $pdo->query("
        SELECT
            COUNT(*) as total_registros,
            COUNT(CASE WHEN fecha_cancelacion IS NULL THEN 1 END) as multas_pendientes,
            COUNT(CASE WHEN fecha_cancelacion IS NOT NULL THEN 1 END) as multas_canceladas,
            COALESCE(SUM(CASE WHEN fecha_cancelacion IS NULL THEN total END), 0) as total_adeudo_general,
            COUNT(DISTINCT TRIM(expediente)) as expedientes_unicos
        FROM public.h_multasnvo
        WHERE expediente IS NOT NULL
        AND expediente <> ''
        AND expediente <> '.'
    ");

    $stats = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total de registros: " . number_format($stats['total_registros']) . "\n";
    echo "   Multas pendientes: " . number_format($stats['multas_pendientes']) . "\n";
    echo "   Multas canceladas: " . number_format($stats['multas_canceladas']) . "\n";
    echo "   Total adeudo general: $" . number_format($stats['total_adeudo_general'], 2) . "\n";
    echo "   Expedientes únicos: " . number_format($stats['expedientes_unicos']) . "\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
