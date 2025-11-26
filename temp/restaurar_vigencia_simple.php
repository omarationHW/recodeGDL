<?php
/**
 * Restaurar vigencia de requerimientos cancelados recientemente (últimas 24 horas)
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

    echo "🔄 Restaurando vigencia de requerimientos cancelados recientemente...\n\n";

    // Ver requerimientos cancelados hoy
    $stmt = $pdo->query("
        SELECT cvereq, cvecuenta, folioreq, axoreq, total, feccan
        FROM catastro_gdl.reqdiftransmision
        WHERE vigencia = 'C'
        AND feccan = CURRENT_DATE
        ORDER BY cvereq
    ");

    $requerimientos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($requerimientos) > 0) {
        echo "📋 Requerimientos cancelados HOY que serán restaurados:\n\n";

        foreach ($requerimientos as $idx => $req) {
            $num = $idx + 1;
            echo "{$num}. CVE: {$req['cvereq']} | Cuenta: {$req['cvecuenta']} | Folio: {$req['folioreq']} | Total: \${$req['total']}\n";
        }

        echo "\n🔄 Restaurando a vigentes...\n";

        // Restaurar solo los de hoy
        $stmt = $pdo->exec("
            UPDATE catastro_gdl.reqdiftransmision
            SET
                vigencia = 'V',
                feccan = NULL
            WHERE vigencia = 'C'
            AND feccan = CURRENT_DATE
        ");

        echo "\n✅ Restaurados: $stmt registros\n\n";

    } else {
        echo "ℹ️  No se encontraron requerimientos cancelados hoy.\n\n";
        echo "💡 Buscando todos los cancelados...\n\n";

        $stmt = $pdo->query("
            SELECT cvereq, cvecuenta, folioreq, axoreq, total, feccan
            FROM catastro_gdl.reqdiftransmision
            WHERE vigencia = 'C'
            ORDER BY feccan DESC NULLS LAST
            LIMIT 10
        ");

        $requerimientos = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($requerimientos) > 0) {
            echo "📋 Últimos 10 requerimientos cancelados:\n\n";

            foreach ($requerimientos as $idx => $req) {
                $num = $idx + 1;
                $feccan = $req['feccan'] ?? 'NULL';
                echo "{$num}. CVE: {$req['cvereq']} | Cuenta: {$req['cvecuenta']} | Folio: {$req['folioreq']} | Total: \${$req['total']} | Fecha: {$feccan}\n";
            }

            echo "\n🔄 Restaurando estos 10 registros...\n";

            $ids = array_column($requerimientos, 'cvereq');
            $placeholders = implode(',', array_fill(0, count($ids), '?'));

            $stmt = $pdo->prepare("
                UPDATE catastro_gdl.reqdiftransmision
                SET
                    vigencia = 'V',
                    feccan = NULL
                WHERE cvereq IN ($placeholders)
            ");

            $stmt->execute($ids);

            echo "\n✅ Restaurados: " . $stmt->rowCount() . " registros\n\n";
        } else {
            echo "ℹ️  No se encontraron requerimientos cancelados.\n";
        }
    }

    // Mostrar estado actual
    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM catastro_gdl.reqdiftransmision
        WHERE vigencia = 'V'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "\n📊 Total de requerimientos VIGENTES: {$result['total']}\n";

    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM catastro_gdl.reqdiftransmision
        WHERE vigencia = 'C'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "📊 Total de requerimientos CANCELADOS: {$result['total']}\n";

    echo "\n✅ ¡Operación completada!\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
