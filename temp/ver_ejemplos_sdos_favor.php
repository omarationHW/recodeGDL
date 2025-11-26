<?php
/**
 * Script para ver ejemplos de registros de saldos a favor
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✅ Conectado a la base de datos: $dbname\n\n";

    // Ver registros de solic_sdosfavor
    echo "📋 EJEMPLOS DE solic_sdosfavor (solicitudes):\n";
    echo "=============================================\n";
    $solic = $pdo->query("
        SELECT id_solic, axofol, folio, cvecuenta, status, feccap, inconf
        FROM solic_sdosfavor
        ORDER BY id_solic DESC
        LIMIT 5
    ")->fetchAll(PDO::FETCH_ASSOC);

    foreach ($solic as $i => $row) {
        echo "\nSolicitud " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  - $key: $value\n";
        }
    }

    // Ver registros de sdosfavor
    echo "\n\n📋 EJEMPLOS DE sdosfavor (saldos):\n";
    echo "===================================\n";
    $sdos = $pdo->query("
        SELECT id_pago_favor, id_solic, cvecuenta, numpago, imp_pago, saldo_favor, fecha_pago
        FROM sdosfavor
        ORDER BY id_pago_favor DESC
        LIMIT 5
    ")->fetchAll(PDO::FETCH_ASSOC);

    foreach ($sdos as $i => $row) {
        echo "\nSaldo " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  - $key: $value\n";
        }
    }

    // Ver registros de saldosafavor
    echo "\n\n📋 EJEMPLOS DE saldosafavor:\n";
    echo "=============================\n";
    $saldos = $pdo->query("
        SELECT cvecuenta, id_convenio, folio, saldoinicial, importeaplicado, fechaalta
        FROM saldosafavor
        ORDER BY cvecuenta DESC
        LIMIT 5
    ")->fetchAll(PDO::FETCH_ASSOC);

    foreach ($saldos as $i => $row) {
        echo "\nSaldo " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  - $key: $value\n";
        }
    }

    // Buscar relación entre tablas
    echo "\n\n🔍 BUSCANDO RELACIONES ENTRE TABLAS:\n";
    echo "=====================================\n";

    // Ver si hay registros con el mismo cvecuenta en ambas tablas
    $relacion = $pdo->query("
        SELECT
            s.id_solic,
            s.folio as folio_solic,
            s.axofol,
            s.cvecuenta,
            sd.saldo_favor,
            sd.imp_pago,
            sd.numpago
        FROM solic_sdosfavor s
        LEFT JOIN sdosfavor sd ON s.id_solic = sd.id_solic
        WHERE sd.id_solic IS NOT NULL
        LIMIT 5
    ")->fetchAll(PDO::FETCH_ASSOC);

    foreach ($relacion as $i => $row) {
        echo "\nRelación " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  - $key: $value\n";
        }
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\n🔍 Stack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
