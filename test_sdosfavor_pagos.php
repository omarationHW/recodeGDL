<?php
// Script para probar el stored procedure recaudadora_sdosfavor_pagos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Crear stored procedure
    echo "1. Creando stored procedure...\n\n";

    $sql = file_get_contents(__DIR__ . '/create_sp_sdosfavor_pagos.sql');
    $pdo->exec($sql);

    echo "   ✓ Stored procedure creado exitosamente\n";

    // 2. Información de las tablas base
    echo "\n\n2. Información de las tablas base...\n\n";

    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM public.pagos_sdosfavor
    ");
    $info_pagos = $stmt->fetch(PDO::FETCH_ASSOC);

    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM public.solic_sdosfavor
    ");
    $info_solic = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Registros en pagos_sdosfavor: " . number_format($info_pagos['total']) . "\n";
    echo "   Registros en solic_sdosfavor: " . number_format($info_solic['total']) . "\n";

    // 3. Ver relaciones existentes
    echo "\n\n3. Relaciones entre tablas...\n\n";

    $stmt = $pdo->query("
        SELECT
            ps.id_solic,
            ps.cvepago,
            ps.status,
            s.cvecuenta,
            s.folio,
            s.axofol
        FROM public.pagos_sdosfavor ps
        LEFT JOIN public.solic_sdosfavor s ON ps.id_solic = s.id_solic
    ");

    echo "   Registros con JOIN:\n";
    echo "   " . str_repeat("-", 80) . "\n";
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $idx => $row) {
        echo "   Registro " . ($idx + 1) . ":\n";
        echo "      ID Solic: " . $row['id_solic'] . "\n";
        echo "      CVE Pago: " . $row['cvepago'] . "\n";
        echo "      Status: " . $row['status'] . "\n";
        echo "      Cuenta: " . ($row['cvecuenta'] ?: 'NULL') . "\n";
        echo "      Folio: " . ($row['folio'] ?: 'NULL') . "\n";
        echo "      Ejercicio: " . ($row['axofol'] ?: 'NULL') . "\n";
        echo "\n";
    }

    // 4. Obtener cuentas disponibles
    echo "4. Cuentas disponibles en pagos...\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT s.cvecuenta
        FROM public.pagos_sdosfavor ps
        LEFT JOIN public.solic_sdosfavor s ON ps.id_solic = s.id_solic
        WHERE s.cvecuenta IS NOT NULL
        ORDER BY s.cvecuenta DESC
    ");

    $cuentas_ejemplo = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "   Cuentas de ejemplo para pruebas:\n";
    foreach ($cuentas_ejemplo as $cuenta) {
        echo "   - " . $cuenta . "\n";
    }

    // 5. Probar stored procedure con todas las cuentas (sin filtro)
    echo "\n\n5. Probando stored procedure (todos los registros)...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sdosfavor_pagos(?)");
    $stmt->execute(['']);
    $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   ✓ Registros encontrados: " . count($resultados) . "\n\n";

    if (count($resultados) > 0) {
        foreach ($resultados as $idx => $reg) {
            echo "   Registro " . ($idx + 1) . ":\n";
            echo "   - ID Pago Favor: " . $reg['id_pago_favor'] . "\n";
            echo "   - Cuenta: " . $reg['cvecuenta'] . "\n";
            echo "   - Folio: " . $reg['folio'] . "\n";
            echo "   - Ejercicio: " . $reg['ejercicio'] . "\n";
            echo "   - Imp. Inconform: $" . number_format($reg['imp_inconform'], 2) . "\n";
            echo "   - Imp. Pago: $" . number_format($reg['imp_pago'], 2) . "\n";
            echo "   - Saldo Favor: $" . number_format($reg['saldo_favor'], 2) . "\n";
            echo "   - Fecha Pago: " . ($reg['fecha_pago'] ?: 'N/A') . "\n";
            echo "   - Solicitante: " . ($reg['solicitante'] ?: 'N/A') . "\n";
            echo "   - Status: " . $reg['status_pago'] . "\n";
            echo "   - CVE Pago: " . $reg['cvepago'] . "\n";
            echo "\n";
        }
    }

    // 6. Probar búsqueda por cuenta específica
    if (count($cuentas_ejemplo) > 0) {
        $cuenta_test = $cuentas_ejemplo[0];

        echo "\n6. Probando búsqueda por cuenta: " . $cuenta_test . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sdosfavor_pagos(?)");
        $stmt->execute([$cuenta_test]);
        $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados: " . count($resultados) . "\n";

        if (count($resultados) > 0) {
            $reg = $resultados[0];
            echo "\n   Primer registro:\n";
            echo "   - Cuenta: " . $reg['cvecuenta'] . "\n";
            echo "   - Folio: " . $reg['folio'] . "\n";
            echo "   - Solicitante: " . $reg['solicitante'] . "\n";
            echo "   - Status: " . $reg['status_pago'] . "\n";
        }
    }

    // 7. Verificar estructura de retorno
    echo "\n\n7. Verificando estructura de retorno...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sdosfavor_pagos('') LIMIT 1");
    $stmt->execute();
    $resultado = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($resultado) {
        $columnas = array_keys($resultado);
        echo "   Total de columnas: " . count($columnas) . "\n\n";
        echo "   Columnas disponibles:\n";
        foreach ($columnas as $col) {
            echo "   - " . $col . "\n";
        }
    }

    // 8. Distribución por status
    echo "\n\n8. Distribución por status de pago...\n\n";

    $stmt = $pdo->query("
        SELECT
            CASE
                WHEN TRIM(status) = 'P' THEN 'Pendiente'
                WHEN TRIM(status) = 'T' THEN 'Terminado'
                WHEN TRIM(status) = 'C' THEN 'Cancelado'
                ELSE 'Sin estado'
            END as estado,
            COUNT(*) as cantidad
        FROM public.pagos_sdosfavor
        GROUP BY
            CASE
                WHEN TRIM(status) = 'P' THEN 'Pendiente'
                WHEN TRIM(status) = 'T' THEN 'Terminado'
                WHEN TRIM(status) = 'C' THEN 'Cancelado'
                ELSE 'Sin estado'
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

    echo "\n\n✅ Todas las pruebas completadas!\n";
    echo "\nRESUMEN:\n";
    echo "- Stored procedure creado correctamente\n";
    echo "- Función: publico.recaudadora_sdosfavor_pagos(VARCHAR)\n";
    echo "- Tablas: public.pagos_sdosfavor + public.solic_sdosfavor (JOIN)\n";
    echo "- Total registros disponibles: " . number_format($info_pagos['total']) . "\n";
    echo "- Filtro: cuenta (opcional, búsqueda parcial)\n";
    echo "- Función lista para uso en SdosFavor_Pagos.vue\n";
    echo "\nNOTA:\n";
    echo "- Los campos imp_pago y saldo_favor retornan 0 por limitaciones de datos\n";
    echo "- fecha_pago usa la fecha de captura de la solicitud\n";
    echo "- imp_inconform usa el campo 'inconf' de la solicitud\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
