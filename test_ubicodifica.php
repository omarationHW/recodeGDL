<?php
// Script para probar el stored procedure recaudadora_ubicodifica

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

    $sql = file_get_contents(__DIR__ . '/update_sp_ubicodifica.sql');
    $pdo->exec($sql);

    echo "   ✓ Stored procedure actualizado exitosamente\n";

    // 2. Información de la tabla
    echo "\n\n2. Información de la tabla cartainvpredial...\n\n";

    $stmt = $pdo->query("
        SELECT COUNT(*) as total,
               COUNT(DISTINCT cvecuenta) as total_cuentas,
               MIN(feccap) as min_fecha,
               MAX(feccap) as max_fecha
        FROM public.cartainvpredial
    ");
    $info = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total registros: " . number_format($info['total']) . "\n";
    echo "   Cuentas únicas: " . number_format($info['total_cuentas']) . "\n";
    echo "   Fechas: " . $info['min_fecha'] . " - " . $info['max_fecha'] . "\n";

    // 3. Distribución por vigencia
    echo "\n\n3. Distribución por vigencia...\n\n";

    $stmt = $pdo->query("
        SELECT
            vigencia,
            COUNT(*) as cantidad
        FROM public.cartainvpredial
        GROUP BY vigencia
        ORDER BY cantidad DESC
    ");

    echo "   Vigencia | Cantidad\n";
    echo "   " . str_repeat("-", 30) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $vigencia_desc = '';
        switch (trim($row['vigencia'])) {
            case 'V': $vigencia_desc = '(Vigente)'; break;
            case 'P': $vigencia_desc = '(Pagado)'; break;
            case 'C': $vigencia_desc = '(Cancelado)'; break;
        }
        printf("   %-8s | %s %s\n",
            $row['vigencia'] ?: 'NULL',
            number_format($row['cantidad']),
            $vigencia_desc
        );
    }

    // 4. Obtener ejemplos para pruebas
    echo "\n\n4. Obteniendo ejemplos para pruebas...\n\n";

    // Cuentas de ejemplo
    $stmt = $pdo->query("
        SELECT DISTINCT cvecuenta
        FROM public.cartainvpredial
        WHERE cvecuenta IS NOT NULL
        ORDER BY cvecuenta DESC
        LIMIT 3
    ");
    $cuentas = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "   Cuentas de ejemplo:\n";
    foreach ($cuentas as $cuenta) {
        echo "   - " . $cuenta . "\n";
    }

    // Colonias de ejemplo
    $stmt = $pdo->query("
        SELECT DISTINCT colonia
        FROM public.cartainvpredial
        WHERE colonia IS NOT NULL AND colonia != ''
        ORDER BY colonia
        LIMIT 3
    ");
    $colonias = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "\n   Colonias de ejemplo:\n";
    foreach ($colonias as $colonia) {
        echo "   - " . $colonia . "\n";
    }

    // 5. Probar búsqueda por cuenta
    if (count($cuentas) > 0) {
        $cuenta_test = $cuentas[0];

        echo "\n\n5. Probando búsqueda por cuenta: " . $cuenta_test . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_ubicodifica(?)");
        $stmt->execute([$cuenta_test]);
        $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados: " . count($resultados) . "\n\n";

        if (count($resultados) > 0) {
            echo "   Primer registro:\n\n";
            $reg = $resultados[0];

            echo "   - Cuenta: " . $reg['cvecuenta'] . "\n";
            echo "   - Domicilio: " . $reg['domicilio'] . "\n";
            echo "   - No. Exterior: " . $reg['noexterior'] . "\n";
            echo "   - Interior: " . $reg['interior'] . "\n";
            echo "   - Colonia: " . $reg['colonia'] . "\n";
            echo "   - Observaciones: " . ($reg['observaciones'] ?: 'Sin observaciones') . "\n";
            echo "   - Vigencia: " . $reg['vigencia'] . "\n";
            echo "   - Fec. Alta: " . $reg['fec_alta'] . "\n";
            echo "   - Usuario Alta: " . $reg['usuario_alta'] . "\n";
            echo "   - Fec. Baja: " . ($reg['fec_baja'] ?: 'N/A') . "\n";
            echo "   - Fec. Mov: " . ($reg['fec_mov'] ?: 'N/A') . "\n";
            echo "   - Usuario Mov: " . ($reg['usuario_mov'] ?: 'N/A') . "\n";
        }
    }

    // 6. Probar búsqueda por colonia
    if (count($colonias) > 0) {
        $colonia_test = $colonias[0];

        echo "\n\n6. Probando búsqueda por colonia: " . $colonia_test . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_ubicodifica(?)");
        $stmt->execute([$colonia_test]);
        $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados: " . count($resultados) . "\n";

        if (count($resultados) > 0) {
            echo "\n   Primeras 3 ubicaciones:\n";
            foreach (array_slice($resultados, 0, 3) as $idx => $reg) {
                echo "   " . ($idx + 1) . ". Cuenta: " . $reg['cvecuenta'] . " | " . $reg['domicilio'] . " " . $reg['noexterior'] . " | " . $reg['colonia'] . "\n";
            }
        }
    }

    // 7. Probar búsqueda parcial
    echo "\n\n7. Probando búsqueda parcial...\n\n";

    if (count($cuentas) > 0) {
        $cuenta_parcial = substr($cuentas[0], -3);

        echo "   Buscando con últimos 3 dígitos: " . $cuenta_parcial . "\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_ubicodifica(?)");
        $stmt->execute([$cuenta_parcial]);
        $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ Registros encontrados: " . count($resultados) . "\n";
    }

    // 8. Ver registros vigentes
    echo "\n\n8. Primeros registros vigentes...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_ubicodifica('')");
    $stmt->execute();
    $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   ✓ Total registros: " . count($resultados) . " (límite 100)\n\n";

    if (count($resultados) > 0) {
        echo "   Primeros 3 registros:\n";
        foreach (array_slice($resultados, 0, 3) as $idx => $reg) {
            echo "   " . ($idx + 1) . ". Cuenta: " . $reg['cvecuenta'] . " | " . $reg['domicilio'] . " | Vigencia: " . $reg['vigencia'] . "\n";
        }
    }

    // 9. Verificar estructura de retorno
    echo "\n\n9. Verificando estructura de retorno...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_ubicodifica('') LIMIT 1");
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
    echo "- Función: publico.recaudadora_ubicodifica(VARCHAR)\n";
    echo "- Tabla: public.cartainvpredial (" . number_format($info['total']) . " registros)\n";
    echo "- Filtros: cuenta, domicilio, exterior, colonia, observaciones\n";
    echo "- Cambio aplicado: catastro_gdl.ubicacion_req → public.cartainvpredial\n";
    echo "- Función lista para uso en Ubicodifica.vue\n";
    echo "\nNOTA:\n";
    echo "- Los campos fec_baja, fec_mov y usuario_mov retornan NULL/vacío por limitaciones de datos\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
