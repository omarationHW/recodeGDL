<?php
// Script para probar el stored procedure recaudadora_reqtrans_list

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Verificar estadísticas de la tabla
    echo "1. Estadísticas de la tabla public.reqdiftransmision...\n\n";

    $stmt = $pdo->query("
        SELECT
            COUNT(*) as total_registros,
            COUNT(DISTINCT cvecuenta) as cuentas_unicas,
            COUNT(DISTINCT axoreq) as años_requerimiento,
            MIN(axoreq) as año_min,
            MAX(axoreq) as año_max,
            MIN(fecemi) as fecha_min,
            MAX(fecemi) as fecha_max
        FROM public.reqdiftransmision
    ");

    $stats = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total de registros: " . number_format($stats['total_registros']) . "\n";
    echo "   Cuentas únicas: " . number_format($stats['cuentas_unicas']) . "\n";
    echo "   Años de requerimiento: " . $stats['años_requerimiento'] . "\n";
    echo "   Rango de años: " . $stats['año_min'] . " - " . $stats['año_max'] . "\n";
    echo "   Rango de fechas emisión: " . $stats['fecha_min'] . " - " . $stats['fecha_max'] . "\n\n";

    // 2. Obtener distribución por vigencia
    echo "2. Distribución por vigencia...\n\n";

    $stmt = $pdo->query("
        SELECT
            vigencia,
            CASE
                WHEN vigencia = 'V' THEN 'Vigente'
                WHEN vigencia = 'C' THEN 'Cancelado'
                WHEN vigencia = 'P' THEN 'Pendiente'
                ELSE 'Otro'
            END as descripcion,
            COUNT(*) as cantidad,
            SUM(total) as total_importe
        FROM public.reqdiftransmision
        GROUP BY vigencia
        ORDER BY cantidad DESC
    ");

    echo "   Vigencia | Descripción | Cantidad | Total Importe\n";
    echo "   " . str_repeat("-", 60) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %-8s | %-11s | %8s | $%12s\n",
            $row['vigencia'],
            $row['descripcion'],
            number_format($row['cantidad']),
            number_format($row['total_importe'], 2)
        );
    }

    // 3. Actualizar stored procedure
    echo "\n\n3. Actualizando stored procedure...\n\n";

    $sql = file_get_contents(__DIR__ . '/update_sp_reqtrans_list.sql');
    $pdo->exec($sql);

    echo "   ✓ Stored procedure actualizado exitosamente\n";

    // 4. Probar búsqueda sin filtro
    echo "\n\n4. Probando búsqueda sin filtro (todos los registros)...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reqtrans_list(NULL, NULL)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total registros retornados: " . count($result) . "\n";

    if (count($result) > 0) {
        echo "\n   Todos los registros:\n";
        echo "   Cvereq | Cuenta    | Folio   | Ejercicio | Estatus\n";
        echo "   " . str_repeat("-", 60) . "\n";

        foreach ($result as $row) {
            printf("   %6d | %9s | %7d | %9d | %s\n",
                $row['cvereq'],
                $row['clave_cuenta'],
                $row['folio'],
                $row['ejercicio'],
                $row['estatus']
            );
        }
    }

    // 5. Obtener cuentas reales para probar
    echo "\n\n5. Obteniendo cuentas para pruebas...\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT cvecuenta, axoreq, foliotransm
        FROM public.reqdiftransmision
        WHERE cvecuenta IS NOT NULL
        ORDER BY axoreq DESC
        LIMIT 3
    ");

    $cuentas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Cuentas disponibles:\n";
    foreach ($cuentas as $c) {
        printf("   - Cuenta: %d, Año: %d, Folio: %s\n",
            $c['cvecuenta'],
            $c['axoreq'],
            $c['foliotransm'] ?: 'N/A'
        );
    }

    // 6. Probar búsqueda por cuenta específica
    if (count($cuentas) > 0) {
        $test_cuenta = $cuentas[0]['cvecuenta'];

        echo "\n\n6. Probando búsqueda por cuenta ($test_cuenta)...\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reqtrans_list(?, NULL)");
        $stmt->execute([(string)$test_cuenta]);
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Total registros encontrados: " . count($result) . "\n\n";

        if (count($result) > 0) {
            echo "   Detalles del requerimiento:\n";
            echo "   Campo         | Valor\n";
            echo "   " . str_repeat("-", 50) . "\n";

            $row = $result[0];
            foreach ($row as $campo => $valor) {
                printf("   %-13s | %s\n", $campo, $valor ?: '-');
            }
        }
    }

    // 7. Probar búsqueda por ejercicio fiscal
    echo "\n\n7. Probando búsqueda por ejercicio fiscal...\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT axoreq, COUNT(*) as cantidad
        FROM public.reqdiftransmision
        GROUP BY axoreq
        ORDER BY axoreq DESC
    ");

    $años = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($años) > 0) {
        foreach ($años as $año_data) {
            $test_año = $año_data['axoreq'];
            echo "   Año: $test_año - Registros: " . $año_data['cantidad'] . "\n";

            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reqtrans_list(NULL, ?)");
            $stmt->execute([$test_año]);
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "   Retornados por SP: " . count($result) . "\n\n";
        }
    }

    // 8. Verificar campos retornados
    echo "\n8. Verificando campos retornados...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reqtrans_list(NULL, NULL) LIMIT 1");
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "   Campos disponibles:\n";
        $i = 1;
        foreach (array_keys($result) as $campo) {
            printf("   %2d. %s\n", $i++, $campo);
        }
    }

    // 9. Información adicional
    echo "\n\n9. Información adicional...\n\n";
    echo "   ℹ️  TABLA BASE:\n";
    echo "   - Tabla: public.reqdiftransmision\n";
    echo "   - Descripción: Requerimientos de diferencias de transmisión\n";
    echo "   - Total registros: " . number_format($stats['total_registros']) . "\n";
    echo "   - Búsqueda: Por cuenta o ejercicio fiscal\n";
    echo "   - Límite: 100 registros por consulta\n";
    echo "   - Campos principales:\n";
    echo "     * cvereq: Clave de requerimiento\n";
    echo "     * cvecuenta: Cuenta del contribuyente\n";
    echo "     * foliotransm: Folio de transmisión\n";
    echo "     * axoreq: Año del requerimiento\n";
    echo "     * vigencia: Estatus (V=Vigente, C=Cancelado, P=Pendiente)\n";
    echo "     * impuesto, recargos, multas: Importes\n";
    echo "     * total: Total a pagar\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

    // 10. Resumen de datos
    echo "\n\n10. Resumen de datos disponibles...\n\n";

    $stmt = $pdo->query("
        SELECT
            SUM(impuesto) as total_impuesto,
            SUM(recargos) as total_recargos,
            SUM(multa) as total_multa,
            SUM(gastos) as total_gastos,
            SUM(total) as total_general
        FROM public.reqdiftransmision
    ");

    $totales = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Totales de la tabla:\n";
    echo "   - Total Impuesto: $" . number_format($totales['total_impuesto'], 2) . "\n";
    echo "   - Total Recargos: $" . number_format($totales['total_recargos'], 2) . "\n";
    echo "   - Total Multas: $" . number_format($totales['total_multa'], 2) . "\n";
    echo "   - Total Gastos: $" . number_format($totales['total_gastos'], 2) . "\n";
    echo "   - Total General: $" . number_format($totales['total_general'], 2) . "\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
