<?php
/**
 * Script para obtener ejemplos de la tabla req_400
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== EJEMPLOS DE REQUERIMIENTOS 400 ===\n\n";

    // Obtener años disponibles
    echo "1. Años disponibles en la tabla:\n";
    $years = $pdo->query("
        SELECT DISTINCT CAST(TRIM(ejereq) AS INTEGER) as year
        FROM catastro_gdl.req_400
        WHERE ejereq IS NOT NULL AND TRIM(ejereq) != ''
        ORDER BY year DESC
        LIMIT 10
    ")->fetchAll(PDO::FETCH_ASSOC);

    foreach ($years as $y) {
        echo "   - {$y['year']}\n";
    }
    echo "\n";

    // Obtener los 3 años más recientes con datos
    $recentYears = array_slice($years, 0, 3);

    echo "2. Total de registros por año:\n";
    foreach ($recentYears as $y) {
        $count = $pdo->query("
            SELECT COUNT(*) as total
            FROM catastro_gdl.req_400
            WHERE CAST(TRIM(ejereq) AS INTEGER) = {$y['year']}
        ")->fetchColumn();
        echo "   Año {$y['year']}: $count registros\n";
    }
    echo "\n";

    echo "3. EJEMPLOS PARA PROBAR EN ConsReq400.vue:\n";
    echo str_repeat("=", 80) . "\n\n";

    $exampleNum = 1;
    foreach ($recentYears as $yearData) {
        $year = $yearData['year'];

        // Obtener un ejemplo de este año
        $example = $pdo->query("
            SELECT
                TRIM(ctarfc) as clave_cuenta,
                TRIM(folreq) as folio,
                TRIM(ejereq) as ejercicio,
                CASE
                    WHEN actreq IS NOT NULL AND TRIM(actreq) != '' THEN 'Activo'
                    WHEN fecpagr IS NOT NULL AND TRIM(fecpagr) != '' THEN 'Pagado'
                    ELSE 'Pendiente'
                END as estatus,
                TRIM(fecreq) as fecha,
                TRIM(fecent1) as fecent1,
                TRIM(fecent2) as fecent2
            FROM catastro_gdl.req_400
            WHERE CAST(TRIM(ejereq) AS INTEGER) = $year
              AND ctarfc IS NOT NULL
              AND TRIM(ctarfc) != ''
            LIMIT 1
        ")->fetch(PDO::FETCH_ASSOC);

        if ($example) {
            echo "EJEMPLO $exampleNum:\n";
            echo "----------------------------------------\n";
            echo "Cuenta: {$example['clave_cuenta']}\n";
            echo "Año: {$example['ejercicio']}\n";
            echo "Folio: {$example['folio']}\n";
            echo "Estatus: {$example['estatus']}\n";
            echo "Fecha: {$example['fecha']}\n";
            if ($example['fecent1']) echo "Fecha Entrada 1: {$example['fecent1']}\n";
            if ($example['fecent2']) echo "Fecha Entrada 2: {$example['fecent2']}\n";
            echo "\n";

            $exampleNum++;
        }
    }

    echo "\n" . str_repeat("=", 80) . "\n";
    echo "INSTRUCCIONES PARA PROBAR:\n";
    echo str_repeat("=", 80) . "\n\n";

    echo "1. Abre el navegador en: http://localhost:5173\n";
    echo "2. Navega al módulo 'Consulta Requerimientos 400'\n";
    echo "3. Usa estos valores en el formulario:\n\n";

    $exampleNum = 1;
    foreach ($recentYears as $yearData) {
        $year = $yearData['year'];

        $example = $pdo->query("
            SELECT
                TRIM(ctarfc) as clave_cuenta,
                TRIM(ejereq) as ejercicio
            FROM catastro_gdl.req_400
            WHERE CAST(TRIM(ejereq) AS INTEGER) = $year
              AND ctarfc IS NOT NULL
              AND TRIM(ctarfc) != ''
            LIMIT 1
        ")->fetch(PDO::FETCH_ASSOC);

        if ($example) {
            echo "   Ejemplo $exampleNum:\n";
            echo "   - Cuenta: {$example['clave_cuenta']}\n";
            echo "   - Año: {$example['ejercicio']}\n\n";
            $exampleNum++;
        }
    }

    // También buscar ejemplos adicionales variados
    echo "\nEJEMPLOS ADICIONALES (Diferentes cuentas del año más reciente):\n";
    echo str_repeat("=", 80) . "\n";

    $mostRecentYear = $recentYears[0]['year'];
    $additionalExamples = $pdo->query("
        SELECT DISTINCT
            TRIM(ctarfc) as clave_cuenta,
            TRIM(ejereq) as ejercicio,
            TRIM(folreq) as folio
        FROM catastro_gdl.req_400
        WHERE CAST(TRIM(ejereq) AS INTEGER) = $mostRecentYear
          AND ctarfc IS NOT NULL
          AND TRIM(ctarfc) != ''
        LIMIT 5
    ")->fetchAll(PDO::FETCH_ASSOC);

    foreach ($additionalExamples as $idx => $ex) {
        echo "\nCuenta " . ($idx + 1) . ": {$ex['clave_cuenta']} (Año: {$ex['ejercicio']}, Folio: {$ex['folio']})\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
