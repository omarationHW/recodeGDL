<?php
// Script para probar el stored procedure recaudadora_req

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

    $sql = file_get_contents(__DIR__ . '/update_sp_req.sql');
    $pdo->exec($sql);

    echo "   ✓ Stored procedure actualizado exitosamente\n";

    // 2. Ver registros actuales en la tabla
    echo "\n\n2. Registros actuales en la tabla reqtransm...\n\n";

    $stmt = $pdo->query("
        SELECT COUNT(*) as total,
               MIN(EXTRACT(YEAR FROM fecemi)) as min_year,
               MAX(EXTRACT(YEAR FROM fecemi)) as max_year,
               COUNT(DISTINCT cvecta) as total_cuentas
        FROM public.reqtransm
    ");
    $info = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total registros: " . $info['total'] . "\n";
    echo "   Años: " . $info['min_year'] . " - " . $info['max_year'] . "\n";
    echo "   Total cuentas únicas: " . $info['total_cuentas'] . "\n";

    // 3. Listar algunos registros para ver datos disponibles
    echo "\n\n3. Muestra de registros disponibles...\n\n";

    $stmt = $pdo->query("
        SELECT
            id,
            folioreq,
            tipo,
            cvecta,
            fecemi,
            vigencia,
            total
        FROM public.reqtransm
        ORDER BY fecemi DESC
        LIMIT 5
    ");

    echo "   ID   | Folio | Tipo | Cuenta   | Fecha Emisión | Vigencia | Total\n";
    echo "   " . str_repeat("-", 75) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %-4d | %-5s | %-4s | %-8s | %-13s | %-8s | $%s\n",
            $row['id'],
            $row['folioreq'] ?: '0',
            $row['tipo'] ?: '-',
            $row['cvecta'] ?: '0',
            $row['fecemi'] ?: 'Sin fecha',
            $row['vigencia'] ?: '-',
            number_format($row['total'] ?: 0, 2)
        );
    }

    // 4. Probar stored procedure - Todos los registros
    echo "\n\n4. Probando stored procedure - Todos los registros...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_req(NULL, NULL)");
    $stmt->execute();
    $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   ✓ Registros encontrados: " . count($resultados) . "\n\n";

    if (count($resultados) > 0) {
        echo "   Primeros 3 registros:\n\n";

        foreach (array_slice($resultados, 0, 3) as $idx => $reg) {
            echo "   Registro " . ($idx + 1) . ":\n";
            echo "   - ID: " . $reg['id'] . "\n";
            echo "   - Folio: " . $reg['folio_requerimiento'] . "\n";
            echo "   - Tipo: " . $reg['tipo'] . "\n";
            echo "   - Cuenta: " . $reg['cuenta'] . "\n";
            echo "   - Ejecutoria: " . $reg['ejecutoria'] . "\n";
            echo "   - Fecha emisión: " . $reg['fecha_emision'] . "\n";
            echo "   - Vigencia: " . $reg['vigencia'] . "\n";
            echo "   - Importe: $" . number_format($reg['importe'], 2) . "\n";
            echo "   - Recargos: $" . number_format($reg['recargos'], 2) . "\n";
            echo "   - Multas extemporáneas: $" . number_format($reg['multas_extemporaneas'], 2) . "\n";
            echo "   - Multas otras: $" . number_format($reg['multas_otras'], 2) . "\n";
            echo "   - Gastos: $" . number_format($reg['gastos'], 2) . "\n";
            echo "   - Total: $" . number_format($reg['total'], 2) . "\n";
            echo "\n";
        }
    }

    // 5. Probar filtro por cuenta (si hay registros)
    if (count($resultados) > 0) {
        $cuenta_ejemplo = $resultados[0]['cuenta'];

        echo "\n5. Probando filtro por cuenta: " . $cuenta_ejemplo . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_req(?, NULL)");
        $stmt->execute([$cuenta_ejemplo]);
        $resultado_cuenta = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados para cuenta " . $cuenta_ejemplo . ": " . count($resultado_cuenta) . "\n";

        if (count($resultado_cuenta) > 0) {
            echo "\n   Detalle:\n";
            foreach ($resultado_cuenta as $reg) {
                echo "   - Folio: " . $reg['folio_requerimiento'] . " | ";
                echo "Tipo: " . $reg['tipo'] . " | ";
                echo "Fecha: " . $reg['fecha_emision'] . " | ";
                echo "Total: $" . number_format($reg['total'], 2) . "\n";
            }
        }
    }

    // 6. Probar filtro por año (si hay registros)
    if (count($resultados) > 0 && $resultados[0]['fecha_emision']) {
        $fecha = $resultados[0]['fecha_emision'];
        $partes = explode('/', $fecha);
        $anio_ejemplo = isset($partes[2]) ? (int)$partes[2] : date('Y');

        echo "\n\n6. Probando filtro por año: " . $anio_ejemplo . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_req(NULL, ?)");
        $stmt->execute([$anio_ejemplo]);
        $resultado_anio = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados para año " . $anio_ejemplo . ": " . count($resultado_anio) . "\n";

        if (count($resultado_anio) > 0) {
            echo "\n   Primeros 3 registros del año " . $anio_ejemplo . ":\n";
            foreach (array_slice($resultado_anio, 0, 3) as $reg) {
                echo "   - Folio: " . $reg['folio_requerimiento'] . " | ";
                echo "Cuenta: " . $reg['cuenta'] . " | ";
                echo "Tipo: " . $reg['tipo'] . " | ";
                echo "Total: $" . number_format($reg['total'], 2) . "\n";
            }
        }
    }

    // 7. Probar filtro combinado (cuenta + año)
    if (count($resultados) > 0) {
        $cuenta_test = $resultados[0]['cuenta'];
        $fecha = $resultados[0]['fecha_emision'];
        $partes = explode('/', $fecha);
        $anio_test = isset($partes[2]) ? (int)$partes[2] : date('Y');

        echo "\n\n7. Probando filtro combinado - Cuenta: " . $cuenta_test . " + Año: " . $anio_test . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_req(?, ?)");
        $stmt->execute([$cuenta_test, $anio_test]);
        $resultado_combinado = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados: " . count($resultado_combinado) . "\n";

        if (count($resultado_combinado) > 0) {
            echo "\n   Detalle:\n";
            foreach ($resultado_combinado as $reg) {
                echo "   - ID: " . $reg['id'] . " | ";
                echo "Folio: " . $reg['folio_requerimiento'] . " | ";
                echo "Tipo: " . $reg['tipo'] . " | ";
                echo "Vigencia: " . $reg['vigencia'] . " | ";
                echo "Total: $" . number_format($reg['total'], 2) . "\n";
            }
        }
    }

    // 8. Verificar estructura de retorno (columnas)
    echo "\n\n8. Verificando estructura de retorno...\n\n";

    if (count($resultados) > 0) {
        $columnas = array_keys($resultados[0]);
        echo "   Total de columnas: " . count($columnas) . "\n\n";
        echo "   Columnas disponibles:\n";
        foreach ($columnas as $col) {
            echo "   - " . $col . "\n";
        }
    }

    // 9. Resumen de tipos de requerimiento
    echo "\n\n9. Resumen por tipo de requerimiento...\n\n";

    $stmt = $pdo->query("
        SELECT
            CASE
                WHEN tipo = 'P' THEN 'Predial'
                WHEN tipo = 'L' THEN 'Licencia'
                WHEN tipo = 'M' THEN 'Multa'
                WHEN tipo = 'A' THEN 'Anuncio'
                WHEN tipo = 'T' THEN 'Transmisión'
                ELSE COALESCE(tipo, 'Sin tipo')
            END as tipo_desc,
            COUNT(*) as cantidad,
            SUM(total) as total_importe
        FROM public.reqtransm
        GROUP BY tipo
        ORDER BY cantidad DESC
    ");

    echo "   Tipo          | Cantidad | Total Importe\n";
    echo "   " . str_repeat("-", 50) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %-13s | %8d | $%s\n",
            $row['tipo_desc'],
            $row['cantidad'],
            number_format($row['total_importe'] ?: 0, 2)
        );
    }

    echo "\n\n✅ Todas las pruebas completadas!\n";
    echo "\nRESUMEN:\n";
    echo "- Stored procedure creado correctamente\n";
    echo "- Función: publico.recaudadora_req(VARCHAR, INTEGER)\n";
    echo "- Tabla: public.reqtransm\n";
    echo "- Filtros: cuenta (opcional) + ejercicio/año (opcional)\n";
    echo "- Función lista para uso en Req.vue\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
