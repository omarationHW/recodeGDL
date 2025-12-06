<?php
// Script para desplegar cuotasmdo_insertar y cuotasmdo_actualizar

$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conectado a base de datos mercados\n\n";

    // Desplegar cuotasmdo_insertar
    echo "Desplegando cuotasmdo_insertar...\n";
    $sqlFile1 = __DIR__ . '/../RefactorX/Base/mercados/database/database/CuotasMdoMntto_cuotasmdo_insertar.sql';
    $sql1 = file_get_contents($sqlFile1);
    $pdo->exec($sql1);
    echo "✓ cuotasmdo_insertar desplegado exitosamente\n\n";

    // Desplegar cuotasmdo_actualizar
    echo "Desplegando cuotasmdo_actualizar...\n";
    $sqlFile2 = __DIR__ . '/../RefactorX/Base/mercados/database/database/CuotasMdoMntto_cuotasmdo_actualizar.sql';
    $sql2 = file_get_contents($sqlFile2);
    $pdo->exec($sql2);
    echo "✓ cuotasmdo_actualizar desplegado exitosamente\n\n";

    // Probar cuotasmdo_insertar
    echo "=== Probando cuotasmdo_insertar ===\n";
    $stmt = $pdo->prepare("SELECT * FROM cuotasmdo_insertar(?, ?, ?, ?, ?, ?)");
    $stmt->execute([2026, 1, '01', 1, 100.50, 1]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result['insertar']) {
        echo "✓ Inserción de prueba exitosa\n";

        // Obtener el ID insertado
        $stmt2 = $pdo->query("SELECT id_cuotas FROM ta_11_cuo_locales WHERE axo=2026 AND categoria=1 AND seccion='01' AND clave_cuota=1");
        $inserted = $stmt2->fetch(PDO::FETCH_ASSOC);
        $id_insertado = $inserted['id_cuotas'];
        echo "  ID insertado: {$id_insertado}\n\n";

        // Probar cuotasmdo_actualizar
        echo "=== Probando cuotasmdo_actualizar ===\n";
        $stmt3 = $pdo->prepare("SELECT * FROM cuotasmdo_actualizar(?, ?, ?, ?, ?, ?, ?)");
        $stmt3->execute([$id_insertado, 2026, 1, '01', 1, 150.75, 1]);
        $result2 = $stmt3->fetch(PDO::FETCH_ASSOC);

        if ($result2['actualizar']) {
            echo "✓ Actualización de prueba exitosa\n";
            echo "  Nuevo importe: 150.75\n\n";
        } else {
            echo "✗ Actualización fallida\n\n";
        }

        // Limpiar datos de prueba
        echo "Limpiando datos de prueba...\n";
        $pdo->exec("DELETE FROM ta_11_cuo_locales WHERE id_cuotas = {$id_insertado}");
        echo "✓ Datos de prueba eliminados\n";

    } else {
        echo "✗ Inserción fallida (posiblemente el registro ya existe)\n";
    }

    echo "\n✅ Todos los SPs desplegados correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
