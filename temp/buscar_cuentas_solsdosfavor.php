<?php
/**
 * Buscar 5 cuentas con solicitudes de saldos a favor
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "🔍 Buscando 5 cuentas con solicitudes de saldos a favor...\n\n";

    // Buscar cuentas con datos completos (que tengan folio, solicitud, observaciones)
    $sql = "
        SELECT DISTINCT
            s.cvecuenta,
            COUNT(s.id_solic) as total_solicitudes,
            MAX(s.axofol) as ultimo_ejercicio,
            MAX(s.folio) as ultimo_folio
        FROM catastro_gdl.solic_sdosfavor s
        WHERE s.cvecuenta IS NOT NULL
        AND s.folio IS NOT NULL
        AND s.observaciones IS NOT NULL
        AND s.observaciones != ''
        GROUP BY s.cvecuenta
        HAVING COUNT(s.id_solic) > 0
        ORDER BY COUNT(s.id_solic) DESC, s.cvecuenta DESC
        LIMIT 5
    ";

    $stmt = $pdo->query($sql);
    $cuentas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($cuentas) > 0) {
        echo "✅ Encontradas " . count($cuentas) . " cuentas:\n\n";

        foreach ($cuentas as $idx => $cuenta) {
            $num = $idx + 1;
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
            echo "CUENTA #{$num}: {$cuenta['cvecuenta']}\n";
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
            echo "  📊 Total de solicitudes: {$cuenta['total_solicitudes']}\n";
            echo "  📅 Último ejercicio: {$cuenta['ultimo_ejercicio']}\n";
            echo "  📋 Último folio: {$cuenta['ultimo_folio']}\n\n";

            // Obtener detalles de todas las solicitudes de esta cuenta
            $detailSql = "
                SELECT
                    id_solic,
                    axofol,
                    folio,
                    solicitante,
                    status,
                    observaciones,
                    feccap,
                    inconf
                FROM catastro_gdl.solic_sdosfavor
                WHERE cvecuenta = :cuenta
                ORDER BY id_solic DESC
            ";

            $stmtDetail = $pdo->prepare($detailSql);
            $stmtDetail->execute(['cuenta' => $cuenta['cvecuenta']]);
            $solicitudes = $stmtDetail->fetchAll(PDO::FETCH_ASSOC);

            echo "  📝 Solicitudes:\n\n";
            foreach ($solicitudes as $sol) {
                echo "    ┌─ ID Solicitud: {$sol['id_solic']}\n";
                echo "    │  Folio: {$sol['folio']} / {$sol['axofol']}\n";
                echo "    │  Solicitante: " . trim($sol['solicitante']) . "\n";
                echo "    │  Status: {$sol['status']}\n";
                echo "    │  Fecha captura: {$sol['feccap']}\n";
                echo "    │  Inconformidad: {$sol['inconf']}\n";
                echo "    │  Observaciones: " . substr($sol['observaciones'], 0, 80) . "...\n";
                echo "    └─\n";
            }
            echo "\n";
        }

        echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        echo "RESUMEN DE CUENTAS PARA PROBAR\n";
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";

        foreach ($cuentas as $idx => $cuenta) {
            $num = $idx + 1;
            echo "{$num}. Cuenta: {$cuenta['cvecuenta']} ({$cuenta['total_solicitudes']} solicitud(es))\n";
        }

        echo "\n💡 Puedes usar cualquiera de estas cuentas en el formulario SolSdosFavor.vue\n";

    } else {
        echo "❌ No se encontraron cuentas con solicitudes\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
