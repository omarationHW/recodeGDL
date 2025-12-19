<?php
// Script para probar el stored procedure recaudadora_multas400frm actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_multas400frm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_multas400frm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar búsqueda sin filtro
    echo "2. Probando búsqueda sin filtro (últimas 100 multas)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multas400frm('')");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " multas\n\n";

    if (count($result) > 0) {
        echo "   === PRIMERAS 5 MULTAS ===\n";
        for ($i = 0; $i < min(5, count($result)); $i++) {
            $multa = $result[$i];
            echo "\n   MULTA " . ($i + 1) . ":\n";
            echo "   ID: {$multa['id_multa']}\n";
            echo "   Acta: {$multa['num_acta']}/{$multa['axo_acta']}\n";
            echo "   Fecha: {$multa['fecha_acta']}\n";
            echo "   Contribuyente: {$multa['contribuyente']}\n";
            echo "   Domicilio: {$multa['domicilio']}\n";
            echo "   Dependencia: {$multa['id_dependencia']}\n";
            echo "   Multa: $" . number_format($multa['multa'], 2) . "\n";
            echo "   Gastos: $" . number_format($multa['gastos'], 2) . "\n";
            echo "   Total: $" . number_format($multa['total'], 2) . "\n";
            echo "   Estado: {$multa['observacion']}\n";
            if ($multa['fecha_recepcion']) {
                echo "   Fecha recepción: {$multa['fecha_recepcion']}\n";
            }
        }
    }

    // 3. Probar búsqueda con filtro por número de acta
    echo "\n\n3. Probando búsqueda con filtro por número de acta (ejemplo: 100)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multas400frm(?)");
    $stmt->execute(['100']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " multas\n";

    if (count($result) > 0) {
        echo "\n   Primeras coincidencias:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $multa = $result[$i];
            echo "   - Acta: {$multa['num_acta']}/{$multa['axo_acta']}, ";
            echo "Contribuyente: {$multa['contribuyente']}, ";
            echo "Total: $" . number_format($multa['total'], 2) . "\n";
        }
    }

    // 4. Probar búsqueda con filtro por nombre
    echo "\n\n4. Probando búsqueda con filtro por nombre (ejemplo: GARCIA)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multas400frm(?)");
    $stmt->execute(['GARCIA']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " multas\n";

    if (count($result) > 0) {
        echo "\n   Primeras coincidencias:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $multa = $result[$i];
            echo "   - Acta: {$multa['num_acta']}/{$multa['axo_acta']}, ";
            echo "Contribuyente: {$multa['contribuyente']}, ";
            echo "Total: $" . number_format($multa['total'], 2) . "\n";
        }
    }

    // 5. Estadísticas generales
    echo "\n\n5. Estadísticas generales de multas_mpal_400...\n";

    $stmt_total = $pdo->query("
        SELECT COUNT(*) as total
        FROM publico.multas_mpal_400
    ");
    $total = $stmt_total->fetch(PDO::FETCH_ASSOC);
    echo "   Total multas en BD: " . number_format($total['total']) . "\n";

    // Ver distribución por estado
    echo "\n   Distribución por estado:\n";
    $stmt_estados = $pdo->query("
        SELECT
            CASE cvevig
                WHEN 'A' THEN 'Activa'
                WHEN 'P' THEN 'Pagada'
                WHEN 'C' THEN 'Cancelada'
                WHEN 'B' THEN 'Estado B'
                WHEN 'T' THEN 'Estado T'
                ELSE 'Otro'
            END as estado,
            COUNT(*) as total
        FROM publico.multas_mpal_400
        GROUP BY cvevig
        ORDER BY total DESC
    ");
    $estados = $stmt_estados->fetchAll(PDO::FETCH_ASSOC);
    foreach ($estados as $est) {
        echo "   - {$est['estado']}: " . number_format($est['total']) . "\n";
    }

    // Ver rangos de fechas (con manejo de fechas inválidas)
    echo "\n   Rango de fechas:\n";
    try {
        $stmt_fechas = $pdo->query("
            SELECT
                MIN(fecha_valida) as fecha_min,
                MAX(fecha_valida) as fecha_max
            FROM (
                SELECT
                    CASE
                        WHEN fecalt > 0 AND LENGTH(fecalt::TEXT) = 6 THEN
                            TO_DATE('19' || fecalt::TEXT, 'YYYYMMDD')
                        WHEN fecalt > 0 AND LENGTH(fecalt::TEXT) = 8 THEN
                            TO_DATE(fecalt::TEXT, 'YYYYMMDD')
                        ELSE NULL
                    END as fecha_valida
                FROM publico.multas_mpal_400
                WHERE fecalt > 0
            ) fechas
            WHERE fecha_valida IS NOT NULL
        ");
        $fechas = $stmt_fechas->fetch(PDO::FETCH_ASSOC);
        echo "   - Desde: {$fechas['fecha_min']}\n";
        echo "   - Hasta: {$fechas['fecha_max']}\n";
    } catch (PDOException $e) {
        echo "   - (Algunas fechas inválidas en la base de datos)\n";
    }

    // Ver resumen de montos
    echo "\n   Resumen de montos:\n";
    $stmt_montos = $pdo->query("
        SELECT
            SUM(COALESCE(impmul, 0)) as total_multas,
            AVG(COALESCE(impmul, 0)) as promedio_multa,
            MIN(COALESCE(impmul, 0)) as multa_min,
            MAX(COALESCE(impmul, 0)) as multa_max
        FROM publico.multas_mpal_400
    ");
    $montos = $stmt_montos->fetch(PDO::FETCH_ASSOC);
    echo "   - Total multas: $" . number_format($montos['total_multas'], 2) . "\n";
    echo "   - Promedio: $" . number_format($montos['promedio_multa'], 2) . "\n";
    echo "   - Mínima: $" . number_format($montos['multa_min'], 2) . "\n";
    echo "   - Máxima: $" . number_format($montos['multa_max'], 2) . "\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
