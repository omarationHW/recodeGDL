<?php
/**
 * Restaurar vigencia de requerimientos de 'C' a 'V' para pruebas
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

    echo "🔄 Restaurando vigencia de requerimientos...\n\n";

    // Primero ver cuántos hay cancelados
    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM catastro_gdl.reqdiftransmision
        WHERE vigencia = 'C'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "📊 Requerimientos cancelados encontrados: {$result['total']}\n\n";

    // Mostrar algunos registros cancelados
    echo "📋 Requerimientos que serán restaurados:\n\n";
    $stmt = $pdo->query("
        SELECT cvereq, cvecuenta, folioreq, axoreq, total, feccan
        FROM catastro_gdl.reqdiftransmision
        WHERE vigencia = 'C'
        ORDER BY feccan DESC
        LIMIT 10
    ");

    $requerimientos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($requerimientos as $idx => $req) {
        $num = $idx + 1;
        echo "{$num}. CVE: {$req['cvereq']} | Cuenta: {$req['cvecuenta']} | Folio: {$req['folioreq']} | Total: \${$req['total']} | Cancelado: {$req['feccan']}\n";
    }

    echo "\n¿Desea restaurar TODOS los requerimientos cancelados a vigentes? (y/n): ";
    $handle = fopen("php://stdin", "r");
    $line = fgets($handle);
    $respuesta = trim($line);
    fclose($handle);

    if (strtolower($respuesta) !== 'y') {
        echo "\n❌ Operación cancelada por el usuario.\n";
        exit(0);
    }

    echo "\n🔄 Restaurando requerimientos...\n";

    // Actualizar de C a V
    $stmt = $pdo->exec("
        UPDATE catastro_gdl.reqdiftransmision
        SET
            vigencia = 'V',
            feccan = NULL
        WHERE vigencia = 'C'
    ");

    echo "\n✅ Restaurados: $stmt registros\n\n";

    // Verificar
    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM catastro_gdl.reqdiftransmision
        WHERE vigencia = 'V'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "📊 Total de requerimientos vigentes ahora: {$result['total']}\n";

    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM catastro_gdl.reqdiftransmision
        WHERE vigencia = 'C'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "📊 Total de requerimientos cancelados ahora: {$result['total']}\n";

    echo "\n✅ ¡Operación completada! Ahora puedes volver a probar los registros.\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
