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

    echo "=== EXPLORANDO DATOS PARA MULTASFRM ===\n\n";

    // Obtener estructura completa de comun.multas
    $sql = "
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'comun' AND table_name = 'multas'
        ORDER BY ordinal_position
    ";

    $stmt = $pdo->query($sql);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "ESTRUCTURA DE comun.multas:\n";
    echo "============================\n";
    foreach ($columns as $col) {
        $len = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
        echo "  - {$col['column_name']}: {$col['data_type']}{$len}\n";
    }

    // Obtener 5 ejemplos completos
    echo "\n\n=== EJEMPLOS DE MULTAS COMPLETAS ===\n\n";

    $sql2 = "
        SELECT
            id_multa,
            id_dependencia,
            axo_acta,
            num_acta,
            fecha_acta,
            fecha_recepcion,
            fecha_cancelacion,
            contribuyente,
            domicilio,
            recaud,
            zona,
            subzona,
            num_licencia,
            giro,
            id_ley,
            id_infraccion,
            calificacion,
            multa,
            gastos,
            total,
            cvepago,
            capturista,
            observacion,
            tipo,
            noexterior,
            interior
        FROM comun.multas
        WHERE num_acta > 0
        ORDER BY RANDOM()
        LIMIT 5
    ";

    $stmt2 = $pdo->query($sql2);
    $ejemplos = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    foreach ($ejemplos as $i => $ej) {
        $num = $i + 1;
        echo "EJEMPLO $num:\n";
        echo "  ID Multa: {$ej['id_multa']}\n";
        echo "  Folio/Acta: {$ej['num_acta']}\n";
        echo "  Año: {$ej['axo_acta']}\n";
        echo "  Fecha Acta: {$ej['fecha_acta']}\n";
        echo "  Contribuyente: {$ej['contribuyente']}\n";
        echo "  Domicilio: {$ej['domicilio']}\n";
        echo "  No. Exterior: {$ej['noexterior']}\n";
        echo "  Giro: {$ej['giro']}\n";
        echo "  Dependencia: {$ej['id_dependencia']}\n";
        echo "  Recaudadora: {$ej['recaud']}\n";
        echo "  Zona/Subzona: {$ej['zona']}/{$ej['subzona']}\n";
        echo "  Licencia: {$ej['num_licencia']}\n";
        echo "  Ley/Infracción: {$ej['id_ley']}/{$ej['id_infraccion']}\n";
        echo "  Calificación: \${$ej['calificacion']}\n";
        echo "  Multa: \${$ej['multa']}\n";
        echo "  Gastos: \${$ej['gastos']}\n";
        echo "  Total: \${$ej['total']}\n";
        echo "  Clave Pago: {$ej['cvepago']}\n";
        echo "  Tipo: {$ej['tipo']}\n";
        echo "  Capturista: {$ej['capturista']}\n";
        echo "  Observación: {$ej['observacion']}\n";
        echo "  Fecha Cancelación: {$ej['fecha_cancelacion']}\n";
        echo "\n";
    }

    // Buscar con filtros específicos
    echo "\n=== EJEMPLOS FILTRABLES ===\n\n";

    // Por contribuyente
    $sql3 = "
        SELECT id_multa, num_acta, axo_acta, contribuyente, total
        FROM comun.multas
        WHERE contribuyente ILIKE '%GARCIA%'
        LIMIT 3
    ";

    $stmt3 = $pdo->query($sql3);
    $ejemplos3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    echo "Búsqueda: Contribuyentes con 'GARCIA'\n";
    foreach ($ejemplos3 as $ej) {
        echo "  - ID: {$ej['id_multa']}, Folio: {$ej['num_acta']}, Año: {$ej['axo_acta']}, Nombre: {$ej['contribuyente']}, Total: \${$ej['total']}\n";
    }

    // Por folio
    echo "\nBúsqueda: Por folio específico (711)\n";
    $sql4 = "
        SELECT id_multa, num_acta, axo_acta, contribuyente, domicilio, total
        FROM comun.multas
        WHERE num_acta = 711
        LIMIT 3
    ";

    $stmt4 = $pdo->query($sql4);
    $ejemplos4 = $stmt4->fetchAll(PDO::FETCH_ASSOC);

    foreach ($ejemplos4 as $ej) {
        echo "  - ID: {$ej['id_multa']}, Folio: {$ej['num_acta']}, Año: {$ej['axo_acta']}, Nombre: {$ej['contribuyente']}, Total: \${$ej['total']}\n";
    }

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
    exit(1);
}
