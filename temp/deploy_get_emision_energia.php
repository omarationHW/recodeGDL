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
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/EmisionEnergia_get_emision_energia.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando get_emision_energia...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Probar el SP con valores de ejemplo
    echo "=== Probando SP ===\n";

    // Buscar datos válidos para probar
    $stmt = $pdo->query("
        SELECT DISTINCT a.oficina, a.num_mercado
        FROM publico.ta_11_locales a
        JOIN publico.ta_11_energia e ON a.id_local = e.id_local
        WHERE a.vigencia = 'A' AND e.vigencia = 'E'
        LIMIT 1
    ");
    $datos = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$datos) {
        echo "No se encontraron locales con energía registrada\n";
        exit(0);
    }

    // Buscar un año y periodo válido en kilowhatts
    $stmt2 = $pdo->query("SELECT axo, periodo FROM publico.ta_11_kilowhatts ORDER BY axo DESC, periodo DESC LIMIT 1");
    $periodo = $stmt2->fetch(PDO::FETCH_ASSOC);

    if (!$periodo) {
        echo "No se encontraron registros en ta_11_kilowhatts\n";
        // Usar valores por defecto
        $periodo = ['axo' => 2025, 'periodo' => 1];
    }

    $oficina = $datos['oficina'];
    $mercado = $datos['num_mercado'];
    $axo = $periodo['axo'];
    $per = $periodo['periodo'];

    echo "Probando con: oficina={$oficina}, mercado={$mercado}, axo={$axo}, periodo={$per}\n";

    try {
        $stmt3 = $pdo->prepare("SELECT * FROM get_emision_energia(?, ?, ?, ?)");
        $stmt3->execute([$oficina, $mercado, $axo, $per]);
        $results = $stmt3->fetchAll(PDO::FETCH_ASSOC);

        if (count($results) > 0) {
            echo "✓ SP ejecutado correctamente\n";
            echo "  Registros encontrados: " . count($results) . "\n";

            // Mostrar primeros 2 registros
            $limit = min(2, count($results));
            for ($i = 0; $i < $limit; $i++) {
                $row = $results[$i];
                echo "\n  Registro #" . ($i + 1) . ":\n";
                echo "    ID Local: {$row['id_local']}\n";
                echo "    Local: {$row['oficina']}-{$row['num_mercado']}-{$row['local']}{$row['letra_local']}\n";
                echo "    Nombre: {$row['nombre']}\n";
                echo "    Descripción: {$row['descripcion']}\n";
                echo "    Cuenta Energía: {$row['cuenta_energia']}\n";
                echo "    Local Adicional: {$row['local_adicional']}\n";
                echo "    Año: {$row['axo']}\n";
                echo "    Período: {$row['periodo']}\n";
                echo "    Importe Kwh: \${$row['importe']}\n";
                echo "    ID Energía: {$row['id_energia']}\n";
                echo "    Clave Consumo: {$row['cve_consumo']}\n";
                echo "    Cantidad: {$row['cantidad']}\n";
                echo "    Importe Energía: \${$row['importe_energia']}\n";
            }

            if (count($results) > 2) {
                echo "\n  ... y " . (count($results) - 2) . " registros más\n";
            }
        } else {
            echo "✓ SP ejecutado pero no retornó resultados\n";
            echo "  (No hay emisiones de energía para estos parámetros)\n";
        }
    } catch (PDOException $e) {
        echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
    }

    echo "\n✅ SP desplegado correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
