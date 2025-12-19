<?php
// Script para probar el stored procedure recaudadora_multasfrmcalif actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_multasfrmcalif...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_multasfrmcalif.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar búsqueda sin filtro (primera página)
    echo "2. Probando búsqueda sin filtro (primera página, 50 registros)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multasfrmcalif('', 0, 50)");
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
            echo "   Folio: {$multa['folio']}/{$multa['ejercicio']}\n";
            echo "   Contribuyente: {$multa['contribuyente']}\n";
            echo "   Domicilio: {$multa['domicilio']}\n";
            echo "   Fecha Acta: {$multa['fecha_acta']}\n";
            echo "   Multa: $" . number_format($multa['multa'], 2) . "\n";
            echo "   Gastos: $" . number_format($multa['gastos'], 2) . "\n";
            echo "   Total: $" . number_format($multa['total'], 2) . "\n";
            echo "   Calificación: $" . number_format($multa['calificacion'], 2) . "\n";
            echo "   Tipo Calificación: {$multa['tipo_calificacion']}\n";
            echo "   Estado: {$multa['estado']}\n";
        }
    }

    // 3. Probar búsqueda con filtro por contribuyente
    echo "\n\n3. Probando búsqueda con filtro por contribuyente (ejemplo: GARCIA)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multasfrmcalif(?, 0, 50)");
    $stmt->execute(['GARCIA']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados en página: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "   Total coincidencias: " . number_format($result[0]['total_count']) . "\n";
        echo "\n   Primeras 3 coincidencias:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $multa = $result[$i];
            echo "   - Folio: {$multa['clave_cuenta']}, ";
            echo "Contribuyente: {$multa['contribuyente']}, ";
            echo "Total: $" . number_format($multa['total'], 2) . ", ";
            echo "Calificación: $" . number_format($multa['calificacion'], 2) . "\n";
        }
    }

    // 4. Probar búsqueda con filtro por folio
    echo "\n\n4. Probando búsqueda con filtro por folio (ejemplo: 1234)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multasfrmcalif(?, 0, 50)");
    $stmt->execute(['1234']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados en página: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "   Total coincidencias: " . number_format($result[0]['total_count']) . "\n";
        echo "\n   Primeras 3 coincidencias:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $multa = $result[$i];
            echo "   - Folio: {$multa['clave_cuenta']}, ";
            echo "Contribuyente: {$multa['contribuyente']}, ";
            echo "Total: $" . number_format($multa['total'], 2) . "\n";
        }
    }

    // 5. Probar paginación (segunda página)
    echo "\n\n5. Probando paginación (segunda página, offset 50)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multasfrmcalif('', 50, 50)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados en página: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "   Primer registro de la página 2:\n";
        $multa = $result[0];
        echo "   - ID: {$multa['id_multa']}, ";
        echo "Folio: {$multa['clave_cuenta']}, ";
        echo "Contribuyente: {$multa['contribuyente']}\n";
    }

    // 6. Buscar multas con tipo de calificación
    echo "\n\n6. Buscando multas con tipo de calificación asignado...\n";

    $stmt = $pdo->query("
        SELECT *
        FROM publico.recaudadora_multasfrmcalif('', 0, 50)
        WHERE tipo_calificacion != 'N/A'
    ");
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total con tipo de calificación: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "\n   Primeras 3 multas con tipo de calificación:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $multa = $result[$i];
            echo "   - Folio: {$multa['clave_cuenta']}, ";
            echo "Tipo: {$multa['tipo_calificacion']}, ";
            echo "Calificación: $" . number_format($multa['calificacion'], 2) . "\n";
        }
    }

    // 7. Estadísticas generales
    echo "\n\n7. Estadísticas generales...\n";

    $stmt_total = $pdo->query("SELECT COUNT(*) as total FROM publico.multas");
    $total = $stmt_total->fetch(PDO::FETCH_ASSOC);
    echo "   Total multas en BD: " . number_format($total['total']) . "\n";

    $stmt_con_calif = $pdo->query("
        SELECT COUNT(*) as total
        FROM publico.multas
        WHERE calificacion IS NOT NULL AND calificacion > 0
    ");
    $con_calif = $stmt_con_calif->fetch(PDO::FETCH_ASSOC);
    echo "   Multas con calificación: " . number_format($con_calif['total']) . "\n";

    $stmt_con_tipo = $pdo->query("
        SELECT COUNT(DISTINCT m.id_multa) as total
        FROM publico.multas m
        INNER JOIN publico.tipo_calificacion_multa tc ON m.id_multa = tc.id_multa
    ");
    $con_tipo = $stmt_con_tipo->fetch(PDO::FETCH_ASSOC);
    echo "   Multas con tipo de calificación: " . number_format($con_tipo['total']) . "\n";

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

    // Ver resumen de calificaciones
    echo "\n   Resumen de calificaciones:\n";
    $stmt_calif = $pdo->query("
        SELECT
            MIN(calificacion) as min_calif,
            MAX(calificacion) as max_calif,
            AVG(calificacion) as avg_calif
        FROM publico.multas
        WHERE calificacion IS NOT NULL AND calificacion > 0
    ");
    $calif = $stmt_calif->fetch(PDO::FETCH_ASSOC);
    echo "   - Mínima: $" . number_format($calif['min_calif'], 2) . "\n";
    echo "   - Máxima: $" . number_format($calif['max_calif'], 2) . "\n";
    echo "   - Promedio: $" . number_format($calif['avg_calif'], 2) . "\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
