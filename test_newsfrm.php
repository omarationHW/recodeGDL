<?php
// Script para probar el stored procedure recaudadora_newsfrm actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_newsfrm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_newsfrm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar búsqueda sin filtro (primera página)
    echo "2. Probando búsqueda sin filtro (primera página, 50 registros)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_newsfrm('', 0, 50)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados en página: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "   Total en base de datos: " . number_format($result[0]['total_count']) . "\n\n";

        echo "   === PRIMERAS 5 NOVEDADES ===\n";
        for ($i = 0; $i < min(5, count($result)); $i++) {
            $multa = $result[$i];
            echo "\n   MULTA " . ($i + 1) . ":\n";
            echo "   ID: {$multa['id_multa']}\n";
            echo "   Folio: {$multa['folio']}\n";
            echo "   Año: {$multa['anio']}\n";
            echo "   Fecha Acta: {$multa['fecha_acta']}\n";
            echo "   Contribuyente: {$multa['contribuyente']}\n";
            echo "   Domicilio: {$multa['domicilio']}\n";
            if ($multa['giro']) {
                echo "   Giro: {$multa['giro']}\n";
            }
            echo "   Multa: $" . number_format($multa['multa'], 2) . "\n";
            echo "   Gastos: $" . number_format($multa['gastos'], 2) . "\n";
            echo "   Total: $" . number_format($multa['total'], 2) . "\n";
            echo "   Estatus: {$multa['estatus']}\n";
        }
    }

    // 3. Probar búsqueda con filtro por contribuyente
    echo "\n\n3. Probando búsqueda con filtro por contribuyente (ejemplo: GARCIA)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_newsfrm(?, 0, 50)");
    $stmt->execute(['GARCIA']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados en página: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "   Total coincidencias: " . number_format($result[0]['total_count']) . "\n";
        echo "\n   Primeras 3 coincidencias:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $multa = $result[$i];
            echo "   - Folio: {$multa['folio']}/{$multa['anio']}, ";
            echo "Contribuyente: {$multa['contribuyente']}, ";
            echo "Total: $" . number_format($multa['total'], 2) . "\n";
        }
    }

    // 4. Probar búsqueda con filtro por año
    echo "\n\n4. Probando búsqueda con filtro por año (ejemplo: 2025)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_newsfrm(?, 0, 50)");
    $stmt->execute(['2025']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados en página: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "   Total multas del 2025: " . number_format($result[0]['total_count']) . "\n";
        echo "\n   Primeras 3 multas del 2025:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $multa = $result[$i];
            echo "   - Folio: {$multa['folio']}/{$multa['anio']}, ";
            echo "Contribuyente: {$multa['contribuyente']}, ";
            echo "Total: $" . number_format($multa['total'], 2) . "\n";
        }
    }

    // 5. Probar búsqueda con filtro por folio
    echo "\n\n5. Probando búsqueda con filtro por folio (ejemplo: 1234)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_newsfrm(?, 0, 50)");
    $stmt->execute(['1234']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados en página: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "   Total coincidencias: " . number_format($result[0]['total_count']) . "\n";
        echo "\n   Primeras 3 coincidencias:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $multa = $result[$i];
            echo "   - Folio: {$multa['folio']}/{$multa['anio']}, ";
            echo "Contribuyente: {$multa['contribuyente']}, ";
            echo "Total: $" . number_format($multa['total'], 2) . "\n";
        }
    }

    // 6. Probar paginación (segunda página)
    echo "\n\n6. Probando paginación (segunda página, offset 50)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_newsfrm('', 50, 50)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados en página: " . count($result) . "\n";
    if (count($result) > 0) {
        echo "   Primer registro de la página 2:\n";
        $multa = $result[0];
        echo "   - ID: {$multa['id_multa']}, ";
        echo "Folio: {$multa['folio']}/{$multa['anio']}, ";
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

    // Ver multas más recientes (últimos 7 días)
    echo "\n   Multas recientes (última semana):\n";
    $stmt_recientes = $pdo->query("
        SELECT COUNT(*) as total
        FROM publico.multas
        WHERE fecha_acta >= CURRENT_DATE - INTERVAL '7 days'
    ");
    $recientes = $stmt_recientes->fetch(PDO::FETCH_ASSOC);
    echo "   - Últimos 7 días: " . number_format($recientes['total']) . " multas\n";

    // Ver distribución por año (últimos 5)
    echo "\n   Años más recientes:\n";
    $stmt_anios = $pdo->query("
        SELECT
            axo_acta AS anio,
            COUNT(*) as total
        FROM publico.multas
        WHERE axo_acta >= 2020 AND axo_acta <= 2025
        GROUP BY axo_acta
        ORDER BY axo_acta DESC
        LIMIT 5
    ");
    $anios = $stmt_anios->fetchAll(PDO::FETCH_ASSOC);
    foreach ($anios as $anio) {
        echo "   - Año {$anio['anio']}: " . number_format($anio['total']) . " multas\n";
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
