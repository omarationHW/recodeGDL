<?php
// Script para probar el stored procedure recaudadora_sdosfavor_ctrlexp

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

    $sql = file_get_contents(__DIR__ . '/update_sp_sdosfavor_ctrlexp.sql');
    $pdo->exec($sql);

    echo "   ✓ Stored procedure actualizado exitosamente\n";

    // 2. Información de la tabla
    echo "\n\n2. Información de la tabla solic_sdosfavor...\n\n";

    $stmt = $pdo->query("
        SELECT COUNT(*) as total,
               MIN(id_solic) as min_id,
               MAX(id_solic) as max_id,
               COUNT(DISTINCT cvecuenta) as total_cuentas,
               MIN(axofol) as min_anio,
               MAX(axofol) as max_anio
        FROM public.solic_sdosfavor
    ");
    $info = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total registros: " . number_format($info['total']) . "\n";
    echo "   IDs: " . $info['min_id'] . " - " . $info['max_id'] . "\n";
    echo "   Cuentas únicas: " . number_format($info['total_cuentas']) . "\n";
    echo "   Años: " . $info['min_anio'] . " - " . $info['max_anio'] . "\n";

    // 3. Distribución por status
    echo "\n\n3. Distribución por estatus...\n\n";

    $stmt = $pdo->query("
        SELECT
            status,
            COUNT(*) as cantidad
        FROM public.solic_sdosfavor
        GROUP BY status
        ORDER BY cantidad DESC
    ");

    echo "   Status | Cantidad\n";
    echo "   " . str_repeat("-", 30) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $status_desc = '';
        switch (trim($row['status'])) {
            case 'P': $status_desc = '(Pendiente)'; break;
            case 'T': $status_desc = '(Terminado)'; break;
            case 'C': $status_desc = '(Cancelado)'; break;
        }
        printf("   %-6s | %s %s\n",
            $row['status'] ?: 'NULL',
            number_format($row['cantidad']),
            $status_desc
        );
    }

    // 4. Obtener algunas cuentas de ejemplo
    echo "\n\n4. Obteniendo cuentas de ejemplo...\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT cvecuenta
        FROM public.solic_sdosfavor
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

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sdosfavor_ctrlexp(?)");
        $stmt->execute([$cuenta_test]);
        $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados: " . count($resultados) . "\n\n";

        if (count($resultados) > 0) {
            echo "   Primer registro:\n\n";
            $reg = $resultados[0];

            echo "   - ID Solicitud: " . $reg['id_solicitud'] . "\n";
            echo "   - Año/Folio: " . $reg['anio_folio'] . "/" . $reg['folio'] . "\n";
            echo "   - Cuenta: " . $reg['cuenta'] . "\n";
            echo "   - Domicilio: " . $reg['domicilio'] . " " . $reg['exterior'] . "\n";
            echo "   - Colonia: " . $reg['colonia'] . "\n";
            echo "   - CP: " . $reg['cp'] . "\n";
            echo "   - Teléfono: " . ($reg['telefono'] ?: 'Sin teléfono') . "\n";
            echo "   - Solicitante: " . $reg['solicitante'] . "\n";
            echo "   - Estatus: " . $reg['estatus'] . "\n";
            echo "   - Observaciones: " . substr($reg['observaciones'], 0, 100) . "...\n";
            echo "   - Fecha Captura: " . $reg['fecha_captura'] . "\n";
            echo "   - Capturista: " . $reg['capturista'] . "\n";
            echo "   - Fecha Término: " . ($reg['fecha_termino'] ?: 'Pendiente') . "\n";
            echo "   - Inconformidad: " . $reg['inconformidad'] . "\n";
            echo "   - Peticionario: " . $reg['peticionario'] . "\n";
            echo "   - Documentos: " . ($reg['documentos'] ?: 'Sin docs') . "\n";
        }
    }

    // 6. Probar búsqueda parcial
    echo "\n\n6. Probando búsqueda parcial (últimos 3 dígitos)...\n\n";

    if (count($cuentas_ejemplo) > 0) {
        $cuenta_parcial = substr($cuentas_ejemplo[0], -3);

        echo "   Buscando con: " . $cuenta_parcial . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sdosfavor_ctrlexp(?)");
        $stmt->execute([$cuenta_parcial]);
        $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados: " . count($resultados) . "\n";

        if (count($resultados) > 0) {
            echo "\n   Primeras 3 cuentas encontradas:\n";
            foreach (array_slice($resultados, 0, 3) as $reg) {
                echo "   - Cuenta: " . $reg['cuenta'] . " | Folio: " . $reg['folio'] . " | Estatus: " . $reg['estatus'] . "\n";
            }
        }
    }

    // 7. Verificar estructura de retorno
    echo "\n\n7. Verificando estructura de retorno...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sdosfavor_ctrlexp(?) LIMIT 1");
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

    // 8. Cuentas con múltiples solicitudes
    echo "\n\n8. Cuentas con múltiples solicitudes...\n\n";

    $stmt = $pdo->query("
        SELECT
            cvecuenta,
            COUNT(*) as total_solicitudes
        FROM public.solic_sdosfavor
        GROUP BY cvecuenta
        HAVING COUNT(*) > 1
        ORDER BY total_solicitudes DESC
        LIMIT 5
    ");

    echo "   Cuenta | Total Solicitudes\n";
    echo "   " . str_repeat("-", 40) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %-6d | %d\n",
            $row['cvecuenta'],
            $row['total_solicitudes']
        );
    }

    // 9. Estadísticas por año
    echo "\n\n9. Top 5 años con más solicitudes...\n\n";

    $stmt = $pdo->query("
        SELECT
            axofol,
            COUNT(*) as cantidad
        FROM public.solic_sdosfavor
        GROUP BY axofol
        ORDER BY cantidad DESC
        LIMIT 5
    ");

    echo "   Año  | Cantidad\n";
    echo "   " . str_repeat("-", 30) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %4d | %s\n",
            $row['axofol'],
            number_format($row['cantidad'])
        );
    }

    echo "\n\n✅ Todas las pruebas completadas!\n";
    echo "\nRESUMEN:\n";
    echo "- Stored procedure creado correctamente\n";
    echo "- Función: publico.recaudadora_sdosfavor_ctrlexp(VARCHAR)\n";
    echo "- Tabla: public.solic_sdosfavor (" . number_format($info['total']) . " registros)\n";
    echo "- Filtro: cuenta (requerido)\n";
    echo "- Función lista para uso en SdosFavor_CtrlExp.vue\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
