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
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/EmisionLibertad_generar_emision_libertad.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando generar_emision_libertad...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Probar el SP con valores de ejemplo
    echo "=== Probando SP ===\n";

    // Buscar datos válidos
    $stmt = $pdo->query("
        SELECT DISTINCT a.oficina, a.num_mercado
        FROM publico.ta_11_locales a
        WHERE a.vigencia = 'A' AND a.bloqueo < 4
        LIMIT 1
    ");
    $datos = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$datos) {
        echo "No se encontraron locales válidos\n";
        exit(0);
    }

    // Buscar año y periodo válido en cuotas
    $stmt2 = $pdo->query("SELECT DISTINCT axo FROM publico.ta_11_cuo_locales ORDER BY axo DESC LIMIT 1");
    $axo = $stmt2->fetch(PDO::FETCH_COLUMN) ?? 2025;

    $oficina = $datos['oficina'];
    $mercados_json = json_encode([$datos['num_mercado']]);
    $periodo = 1;

    echo "Probando con: oficina={$oficina}, mercados={$mercados_json}, axo={$axo}, periodo={$periodo}\n\n";

    try {
        $stmt3 = $pdo->prepare("SELECT * FROM generar_emision_libertad(?::SMALLINT, ?::json, ?::SMALLINT, ?::SMALLINT, ?::INTEGER)");
        $stmt3->execute([$oficina, $mercados_json, $axo, $periodo, 1]);
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
                echo "    Nombre: {$row['nombre']}\n";
                echo "    Mercado: {$row['descripcion']}\n";
                echo "    Local: {$row['oficina']}-{$row['num_mercado']}-{$row['local']}{$row['letra_local']}\n";
                echo "    Renta: \${$row['renta']}\n";
                echo "    Descuento: \${$row['descuento']}\n";
                echo "    Adeudos: \${$row['adeudos']}\n";
                echo "    Recargos: \${$row['recargos']}\n";
                echo "    Subtotal: \${$row['subtotal']}\n";
                echo "    Multas: \${$row['multas']}\n";
                echo "    Gastos: \${$row['gastos']}\n";
                echo "    Folios: {$row['folios']}\n";
            }

            if (count($results) > 2) {
                echo "\n  ... y " . (count($results) - 2) . " registros más\n";
            }
        } else {
            echo "✓ SP ejecutado pero no retornó resultados\n";
            echo "  (No hay locales que cumplan las condiciones)\n";
        }
    } catch (PDOException $e) {
        echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
    }

    echo "\n✅ SP desplegado correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
