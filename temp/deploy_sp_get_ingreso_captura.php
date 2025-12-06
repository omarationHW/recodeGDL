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
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/IngresoCaptura_sp_get_ingreso_captura.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando sp_get_ingreso_captura...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Probar el SP
    echo "=== Probando SP ===\n";

    // Buscar datos válidos para probar
    $stmt = $pdo->query("
        SELECT
            a.num_mercado,
            b.fecha_pago,
            b.oficina_pago,
            b.caja_pago,
            b.operacion_pago,
            COUNT(*) as total
        FROM publico.ta_11_locales a
        JOIN publico.ta_11_pagos_local b ON a.id_local = b.id_local
        GROUP BY a.num_mercado, b.fecha_pago, b.oficina_pago, b.caja_pago, b.operacion_pago
        HAVING COUNT(*) > 0
        ORDER BY b.fecha_pago DESC
        LIMIT 1
    ");
    $datos = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$datos) {
        echo "No se encontraron pagos para probar\n";
        exit(0);
    }

    $mercado = $datos['num_mercado'];
    $fecha = $datos['fecha_pago'];
    $oficina = $datos['oficina_pago'];
    $caja = $datos['caja_pago'];
    $operacion = $datos['operacion_pago'];

    echo "Probando con:\n";
    echo "  Mercado: {$mercado}\n";
    echo "  Fecha: {$fecha}\n";
    echo "  Oficina: {$oficina}\n";
    echo "  Caja: {$caja}\n";
    echo "  Operación: {$operacion}\n\n";

    try {
        $stmt2 = $pdo->prepare("SELECT * FROM sp_get_ingreso_captura(?, ?, ?, ?, ?)");
        $stmt2->execute([$mercado, $fecha, $oficina, $caja, $operacion]);
        $results = $stmt2->fetchAll(PDO::FETCH_ASSOC);

        if (count($results) > 0) {
            echo "✓ SP ejecutado correctamente\n";
            echo "  Registros encontrados: " . count($results) . "\n";

            // Mostrar todos los registros
            foreach ($results as $i => $row) {
                echo "\n  Registro #" . ($i + 1) . ":\n";
                echo "    Fecha Pago: {$row['fecha_pago']}\n";
                echo "    Caja: {$row['caja_pago']}\n";
                echo "    Operación: {$row['operacion_pago']}\n";
                echo "    Total Pagos: {$row['pagos']}\n";
                echo "    Importe Total: \${$row['importe']}\n";
            }
        } else {
            echo "✓ SP ejecutado pero no retornó resultados\n";
        }
    } catch (PDOException $e) {
        echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
    }

    echo "\n✅ SP desplegado correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
