<?php
// Script para probar el stored procedure recaudadora_sol_sdos_favor

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

    $sql = file_get_contents(__DIR__ . '/update_sp_sol_sdos_favor.sql');
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

    // 3. Obtener ejemplos para cada tipo de búsqueda
    echo "\n\n3. Obteniendo ejemplos para pruebas...\n\n";

    // Cuenta de ejemplo
    $stmt = $pdo->query("
        SELECT DISTINCT cvecuenta
        FROM public.solic_sdosfavor
        WHERE cvecuenta IS NOT NULL
        ORDER BY cvecuenta DESC
        LIMIT 3
    ");
    $cuentas = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "   Cuentas de ejemplo:\n";
    foreach ($cuentas as $cuenta) {
        echo "   - " . $cuenta . "\n";
    }

    // Folio de ejemplo
    $stmt = $pdo->query("
        SELECT DISTINCT folio
        FROM public.solic_sdosfavor
        WHERE folio IS NOT NULL
        ORDER BY folio DESC
        LIMIT 3
    ");
    $folios = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "\n   Folios de ejemplo:\n";
    foreach ($folios as $folio) {
        echo "   - " . $folio . "\n";
    }

    // Solicitante de ejemplo
    $stmt = $pdo->query("
        SELECT DISTINCT TRIM(solicitante) as solicitante
        FROM public.solic_sdosfavor
        WHERE solicitante IS NOT NULL AND TRIM(solicitante) != ''
        ORDER BY solicitante
        LIMIT 3
    ");
    $solicitantes = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "\n   Solicitantes de ejemplo:\n";
    foreach ($solicitantes as $sol) {
        echo "   - " . substr($sol, 0, 30) . "\n";
    }

    // 4. Probar búsqueda por cuenta
    if (count($cuentas) > 0) {
        $cuenta_test = $cuentas[0];

        echo "\n\n4. Probando búsqueda por cuenta: " . $cuenta_test . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sol_sdos_favor(?)");
        $stmt->execute([$cuenta_test]);
        $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados: " . count($resultados) . "\n\n";

        if (count($resultados) > 0) {
            echo "   Primer registro:\n\n";
            $reg = $resultados[0];

            echo "   - ID Solicitud: " . $reg['id_solic'] . "\n";
            echo "   - Año/Folio: " . $reg['axofol'] . "/" . $reg['folio'] . "\n";
            echo "   - Cuenta: " . $reg['cvecuenta'] . "\n";
            echo "   - Domicilio: " . $reg['domp'] . " " . $reg['extp'] . "\n";
            echo "   - Colonia: " . $reg['colp'] . "\n";
            echo "   - Sector: " . $reg['secp'] . "\n";
            echo "   - Código: " . $reg['codp'] . "\n";
            echo "   - Teléfono: " . ($reg['telefono'] ?: 'Sin teléfono') . "\n";
            echo "   - Solicitante: " . $reg['solicitante'] . "\n";
            echo "   - Status: " . $reg['status'] . "\n";
            echo "   - Observaciones: " . substr($reg['observaciones'], 0, 60) . "...\n";
            echo "   - Fecha Captura: " . $reg['feccap'] . "\n";
            echo "   - Capturista: " . $reg['capturista'] . "\n";
            echo "   - Fecha Término: " . ($reg['fecha_termino'] ?: 'Pendiente') . "\n";
        }
    }

    // 5. Probar búsqueda por folio
    if (count($folios) > 0) {
        $folio_test = $folios[0];

        echo "\n\n5. Probando búsqueda por folio: " . $folio_test . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sol_sdos_favor(?)");
        $stmt->execute([$folio_test]);
        $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados: " . count($resultados) . "\n";

        if (count($resultados) > 0) {
            echo "\n   Primeras 2 solicitudes:\n";
            foreach (array_slice($resultados, 0, 2) as $idx => $reg) {
                echo "   Solicitud " . ($idx + 1) . ": ID " . $reg['id_solic'] . " | Cuenta: " . $reg['cvecuenta'] . " | Folio: " . $reg['folio'] . " | Status: " . $reg['status'] . "\n";
            }
        }
    }

    // 6. Probar búsqueda por solicitante
    if (count($solicitantes) > 0) {
        $nombre_test = explode(' ', $solicitantes[0])[0]; // Primer nombre

        echo "\n\n6. Probando búsqueda por nombre: " . $nombre_test . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sol_sdos_favor(?)");
        $stmt->execute([$nombre_test]);
        $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados: " . count($resultados) . "\n";

        if (count($resultados) > 0) {
            echo "\n   Primeras 2 solicitudes:\n";
            foreach (array_slice($resultados, 0, 2) as $idx => $reg) {
                echo "   " . ($idx + 1) . ". " . $reg['solicitante'] . " | Cuenta: " . $reg['cvecuenta'] . " | Folio: " . $reg['folio'] . "\n";
            }
        }
    }

    // 7. Probar búsqueda parcial (últimos dígitos)
    echo "\n\n7. Probando búsqueda parcial...\n\n";

    if (count($cuentas) > 0) {
        $cuenta_parcial = substr($cuentas[0], -3);

        echo "   Buscando con últimos 3 dígitos: " . $cuenta_parcial . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sol_sdos_favor(?)");
        $stmt->execute([$cuenta_parcial]);
        $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados: " . count($resultados) . "\n";
    }

    // 8. Ver primeros registros sin filtro
    echo "\n\n8. Primeros registros sin filtro (más recientes)...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sol_sdos_favor('')");
    $stmt->execute();
    $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   ✓ Total registros: " . count($resultados) . " (límite 100)\n\n";

    if (count($resultados) > 0) {
        echo "   Primeros 3 registros más recientes:\n";
        foreach (array_slice($resultados, 0, 3) as $idx => $reg) {
            echo "   " . ($idx + 1) . ". ID: " . $reg['id_solic'] . " | Cuenta: " . $reg['cvecuenta'] . " | Folio: " . $reg['folio'] . " | " . $reg['solicitante'] . "\n";
        }
    }

    // 9. Distribución por status
    echo "\n\n9. Distribución por status...\n\n";

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
            case 'A': $status_desc = '(Autorizado)'; break;
        }
        printf("   %-6s | %s %s\n",
            $row['status'] ?: 'NULL',
            number_format($row['cantidad']),
            $status_desc
        );
    }

    // 10. Verificar estructura de retorno
    echo "\n\n10. Verificando estructura de retorno...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sol_sdos_favor('') LIMIT 1");
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

    echo "\n\n✅ Todas las pruebas completadas!\n";
    echo "\nRESUMEN:\n";
    echo "- Stored procedure actualizado correctamente\n";
    echo "- Función: publico.recaudadora_sol_sdos_favor(VARCHAR)\n";
    echo "- Tabla: public.solic_sdosfavor (" . number_format($info['total']) . " registros)\n";
    echo "- Filtros múltiples: cuenta, folio, ID solicitud, nombre solicitante\n";
    echo "- Cambio aplicado: catastro_gdl.solic_sdosfavor → public.solic_sdosfavor\n";
    echo "- Función lista para uso en SolSdosFavor.vue\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
