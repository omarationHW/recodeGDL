<?php
// Script para probar el stored procedure recaudadora_reqmultas400frm

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Verificar estadísticas de la tabla
    echo "1. Estadísticas de la tabla public.req_mul_400...\n\n";

    $stmt = $pdo->query("
        SELECT
            COUNT(*) as total_registros,
            COUNT(DISTINCT cveapl) as tipos_aplicacion,
            COUNT(DISTINCT axoreq) as años_requerimiento,
            MIN(axoreq) as año_min,
            MAX(axoreq) as año_max
        FROM public.req_mul_400
    ");

    $stats = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total de registros: " . number_format($stats['total_registros']) . "\n";
    echo "   Tipos de aplicación: " . $stats['tipos_aplicacion'] . "\n";
    echo "   Años de requerimiento: " . $stats['años_requerimiento'] . "\n";
    echo "   Rango de años: " . $stats['año_min'] . " - " . $stats['año_max'] . "\n\n";

    // 2. Obtener muestras por tipo de multa
    echo "2. Distribución por tipo de multa...\n\n";

    $stmt = $pdo->query("
        SELECT
            cveapl,
            CASE
                WHEN cveapl = 6 THEN 'Federal'
                WHEN cveapl = 5 THEN 'Municipal'
                ELSE 'Otro'
            END as tipo_multa,
            COUNT(*) as cantidad
        FROM public.req_mul_400
        GROUP BY cveapl
        ORDER BY cantidad DESC
    ");

    echo "   Tipo     | Cantidad\n";
    echo "   " . str_repeat("-", 30) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %-8s | %s\n", $row['tipo_multa'], number_format($row['cantidad']));
    }

    // 3. Probar búsqueda sin filtro (primeros 100)
    echo "\n\n3. Probando búsqueda sin filtro (primeros 100 registros)...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reqmultas400frm(NULL)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total registros retornados: " . count($result) . "\n";

    if (count($result) > 0) {
        echo "\n   Primeros 5 registros:\n";
        echo "   Folio | Año Req | Tipo      | Importe     | Vigencia\n";
        echo "   " . str_repeat("-", 60) . "\n";

        foreach (array_slice($result, 0, 5) as $row) {
            printf("   %5d | %7d | %-9s | $%10.2f | %s\n",
                $row['folreq'],
                $row['axoreq'],
                $row['tipo_multa'],
                $row['impcuo'],
                $row['vigreq']
            );
        }
    }

    // 4. Obtener un folio real para probar
    echo "\n\n4. Obteniendo folios reales para pruebas...\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT folreq
        FROM public.req_mul_400
        WHERE folreq IS NOT NULL
        ORDER BY folreq DESC
        LIMIT 5
    ");

    $folios = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Folios disponibles:\n";
    foreach ($folios as $f) {
        echo "   - " . $f['folreq'] . "\n";
    }

    // 5. Probar búsqueda por folio
    if (count($folios) > 0) {
        $test_folio = $folios[0]['folreq'];

        echo "\n\n5. Probando búsqueda por folio ($test_folio)...\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reqmultas400frm(?)");
        $stmt->execute([(string)$test_folio]);
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Total registros encontrados: " . count($result) . "\n\n";

        if (count($result) > 0) {
            echo "   Detalles del requerimiento:\n";
            echo "   Campo          | Valor\n";
            echo "   " . str_repeat("-", 50) . "\n";

            $row = $result[0];
            foreach ($row as $campo => $valor) {
                printf("   %-14s | %s\n", $campo, $valor ?: '-');
            }
        }
    }

    // 6. Probar búsqueda por año de requerimiento
    echo "\n\n6. Probando búsqueda por año de requerimiento...\n\n";

    $stmt = $pdo->query("
        SELECT axoreq, COUNT(*) as cantidad
        FROM public.req_mul_400
        GROUP BY axoreq
        ORDER BY axoreq DESC
        LIMIT 3
    ");

    $años = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($años) > 0) {
        $test_año = $años[0]['axoreq'];

        echo "   Buscando año: $test_año\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reqmultas400frm(?)");
        $stmt->execute([(string)$test_año]);
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Total registros encontrados: " . count($result) . "\n";

        if (count($result) > 0) {
            // Calcular totales
            $total_federal = 0;
            $total_municipal = 0;
            $importe_total = 0;

            foreach ($result as $row) {
                if ($row['tipo_multa'] === 'Federal') {
                    $total_federal++;
                } elseif ($row['tipo_multa'] === 'Municipal') {
                    $total_municipal++;
                }
                $importe_total += $row['impcuo'];
            }

            echo "   Multas Federales: " . $total_federal . "\n";
            echo "   Multas Municipales: " . $total_municipal . "\n";
            echo "   Importe total: $" . number_format($importe_total, 2) . "\n";
        }
    }

    // 7. Verificar campos retornados
    echo "\n\n7. Verificando campos retornados...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reqmultas400frm(NULL) LIMIT 1");
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "   Campos disponibles:\n";
        $i = 1;
        foreach (array_keys($result) as $campo) {
            printf("   %2d. %s\n", $i++, $campo);
        }
    }

    // 8. Información adicional
    echo "\n\n8. Información adicional...\n\n";
    echo "   ℹ️  TABLA BASE:\n";
    echo "   - Tabla: public.req_mul_400\n";
    echo "   - Descripción: Requerimientos de multas 400\n";
    echo "   - Total registros: " . number_format($stats['total_registros']) . "\n";
    echo "   - Búsqueda: Por clave letra, folio o año de requerimiento\n";
    echo "   - Límite: 100 registros por consulta\n";
    echo "   - Campos principales:\n";
    echo "     * cvelet: Clave letra\n";
    echo "     * cvenum: Año acta\n";
    echo "     * ctarfc: Número de acta\n";
    echo "     * cveapl: Tipo (5=Municipal, 6=Federal)\n";
    echo "     * axoreq: Año de requerimiento\n";
    echo "     * folreq: Folio de requerimiento\n";
    echo "     * fecreq: Fecha de requerimiento\n";
    echo "     * impcuo: Importe\n";
    echo "     * observr: Observaciones\n";
    echo "     * vigreq: Vigencia\n";
    echo "     * actreq: Activación\n";
    echo "     * tipo_multa: Tipo descriptivo (Federal/Municipal/Otro)\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
