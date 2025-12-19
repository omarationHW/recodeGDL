<?php
// Script para probar el stored procedure recaudadora_requerxcvecat

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Verificar estadísticas de la tabla
    echo "1. Estadísticas de la tabla public.cartainvpredial...\n\n";

    $stmt = $pdo->query("
        SELECT
            COUNT(*) as total_registros,
            COUNT(DISTINCT cvecatnva) as claves_catastrales,
            COUNT(DISTINCT axoini) as años_inicio,
            MIN(axoini) as año_min,
            MAX(axoini) as año_max,
            MIN(fecemi) as fecha_min,
            MAX(fecemi) as fecha_max
        FROM public.cartainvpredial
    ");

    $stats = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total de registros: " . number_format($stats['total_registros']) . "\n";
    echo "   Claves catastrales únicas: " . number_format($stats['claves_catastrales']) . "\n";
    echo "   Años de ejercicio: " . $stats['años_inicio'] . "\n";
    echo "   Rango de años: " . $stats['año_min'] . " - " . $stats['año_max'] . "\n";
    echo "   Rango de fechas: " . $stats['fecha_min'] . " - " . $stats['fecha_max'] . "\n\n";

    // 2. Obtener distribución por vigencia
    echo "2. Distribución por vigencia...\n\n";

    $stmt = $pdo->query("
        SELECT
            vigencia,
            CASE
                WHEN vigencia = 'P' THEN 'Pendiente'
                WHEN vigencia = 'C' THEN 'Cancelado'
                WHEN vigencia = 'E' THEN 'Entregado'
                WHEN vigencia = 'V' THEN 'Vigente'
                ELSE 'Otro'
            END as descripcion,
            COUNT(*) as cantidad,
            SUM(total) as total_importe
        FROM public.cartainvpredial
        GROUP BY vigencia
        ORDER BY cantidad DESC
    ");

    echo "   Vigencia | Descripción  | Cantidad   | Total Importe\n";
    echo "   " . str_repeat("-", 60) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %-8s | %-12s | %10s | $%15s\n",
            $row['vigencia'],
            $row['descripcion'],
            number_format($row['cantidad']),
            number_format($row['total_importe'], 2)
        );
    }

    // 3. Actualizar stored procedure
    echo "\n\n3. Actualizando stored procedure...\n\n";

    $sql = file_get_contents(__DIR__ . '/update_sp_requerxcvecat.sql');
    $pdo->exec($sql);

    echo "   ✓ Stored procedure actualizado exitosamente\n";

    // 4. Probar búsqueda sin filtro (primeros 100)
    echo "\n\n4. Probando búsqueda sin filtro (primeros 100 registros)...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_requerxcvecat(NULL)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total registros retornados: " . count($result) . "\n";

    if (count($result) > 0) {
        echo "\n   Primeros 5 registros:\n";
        echo "   Folio | Cuenta  | Clave Catastral | Ejercicio | Total        | Vigencia\n";
        echo "   " . str_repeat("-", 80) . "\n";

        foreach (array_slice($result, 0, 5) as $row) {
            printf("   %5d | %7d | %-15s | %9d | $%10.2f | %s\n",
                $row['folio'],
                $row['cuenta'],
                $row['clave_catastral'],
                $row['ejercicio'],
                $row['total'],
                $row['vigencia']
            );
        }
    }

    // 5. Obtener claves catastrales reales para probar
    echo "\n\n5. Obteniendo claves catastrales para pruebas...\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT cvecatnva
        FROM public.cartainvpredial
        WHERE cvecatnva IS NOT NULL
        AND TRIM(cvecatnva) != ''
        ORDER BY cvecatnva
        LIMIT 5
    ");

    $claves = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Claves catastrales disponibles:\n";
    foreach ($claves as $c) {
        echo "   - " . $c['cvecatnva'] . "\n";
    }

    // 6. Probar búsqueda por clave catastral específica
    if (count($claves) > 0) {
        $test_clave = trim($claves[0]['cvecatnva']);

        echo "\n\n6. Probando búsqueda por clave catastral ($test_clave)...\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_requerxcvecat(?)");
        $stmt->execute([$test_clave]);
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Total registros encontrados: " . count($result) . "\n\n";

        if (count($result) > 0) {
            echo "   Detalles del requerimiento:\n";
            echo "   Campo            | Valor\n";
            echo "   " . str_repeat("-", 60) . "\n";

            $row = $result[0];
            foreach ($row as $campo => $valor) {
                if ($campo === 'total' || $campo === 'impuesto' || $campo === 'recargos' ||
                    $campo === 'gastos' || $campo === 'multas') {
                    $valor = '$' . number_format($valor, 2);
                }
                printf("   %-16s | %s\n", $campo, $valor ?: '-');
            }
        }
    }

    // 7. Probar búsqueda parcial por clave catastral
    echo "\n\n7. Probando búsqueda parcial (D65)...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_requerxcvecat(?)");
    $stmt->execute(['D65']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total registros encontrados: " . count($result) . "\n";

    if (count($result) > 0) {
        // Calcular totales
        $total_impuesto = 0;
        $total_recargos = 0;
        $total_gastos = 0;
        $total_multas = 0;
        $total_general = 0;

        foreach ($result as $row) {
            $total_impuesto += $row['impuesto'];
            $total_recargos += $row['recargos'];
            $total_gastos += $row['gastos'];
            $total_multas += $row['multas'];
            $total_general += $row['total'];
        }

        echo "\n   Resumen de importes:\n";
        echo "   Total Impuesto: $" . number_format($total_impuesto, 2) . "\n";
        echo "   Total Recargos: $" . number_format($total_recargos, 2) . "\n";
        echo "   Total Gastos: $" . number_format($total_gastos, 2) . "\n";
        echo "   Total Multas: $" . number_format($total_multas, 2) . "\n";
        echo "   Total General: $" . number_format($total_general, 2) . "\n";
    }

    // 8. Verificar campos retornados
    echo "\n\n8. Verificando campos retornados...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_requerxcvecat(NULL) LIMIT 1");
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
    echo "   - Tabla: public.cartainvpredial\n";
    echo "   - Descripción: Cartas de invitación predial\n";
    echo "   - Total registros: " . number_format($stats['total_registros']) . "\n";
    echo "   - Búsqueda: Por clave catastral (parcial o completa)\n";
    echo "   - Límite: 100 registros por consulta\n";
    echo "   - Campos principales:\n";
    echo "     * cvereq: Clave de requerimiento\n";
    echo "     * foliocarta: Folio de carta\n";
    echo "     * cvecuenta: Cuenta\n";
    echo "     * cvecatnva: Clave catastral\n";
    echo "     * axoini: Año inicial del ejercicio\n";
    echo "     * fecemi: Fecha de emisión\n";
    echo "     * fecprac: Fecha de practicación\n";
    echo "     * impuesto, recargos, gastos, multas: Importes\n";
    echo "     * total: Total a pagar\n";
    echo "     * vigencia: Estatus (P/C/E/V)\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
