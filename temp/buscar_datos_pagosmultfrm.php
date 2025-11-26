<?php
/**
 * Buscar datos para ejemplos de pagos múltiples
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

    echo "🔍 Buscando datos para pagos múltiples...\n\n";

    // Buscar 5 requerimientos vigentes con diferentes cuentas
    $sql = "
        SELECT
            cvereq,
            cvecuenta,
            folioreq,
            axoreq,
            total,
            impuesto,
            recargos,
            multa
        FROM catastro_gdl.reqdiftransmision
        WHERE vigencia = 'V'
        AND cvecuenta > 0
        AND total > 0
        ORDER BY cvereq DESC
        LIMIT 5
    ";

    $stmt = $pdo->query($sql);
    $requerimientos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($requerimientos) > 0) {
        echo "✅ Encontrados " . count($requerimientos) . " requerimientos:\n\n";

        // Generar JSON de ejemplo
        $registros = [];

        foreach ($requerimientos as $req) {
            $registros[] = [
                'cvereq' => (int)$req['cvereq'],
                'cuenta' => (int)$req['cvecuenta'],
                'folio' => (int)$req['folioreq'],
                'ejercicio' => (int)$req['axoreq'],
                'importe' => (float)$req['total']
            ];

            echo "Requerimiento: {$req['cvereq']}\n";
            echo "  - Cuenta: {$req['cvecuenta']}\n";
            echo "  - Folio: {$req['folioreq']}\n";
            echo "  - Ejercicio: {$req['axoreq']}\n";
            echo "  - Total: \${$req['total']}\n\n";
        }

        echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        echo "EJEMPLO 1: JSON con todos los registros\n";
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";
        echo json_encode($registros, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

        echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        echo "EJEMPLO 2: JSON con solo 2 registros\n";
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";
        echo json_encode(array_slice($registros, 0, 2), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

        echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        echo "EJEMPLO 3: JSON formato simplificado\n";
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";

        $registrosSimple = [];
        foreach (array_slice($requerimientos, 0, 3) as $req) {
            $registrosSimple[] = [
                'cuenta' => (int)$req['cvecuenta'],
                'folio' => (int)$req['folioreq'],
                'importe' => (float)$req['total']
            ];
        }
        echo json_encode($registrosSimple, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

    } else {
        echo "❌ No se encontraron requerimientos vigentes\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
