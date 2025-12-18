<?php
// Script para probar el stored procedure recaudadora_autdescto

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Crear el stored procedure
    echo "1. Creando stored procedure recaudadora_autdescto...\n";
    $sql = file_get_contents(__DIR__ . '/create_sp_recaudadora_autdescto.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 2. Probar con una cuenta existente
    echo "2. Probando con cuenta JBB3383...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_autdescto(?)");
    $stmt->execute(['JBB3383']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Resultados: " . count($rows) . " registros encontrados\n";

    if (count($rows) > 0) {
        echo "\n   Primeros 3 registros:\n";
        foreach (array_slice($rows, 0, 3) as $i => $r) {
            echo "   ---\n";
            echo "   Registro " . ($i + 1) . ":\n";
            echo "     Cuenta: " . $r["cuenta"] . "\n";
            echo "     Nombre: " . $r["nombre"] . "\n";
            echo "     Tipo: " . $r["tipo_descuento"] . "\n";
            echo "     Porcentaje: " . $r["porcentaje"] . "%\n";
            echo "     Monto: $" . number_format($r["monto_descuento"], 2) . "\n";
            echo "     Fecha: " . $r["fecha_autorizacion"] . "\n";
            echo "     Autorizado por: " . $r["autorizado_por"] . "\n";
            echo "     Estatus: " . $r["estatus"] . "\n";
        }
    }

    echo "\n\n3. Probando con cuenta 317396...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_autdescto(?)");
    $stmt->execute(['317396']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " registros encontrados\n";

    echo "\n\n4. Probando con cuenta inexistente...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_autdescto(?)");
    $stmt->execute(['CUENTA-NO-EXISTE']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " registros encontrados\n";

    echo "\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
