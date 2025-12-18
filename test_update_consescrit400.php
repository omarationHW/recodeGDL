<?php
// Script para probar el stored procedure recaudadora_consescrit400 actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_consescrit400...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_consescrit400.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar con cuenta conocida
    echo "2. Probando con cuenta '10356'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consescrit400(?)");
    $stmt->execute(['10356']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Resultados: " . count($rows) . " escrituras encontradas\n";

    if (count($rows) > 0) {
        echo "\n   Primeras 3 escrituras:\n";
        foreach (array_slice($rows, 0, 3) as $i => $r) {
            echo "   ---\n";
            echo "   Escritura " . ($i + 1) . ":\n";
            echo "     ID: " . $r["id_escritura"] . "\n";
            echo "     Cuenta: " . $r["clave_cuenta"] . "\n";
            echo "     Número: " . $r["numero_escritura"] . "\n";
            echo "     Fecha: " . ($r["fecha_escritura"] ?? 'N/A') . "\n";
            echo "     Notaría: " . $r["notaria"] . "\n";
            echo "     Tipo: " . $r["tipo_operacion"] . "\n";
            echo "     Estado: " . $r["estado"] . "\n";
            echo "     Ubicación: " . $r["ubicacion"] . "\n";
            if ($r["dias_desde_registro"] !== null) {
                echo "     Días desde registro: " . $r["dias_desde_registro"] . "\n";
            }
        }
    }

    // 3. Probar con cuenta '83284'
    echo "\n\n3. Probando con cuenta '83284'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consescrit400(?)");
    $stmt->execute(['83284']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " escrituras encontradas\n";

    if (count($rows) > 0) {
        $r = $rows[0];
        echo "\n   Primera escritura:\n";
        echo "     ID: {$r['id_escritura']}\n";
        echo "     Número: {$r['numero_escritura']}\n";
        echo "     Fecha: " . ($r['fecha_escritura'] ?? 'N/A') . "\n";
        echo "     Notaría: {$r['notaria']}\n";
    }

    // 4. Probar con cuenta inexistente
    echo "\n\n4. Probando con cuenta inexistente...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consescrit400(?)");
    $stmt->execute(['999999999']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " escrituras encontradas\n";

    // 5. Listar algunas cuentas disponibles
    echo "\n\n5. Buscando cuentas con escrituras (primeras 5)...\n";
    $stmt = $pdo->query("SELECT DISTINCT cuenta FROM publico.escrituras_400 ORDER BY cuenta LIMIT 5");
    $cuentas = $stmt->fetchAll(PDO::FETCH_COLUMN);

    echo "   Cuentas disponibles:\n";
    foreach ($cuentas as $cuenta) {
        echo "     - $cuenta\n";
    }

    echo "\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
