<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conectado a base de datos mercados\n\n";

    // Leer y desplegar el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/FechaDescuento_sp_fechadescuento_update.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando sp_fechadescuento_update...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Probar el SP
    echo "=== Probando SP ===\n";

    // Primero obtener un mes existente
    $stmt = $pdo->query("SELECT mes, fecha_descuento, fecha_recargos FROM publico.ta_11_fecha_desc LIMIT 1");
    $registro = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$registro) {
        echo "No hay registros para probar\n";
        exit(0);
    }

    $mes = $registro['mes'];
    $fecha_desc_original = $registro['fecha_descuento'];
    $fecha_rec_original = $registro['fecha_recargos'];

    echo "Registro original:\n";
    echo "  Mes: {$mes}\n";
    echo "  Fecha Descuento: {$fecha_desc_original}\n";
    echo "  Fecha Recargos: {$fecha_rec_original}\n\n";

    // Probar actualización válida (sin cambiar realmente las fechas)
    echo "Probando actualización (sin cambios)...\n";
    try {
        $stmt2 = $pdo->prepare("SELECT * FROM sp_fechadescuento_update(?, ?, ?, ?)");
        $stmt2->execute([$mes, $fecha_desc_original, $fecha_rec_original, 1]);
        $result = $stmt2->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            echo "✓ SP ejecutado correctamente\n";
            echo "  Success: " . ($result['success'] ? 'true' : 'false') . "\n";
            echo "  Message: {$result['message']}\n";
        }
    } catch (PDOException $e) {
        echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
    }

    echo "\n";

    // Probar con mes inexistente
    echo "Probando con mes inexistente (99)...\n";
    try {
        $stmt3 = $pdo->prepare("SELECT * FROM sp_fechadescuento_update(?, ?, ?, ?)");
        $stmt3->execute([99, $fecha_desc_original, $fecha_rec_original, 1]);
        $result2 = $stmt3->fetch(PDO::FETCH_ASSOC);

        if ($result2) {
            echo "✓ SP ejecutado correctamente\n";
            echo "  Success: " . ($result2['success'] ? 'true' : 'false') . "\n";
            echo "  Message: {$result2['message']}\n";
        }
    } catch (PDOException $e) {
        echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
    }

    echo "\n✅ SP desplegado correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
