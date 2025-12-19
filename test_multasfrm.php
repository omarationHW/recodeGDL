<?php
// Script para probar el stored procedure recaudadora_multasfrm actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_multasfrm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_multasfrm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar búsqueda sin filtro
    echo "2. Probando búsqueda sin filtro (últimas 100 multas)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multasfrm('')");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " multas\n\n";

    if (count($result) > 0) {
        echo "   === PRIMERAS 5 MULTAS ===\n";
        for ($i = 0; $i < min(5, count($result)); $i++) {
            $multa = $result[$i];
            echo "\n   MULTA " . ($i + 1) . ":\n";
            echo "   ID: {$multa['id_multa']}\n";
            echo "   Folio: {$multa['folio']}\n";
            echo "   Año: {$multa['anio']}\n";
            echo "   Fecha: {$multa['fecha_acta']}\n";
            echo "   Contribuyente: {$multa['contribuyente']}\n";
            echo "   Domicilio: {$multa['domicilio']}\n";
            if ($multa['giro']) {
                echo "   Giro: {$multa['giro']}\n";
            }
            if ($multa['licencia']) {
                echo "   Licencia: {$multa['licencia']}\n";
            }
            echo "   Total: $" . number_format($multa['total'], 2) . "\n";
            echo "   Estatus: {$multa['estatus']}\n";
        }
    }

    // 3. Probar búsqueda con filtro por contribuyente
    echo "\n\n3. Probando búsqueda con filtro por contribuyente (ejemplo: GARCIA)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multasfrm(?)");
    $stmt->execute(['GARCIA']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " multas\n";

    if (count($result) > 0) {
        echo "\n   Primeras 3 coincidencias:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $multa = $result[$i];
            echo "   - Folio: {$multa['folio']}/{$multa['anio']}, ";
            echo "Contribuyente: {$multa['contribuyente']}, ";
            echo "Total: $" . number_format($multa['total'], 2) . "\n";
        }
    }

    // 4. Probar búsqueda con filtro por folio
    echo "\n\n4. Probando búsqueda con filtro por folio (ejemplo: 1234)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multasfrm(?)");
    $stmt->execute(['1234']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " multas\n";

    if (count($result) > 0) {
        echo "\n   Primeras 3 coincidencias:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $multa = $result[$i];
            echo "   - Folio: {$multa['folio']}/{$multa['anio']}, ";
            echo "Contribuyente: {$multa['contribuyente']}, ";
            echo "Total: $" . number_format($multa['total'], 2) . "\n";
        }
    }

    // 5. Probar búsqueda con filtro por giro
    echo "\n\n5. Probando búsqueda con filtro por giro (ejemplo: COMERCIO)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multasfrm(?)");
    $stmt->execute(['COMERCIO']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " multas\n";

    if (count($result) > 0) {
        echo "\n   Primeras 3 coincidencias:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $multa = $result[$i];
            echo "   - Folio: {$multa['folio']}/{$multa['anio']}, ";
            echo "Giro: {$multa['giro']}, ";
            echo "Total: $" . number_format($multa['total'], 2) . "\n";
        }
    }

    // 6. Estadísticas generales
    echo "\n\n6. Estadísticas generales...\n";

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

    // Ver giros más comunes
    echo "\n   Giros más comunes (top 5):\n";
    $stmt_giros = $pdo->query("
        SELECT
            giro,
            COUNT(*) as total
        FROM publico.multas
        WHERE giro IS NOT NULL AND giro != ''
        GROUP BY giro
        ORDER BY total DESC
        LIMIT 5
    ");
    $giros = $stmt_giros->fetchAll(PDO::FETCH_ASSOC);
    foreach ($giros as $g) {
        $giro_texto = trim($g['giro']);
        if (strlen($giro_texto) > 50) {
            $giro_texto = substr($giro_texto, 0, 50) . '...';
        }
        echo "   - {$giro_texto}: " . number_format($g['total']) . " multas\n";
    }

    // Ver resumen de montos
    echo "\n   Resumen de montos:\n";
    $stmt_montos = $pdo->query("
        SELECT
            SUM(COALESCE(total, 0)) as total_general,
            AVG(COALESCE(total, 0)) as promedio,
            MIN(COALESCE(total, 0)) as minimo,
            MAX(COALESCE(total, 0)) as maximo
        FROM publico.multas
    ");
    $montos = $stmt_montos->fetch(PDO::FETCH_ASSOC);
    echo "   - Total general: $" . number_format($montos['total_general'], 2) . "\n";
    echo "   - Promedio: $" . number_format($montos['promedio'], 2) . "\n";
    echo "   - Mínimo: $" . number_format($montos['minimo'], 2) . "\n";
    echo "   - Máximo: $" . number_format($montos['maximo'], 2) . "\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
