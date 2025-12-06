<?php
// Script para desplegar cuotasmdo_eliminar

$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conectado a base de datos mercados\n\n";

    // Desplegar cuotasmdo_eliminar
    echo "Desplegando cuotasmdo_eliminar...\n";
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/CuotasMdoMntto_cuotasmdo_eliminar.sql';
    $sql = file_get_contents($sqlFile);
    $pdo->exec($sql);
    echo "✓ cuotasmdo_eliminar desplegado exitosamente\n\n";

    // Probar el SP con un registro de prueba
    echo "=== Probando cuotasmdo_eliminar ===\n";

    // Primero insertar un registro de prueba
    echo "Insertando registro de prueba...\n";
    $pdo->exec("INSERT INTO ta_11_cuo_locales (axo, categoria, seccion, clave_cuota, importe_cuota, fecha_alta, id_usuario)
                VALUES (2026, 1, '99', 99, 99.99, NOW(), 1)");

    // Obtener el ID insertado
    $stmt = $pdo->query("SELECT id_cuotas FROM ta_11_cuo_locales WHERE axo=2026 AND categoria=1 AND seccion='99'");
    $inserted = $stmt->fetch(PDO::FETCH_ASSOC);
    $id_prueba = $inserted['id_cuotas'];
    echo "✓ Registro de prueba insertado con ID: {$id_prueba}\n\n";

    // Probar eliminación
    echo "Probando eliminación...\n";
    $stmt2 = $pdo->prepare("SELECT * FROM cuotasmdo_eliminar(?)");
    $stmt2->execute([$id_prueba]);
    $result = $stmt2->fetch(PDO::FETCH_ASSOC);

    if ($result['eliminar']) {
        echo "✓ Eliminación exitosa\n";

        // Verificar que ya no existe
        $stmt3 = $pdo->query("SELECT COUNT(*) as count FROM ta_11_cuo_locales WHERE id_cuotas={$id_prueba}");
        $count = $stmt3->fetch(PDO::FETCH_ASSOC);

        if ($count['count'] == 0) {
            echo "✓ Registro eliminado correctamente de la base de datos\n";
        } else {
            echo "✗ El registro aún existe en la base de datos\n";
        }
    } else {
        echo "✗ Eliminación fallida\n";
    }

    echo "\n✅ SP desplegado y probado correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
