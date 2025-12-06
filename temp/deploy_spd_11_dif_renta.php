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
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/PagosDifIngresos_spd_11_dif_renta.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando spd_11_dif_renta...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Probar el SP con valores de ejemplo
    echo "=== Probando SP ===\n";

    // Primero obtener una oficina válida
    $stmt = $pdo->query("SELECT DISTINCT oficina FROM public.ta_11_mercados LIMIT 1");
    $oficina = $stmt->fetch(PDO::FETCH_COLUMN);

    if (!$oficina) {
        echo "No se encontró ninguna oficina en ta_11_mercados\n";
        exit(0);
    }

    // Parámetros de ejemplo: oficina encontrada, rango de fechas amplio
    $rec = $oficina;
    $fecha_desde = '2024-01-01';
    $fecha_hasta = '2025-12-31';

    echo "Probando con: oficina={$rec}, fecha_desde={$fecha_desde}, fecha_hasta={$fecha_hasta}\n";

    try {
        $stmt = $pdo->prepare("SELECT * FROM spd_11_dif_renta(?, ?, ?)");
        $stmt->execute([$rec, $fecha_desde, $fecha_hasta]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($results) > 0) {
            echo "✓ SP ejecutado correctamente\n";
            echo "  Registros encontrados: " . count($results) . "\n";

            // Mostrar primeros 2 registros
            $limit = min(2, count($results));
            for ($i = 0; $i < $limit; $i++) {
                $row = $results[$i];
                echo "\n  Registro #" . ($i + 1) . ":\n";
                echo "    ID Pago Local: {$row['id_pago_local']}\n";
                echo "    ID Local: {$row['id_local']}\n";
                echo "    Año: {$row['axo']}\n";
                echo "    Período: {$row['periodo']}\n";
                echo "    Fecha Pago: {$row['fecha_pago']}\n";
                echo "    Oficina Pago: {$row['oficina_pago']}\n";
                echo "    Caja: {$row['caja_pago']}\n";
                echo "    Operación: {$row['operacion_pago']}\n";
                echo "    Importe Pagado: \${$row['importe_pago']}\n";
                echo "    Renta Esperada: \${$row['renta_esperada']}\n";
                echo "    Diferencia: \$" . ($row['importe_pago'] - $row['renta_esperada']) . "\n";
                echo "    Folio: {$row['folio']}\n";
                echo "    Usuario: {$row['usuario']}\n";
                echo "    Local: {$row['oficina']}-{$row['num_mercado']}-{$row['local']}{$row['letra_local']}\n";
            }

            if (count($results) > 2) {
                echo "\n  ... y " . (count($results) - 2) . " registros más\n";
            }
        } else {
            echo "✓ SP ejecutado pero no retornó resultados\n";
            echo "  (No hay pagos con diferencia de renta en el rango especificado)\n";
        }
    } catch (PDOException $e) {
        echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
    }

    echo "\n✅ SP desplegado correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
