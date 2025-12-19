<?php
// Script para probar el stored procedure recaudadora_polcon actualizado con tabla auditoria

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_polcon...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_polcon_real.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar sin fechas (todas las pólizas)
    echo "2. Probando sin fechas (todas las pólizas consolidadas)...\n";

    $start = microtime(true);
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_polcon(NULL, NULL)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $time = round(microtime(true) - $start, 2);

    echo "   Total encontrados: " . count($result) . " cuentas de aplicación\n";
    echo "   Tiempo: {$time}s\n\n";

    if (count($result) > 0) {
        echo "   === TOP 10 CUENTAS POR MOVIMIENTOS ===\n\n";
        $top10 = array_slice($result, 0, 10);
        foreach ($top10 as $row) {
            echo "   • {$row['cvectaapl']} - {$row['ctaaplicacion']}\n";
            echo "     Pagos únicos: " . number_format($row['totpar']) . "\n";
            echo "     Suma: $" . number_format($row['suma'], 2) . "\n";
            echo "     Movimientos: " . number_format($row['num_movimientos']) . "\n\n";
        }
    }

    // 3. Probar con rango de fechas (año 2024)
    echo "\n3. Probando con rango de fechas (2024-01-01 a 2024-12-31)...\n";

    $start = microtime(true);
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_polcon(?, ?)");
    $stmt->execute(['2024-01-01', '2024-12-31']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $time = round(microtime(true) - $start, 2);

    echo "   Total encontrados: " . count($result) . " cuentas\n";
    echo "   Tiempo: {$time}s\n\n";

    if (count($result) > 0) {
        echo "   === TOP 5 CUENTAS DEL 2024 ===\n\n";
        $top5 = array_slice($result, 0, 5);
        foreach ($top5 as $row) {
            echo "   • {$row['cvectaapl']}: " . number_format($row['num_movimientos']) . " movimientos";
            echo " - $" . number_format($row['suma'], 2) . "\n";
        }
    } else {
        echo "   ℹ️  No hay movimientos para el año 2024\n";
    }

    // 4. Probar con fecha desde (desde 2020)
    echo "\n\n4. Probando con fecha desde (2020-01-01)...\n";

    $start = microtime(true);
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_polcon(?, NULL)");
    $stmt->execute(['2020-01-01']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $time = round(microtime(true) - $start, 2);

    echo "   Total encontrados: " . count($result) . " cuentas\n";
    echo "   Tiempo: {$time}s\n\n";

    if (count($result) > 0) {
        // Calcular totales
        $total_movimientos = 0;
        $total_suma = 0;
        foreach ($result as $row) {
            $total_movimientos += $row['num_movimientos'];
            $total_suma += $row['suma'];
        }

        echo "   === RESUMEN DESDE 2020 ===\n\n";
        echo "   Total movimientos: " . number_format($total_movimientos) . "\n";
        echo "   Suma total: $" . number_format($total_suma, 2) . "\n";
        echo "   Cuentas diferentes: " . count($result) . "\n";
    }

    // 5. Probar rango específico (2015-2018)
    echo "\n\n5. Probando periodo 2015-2018...\n";

    $start = microtime(true);
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_polcon(?, ?)");
    $stmt->execute(['2015-01-01', '2018-12-31']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $time = round(microtime(true) - $start, 2);

    echo "   Total encontrados: " . count($result) . " cuentas\n";
    echo "   Tiempo: {$time}s\n";

    if (count($result) > 0) {
        $total_movimientos = 0;
        foreach ($result as $row) {
            $total_movimientos += $row['num_movimientos'];
        }
        echo "   Movimientos totales: " . number_format($total_movimientos) . "\n";
    }

    // 6. Información adicional
    echo "\n\n6. Información adicional...\n";
    echo "\n   ✅ IMPORTANTE:\n";
    echo "   - Esta función usa la tabla 'public.auditoria' (29.5M registros)\n";
    echo "   - Agrupa movimientos contables por cuenta de aplicación (cvectaapl)\n";
    echo "   - Excluye movimientos cancelados\n";
    echo "   - Filtra por año cuando se proporcionan fechas\n";
    echo "   - La estructura retornada es:\n";
    echo "     * cvectaapl: Código de cuenta aplicación\n";
    echo "     * ctaaplicacion: Descripción generada\n";
    echo "     * totpar: Total de pagos únicos\n";
    echo "     * suma: Suma de montos\n";
    echo "     * num_movimientos: Cantidad de movimientos\n\n";
    echo "   📌 La tabla auditoria contiene 460 cuentas diferentes\n";
    echo "      con movimientos desde 1990 hasta 2024.\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
