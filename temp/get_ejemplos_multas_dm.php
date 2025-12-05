<?php
/**
 * Script para obtener 3 ejemplos reales de multas para pruebas
 */

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

    echo "=== OBTENIENDO EJEMPLOS REALES DE MULTAS ===\n\n";

    // Obtener 3 ejemplos diferentes con información completa
    $sql = "
        SELECT
            cvepago,
            num_acta,
            axo_acta,
            fecha_acta,
            contribuyente,
            total,
            fecha_cancelacion
        FROM comun.multas
        WHERE cvepago IS NOT NULL
        AND num_acta > 0
        AND axo_acta > 0
        ORDER BY RANDOM()
        LIMIT 3
    ";

    $stmt = $pdo->query($sql);
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "EJEMPLOS PARA PROBAR EL FORMULARIO:\n";
    echo "====================================\n\n";

    foreach ($ejemplos as $i => $ejemplo) {
        $num = $i + 1;
        $estatus = $ejemplo['fecha_cancelacion'] ? 'CANCELADA' : 'PAGADA';

        echo "EJEMPLO $num:\n";
        echo "  Cuenta: {$ejemplo['cvepago']}\n";
        echo "  Ejercicio (Año): {$ejemplo['axo_acta']}\n";
        echo "  Folio: {$ejemplo['num_acta']}\n";
        echo "  Contribuyente: {$ejemplo['contribuyente']}\n";
        echo "  Importe: \${$ejemplo['total']}\n";
        echo "  Fecha Acta: {$ejemplo['fecha_acta']}\n";
        echo "  Estatus: $estatus\n";
        echo "\n";
    }

    echo "\n=== EJEMPLOS POR AÑO ESPECÍFICO (1992) ===\n\n";

    $sql2 = "
        SELECT
            cvepago,
            num_acta,
            axo_acta,
            fecha_acta,
            contribuyente,
            total,
            fecha_cancelacion
        FROM comun.multas
        WHERE axo_acta = 1992
        AND num_acta > 0
        LIMIT 3
    ";

    $stmt2 = $pdo->query($sql2);
    $ejemplos1992 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    echo "EJEMPLOS DE 1992:\n";
    echo "=================\n\n";

    foreach ($ejemplos1992 as $i => $ejemplo) {
        $num = $i + 1;
        $estatus = $ejemplo['fecha_cancelacion'] ? 'CANCELADA' : ($ejemplo['cvepago'] ? 'PAGADA' : 'PENDIENTE');

        echo "EJEMPLO $num:\n";
        echo "  Cuenta: " . ($ejemplo['cvepago'] ?? 'N/A') . "\n";
        echo "  Ejercicio (Año): {$ejemplo['axo_acta']}\n";
        echo "  Folio: {$ejemplo['num_acta']}\n";
        echo "  Contribuyente: {$ejemplo['contribuyente']}\n";
        echo "  Importe: \${$ejemplo['total']}\n";
        echo "  Fecha Acta: {$ejemplo['fecha_acta']}\n";
        echo "  Estatus: $estatus\n";
        echo "\n";
    }

    echo "\n=== RESUMEN DE DATOS DISPONIBLES ===\n\n";

    // Contar registros por año
    $sqlYears = "
        SELECT
            axo_acta,
            COUNT(*) as total,
            SUM(CASE WHEN cvepago IS NOT NULL THEN 1 ELSE 0 END) as con_cuenta
        FROM comun.multas
        WHERE axo_acta > 0
        GROUP BY axo_acta
        ORDER BY axo_acta DESC
        LIMIT 10
    ";

    $stmtYears = $pdo->query($sqlYears);
    $years = $stmtYears->fetchAll(PDO::FETCH_ASSOC);

    echo "Top 10 años con más multas:\n";
    foreach ($years as $year) {
        echo "  Año {$year['axo_acta']}: {$year['total']} multas ({$year['con_cuenta']} con cuenta)\n";
    }

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
    exit(1);
}
