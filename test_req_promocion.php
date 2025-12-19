<?php
// Script para probar el stored procedure recaudadora_req_promocion

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Verificar estadísticas de la tabla
    echo "1. Estadísticas de la tabla public.c_descpred...\n\n";

    $stmt = $pdo->query("
        SELECT
            COUNT(*) as total_registros,
            COUNT(DISTINCT axodescto) as años_descuento,
            MIN(axodescto) as año_min,
            MAX(axodescto) as año_max,
            AVG(porcentaje) as porcentaje_promedio,
            MIN(porcentaje) as porcentaje_min,
            MAX(porcentaje) as porcentaje_max
        FROM public.c_descpred
    ");

    $stats = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total de registros: " . number_format($stats['total_registros']) . "\n";
    echo "   Años de descuento: " . $stats['años_descuento'] . "\n";
    echo "   Rango de años: " . $stats['año_min'] . " - " . $stats['año_max'] . "\n";
    echo "   Porcentaje promedio: " . round($stats['porcentaje_promedio'], 2) . "%\n";
    echo "   Porcentaje mínimo: " . $stats['porcentaje_min'] . "%\n";
    echo "   Porcentaje máximo: " . $stats['porcentaje_max'] . "%\n\n";

    // 2. Obtener distribución por porcentaje
    echo "2. Distribución por porcentaje de descuento...\n\n";

    $stmt = $pdo->query("
        SELECT
            porcentaje,
            COUNT(*) as cantidad
        FROM public.c_descpred
        GROUP BY porcentaje
        ORDER BY porcentaje DESC
    ");

    echo "   Porcentaje | Cantidad\n";
    echo "   " . str_repeat("-", 30) . "\n";

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        printf("   %10s%% | %s\n",
            $row['porcentaje'],
            number_format($row['cantidad'])
        );
    }

    // 3. Actualizar stored procedure
    echo "\n\n3. Actualizando stored procedure...\n\n";

    $sql = file_get_contents(__DIR__ . '/update_sp_req_promocion.sql');
    $pdo->exec($sql);

    echo "   ✓ Stored procedure actualizado exitosamente\n";

    // 4. Probar búsqueda sin filtro (primeros 100)
    echo "\n\n4. Probando búsqueda sin filtro (primeros 100 registros)...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_req_promocion(NULL, NULL)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total registros retornados: " . count($result) . "\n";

    if (count($result) > 0) {
        echo "\n   Primeros 5 registros:\n";
        echo "   Código | Descripción                        | Porcentaje\n";
        echo "   " . str_repeat("-", 70) . "\n";

        foreach (array_slice($result, 0, 5) as $row) {
            printf("   %6d | %-34s | %6d%%\n",
                $row['cvedescuento'],
                substr($row['descripcion'], 0, 34),
                $row['importe']
            );
        }
    }

    // 5. Obtener códigos de descuento reales para probar
    echo "\n\n5. Obteniendo códigos de descuento para pruebas...\n\n";

    $stmt = $pdo->query("
        SELECT cvedescuento, descripcion, porcentaje, axodescto
        FROM public.c_descpred
        WHERE porcentaje = 50
        ORDER BY axodescto DESC
        LIMIT 5
    ");

    $codigos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Códigos disponibles (descuento 50%):\n";
    foreach ($codigos as $c) {
        printf("   - Código: %d, Año: %d, Desc: %s\n",
            $c['cvedescuento'],
            $c['axodescto'],
            trim($c['descripcion'])
        );
    }

    // 6. Probar búsqueda por código específico
    if (count($codigos) > 0) {
        $test_codigo = $codigos[0]['cvedescuento'];

        echo "\n\n6. Probando búsqueda por código ($test_codigo)...\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_req_promocion(?, NULL)");
        $stmt->execute([(string)$test_codigo]);
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Total registros encontrados: " . count($result) . "\n\n";

        if (count($result) > 0) {
            echo "   Detalles del descuento:\n";
            echo "   Campo         | Valor\n";
            echo "   " . str_repeat("-", 50) . "\n";

            $row = $result[0];
            printf("   %-13s | %s\n", "Código", $row['cvedescuento']);
            printf("   %-13s | %s\n", "Descripción", $row['descripcion']);
            printf("   %-13s | %s%%\n", "Porcentaje", $row['importe']);
        }
    }

    // 7. Probar búsqueda por ejercicio fiscal
    echo "\n\n7. Probando búsqueda por ejercicio fiscal (2020)...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_req_promocion(NULL, ?)");
    $stmt->execute([2020]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total registros encontrados: " . count($result) . "\n";

    if (count($result) > 0) {
        // Calcular estadísticas
        $total_50 = 0;
        $total_100 = 0;
        $otros = 0;

        foreach ($result as $row) {
            if ($row['importe'] == 50) {
                $total_50++;
            } elseif ($row['importe'] == 100) {
                $total_100++;
            } else {
                $otros++;
            }
        }

        echo "\n   Distribución por porcentaje:\n";
        echo "   Descuento 50%: " . $total_50 . "\n";
        echo "   Descuento 100%: " . $total_100 . "\n";
        echo "   Otros: " . $otros . "\n";
    }

    // 8. Verificar campos retornados
    echo "\n\n8. Verificando campos retornados...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_req_promocion(NULL, NULL) LIMIT 1");
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
    echo "   - Tabla: public.c_descpred\n";
    echo "   - Descripción: Catálogo de descuentos prediales\n";
    echo "   - Total registros: " . number_format($stats['total_registros']) . "\n";
    echo "   - Búsqueda: Por código de descuento o ejercicio fiscal\n";
    echo "   - Límite: 100 registros por consulta\n";
    echo "   - Campos principales:\n";
    echo "     * cvedescuento: Código del descuento\n";
    echo "     * descripcion: Descripción del tipo de descuento\n";
    echo "     * porcentaje: Porcentaje de descuento (usado como 'importe')\n";
    echo "     * axodescto: Año del ejercicio fiscal\n";
    echo "     * aplcuotafija: Si aplica cuota fija (S/N)\n";
    echo "     * limvalfisdes: Límite de valor fiscal para descuento\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
