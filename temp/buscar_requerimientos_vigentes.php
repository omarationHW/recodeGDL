<?php
/**
 * Buscar requerimientos vigentes para ejemplos
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

    echo "🔍 Buscando requerimientos vigentes...\n\n";

    // Buscar 5 requerimientos vigentes
    $sql = "
        SELECT
            cvereq,
            cvecuenta,
            folioreq,
            axoreq,
            total,
            vigencia
        FROM catastro_gdl.reqdiftransmision
        WHERE vigencia = 'V'
        AND cvecuenta > 0
        AND total > 0
        ORDER BY cvereq ASC
        LIMIT 10
    ";

    $stmt = $pdo->query($sql);
    $requerimientos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($requerimientos) > 0) {
        echo "✅ Encontrados " . count($requerimientos) . " requerimientos vigentes:\n\n";

        $registros = [];

        foreach ($requerimientos as $idx => $req) {
            $num = $idx + 1;
            echo "{$num}. CVE REQ: {$req['cvereq']} | Cuenta: {$req['cvecuenta']} | Folio: {$req['folioreq']} | Año: {$req['axoreq']} | Total: \${$req['total']}\n";

            $registros[] = [
                'cvereq' => (int)$req['cvereq'],
                'cuenta' => (int)$req['cvecuenta'],
                'folio' => (int)$req['folioreq'],
                'ejercicio' => (int)$req['axoreq'],
                'importe' => (float)$req['total']
            ];
        }

        echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        echo "EJEMPLO 1: Con 2 registros\n";
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";
        echo json_encode(array_slice($registros, 0, 2), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

        echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        echo "EJEMPLO 2: Con 3 registros\n";
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";
        echo json_encode(array_slice($registros, 0, 3), JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

        echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        echo "EJEMPLO 3: Formato simplificado (sin cvereq)\n";
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

        echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        echo "EJEMPLO 4: Un solo registro\n";
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";
        echo json_encode([$registrosSimple[0]], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

        echo "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
        echo "EJEMPLO 5: Formato compacto (una línea)\n";
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n";
        echo json_encode(array_slice($registrosSimple, 0, 2)) . "\n\n";

    } else {
        echo "❌ No se encontraron requerimientos vigentes\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
