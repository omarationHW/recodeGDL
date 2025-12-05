<?php
// Script para obtener estructura y ejemplos de licencias

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== ESTRUCTURA DE LICENCIAS ===\n\n";

    // Obtener estructura de la tabla licencias en comun
    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'licencias'
        ORDER BY ordinal_position
        LIMIT 50
    ");

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $length = $row['character_maximum_length'] ? "({$row['character_maximum_length']})" : "";
        echo "  {$row['column_name']} {$row['data_type']}$length\n";
    }

    echo "\n=== EJEMPLOS DE LICENCIAS CON SALDOS PENDIENTES ===\n\n";

    // Obtener 5 ejemplos de licencias con saldos pendientes
    $stmt = $pdo->query("
        SELECT
            l.id_licencia,
            l.licencia,
            l.propietario,
            l.id_giro,
            d.axo,
            d.saldo,
            d.derechos,
            d.recargos,
            d.forma
        FROM comun.licencias l
        INNER JOIN comun.detsal_lic d ON l.id_licencia = d.id_licencia
        WHERE d.saldo > 0
        ORDER BY l.id_licencia
        LIMIT 5
    ");

    $ejemplos = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $ejemplos[] = $row;
        echo "ID Licencia: {$row['id_licencia']}\n";
        echo "  Número Licencia: {$row['licencia']}\n";
        echo "  Propietario: {$row['propietario']}\n";
        echo "  Giro: {$row['id_giro']}\n";
        echo "  Año: {$row['axo']}\n";
        echo "  Saldo: \${$row['saldo']}\n";
        echo "  Derechos: \${$row['derechos']}\n";
        echo "  Recargos: \${$row['recargos']}\n";
        echo "  Forma: \${$row['forma']}\n\n";
    }

    // Guardar ejemplos para uso posterior
    file_put_contents('temp/ejemplos_licencias.json', json_encode($ejemplos, JSON_PRETTY_PRINT));

    echo "\n=== CONTEO TOTAL DE LICENCIAS CON SALDO ===\n";
    $stmt = $pdo->query("
        SELECT COUNT(DISTINCT l.id_licencia) as total
        FROM comun.licencias l
        INNER JOIN comun.detsal_lic d ON l.id_licencia = d.id_licencia
        WHERE d.saldo > 0
    ");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total de licencias con saldo: {$total['total']}\n";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
