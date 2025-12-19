<?php
// Script para extraer ejemplos específicos de reqtransm

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== TODOS LOS REGISTROS DE REQTRANSM ===\n\n";

    $stmt = $pdo->query("
        SELECT
            id,
            folioreq,
            tipo,
            cvecta,
            cveejec,
            TO_CHAR(fecemi, 'DD/MM/YYYY') as fecha_emision,
            TO_CHAR(feceje, 'DD/MM/YYYY') as fecha_ejecucion,
            TO_CHAR(fecprac, 'DD/MM/YYYY') as fecha_practica,
            TO_CHAR(fecbaja, 'DD/MM/YYYY') as fecha_baja,
            TO_CHAR(fecha_pago, 'DD/MM/YYYY') as fecha_pago,
            vigencia,
            importe,
            recargos,
            multas_ex,
            multas_otr,
            gastos,
            gastos_req,
            total,
            EXTRACT(YEAR FROM fecemi) as anio_emision,
            observ
        FROM public.reqtransm
        ORDER BY fecemi DESC NULLS LAST, id DESC
    ");

    $registros = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Total de registros: " . count($registros) . "\n\n";
    echo str_repeat("=", 120) . "\n\n";

    foreach ($registros as $idx => $reg) {
        echo "REGISTRO #" . ($idx + 1) . ":\n";
        echo str_repeat("-", 120) . "\n";
        echo "ID: " . $reg['id'] . "\n";
        echo "Folio Requerimiento: " . ($reg['folioreq'] ?: 'Sin folio') . "\n";
        echo "Tipo: " . ($reg['tipo'] ?: 'Sin tipo') . "\n";
        echo "Cuenta: " . ($reg['cvecta'] ?: '0') . "\n";
        echo "Ejecutoria: " . ($reg['cveejec'] ?: '0') . "\n";
        echo "\n";
        echo "Fecha Emisión: " . ($reg['fecha_emision'] ?: 'Sin fecha') . "\n";
        echo "Fecha Ejecución: " . ($reg['fecha_ejecucion'] ?: 'Sin fecha') . "\n";
        echo "Fecha Práctica: " . ($reg['fecha_practica'] ?: 'Sin fecha') . "\n";
        echo "Fecha Baja: " . ($reg['fecha_baja'] ?: 'Sin fecha') . "\n";
        echo "Fecha Pago: " . ($reg['fecha_pago'] ?: 'Sin fecha') . "\n";
        echo "Año Emisión: " . ($reg['anio_emision'] ?: 'Sin año') . "\n";
        echo "\n";
        echo "Vigencia: " . ($reg['vigencia'] ?: 'Sin vigencia') . "\n";
        echo "\n";
        echo "IMPORTES:\n";
        echo "  - Importe: $" . number_format($reg['importe'] ?: 0, 2) . "\n";
        echo "  - Recargos: $" . number_format($reg['recargos'] ?: 0, 2) . "\n";
        echo "  - Multas Extemporáneas: $" . number_format($reg['multas_ex'] ?: 0, 2) . "\n";
        echo "  - Multas Otras: $" . number_format($reg['multas_otr'] ?: 0, 2) . "\n";
        echo "  - Gastos: $" . number_format($reg['gastos'] ?: 0, 2) . "\n";
        echo "  - Gastos Req: $" . number_format($reg['gastos_req'] ?: 0, 2) . "\n";
        echo "  - TOTAL: $" . number_format($reg['total'] ?: 0, 2) . "\n";
        echo "\n";
        echo "Observaciones: " . ($reg['observ'] ?: 'Sin observaciones') . "\n";
        echo "\n";
        echo str_repeat("=", 120) . "\n\n";
    }

    // Resumen por año y cuenta
    echo "\n\n=== RESUMEN POR AÑO ===\n\n";

    $stmt = $pdo->query("
        SELECT
            EXTRACT(YEAR FROM fecemi) as anio,
            COUNT(*) as cantidad,
            COUNT(DISTINCT cvecta) as cuentas_unicas,
            SUM(total) as total_importe
        FROM public.reqtransm
        WHERE fecemi IS NOT NULL
        GROUP BY EXTRACT(YEAR FROM fecemi)
        ORDER BY anio DESC
    ");

    echo "Año  | Cantidad | Cuentas Únicas | Total Importe\n";
    echo str_repeat("-", 60) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("%4d | %8d | %14d | $%s\n",
            $row['anio'],
            $row['cantidad'],
            $row['cuentas_unicas'],
            number_format($row['total_importe'] ?: 0, 2)
        );
    }

    echo "\n\n=== CUENTAS DISPONIBLES ===\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT
            cvecta as cuenta,
            COUNT(*) as total_requerimientos,
            SUM(total) as total_importe
        FROM public.reqtransm
        WHERE cvecta IS NOT NULL AND cvecta != 0
        GROUP BY cvecta
        ORDER BY cvecta
    ");

    echo "Cuenta   | Total Requerimientos | Total Importe\n";
    echo str_repeat("-", 60) . "\n";

    $cuentas = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($cuentas as $row) {
        printf("%8d | %20d | $%s\n",
            $row['cuenta'],
            $row['total_requerimientos'],
            number_format($row['total_importe'] ?: 0, 2)
        );
    }

    if (empty($cuentas)) {
        echo "No se encontraron cuentas distintas de 0\n";
    }

    // Registros con y sin fecha
    echo "\n\n=== DISTRIBUCIÓN DE REGISTROS ===\n\n";

    $stmt = $pdo->query("
        SELECT
            COUNT(*) FILTER (WHERE fecemi IS NOT NULL) as con_fecha,
            COUNT(*) FILTER (WHERE fecemi IS NULL) as sin_fecha,
            COUNT(*) FILTER (WHERE total > 0) as con_importe,
            COUNT(*) FILTER (WHERE total = 0 OR total IS NULL) as sin_importe
        FROM public.reqtransm
    ");

    $dist = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Registros con fecha de emisión: " . $dist['con_fecha'] . "\n";
    echo "Registros sin fecha de emisión: " . $dist['sin_fecha'] . "\n";
    echo "Registros con importe > 0: " . $dist['con_importe'] . "\n";
    echo "Registros con importe = 0: " . $dist['sin_importe'] . "\n";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
