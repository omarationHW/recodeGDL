<?php
// Script para probar el stored procedure recaudadora_requerimientos_dm

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar stored procedure
    echo "1. Actualizando stored procedure...\n\n";

    $sql = file_get_contents(__DIR__ . '/update_sp_requerimientos_dm.sql');
    $pdo->exec($sql);

    echo "   ✓ Stored procedure actualizado exitosamente\n";

    // 2. Ver información de la tabla
    echo "\n\n2. Información de la tabla reqbfpredial...\n\n";

    $stmt = $pdo->query("
        SELECT COUNT(*) as total,
               MIN(axodesde) as min_year,
               MAX(axodesde) as max_year,
               COUNT(DISTINCT cvecuenta) as total_cuentas,
               SUM(total) as total_importe
        FROM public.reqbfpredial
    ");
    $info = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total registros: " . number_format($info['total']) . "\n";
    echo "   Años: " . $info['min_year'] . " - " . $info['max_year'] . "\n";
    echo "   Total cuentas únicas: " . number_format($info['total_cuentas']) . "\n";
    echo "   Total importe: $" . number_format($info['total_importe'], 2) . "\n";

    // 3. Distribución por vigencia
    echo "\n\n3. Distribución por vigencia...\n\n";

    $stmt = $pdo->query("
        SELECT
            vigencia,
            COUNT(*) as cantidad,
            SUM(total) as total_importe
        FROM public.reqbfpredial
        GROUP BY vigencia
        ORDER BY cantidad DESC
    ");

    echo "   Vigencia | Cantidad    | Total Importe\n";
    echo "   " . str_repeat("-", 60) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %-8s | %11s | $%s\n",
            $row['vigencia'] ?: 'NULL',
            number_format($row['cantidad']),
            number_format($row['total_importe'] ?: 0, 2)
        );
    }

    // 4. Muestra de registros
    echo "\n\n4. Muestra de registros disponibles...\n\n";

    $stmt = $pdo->query("
        SELECT
            cvecuenta,
            cveejecut,
            axodesde,
            fecemi,
            feccap,
            impuesto,
            recargos,
            gastos,
            multas,
            total,
            vigencia
        FROM public.reqbfpredial
        ORDER BY axodesde DESC, cvecuenta DESC
        LIMIT 5
    ");

    echo "   Cuenta | Ejecut | Año  | F.Emisión  | Impuesto   | Total      | Vigencia\n";
    echo "   " . str_repeat("-", 85) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %-6d | %-6d | %-4d | %-10s | $%-9s | $%-9s | %s\n",
            $row['cvecuenta'],
            $row['cveejecut'] ?: 0,
            $row['axodesde'] ?: 0,
            $row['fecemi'] ?: 'Sin fecha',
            number_format($row['impuesto'] ?: 0, 2),
            number_format($row['total'] ?: 0, 2),
            $row['vigencia'] ?: '-'
        );
    }

    // 5. Probar stored procedure - Todos los registros
    echo "\n\n5. Probando stored procedure - Todos los registros (primeros 10)...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_requerimientos_dm(NULL, NULL) LIMIT 10");
    $stmt->execute();
    $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   ✓ Registros encontrados: " . count($resultados) . "\n\n";

    if (count($resultados) > 0) {
        echo "   Primeros 3 registros:\n\n";

        foreach (array_slice($resultados, 0, 3) as $idx => $reg) {
            echo "   Registro " . ($idx + 1) . ":\n";
            echo "   - ID (cvereq): " . $reg['cvereq'] . "\n";
            echo "   - Folio: " . $reg['folio'] . "\n";
            echo "   - Cuenta: " . $reg['cuenta'] . "\n";
            echo "   - Ejercicio: " . $reg['ejercicio'] . "\n";
            echo "   - Fecha emisión: " . $reg['fecha_emision'] . "\n";
            echo "   - Fecha entrega: " . $reg['fecha_entrega'] . "\n";
            echo "   - Vigencia: " . $reg['vigencia'] . "\n";
            echo "   - Impuesto: $" . number_format($reg['impuesto'], 2) . "\n";
            echo "   - Recargos: $" . number_format($reg['recargos'], 2) . "\n";
            echo "   - Gastos: $" . number_format($reg['gastos'], 2) . "\n";
            echo "   - Multas: $" . number_format($reg['multas'], 2) . "\n";
            echo "   - Total: $" . number_format($reg['total'], 2) . "\n";
            echo "\n";
        }
    }

    // 6. Probar filtro por cuenta
    if (count($resultados) > 0) {
        $cuenta_ejemplo = $resultados[0]['cuenta'];

        echo "\n6. Probando filtro por cuenta: " . $cuenta_ejemplo . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_requerimientos_dm(?, NULL)");
        $stmt->execute([$cuenta_ejemplo]);
        $resultado_cuenta = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados para cuenta " . $cuenta_ejemplo . ": " . count($resultado_cuenta) . "\n";

        if (count($resultado_cuenta) > 0) {
            echo "\n   Detalle:\n";
            foreach (array_slice($resultado_cuenta, 0, 3) as $reg) {
                echo "   - Folio: " . $reg['folio'] . " | ";
                echo "Ejercicio: " . $reg['ejercicio'] . " | ";
                echo "Fecha: " . $reg['fecha_emision'] . " | ";
                echo "Total: $" . number_format($reg['total'], 2) . " | ";
                echo "Vigencia: " . $reg['vigencia'] . "\n";
            }
        }
    }

    // 7. Probar filtro por año
    if (count($resultados) > 0) {
        $anio_ejemplo = $resultados[0]['ejercicio'];

        echo "\n\n7. Probando filtro por año: " . $anio_ejemplo . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_requerimientos_dm(NULL, ?)");
        $stmt->execute([$anio_ejemplo]);
        $resultado_anio = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados para año " . $anio_ejemplo . ": " . count($resultado_anio) . "\n";

        if (count($resultado_anio) > 0) {
            echo "\n   Primeros 3 registros del año " . $anio_ejemplo . ":\n";
            foreach (array_slice($resultado_anio, 0, 3) as $reg) {
                echo "   - Cuenta: " . $reg['cuenta'] . " | ";
                echo "Folio: " . $reg['folio'] . " | ";
                echo "Total: $" . number_format($reg['total'], 2) . " | ";
                echo "Vigencia: " . $reg['vigencia'] . "\n";
            }
        }
    }

    // 8. Probar filtro combinado
    if (count($resultados) > 0) {
        $cuenta_test = $resultados[0]['cuenta'];
        $anio_test = $resultados[0]['ejercicio'];

        echo "\n\n8. Probando filtro combinado - Cuenta: " . $cuenta_test . " + Año: " . $anio_test . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_requerimientos_dm(?, ?)");
        $stmt->execute([$cuenta_test, $anio_test]);
        $resultado_combinado = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados: " . count($resultado_combinado) . "\n";

        if (count($resultado_combinado) > 0) {
            echo "\n   Detalle:\n";
            foreach ($resultado_combinado as $reg) {
                echo "   - Cuenta: " . $reg['cuenta'] . " | ";
                echo "Folio: " . $reg['folio'] . " | ";
                echo "Ejercicio: " . $reg['ejercicio'] . " | ";
                echo "Total: $" . number_format($reg['total'], 2) . " | ";
                echo "Vigencia: " . $reg['vigencia'] . "\n";
            }
        }
    }

    // 9. Resumen por año
    echo "\n\n9. Resumen por año...\n\n";

    $stmt = $pdo->query("
        SELECT
            axodesde as anio,
            COUNT(*) as cantidad,
            SUM(total) as total_importe
        FROM public.reqbfpredial
        GROUP BY axodesde
        ORDER BY anio DESC
        LIMIT 10
    ");

    echo "   Año  | Cantidad    | Total Importe\n";
    echo "   " . str_repeat("-", 50) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %4d | %11s | $%s\n",
            $row['anio'] ?: 0,
            number_format($row['cantidad']),
            number_format($row['total_importe'] ?: 0, 2)
        );
    }

    echo "\n\n✅ Todas las pruebas completadas!\n";
    echo "\nRESUMEN:\n";
    echo "- Stored procedure actualizado correctamente\n";
    echo "- Función: publico.recaudadora_requerimientos_dm(VARCHAR, INTEGER)\n";
    echo "- Tabla: public.reqbfpredial (" . number_format($info['total']) . " registros)\n";
    echo "- Filtros: cuenta (opcional) + ejercicio/año (opcional)\n";
    echo "- Función lista para uso en RequerimientosDM.vue\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
