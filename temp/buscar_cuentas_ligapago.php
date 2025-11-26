<?php
/**
 * Buscar 5 cuentas con requerimientos para probar ligapago.vue
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

    echo "🔍 Buscando cuentas con requerimientos para probar ligapago.vue...\n\n";

    // Buscar cuentas con requerimientos vigentes
    $sql = "
        SELECT DISTINCT
            r.cvecuenta,
            COUNT(r.cvereq) as total_requerimientos,
            MIN(r.folioreq) as primer_folio,
            MAX(r.folioreq) as ultimo_folio,
            MAX(r.axoreq) as ultimo_ano,
            SUM(r.total) as total_importe
        FROM catastro_gdl.reqdiftransmision r
        WHERE r.cvecuenta IS NOT NULL
        AND r.folioreq IS NOT NULL
        AND r.total > 0
        AND r.vigencia = 'V'
        GROUP BY r.cvecuenta
        HAVING COUNT(r.cvereq) > 0
        ORDER BY SUM(r.total) DESC, r.cvecuenta DESC
        LIMIT 5
    ";

    $stmt = $pdo->query($sql);
    $cuentas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($cuentas) > 0) {
        echo "✅ Encontradas " . count($cuentas) . " cuentas con requerimientos:\n\n";

        foreach ($cuentas as $idx => $cuenta) {
            $num = $idx + 1;
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
            echo "CUENTA #{$num}: {$cuenta['cvecuenta']}\n";
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
            echo "  📊 Total de requerimientos: {$cuenta['total_requerimientos']}\n";
            echo "  📋 Primer folio: {$cuenta['primer_folio']}\n";
            echo "  📋 Último folio: {$cuenta['ultimo_folio']}\n";
            echo "  📅 Último año: {$cuenta['ultimo_ano']}\n";
            echo "  💰 Total importe: $" . number_format($cuenta['total_importe'], 2) . "\n\n";

            // Obtener detalles de los requerimientos de esta cuenta
            $detailSql = "
                SELECT
                    cvereq,
                    folioreq,
                    axoreq,
                    foliotransm,
                    total,
                    impuesto,
                    recargos,
                    multa,
                    vigencia,
                    fecemi
                FROM catastro_gdl.reqdiftransmision
                WHERE cvecuenta = :cvecuenta
                AND vigencia = 'V'
                ORDER BY folioreq DESC
                LIMIT 3
            ";

            $stmtDetail = $pdo->prepare($detailSql);
            $stmtDetail->execute(['cvecuenta' => $cuenta['cvecuenta']]);
            $requerimientos = $stmtDetail->fetchAll(PDO::FETCH_ASSOC);

            echo "  📝 Últimos 3 requerimientos vigentes:\n\n";
            foreach ($requerimientos as $req) {
                echo "    ┌─ Folio Req: {$req['folioreq']} ({$req['axoreq']})\n";
                echo "    │  Folio Transm: " . ($req['foliotransm'] ?? 'N/A') . "\n";
                echo "    │  Total: $" . number_format($req['total'], 2) . "\n";
                echo "    │  Impuesto: $" . number_format($req['impuesto'] ?? 0, 2) . "\n";
                echo "    │  Recargos: $" . number_format($req['recargos'] ?? 0, 2) . "\n";
                echo "    │  Multa: $" . number_format($req['multa'] ?? 0, 2) . "\n";
                echo "    │  Fecha Emisión: " . ($req['fecemi'] ?? 'N/A') . "\n";
                echo "    │  Vigencia: {$req['vigencia']}\n";
                echo "    └─\n";
            }
            echo "\n";
        }

        echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        echo "RESUMEN DE CUENTAS PARA PROBAR\n";
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";

        foreach ($cuentas as $idx => $cuenta) {
            $num = $idx + 1;
            echo "{$num}. Cuenta: {$cuenta['cvecuenta']} ({$cuenta['total_requerimientos']} req(s), \$" . number_format($cuenta['total_importe'], 2) . ")\n";
        }

        echo "\n💡 Puedes usar cualquiera de estas cuentas en el formulario ligapago.vue\n";
        echo "⚠️  NOTA: El SP recaudadora_ligapago aún no está implementado (es un placeholder)\n";

    } else {
        echo "❌ No se encontraron cuentas con requerimientos vigentes\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
