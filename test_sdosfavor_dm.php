<?php
// Script para probar el stored procedure recaudadora_sdosfavor_dm

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

    $sql = file_get_contents(__DIR__ . '/update_sp_sdosfavor_dm.sql');
    $pdo->exec($sql);

    echo "   ✓ Stored procedure actualizado exitosamente\n";

    // 2. Información de la tabla
    echo "\n\n2. Información de la tabla saldosafavor...\n\n";

    $stmt = $pdo->query("
        SELECT COUNT(*) as total,
               MIN(cvecuenta) as min_cuenta,
               MAX(cvecuenta) as max_cuenta,
               SUM(saldoinicial) as total_saldo_inicial,
               SUM(importeaplicado) as total_importe_aplicado,
               MIN(fechaalta) as min_fecha,
               MAX(fechaalta) as max_fecha
        FROM public.saldosafavor
    ");
    $info = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total registros: " . number_format($info['total']) . "\n";
    echo "   Cuentas: " . $info['min_cuenta'] . " - " . $info['max_cuenta'] . "\n";
    echo "   Total saldo inicial: $" . number_format($info['total_saldo_inicial'], 2) . "\n";
    echo "   Total importe aplicado: $" . number_format($info['total_importe_aplicado'], 2) . "\n";
    echo "   Fechas: " . $info['min_fecha'] . " - " . $info['max_fecha'] . "\n";

    // 3. Distribución de estados (simulada)
    echo "\n\n3. Distribución por estado...\n\n";

    $stmt = $pdo->query("
        SELECT
            CASE
                WHEN fechacan IS NOT NULL THEN 'Cancelado'
                WHEN (saldoinicial - importeaplicado) > 0 THEN 'Pendiente'
                WHEN (saldoinicial - importeaplicado) = 0 THEN 'Liquidado'
                ELSE 'Aplicado'
            END as estado,
            COUNT(*) as cantidad
        FROM public.saldosafavor
        GROUP BY
            CASE
                WHEN fechacan IS NOT NULL THEN 'Cancelado'
                WHEN (saldoinicial - importeaplicado) > 0 THEN 'Pendiente'
                WHEN (saldoinicial - importeaplicado) = 0 THEN 'Liquidado'
                ELSE 'Aplicado'
            END
        ORDER BY cantidad DESC
    ");

    echo "   Estado | Cantidad\n";
    echo "   " . str_repeat("-", 40) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %-12s | %s\n",
            $row['estado'],
            number_format($row['cantidad'])
        );
    }

    // 4. Obtener algunas cuentas de ejemplo
    echo "\n\n4. Obteniendo cuentas de ejemplo...\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT cvecuenta
        FROM public.saldosafavor
        WHERE cvecuenta IS NOT NULL
        ORDER BY cvecuenta DESC
        LIMIT 5
    ");

    $cuentas_ejemplo = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "   Cuentas de ejemplo para pruebas:\n";
    foreach ($cuentas_ejemplo as $cuenta) {
        echo "   - " . $cuenta . "\n";
    }

    // 5. Probar stored procedure con una cuenta
    if (count($cuentas_ejemplo) > 0) {
        $cuenta_test = $cuentas_ejemplo[0];

        echo "\n\n5. Probando stored procedure con cuenta: " . $cuenta_test . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sdosfavor_dm(?)");
        $stmt->execute([$cuenta_test]);
        $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados: " . count($resultados) . "\n\n";

        if (count($resultados) > 0) {
            echo "   Primer registro:\n\n";
            $reg = $resultados[0];

            echo "   - Cuenta: " . $reg['cvecuenta'] . "\n";
            echo "   - ID Convenio: " . $reg['id_convenio'] . "\n";
            echo "   - Folio: " . $reg['folio'] . "\n";
            echo "   - Saldo Inicial: $" . number_format($reg['saldo_inicial'], 2) . "\n";
            echo "   - Importe Aplicado: $" . number_format($reg['importe_aplicado'], 2) . "\n";
            echo "   - Saldo Restante: $" . number_format($reg['saldo_restante'], 2) . "\n";
            echo "   - Estado: " . $reg['estado'] . "\n";
            echo "   - Fecha Alta: " . $reg['fecha_alta'] . "\n";
            echo "   - Usuario Alta: " . ($reg['usuario_alta'] ?: 'Sin usuario') . "\n";
            echo "   - Fecha Cancelación: " . ($reg['fecha_cancelacion'] ?: 'Sin cancelación') . "\n";
            echo "   - Usuario Cancelación: " . ($reg['usuario_cancelacion'] ?: 'Sin usuario') . "\n";
        }
    }

    // 6. Probar búsqueda parcial
    echo "\n\n6. Probando búsqueda parcial (últimos 3 dígitos)...\n\n";

    if (count($cuentas_ejemplo) > 0) {
        $cuenta_parcial = substr($cuentas_ejemplo[0], -3);

        echo "   Buscando con: " . $cuenta_parcial . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sdosfavor_dm(?)");
        $stmt->execute([$cuenta_parcial]);
        $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados: " . count($resultados) . "\n";

        if (count($resultados) > 0) {
            echo "\n   Primeras 3 cuentas encontradas:\n";
            foreach (array_slice($resultados, 0, 3) as $reg) {
                echo "   - Cuenta: " . $reg['cvecuenta'] . " | Folio: " . $reg['folio'] . " | Estado: " . $reg['estado'] . " | Saldo Restante: $" . number_format($reg['saldo_restante'], 2) . "\n";
            }
        }
    }

    // 7. Verificar estructura de retorno
    echo "\n\n7. Verificando estructura de retorno...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sdosfavor_dm(?) LIMIT 1");
    $stmt->execute([$cuentas_ejemplo[0]]);
    $resultado = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($resultado) {
        $columnas = array_keys($resultado);
        echo "   Total de columnas: " . count($columnas) . "\n\n";
        echo "   Columnas disponibles:\n";
        foreach ($columnas as $col) {
            echo "   - " . $col . "\n";
        }
    }

    // 8. Cuentas con mayores saldos
    echo "\n\n8. Cuentas con mayores saldos restantes...\n\n";

    $stmt = $pdo->query("
        SELECT
            cvecuenta,
            (saldoinicial - importeaplicado) as saldo_restante
        FROM public.saldosafavor
        WHERE (saldoinicial - importeaplicado) > 0
        ORDER BY saldo_restante DESC
        LIMIT 5
    ");

    echo "   Cuenta | Saldo Restante\n";
    echo "   " . str_repeat("-", 40) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %-6d | $%s\n",
            $row['cvecuenta'],
            number_format($row['saldo_restante'], 2)
        );
    }

    // 9. Distribución por año de alta
    echo "\n\n9. Top 5 años con más registros...\n\n";

    $stmt = $pdo->query("
        SELECT
            EXTRACT(YEAR FROM fechaalta) as anio,
            COUNT(*) as cantidad
        FROM public.saldosafavor
        WHERE fechaalta IS NOT NULL
        GROUP BY EXTRACT(YEAR FROM fechaalta)
        ORDER BY cantidad DESC
        LIMIT 5
    ");

    echo "   Año  | Cantidad\n";
    echo "   " . str_repeat("-", 30) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %4d | %s\n",
            $row['anio'],
            number_format($row['cantidad'])
        );
    }

    echo "\n\n✅ Todas las pruebas completadas!\n";
    echo "\nRESUMEN:\n";
    echo "- Stored procedure actualizado correctamente\n";
    echo "- Función: publico.recaudadora_sdosfavor_dm(VARCHAR)\n";
    echo "- Tabla: public.saldosafavor (" . number_format($info['total']) . " registros)\n";
    echo "- Filtro: cuenta (opcional, búsqueda parcial)\n";
    echo "- Cambio aplicado: catastro_gdl.saldosafavor → public.saldosafavor\n";
    echo "- Función lista para uso en SdosFavorDM.vue\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
