<?php
// Script para probar el stored procedure recaudadora_pagosdivfrm actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_pagosdivfrm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_pagosdivfrm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar búsqueda sin filtro (últimos 100 pagos)
    echo "2. Probando búsqueda sin filtro (últimos 100 pagos)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pagosdivfrm('')");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " pagos\n\n";

    if (count($result) > 0) {
        echo "   === PRIMEROS 5 PAGOS DIVERSOS ===\n";
        for ($i = 0; $i < min(5, count($result)); $i++) {
            $pago = $result[$i];
            echo "\n   PAGO " . ($i + 1) . ":\n";
            echo "   ID: {$pago['id_pago']}\n";
            echo "   Folio: {$pago['folio_pago']}\n";
            echo "   Fecha: {$pago['fecha_pago']}\n";
            echo "   Contribuyente: {$pago['contribuyente']}\n";
            echo "   Domicilio: {$pago['domicilio']}\n";
            $concepto_short = substr($pago['concepto'], 0, 80);
            if (strlen($pago['concepto']) > 80) {
                $concepto_short .= '...';
            }
            echo "   Concepto: {$concepto_short}\n";
            echo "   Referencia: {$pago['referencia']}\n";
            echo "   Estatus: {$pago['estatus']}\n";
        }
    }

    // 3. Probar búsqueda con filtro por contribuyente
    echo "\n\n3. Probando búsqueda con filtro por contribuyente (ejemplo: HERNANDEZ)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pagosdivfrm(?)");
    $stmt->execute(['HERNANDEZ']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " pagos\n";
    if (count($result) > 0) {
        echo "\n   Primeros 3 pagos:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $pago = $result[$i];
            echo "   - ID: {$pago['id_pago']}, ";
            echo "Contribuyente: {$pago['contribuyente']}, ";
            echo "Fecha: {$pago['fecha_pago']}\n";
        }
    }

    // 4. Probar búsqueda con filtro por concepto
    echo "\n\n4. Probando búsqueda con filtro por concepto (ejemplo: CERTIFICADO)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pagosdivfrm(?)");
    $stmt->execute(['CERTIFICADO']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " pagos\n";
    if (count($result) > 0) {
        echo "\n   Primeros 3 pagos con 'CERTIFICADO':\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $pago = $result[$i];
            $concepto_short = substr($pago['concepto'], 0, 60);
            echo "   - ID: {$pago['id_pago']}, ";
            echo "Concepto: {$concepto_short}...\n";
        }
    }

    // 5. Probar búsqueda con filtro por referencia
    echo "\n\n5. Probando búsqueda con filtro por referencia (ejemplo: 282234)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pagosdivfrm(?)");
    $stmt->execute(['282234']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " pagos\n";
    if (count($result) > 0) {
        echo "\n   Pago encontrado:\n";
        $pago = $result[0];
        echo "   - ID: {$pago['id_pago']}\n";
        echo "   - Contribuyente: {$pago['contribuyente']}\n";
        echo "   - Referencia: {$pago['referencia']}\n";
        echo "   - Fecha: {$pago['fecha_pago']}\n";
    }

    // 6. Probar búsqueda con filtro por ID de pago
    echo "\n\n6. Probando búsqueda con filtro por ID (ejemplo: 8108543)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pagosdivfrm(?)");
    $stmt->execute(['8108543']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " pagos\n";
    if (count($result) > 0) {
        echo "\n   Pago encontrado:\n";
        $pago = $result[0];
        echo "   - ID: {$pago['id_pago']}\n";
        echo "   - Folio: {$pago['folio_pago']}\n";
        echo "   - Contribuyente: {$pago['contribuyente']}\n";
        echo "   - Fecha: {$pago['fecha_pago']}\n";
        $concepto_short = substr($pago['concepto'], 0, 80);
        echo "   - Concepto: {$concepto_short}...\n";
    }

    // 7. Estadísticas generales
    echo "\n\n7. Estadísticas generales...\n";

    $stmt_total = $pdo->query("SELECT COUNT(*) as total FROM public.pago_diversos");
    $total = $stmt_total->fetch(PDO::FETCH_ASSOC);
    echo "   Total pagos diversos: " . number_format($total['total']) . "\n";

    // Ver pagos con referencia
    echo "\n   Pagos con referencia:\n";
    $stmt_ref = $pdo->query("
        SELECT COUNT(*) as total
        FROM public.pago_diversos
        WHERE referencia IS NOT NULL AND referencia > 0
    ");
    $ref = $stmt_ref->fetch(PDO::FETCH_ASSOC);
    echo "   - Con referencia: " . number_format($ref['total']) . "\n";

    // Ver distribución por años
    echo "\n   Distribución por años (top 5):\n";
    $stmt_anios = $pdo->query("
        SELECT
            axoini AS anio,
            COUNT(*) as total
        FROM public.pago_diversos
        WHERE axoini > 1900 AND axoini < 2100
        GROUP BY axoini
        ORDER BY total DESC
        LIMIT 5
    ");
    $anios = $stmt_anios->fetchAll(PDO::FETCH_ASSOC);
    foreach ($anios as $anio) {
        echo "   - Año {$anio['anio']}: " . number_format($anio['total']) . " pagos\n";
    }

    // Ver distribución por bimestre
    echo "\n   Distribución por bimestre:\n";
    $stmt_bim = $pdo->query("
        SELECT
            bimini AS bimestre,
            COUNT(*) as total
        FROM public.pago_diversos
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
        echo "   - Bimestre {$bim['bimestre']} ({$nombre_bim}): " . number_format($bim['total']) . " pagos\n";
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
