<?php
// Script para probar el stored procedure recaudadora_consdesc actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_consdesc...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_consdesc.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar con cuenta conocida
    echo "2. Probando con cuenta 'JBB3383'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consdesc(?)");
    $stmt->execute(['JBB3383']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Resultados: " . count($rows) . " descuentos encontrados\n";

    if (count($rows) > 0) {
        echo "\n   Primeros 3 descuentos:\n";
        foreach (array_slice($rows, 0, 3) as $i => $r) {
            echo "   ---\n";
            echo "   Descuento " . ($i + 1) . ":\n";
            echo "     ID: " . $r["id_descuento"] . "\n";
            echo "     Cuenta: " . $r["clave_cuenta"] . "\n";
            echo "     Tipo: " . $r["tipo_descuento"] . "\n";
            echo "     Porcentaje: " . $r["porcentaje_descuento"] . "%\n";
            echo "     Monto: $" . number_format($r["monto_fijo"], 2) . "\n";
            echo "     Estado: " . $r["estado"] . "\n";
            echo "     Fecha Registro: " . $r["fecha_registro"] . "\n";
            echo "     Autorizado por: " . $r["autorizado_por"] . "\n";
            if ($r["dias_vigencia"] !== null) {
                echo "     Días vigencia: " . $r["dias_vigencia"] . "\n";
            }
        }
    }

    // 3. Probar con cuenta '317396'
    echo "\n\n3. Probando con cuenta '317396'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consdesc(?)");
    $stmt->execute(['317396']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " descuentos encontrados\n";

    if (count($rows) > 0) {
        $r = $rows[0];
        echo "\n   Primer descuento:\n";
        echo "     ID: {$r['id_descuento']}\n";
        echo "     Tipo: {$r['tipo_descuento']}\n";
        echo "     Porcentaje: {$r['porcentaje_descuento']}%\n";
        echo "     Monto: $" . number_format($r['monto_fijo'], 2) . "\n";
        echo "     Estado: {$r['estado']}\n";
    }

    // 4. Probar con cuenta inexistente
    echo "\n\n4. Probando con cuenta inexistente...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_consdesc(?)");
    $stmt->execute(['CUENTA-NO-EXISTE']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " descuentos encontrados\n";

    // 5. Contar descuentos por estado
    echo "\n\n5. Estadísticas de descuentos para cuenta 'JBB3383'...\n";
    $stmt = $pdo->prepare("
        SELECT estado, COUNT(*) as total
        FROM publico.recaudadora_consdesc('JBB3383')
        GROUP BY estado
        ORDER BY estado
    ");
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($rows) > 0) {
        echo "   Por estado:\n";
        foreach ($rows as $r) {
            $estadoNombre = $r['estado'] == 'A' ? 'Activo' : ($r['estado'] == 'B' ? 'Baja' : ($r['estado'] == 'C' ? 'Cancelado' : 'Inactivo'));
            echo "     - {$estadoNombre}: {$r['total']}\n";
        }
    }

    echo "\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
