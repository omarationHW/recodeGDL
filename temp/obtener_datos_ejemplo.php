<?php
/**
 * Script para obtener datos de ejemplo para probar el formulario
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo str_repeat("=", 80) . "\n";
    echo "DATOS DE EJEMPLO PARA PROBAR EL FORMULARIO\n";
    echo str_repeat("=", 80) . "\n\n";

    // Obtener años con multas disponibles
    echo "1. AÑOS CON MULTAS DISPONIBLES:\n";
    echo str_repeat("-", 80) . "\n";

    $sqlYears = "
        SELECT axoreq as año, COUNT(*) as total_multas,
               SUM(CASE WHEN vigencia = 'V' THEN 1 ELSE 0 END) as vigentes,
               SUM(CASE WHEN vigencia = 'B' THEN 1 ELSE 0 END) as bloqueadas
        FROM catastro_gdl.reqmultas
        WHERE vigencia IN ('V', 'B')
        GROUP BY axoreq
        ORDER BY axoreq DESC
        LIMIT 10;
    ";

    $stmtYears = $pdo->query($sqlYears);
    $years = $stmtYears->fetchAll(PDO::FETCH_ASSOC);

    foreach ($years as $year) {
        echo sprintf(
            "   Año %d: %d multas (%d vigentes, %d bloqueadas)\n",
            $year['año'],
            $year['total_multas'],
            $year['vigentes'],
            $year['bloqueadas']
        );
    }

    // Obtener ejemplos de multas para el año más reciente
    if (!empty($years)) {
        $yearToTest = $years[0]['año'];

        echo "\n\n2. EJEMPLOS DE MULTAS DEL AÑO $yearToTest:\n";
        echo str_repeat("-", 80) . "\n";

        $sqlExamples = "
            SELECT
                cvereq,
                folioreq as folio,
                axoreq as año,
                vigencia,
                CASE
                    WHEN vigencia = 'V' THEN 'Vigente'
                    WHEN vigencia = 'B' THEN 'Bloqueado'
                    ELSE vigencia
                END as estatus,
                multas,
                total,
                SUBSTRING(obs, 1, 50) as observaciones_cortas
            FROM catastro_gdl.reqmultas
            WHERE axoreq = :year
              AND vigencia IN ('V', 'B')
            ORDER BY folioreq DESC
            LIMIT 10;
        ";

        $stmtExamples = $pdo->prepare($sqlExamples);
        $stmtExamples->execute(['year' => $yearToTest]);
        $examples = $stmtExamples->fetchAll(PDO::FETCH_ASSOC);

        foreach ($examples as $idx => $multa) {
            echo "\nEjemplo " . ($idx + 1) . ":\n";
            echo "   Folio: {$multa['folio']}\n";
            echo "   Año: {$multa['año']}\n";
            echo "   Cvereq: {$multa['cvereq']}\n";
            echo "   Estatus: {$multa['estatus']}\n";
            echo "   Multa: \${$multa['multas']}\n";
            echo "   Total: \${$multa['total']}\n";
            if ($multa['observaciones_cortas']) {
                echo "   Obs: {$multa['observaciones_cortas']}...\n";
            }
        }

        // Búsquedas sugeridas
        echo "\n\n3. BÚSQUEDAS SUGERIDAS PARA EL FORMULARIO:\n";
        echo str_repeat("-", 80) . "\n";
        echo "\nOpción 1: Ver todas las multas del año $yearToTest\n";
        echo "   Campo Cuenta: (dejar vacío)\n";
        echo "   Campo Año: $yearToTest\n";
        echo "   → Mostrará todas las multas vigentes y bloqueadas\n";

        if (!empty($examples)) {
            $firstExample = $examples[0];
            echo "\nOpción 2: Buscar una multa específica\n";
            echo "   Campo Cuenta: {$firstExample['folio']}\n";
            echo "   Campo Año: {$firstExample['año']}\n";
            echo "   → Mostrará solo la multa folio {$firstExample['folio']}/{$firstExample['año']}\n";

            if ($firstExample['vigencia'] === 'V') {
                echo "   → Esta multa está VIGENTE, puedes BLOQUEARLA\n";
            } else {
                echo "   → Esta multa está BLOQUEADA, puedes DESBLOQUEARLA\n";
            }
        }

        // Contar folios más comunes
        echo "\n\n4. FOLIOS CON MÁS REGISTROS (para probar búsqueda):\n";
        echo str_repeat("-", 80) . "\n";

        $sqlCommonFolios = "
            SELECT
                folioreq as folio,
                COUNT(*) as cantidad,
                MIN(axoreq) as año_min,
                MAX(axoreq) as año_max,
                SUM(CASE WHEN vigencia = 'V' THEN 1 ELSE 0 END) as vigentes
            FROM catastro_gdl.reqmultas
            WHERE vigencia IN ('V', 'B')
            GROUP BY folioreq
            HAVING COUNT(*) > 1
            ORDER BY cantidad DESC
            LIMIT 5;
        ";

        $stmtFolios = $pdo->query($sqlCommonFolios);
        $folios = $stmtFolios->fetchAll(PDO::FETCH_ASSOC);

        foreach ($folios as $idx => $folio) {
            echo sprintf(
                "\n%d. Folio %d: %d registros (años %d-%d, %d vigentes)\n",
                $idx + 1,
                $folio['folio'],
                $folio['cantidad'],
                $folio['año_min'],
                $folio['año_max'],
                $folio['vigentes']
            );
            echo "   Búsqueda: Campo Cuenta = '{$folio['folio']}', Campo Año = '{$folio['año_max']}'\n";
        }
    }

    // Estadísticas generales
    echo "\n\n5. ESTADÍSTICAS GENERALES:\n";
    echo str_repeat("-", 80) . "\n";

    $sqlStats = "
        SELECT
            COUNT(*) as total,
            SUM(CASE WHEN vigencia = 'V' THEN 1 ELSE 0 END) as vigentes,
            SUM(CASE WHEN vigencia = 'B' THEN 1 ELSE 0 END) as bloqueadas,
            SUM(CASE WHEN vigencia = 'C' THEN 1 ELSE 0 END) as canceladas,
            SUM(CASE WHEN vigencia = 'P' THEN 1 ELSE 0 END) as pagadas
        FROM catastro_gdl.reqmultas;
    ";

    $stmtStats = $pdo->query($sqlStats);
    $stats = $stmtStats->fetch(PDO::FETCH_ASSOC);

    echo "Total de requerimientos: " . number_format($stats['total']) . "\n";
    echo "   Vigentes (V): " . number_format($stats['vigentes']) . " - Pueden ser BLOQUEADAS\n";
    echo "   Bloqueadas (B): " . number_format($stats['bloqueadas']) . " - Pueden ser DESBLOQUEADAS\n";
    echo "   Canceladas (C): " . number_format($stats['canceladas']) . "\n";
    echo "   Pagadas (P): " . number_format($stats['pagadas']) . "\n";

    // Motivos de ejemplo
    echo "\n\n6. MOTIVOS DE EJEMPLO PARA BLOQUEAR/DESBLOQUEAR:\n";
    echo str_repeat("-", 80) . "\n";
    echo "\nPara BLOQUEAR:\n";
    echo "   - Documentación incompleta - requiere revisión\n";
    echo "   - En proceso de validación por el área legal\n";
    echo "   - Solicitud de condonación en proceso\n";
    echo "   - Revisión de montos por duplicidad\n";
    echo "   - Cuenta del contribuyente en proceso de actualización\n";

    echo "\nPara DESBLOQUEAR:\n";
    echo "   - Documentación completada y validada\n";
    echo "   - Validación legal finalizada - procede cobro\n";
    echo "   - Solicitud de condonación rechazada\n";
    echo "   - Montos verificados - sin duplicidad\n";
    echo "   - Información actualizada correctamente\n";

    // Resumen final
    echo "\n\n" . str_repeat("=", 80) . "\n";
    echo "RESUMEN PARA PROBAR:\n";
    echo str_repeat("=", 80) . "\n";

    if (!empty($examples) && !empty($years)) {
        $testYear = $years[0]['año'];
        $testFolio = $examples[0]['folio'];
        $testEstatus = $examples[0]['estatus'];

        echo "\n1. Abre el navegador en: http://localhost:3000\n";
        echo "2. Navega a: Multas y Reglamentos → Bloqueo de Multa\n";
        echo "3. En el formulario:\n";
        echo "   - Cuenta: (vacío para ver todas o '$testFolio' para específica)\n";
        echo "   - Año: $testYear\n";
        echo "4. Click en 'Buscar'\n";
        echo "5. Verás " . count($examples) . " multas del año $testYear\n";
        echo "6. La primera multa está: $testEstatus\n";

        if ($testEstatus === 'Vigente') {
            echo "7. Puedes hacer click en el botón 🔒 (amarillo) para BLOQUEARLA\n";
        } else {
            echo "7. Puedes hacer click en el botón 🔓 (verde) para DESBLOQUEARLA\n";
        }

        echo "8. Ingresa un motivo de ejemplo y confirma\n";
        echo "9. Verás una notificación de éxito y la tabla se actualizará\n";
    }

    echo "\n✅ Datos listos para probar!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
