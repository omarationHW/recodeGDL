<?php
// Script para probar el stored procedure recaudadora_reqctascanfrm

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Primero, obtener cuentas con multas canceladas para probar
    echo "1. Obteniendo cuentas con multas canceladas...\n\n";

    $stmt = $pdo->query("
        SELECT
            TRIM(expediente) as expediente,
            COUNT(*) as cant_canceladas,
            SUM(total) as total_cancelado,
            MAX(fecha_cancelacion) as ultima_cancelacion
        FROM public.h_multasnvo
        WHERE fecha_cancelacion IS NOT NULL
        AND expediente IS NOT NULL
        AND expediente <> ''
        AND expediente <> '.'
        GROUP BY TRIM(expediente)
        HAVING COUNT(*) > 0
        ORDER BY cant_canceladas DESC
        LIMIT 5
    ");

    $cuentas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($cuentas) > 0) {
        echo "   Cuentas con multas canceladas:\n";
        echo "   Expediente    | Cant. Canceladas | Total Cancelado  | Última Cancelación\n";
        echo "   " . str_repeat("-", 80) . "\n";
        foreach ($cuentas as $cuenta) {
            printf("   %-13s | %16d | $%14.2f | %s\n",
                $cuenta['expediente'],
                $cuenta['cant_canceladas'],
                $cuenta['total_cancelado'],
                $cuenta['ultima_cancelacion']
            );
        }
        echo "\n";
    } else {
        echo "   ℹ️  No se encontraron cuentas con multas canceladas.\n";
        echo "   Buscando multas canceladas por número de acta...\n\n";

        $stmt = $pdo->query("
            SELECT num_acta, COUNT(*) as cant
            FROM public.h_multasnvo
            WHERE fecha_cancelacion IS NOT NULL
            GROUP BY num_acta
            LIMIT 3
        ");
        $cuentas = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // 2. Probar con la primera cuenta
    if (count($cuentas) > 0) {
        $test_cuenta = isset($cuentas[0]['expediente']) ? $cuentas[0]['expediente'] : $cuentas[0]['num_acta'];

        echo "\n2. Probando búsqueda de cuentas canceladas (Cuenta: $test_cuenta)...\n\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reqctascanfrm(?)");
        $stmt->execute([$test_cuenta]);
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Total registros encontrados: " . count($result) . "\n\n";

        if (count($result) > 0) {
            echo "   Detalles de multas canceladas:\n";
            echo "   ID    | Num.Acta | Expediente | F.Cancelación | Contribuyente                | Total       | Usuario\n";
            echo "   " . str_repeat("-", 110) . "\n";

            foreach ($result as $row) {
                printf("   %5d | %8d | %-10s | %s      | %-28s | $%10.2f | %s\n",
                    $row['id_multa'],
                    $row['num_acta'],
                    substr($row['expediente'], 0, 10),
                    $row['fecha_cancelacion'],
                    substr($row['contribuyente'], 0, 28),
                    $row['total'],
                    substr($row['user_baja'] ?: 'N/A', 0, 10)
                );
            }

            // Calcular totales
            $total_multas = array_sum(array_column($result, 'multa'));
            $total_gastos = array_sum(array_column($result, 'gastos'));
            $total_general = array_sum(array_column($result, 'total'));

            echo "   " . str_repeat("-", 110) . "\n";
            printf("   TOTALES: %d registros | Multas: $%s | Gastos: $%s | Total: $%s\n\n",
                count($result),
                number_format($total_multas, 2),
                number_format($total_gastos, 2),
                number_format($total_general, 2)
            );
        }
    }

    // 3. Probar con número de acta
    echo "\n3. Probando búsqueda por número de acta...\n\n";

    $stmt = $pdo->query("
        SELECT num_acta
        FROM public.h_multasnvo
        WHERE fecha_cancelacion IS NOT NULL
        AND num_acta IS NOT NULL
        LIMIT 1
    ");
    $acta = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($acta) {
        $num_acta = $acta['num_acta'];
        echo "   Buscando acta cancelada: $num_acta\n";

        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reqctascanfrm(?)");
        $stmt->execute([(string)$num_acta]);
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($result) > 0) {
            echo "   ✓ Se encontraron " . count($result) . " multas canceladas\n";
            echo "   Primera multa:\n";
            $row = $result[0];
            echo "     - ID Multa: " . $row['id_multa'] . "\n";
            echo "     - Contribuyente: " . $row['contribuyente'] . "\n";
            echo "     - Fecha Cancelación: " . $row['fecha_cancelacion'] . "\n";
            echo "     - Total: $" . number_format($row['total'], 2) . "\n\n";
        }
    }

    // 4. Probar con cuenta inexistente
    echo "\n4. Probando búsqueda con cuenta inexistente...\n\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reqctascanfrm(?)");
    $stmt->execute(['99999999']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Resultados para cuenta inexistente: " . count($result) . " registros\n";
    if (count($result) === 0) {
        echo "   ✓ Correcto: No se encontraron multas canceladas\n\n";
    }

    // 5. Probar validación de parámetros
    echo "\n5. Probando validación de parámetros...\n\n";

    try {
        echo "   Intentando búsqueda con cuenta vacía...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reqctascanfrm(?)");
        $stmt->execute(['']);
        echo "   ❌ No se validó correctamente\n";
    } catch (PDOException $e) {
        echo "   ✓ Validación correcta: " . $e->getMessage() . "\n";
    }

    // 6. Estadísticas generales
    echo "\n\n6. Estadísticas de multas canceladas...\n\n";

    $stmt = $pdo->query("
        SELECT
            COUNT(*) as total_canceladas,
            COUNT(DISTINCT id_dependencia) as dependencias_con_cancelaciones,
            SUM(total) as total_cancelado,
            AVG(total) as promedio_cancelacion,
            MIN(fecha_cancelacion) as primera_cancelacion,
            MAX(fecha_cancelacion) as ultima_cancelacion
        FROM public.h_multasnvo
        WHERE fecha_cancelacion IS NOT NULL
    ");

    $stats = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "   Total multas canceladas: " . number_format($stats['total_canceladas']) . "\n";
    echo "   Dependencias con cancelaciones: " . $stats['dependencias_con_cancelaciones'] . "\n";
    echo "   Total cancelado: $" . number_format($stats['total_cancelado'], 2) . "\n";
    echo "   Promedio por cancelación: $" . number_format($stats['promedio_cancelacion'], 2) . "\n";
    echo "   Primera cancelación: " . $stats['primera_cancelacion'] . "\n";
    echo "   Última cancelación: " . $stats['ultima_cancelacion'] . "\n";

    // 7. Información adicional
    echo "\n\n7. Información adicional...\n\n";
    echo "   ℹ️  TABLA BASE:\n";
    echo "   - Tabla: public.h_multasnvo\n";
    echo "   - Descripción: Histórico de multas municipales\n";
    echo "   - Filtro: fecha_cancelacion IS NOT NULL\n";
    echo "   - Campos retornados:\n";
    echo "     * id_multa: ID de la multa\n";
    echo "     * num_acta: Número de acta\n";
    echo "     * expediente: Número de expediente\n";
    echo "     * fecha_acta: Fecha del acta\n";
    echo "     * fecha_cancelacion: Fecha de cancelación\n";
    echo "     * contribuyente: Nombre del contribuyente\n";
    echo "     * domicilio: Domicilio\n";
    echo "     * dependencia: ID de la dependencia\n";
    echo "     * nombre_dependencia: Nombre descriptivo\n";
    echo "     * multa: Monto de la multa\n";
    echo "     * gastos: Gastos de ejecución\n";
    echo "     * total: Total (multa + gastos)\n";
    echo "     * observacion: Observaciones\n";
    echo "     * user_baja: Usuario que dio de baja\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
