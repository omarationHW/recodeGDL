<?php
// Script para probar el stored procedure recaudadora_pagosmultfrm actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_pagosmultfrm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_pagosmultfrm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar búsqueda sin filtro (últimos 100 pagos)
    echo "2. Probando búsqueda sin filtro (últimos 100 pagos)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pagosmultfrm('', NULL)");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " pagos\n\n";

    if (count($result) > 0) {
        echo "   === PRIMEROS 5 PAGOS ===\n";
        for ($i = 0; $i < min(5, count($result)); $i++) {
            $pago = $result[$i];
            echo "\n   PAGO " . ($i + 1) . ":\n";
            echo "   ID: {$pago['id_pago']}\n";
            echo "   Cuenta: {$pago['cuenta']}\n";
            echo "   Fecha: {$pago['anio']}/{$pago['mes']}/{$pago['dia']}";
            if ($pago['fecha_pago']) {
                echo " ({$pago['fecha_pago']})";
            }
            echo "\n";
            echo "   Oficina: {$pago['oficina']}\n";
            echo "   Cajero: {$pago['cajero']}\n";
            echo "   Operación: {$pago['operacion']}\n";
            echo "   Tipo: {$pago['tipo_operacion']}\n";
            echo "   Importe: $" . number_format($pago['importe'], 2) . "\n";
        }
    }

    // 3. Probar búsqueda con filtro por cuenta
    echo "\n\n3. Probando búsqueda con filtro por cuenta (ejemplo: 19748)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pagosmultfrm(?, NULL)");
    $stmt->execute(['19748']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " pagos\n";
    if (count($result) > 0) {
        echo "\n   Primeros 3 pagos de la cuenta:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $pago = $result[$i];
            echo "   - Cuenta: {$pago['cuenta']}, ";
            echo "Fecha: {$pago['anio']}/{$pago['mes']}/{$pago['dia']}, ";
            echo "Importe: $" . number_format($pago['importe'], 2) . "\n";
        }
    }

    // 4. Probar búsqueda con filtro por año
    echo "\n\n4. Probando búsqueda con filtro por año (ejemplo: 1990)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pagosmultfrm('', ?)");
    $stmt->execute([1990]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " pagos\n";
    if (count($result) > 0) {
        echo "\n   Primeros 3 pagos del año 1990:\n";
        for ($i = 0; $i < min(3, count($result)); $i++) {
            $pago = $result[$i];
            echo "   - Cuenta: {$pago['cuenta']}, ";
            echo "Fecha: {$pago['anio']}/{$pago['mes']}/{$pago['dia']}, ";
            echo "Importe: $" . number_format($pago['importe'], 2) . "\n";
        }
    }

    // 5. Probar búsqueda con filtro combinado (cuenta + año)
    echo "\n\n5. Probando búsqueda con filtro combinado (cuenta 19748 + año 1990)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pagosmultfrm(?, ?)");
    $stmt->execute(['19748', 1990]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " pagos\n";
    if (count($result) > 0) {
        echo "\n   Pagos encontrados:\n";
        foreach ($result as $pago) {
            echo "   - Cuenta: {$pago['cuenta']}, ";
            echo "Fecha: {$pago['anio']}/{$pago['mes']}/{$pago['dia']}, ";
            echo "Importe: $" . number_format($pago['importe'], 2) . "\n";
        }
    }

    // 6. Estadísticas generales
    echo "\n\n6. Estadísticas generales...\n";

    $stmt_total = $pdo->query("SELECT COUNT(*) as total FROM public.pagos_400");
    $total = $stmt_total->fetch(PDO::FETCH_ASSOC);
    echo "   Total pagos en BD: " . number_format($total['total']) . "\n";

    // Ver distribución por años
    echo "\n   Distribución por años (top 5):\n";
    $stmt_anios = $pdo->query("
        SELECT
            CASE
                WHEN axopag < 100 THEN 1900 + axopag
                ELSE axopag
            END AS anio,
            COUNT(*) as total
        FROM public.pagos_400
        GROUP BY anio
        ORDER BY total DESC
        LIMIT 5
    ");
    $anios = $stmt_anios->fetchAll(PDO::FETCH_ASSOC);
    foreach ($anios as $anio) {
        echo "   - Año {$anio['anio']}: " . number_format($anio['total']) . " pagos\n";
    }

    // Ver distribución por tipo de operación
    echo "\n   Distribución por tipo de operación:\n";
    $stmt_tipo = $pdo->query("
        SELECT
            CASE
                WHEN TRIM(tpopag) = 'M' THEN 'Manual'
                WHEN TRIM(tpopag) = 'A' THEN 'Automático'
                ELSE 'Desconocido'
            END as tipo,
            COUNT(*) as total
        FROM public.pagos_400
        GROUP BY tipo
        ORDER BY total DESC
    ");
    $tipos = $stmt_tipo->fetchAll(PDO::FETCH_ASSOC);
    foreach ($tipos as $tipo) {
        echo "   - {$tipo['tipo']}: " . number_format($tipo['total']) . " pagos\n";
    }

    // Ver resumen de importes
    echo "\n   Resumen de importes:\n";
    $stmt_importes = $pdo->query("
        SELECT
            SUM(COALESCE(impto, 0)) as total_general,
            AVG(COALESCE(impto, 0)) as promedio,
            MIN(COALESCE(impto, 0)) as minimo,
            MAX(COALESCE(impto, 0)) as maximo
        FROM public.pagos_400
    ");
    $importes = $stmt_importes->fetch(PDO::FETCH_ASSOC);
    echo "   - Total general: $" . number_format($importes['total_general'], 2) . "\n";
    echo "   - Promedio: $" . number_format($importes['promedio'], 2) . "\n";
    echo "   - Mínimo: $" . number_format($importes['minimo'], 2) . "\n";
    echo "   - Máximo: $" . number_format($importes['maximo'], 2) . "\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
