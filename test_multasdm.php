<?php
// Script para probar el stored procedure recaudadora_multas_dm actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_multas_dm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_multasdm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar búsqueda sin filtros (primera página)
    echo "2. Probando búsqueda sin filtros (primera página, 50 registros)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multas_dm('', 0, 0, 50)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados en página: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "   Total en base de datos: " . number_format($result[0]['total_count']) . "\n\n";

        echo "   === PRIMERAS 5 MULTAS ===\n";
        for ($i = 0; $i < min(5, count($result)); $i++) {
            $multa = $result[$i];
            echo "\n   MULTA " . ($i + 1) . ":\n";
            echo "   ID: {$multa['id_multa']}\n";
            echo "   Clave Cuenta: {$multa['clave_cuenta']}\n";
            echo "   Folio: {$multa['folio']}\n";
            echo "   Ejercicio: {$multa['ejercicio']}\n";
            echo "   Contribuyente: {$multa['contribuyente']}\n";
            echo "   Domicilio: {$multa['domicilio']}\n";
            echo "   Fecha Acta: {$multa['fecha_acta']}\n";
            echo "   Multa: $" . number_format($multa['multa'], 2) . "\n";
            echo "   Gastos: $" . number_format($multa['gastos'], 2) . "\n";
            echo "   Total: $" . number_format($multa['total'], 2) . "\n";
            echo "   Estado: {$multa['estado']}\n";
            if ($multa['expediente']) {
                echo "   Expediente: {$multa['expediente']}\n";
            }
        }
    }

    // 3. Probar búsqueda con filtro por clave_cuenta
    echo "\n\n3. Probando búsqueda con filtro por clave (ejemplo: 1234)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multas_dm(?, 0, 0, 50)");
    $stmt->execute(['1234']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados en página: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "   Total coincidencias: " . number_format($result[0]['total_count']) . "\n";
        echo "\n   Primeras 3 coincidencias:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $multa = $result[$i];
            echo "   - Clave: {$multa['clave_cuenta']}, ";
            echo "Contribuyente: {$multa['contribuyente']}, ";
            echo "Total: $" . number_format($multa['total'], 2) . "\n";
        }
    }

    // 4. Probar filtro por ejercicio (año 2025)
    echo "\n\n4. Probando filtro por ejercicio (año 2025)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multas_dm('', ?, 0, 50)");
    $stmt->execute([2025]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados en página: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "   Total multas del 2025: " . number_format($result[0]['total_count']) . "\n";
        echo "\n   Primeras 3 multas del 2025:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $multa = $result[$i];
            echo "   - Folio: {$multa['folio']}/{$multa['ejercicio']}, ";
            echo "Contribuyente: {$multa['contribuyente']}, ";
            echo "Total: $" . number_format($multa['total'], 2) . "\n";
        }
    }

    // 5. Probar filtro combinado (clave + ejercicio)
    echo "\n\n5. Probando filtro combinado (clave '100' + ejercicio 2024)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multas_dm(?, ?, 0, 50)");
    $stmt->execute(['100', 2024]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados en página: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "   Total coincidencias: " . number_format($result[0]['total_count']) . "\n";
        echo "\n   Primeras 3 coincidencias:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $multa = $result[$i];
            echo "   - Clave: {$multa['clave_cuenta']}, ";
            echo "Contribuyente: {$multa['contribuyente']}, ";
            echo "Total: $" . number_format($multa['total'], 2) . "\n";
        }
    }

    // 6. Probar paginación (segunda página)
    echo "\n\n6. Probando paginación (segunda página, offset 50)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multas_dm('', 0, 50, 50)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados en página: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "   Primer registro de la página 2:\n";
        $multa = $result[0];
        echo "   - ID: {$multa['id_multa']}, ";
        echo "Clave: {$multa['clave_cuenta']}, ";
        echo "Contribuyente: {$multa['contribuyente']}\n";
    }

    // 7. Estadísticas generales
    echo "\n\n7. Estadísticas generales...\n";

    $stmt_total = $pdo->query("SELECT COUNT(*) as total FROM publico.multas");
    $total = $stmt_total->fetch(PDO::FETCH_ASSOC);
    echo "   Total multas en BD: " . number_format($total['total']) . "\n";

    // Ver distribución por estado
    echo "\n   Distribución por estado:\n";
    $stmt_estados = $pdo->query("
        SELECT
            CASE
                WHEN fecha_cancelacion IS NOT NULL THEN 'Cancelada'
                ELSE 'Activa'
            END as estado,
            COUNT(*) as total
        FROM publico.multas
        GROUP BY estado
        ORDER BY total DESC
    ");
    $estados = $stmt_estados->fetchAll(PDO::FETCH_ASSOC);
    foreach ($estados as $est) {
        echo "   - {$est['estado']}: " . number_format($est['total']) . "\n";
    }

    // Ver ejercicios más recientes
    echo "\n   Ejercicios más recientes (últimos 5):\n";
    $stmt_ejercicios = $pdo->query("
        SELECT
            axo_acta AS ejercicio,
            COUNT(*) as total
        FROM publico.multas
        WHERE axo_acta >= 2020 AND axo_acta <= 2025
        GROUP BY axo_acta
        ORDER BY axo_acta DESC
        LIMIT 5
    ");
    $ejercicios = $stmt_ejercicios->fetchAll(PDO::FETCH_ASSOC);
    foreach ($ejercicios as $ej) {
        echo "   - Ejercicio {$ej['ejercicio']}: " . number_format($ej['total']) . " multas\n";
    }

    // Ver resumen de montos
    echo "\n   Resumen de montos:\n";
    $stmt_montos = $pdo->query("
        SELECT
            SUM(COALESCE(multa, 0)) as total_multas,
            SUM(COALESCE(gastos, 0)) as total_gastos,
            SUM(COALESCE(total, 0)) as total_general,
            AVG(COALESCE(total, 0)) as promedio
        FROM publico.multas
    ");
    $montos = $stmt_montos->fetch(PDO::FETCH_ASSOC);
    echo "   - Total multas: $" . number_format($montos['total_multas'], 2) . "\n";
    echo "   - Total gastos: $" . number_format($montos['total_gastos'], 2) . "\n";
    echo "   - Total general: $" . number_format($montos['total_general'], 2) . "\n";
    echo "   - Promedio por multa: $" . number_format($montos['promedio'], 2) . "\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
