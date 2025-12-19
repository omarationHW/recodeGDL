<?php
// Script para probar el stored procedure recaudadora_pagos_espe actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_pagos_espe...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_pagosespe.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar búsqueda sin filtro (últimas 100 autorizaciones)
    echo "2. Probando búsqueda sin filtro (últimas 100 autorizaciones)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pagos_espe('', NULL)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " autorizaciones\n\n";

    if (count($result) > 0) {
        echo "   === PRIMERAS 5 AUTORIZACIONES ===\n";
        for ($i = 0; $i < min(5, count($result)); $i++) {
            $aut = $result[$i];
            echo "\n   AUTORIZACIÓN " . ($i + 1) . ":\n";
            echo "   Clave Aut: {$aut['cveaut']}\n";
            echo "   Cuenta: {$aut['cvecuenta']}\n";
            echo "   Periodo: Bim {$aut['bimestre_inicio']}/{$aut['año_inicio']} - Bim {$aut['bimestre_fin']}/{$aut['año_fin']}\n";
            echo "   Fecha Autorización: {$aut['fecha_autorizacion']}\n";
            echo "   Autorizado por: {$aut['autorizado_por']}\n";
            echo "   Clave Pago: {$aut['cve_pago']}\n";
            echo "   Estado: {$aut['estado']}\n";
        }
    }

    // 3. Probar búsqueda con filtro por cuenta
    echo "\n\n3. Probando búsqueda con filtro por cuenta (ejemplo: 104241)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pagos_espe(?, NULL)");
    $stmt->execute(['104241']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " autorizaciones\n";
    if (count($result) > 0) {
        echo "\n   Autorizaciones encontradas:\n";
        foreach ($result as $aut) {
            echo "   - Clave Aut: {$aut['cveaut']}, ";
            echo "Cuenta: {$aut['cvecuenta']}, ";
            echo "Fecha: {$aut['fecha_autorizacion']}, ";
            echo "Autorizado por: {$aut['autorizado_por']}\n";
        }
    }

    // 4. Probar búsqueda con filtro por ejercicio
    echo "\n\n4. Probando búsqueda con filtro por ejercicio (ejemplo: 1999)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pagos_espe('', ?)");
    $stmt->execute([1999]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " autorizaciones\n";
    if (count($result) > 0) {
        echo "   Total autorizaciones del año 1999\n";
        echo "\n   Primeras 3 autorizaciones del 1999:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $aut = $result[$i];
            echo "   - Clave Aut: {$aut['cveaut']}, ";
            echo "Cuenta: {$aut['cvecuenta']}, ";
            echo "Periodo: {$aut['año_inicio']}-{$aut['año_fin']}\n";
        }
    }

    // 5. Probar búsqueda con filtro combinado (cuenta + ejercicio)
    echo "\n\n5. Probando búsqueda con filtro combinado (cuenta 104241 + ejercicio 1999)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pagos_espe(?, ?)");
    $stmt->execute(['104241', 1999]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " autorizaciones\n";
    if (count($result) > 0) {
        echo "\n   Autorización encontrada:\n";
        $aut = $result[0];
        echo "   - Clave Aut: {$aut['cveaut']}\n";
        echo "   - Cuenta: {$aut['cvecuenta']}\n";
        echo "   - Periodo: Bim {$aut['bimestre_inicio']}/{$aut['año_inicio']} - Bim {$aut['bimestre_fin']}/{$aut['año_fin']}\n";
        echo "   - Fecha Autorización: {$aut['fecha_autorizacion']}\n";
        echo "   - Autorizado por: {$aut['autorizado_por']}\n";
        echo "   - Clave Pago: {$aut['cve_pago']}\n";
    }

    // 6. Estadísticas generales
    echo "\n\n6. Estadísticas generales...\n";

    $stmt_total = $pdo->query("SELECT COUNT(*) as total FROM public.autpagoesp");
    $total = $stmt_total->fetch(PDO::FETCH_ASSOC);
    echo "   Total autorizaciones: " . number_format($total['total']) . "\n";

    // Ver distribución por años iniciales
    echo "\n   Distribución por años iniciales (top 5):\n";
    $stmt_anios = $pdo->query("
        SELECT
            axoini AS anio,
            COUNT(*) as total
        FROM public.autpagoesp
        WHERE axoini > 1900 AND axoini < 2100
        GROUP BY axoini
        ORDER BY total DESC
        LIMIT 5
    ");
    $anios = $stmt_anios->fetchAll(PDO::FETCH_ASSOC);
    foreach ($anios as $anio) {
        echo "   - Año {$anio['anio']}: " . number_format($anio['total']) . " autorizaciones\n";
    }

    // Ver distribución por bimestre inicial
    echo "\n   Distribución por bimestre inicial:\n";
    $stmt_bim = $pdo->query("
        SELECT
            bimini AS bimestre,
            COUNT(*) as total
        FROM public.autpagoesp
        WHERE bimini BETWEEN 1 AND 6
        GROUP BY bimini
        ORDER BY bimini
    ");
    $bims = $stmt_bim->fetchAll(PDO::FETCH_ASSOC);
    foreach ($bims as $bim) {
        $nombre_bim = match($bim['bimestre']) {
            1 => 'Ene-Feb',
            2 => 'Mar-Abr',
            3 => 'May-Jun',
            4 => 'Jul-Ago',
            5 => 'Sep-Oct',
            6 => 'Nov-Dic',
            default => 'N/A'
        };
        echo "   - Bimestre {$bim['bimestre']} ({$nombre_bim}): " . number_format($bim['total']) . " autorizaciones\n";
    }

    // Ver usuarios que más autorizaron
    echo "\n   Usuarios que más autorizaron (top 5):\n";
    $stmt_users = $pdo->query("
        SELECT
            TRIM(autorizo) as usuario,
            COUNT(*) as total
        FROM public.autpagoesp
        GROUP BY autorizo
        ORDER BY total DESC
        LIMIT 5
    ");
    $users = $stmt_users->fetchAll(PDO::FETCH_ASSOC);
    foreach ($users as $user) {
        echo "   - {$user['usuario']}: " . number_format($user['total']) . " autorizaciones\n";
    }

    // Ver rango de fechas
    echo "\n   Rango de fechas:\n";
    $stmt_fechas = $pdo->query("
        SELECT
            MIN(fecaut) as fecha_min,
            MAX(fecaut) as fecha_max
        FROM public.autpagoesp
        WHERE fecaut IS NOT NULL
    ");
    $fechas = $stmt_fechas->fetch(PDO::FETCH_ASSOC);
    if ($fechas) {
        echo "   - Primera autorización: {$fechas['fecha_min']}\n";
        echo "   - Última autorización: {$fechas['fecha_max']}\n";
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
