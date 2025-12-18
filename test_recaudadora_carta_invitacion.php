<?php
// Script para probar el stored procedure recaudadora_carta_invitacion

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Crear el stored procedure
    echo "1. Creando stored procedure recaudadora_carta_invitacion...\n";
    $sql = file_get_contents(__DIR__ . '/create_sp_recaudadora_carta_invitacion.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 2. Probar con cuentas existentes
    echo "2. Probando con cuenta 120912...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_carta_invitacion(?, 0)");
    $stmt->execute(['120912']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Resultados: " . count($rows) . " registros encontrados\n";

    if (count($rows) > 0) {
        $r = $rows[0];
        echo "\n   Primer registro:\n";
        echo "     Folio Carta: " . $r["foliocarta"] . "\n";
        echo "     Cuenta: " . $r["cvecuenta"] . "\n";
        echo "     Clave Catastral: " . $r["cvecatnva"] . "\n";
        echo "     Nombre: " . $r["nombre"] . "\n";
        echo "     Dirección: " . $r["calle"] . " " . $r["exterior"] . ", " . $r["colonia"] . "\n";
        echo "     Total: $" . number_format($r["total"], 2) . "\n";
        echo "     Impuesto: $" . number_format($r["impuesto"], 2) . "\n";
        echo "     Ejercicio: " . $r["axoini"] . " - " . $r["axofin"] . "\n";
        echo "     Fecha Emisión: " . $r["fecemi"] . "\n";
    }

    echo "\n\n3. Probando con cuenta 121585...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_carta_invitacion(?, 0)");
    $stmt->execute(['121585']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " registros encontrados\n";

    if (count($rows) > 0) {
        $r = $rows[0];
        echo "\n   Primer registro:\n";
        echo "     Folio Carta: " . $r["foliocarta"] . "\n";
        echo "     Nombre: " . $r["nombre"] . "\n";
        echo "     Total: $" . number_format($r["total"], 2) . "\n";
    }

    echo "\n\n4. Probando con filtro de ejercicio 2019...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_carta_invitacion(?, 2019)");
    $stmt->execute(['120912']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " registros con ejercicio 2019\n";

    echo "\n\n5. Probando con cuenta inexistente...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_carta_invitacion(?, 0)");
    $stmt->execute(['999999999']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " registros encontrados\n";

    echo "\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
