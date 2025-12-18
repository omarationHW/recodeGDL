<?php
// Script para probar el stored procedure recaudadora_bloqctasreqfrm

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Crear el stored procedure
    echo "1. Creando stored procedure recaudadora_bloqctasreqfrm...\n";
    $sql = file_get_contents(__DIR__ . '/create_sp_recaudadora_bloqctasreqfrm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 2. Probar con cuentas existentes
    echo "2. Probando con cuenta 256339...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_bloqctasreqfrm(?)");
    $stmt->execute(['256339']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Resultados: " . count($rows) . " registros encontrados\n";

    if (count($rows) > 0) {
        echo "\n   Primeros 2 registros:\n";
        foreach (array_slice($rows, 0, 2) as $i => $r) {
            echo "   ---\n";
            echo "   Registro " . ($i + 1) . ":\n";
            echo "     Cuenta: " . $r["cuenta"] . "\n";
            echo "     Fecha bloqueo: " . $r["fecha_bloqueo"] . "\n";
            echo "     Motivo: " . $r["motivo"] . "\n";
            echo "     Usuario: " . $r["usuario"] . "\n";
            echo "     Estatus: " . $r["estatus"] . "\n";
            echo "     Observaciones: " . substr($r["observaciones"], 0, 100) . "...\n";
        }
    }

    echo "\n\n3. Probando con cuenta 352938...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_bloqctasreqfrm(?)");
    $stmt->execute(['352938']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " registros encontrados\n";

    if (count($rows) > 0) {
        $r = $rows[0];
        echo "\n   Primer registro:\n";
        echo "     Cuenta: " . $r["cuenta"] . "\n";
        echo "     Motivo: " . $r["motivo"] . "\n";
        echo "     Estatus: " . $r["estatus"] . "\n";
    }

    echo "\n\n4. Probando con cuenta inexistente...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_bloqctasreqfrm(?)");
    $stmt->execute(['999999999']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " registros encontrados\n";

    echo "\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
