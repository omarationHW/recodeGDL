<?php
// Script para probar el stored procedure recaudadora_resolucion_juez

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

    $sql = file_get_contents(__DIR__ . '/update_sp_resolucion_juez.sql');
    $pdo->exec($sql);

    echo "   ✓ Stored procedure actualizado exitosamente\n";

    // 2. Información de la tabla
    echo "\n\n2. Información de la tabla resolucion_juez...\n\n";

    $stmt = $pdo->query("
        SELECT COUNT(*) as total,
               MIN(id_resolucion) as min_id,
               MAX(id_resolucion) as max_id,
               COUNT(DISTINCT cvecuenta) as total_cuentas,
               MIN(axoini) as min_anio,
               MAX(axofin) as max_anio
        FROM public.resolucion_juez
    ");
    $info = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total registros: " . $info['total'] . "\n";
    echo "   IDs: " . $info['min_id'] . " - " . $info['max_id'] . "\n";
    echo "   Cuentas únicas: " . $info['total_cuentas'] . "\n";
    echo "   Años: " . $info['min_anio'] . " - " . $info['max_anio'] . "\n";

    // 3. Distribuciones
    echo "\n\n3. Distribución por vigencia...\n\n";

    $stmt = $pdo->query("
        SELECT
            vigencia,
            COUNT(*) as cantidad
        FROM public.resolucion_juez
        GROUP BY vigencia
        ORDER BY cantidad DESC
    ");

    echo "   Vigencia | Cantidad\n";
    echo "   " . str_repeat("-", 30) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %-8s | %d\n",
            $row['vigencia'] ?: 'NULL',
            $row['cantidad']
        );
    }

    // 4. Muestra de registros
    echo "\n\n4. Muestra de registros disponibles...\n\n";

    $stmt = $pdo->query("
        SELECT
            id_resolucion,
            cvecuenta,
            axoini,
            bimini,
            axofin,
            bimfin,
            vigencia,
            LEFT(observaciones, 50) as observ_corta
        FROM public.resolucion_juez
        ORDER BY id_resolucion DESC
        LIMIT 5
    ");

    echo "   ID | Cuenta | Periodo             | Vigencia | Observaciones\n";
    echo "   " . str_repeat("-", 100) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %-2d | %-6d | %4d/%d - %4d/%d | %-8s | %s\n",
            $row['id_resolucion'],
            $row['cvecuenta'] ?: 0,
            $row['axoini'] ?: 0,
            $row['bimini'] ?: 0,
            $row['axofin'] ?: 0,
            $row['bimfin'] ?: 0,
            $row['vigencia'] ?: '-',
            $row['observ_corta'] ?: 'Sin obs'
        );
    }

    // 5. Probar stored procedure - Todos los registros
    echo "\n\n5. Probando stored procedure - Todos los registros...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_resolucion_juez(NULL, NULL)");
    $stmt->execute();
    $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   ✓ Registros encontrados: " . count($resultados) . "\n\n";

    if (count($resultados) > 0) {
        echo "   Primeros 3 registros:\n\n";

        foreach (array_slice($resultados, 0, 3) as $idx => $reg) {
            echo "   Registro " . ($idx + 1) . ":\n";
            echo "   - ID: " . $reg['id_resolucion'] . "\n";
            echo "   - Folio: " . $reg['folio'] . "\n";
            echo "   - Cuenta: " . $reg['cuenta'] . "\n";
            echo "   - Periodo: " . $reg['periodo'] . "\n";
            echo "   - Accesorios: " . $reg['accesorios'] . "\n";
            echo "   - Vigencia: " . $reg['vigencia'] . "\n";
            echo "   - CVE Pago: " . $reg['cvepago'] . "\n";
            echo "   - Notif. Canceladas: " . ($reg['notificaciones_canceladas'] ?: 'Ninguna') . "\n";
            echo "   - Observaciones: " . substr($reg['observaciones'], 0, 80) . "...\n";
            echo "   - Usuario Alta: " . $reg['usuario_alta'] . "\n";
            echo "   - Fecha Alta: " . $reg['fecha_alta'] . "\n";
            echo "\n";
        }
    }

    // 6. Probar filtro por cuenta
    if (count($resultados) > 0) {
        $cuenta_ejemplo = $resultados[0]['cuenta'];

        echo "\n6. Probando filtro por cuenta: " . $cuenta_ejemplo . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_resolucion_juez(?, NULL)");
        $stmt->execute([$cuenta_ejemplo]);
        $resultado_cuenta = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados para cuenta " . $cuenta_ejemplo . ": " . count($resultado_cuenta) . "\n";

        if (count($resultado_cuenta) > 0) {
            echo "\n   Detalle:\n";
            foreach ($resultado_cuenta as $reg) {
                echo "   - ID: " . $reg['id_resolucion'] . " | ";
                echo "Periodo: " . $reg['periodo'] . " | ";
                echo "Vigencia: " . $reg['vigencia'] . "\n";
            }
        }
    }

    // 7. Probar filtro por folio
    if (count($resultados) > 0) {
        $folio_ejemplo = $resultados[0]['folio'];

        echo "\n\n7. Probando filtro por folio: " . $folio_ejemplo . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_resolucion_juez(NULL, ?)");
        $stmt->execute([$folio_ejemplo]);
        $resultado_folio = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados para folio " . $folio_ejemplo . ": " . count($resultado_folio) . "\n";

        if (count($resultado_folio) > 0) {
            $reg = $resultado_folio[0];
            echo "\n   Detalle:\n";
            echo "   - ID: " . $reg['id_resolucion'] . "\n";
            echo "   - Cuenta: " . $reg['cuenta'] . "\n";
            echo "   - Periodo: " . $reg['periodo'] . "\n";
            echo "   - Accesorios: " . $reg['accesorios'] . "\n";
            echo "   - Vigencia: " . $reg['vigencia'] . "\n";
        }
    }

    // 8. Probar filtro combinado
    if (count($resultados) > 0) {
        $cuenta_test = $resultados[0]['cuenta'];
        $folio_test = $resultados[0]['folio'];

        echo "\n\n8. Probando filtro combinado - Cuenta: " . $cuenta_test . " + Folio: " . $folio_test . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_resolucion_juez(?, ?)");
        $stmt->execute([$cuenta_test, $folio_test]);
        $resultado_combinado = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados: " . count($resultado_combinado) . "\n";

        if (count($resultado_combinado) > 0) {
            $reg = $resultado_combinado[0];
            echo "\n   Detalle:\n";
            echo "   - ID: " . $reg['id_resolucion'] . "\n";
            echo "   - Cuenta: " . $reg['cuenta'] . "\n";
            echo "   - Periodo: " . $reg['periodo'] . "\n";
            echo "   - Vigencia: " . $reg['vigencia'] . "\n";
        }
    }

    // 9. Listar cuentas disponibles
    echo "\n\n9. Cuentas disponibles para pruebas...\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT
            cvecuenta,
            COUNT(*) as total_resoluciones
        FROM public.resolucion_juez
        GROUP BY cvecuenta
        ORDER BY total_resoluciones DESC, cvecuenta
        LIMIT 10
    ");

    echo "   Cuenta | Total Resoluciones\n";
    echo "   " . str_repeat("-", 40) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %-6d | %d\n",
            $row['cvecuenta'],
            $row['total_resoluciones']
        );
    }

    // 10. Verificar estructura de retorno
    echo "\n\n10. Verificando estructura de retorno...\n\n";

    if (count($resultados) > 0) {
        $columnas = array_keys($resultados[0]);
        echo "   Total de columnas: " . count($columnas) . "\n\n";
        echo "   Columnas disponibles:\n";
        foreach ($columnas as $col) {
            echo "   - " . $col . "\n";
        }
    }

    echo "\n\n✅ Todas las pruebas completadas!\n";
    echo "\nRESUMEN:\n";
    echo "- Stored procedure actualizado correctamente\n";
    echo "- Función: publico.recaudadora_resolucion_juez(VARCHAR, INTEGER)\n";
    echo "- Tabla: public.resolucion_juez (" . $info['total'] . " registros)\n";
    echo "- Filtros: cuenta (opcional) + folio (opcional)\n";
    echo "- Función lista para uso en ResolucionJuez.vue\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
