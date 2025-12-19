<?php
// Script para probar el stored procedure recaudadora_prepagofrm

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_prepagofrm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_prepagofrm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar sin búsqueda (todos los registros, últimos 100)
    echo "2. Probando sin búsqueda (últimos 100 registros)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_prepagofrm('')");
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " registro(s)\n\n";

    if (count($result) > 0) {
        echo "   === PRIMEROS 5 REGISTROS ===\n\n";
        $top5 = array_slice($result, 0, 5);
        foreach ($top5 as $i => $row) {
            echo "   Registro " . ($i + 1) . ":\n";
            echo "     CVE Pago: {$row['cvepago']}\n";
            echo "     Licencia: {$row['cvecuenta']}\n";
            echo "     Folio: {$row['folio']}\n";
            echo "     Fecha: {$row['fecha_pago']}\n";
            echo "     Importe: $" . number_format($row['importe'], 2) . "\n";
            echo "     Caja: {$row['caja']}\n";
            echo "     Cajero: {$row['cajero']}\n";
            echo "     Estado: {$row['cancelado']}\n\n";
        }
    }

    // 3. Probar búsqueda por licencia específica
    echo "\n3. Probando búsqueda por licencia '200277'...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_prepagofrm(?)");
    $stmt->execute(['200277']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " registro(s)\n";

    if (count($result) > 0) {
        echo "\n   === RESULTADOS ===\n";
        foreach ($result as $row) {
            echo "   • Licencia {$row['cvecuenta']} - Folio: {$row['folio']} - ";
            echo "Fecha: {$row['fecha_pago']} - Importe: $" . number_format($row['importe'], 2) . "\n";
        }
    }

    // 4. Probar búsqueda por folio
    echo "\n\n4. Probando búsqueda por folio '3337'...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_prepagofrm(?)");
    $stmt->execute(['3337']);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Total encontrados: " . count($result) . " registro(s)\n";

    if (count($result) > 0) {
        echo "\n   === RESULTADOS ===\n";
        foreach (array_slice($result, 0, 5) as $row) {
            echo "   • Folio {$row['folio']} - Licencia: {$row['cvecuenta']} - ";
            echo "$" . number_format($row['importe'], 2) . "\n";
        }
    }

    // 5. Estadísticas generales
    echo "\n\n5. Estadísticas generales...\n";

    $stmt = $pdo->query("
        SELECT
            COUNT(*) as total,
            COUNT(DISTINCT licencia) as licencias_diferentes,
            SUM(t_importe) as suma_total,
            MIN(fecha_registro) as fecha_min,
            MAX(fecha_registro) as fecha_max
        FROM public.lic_pago_alt
    ");

    $stats = $stmt->fetch(PDO::FETCH_ASSOC);

    echo "\n   Total registros en tabla: " . number_format($stats['total']) . "\n";
    echo "   Licencias diferentes: " . number_format($stats['licencias_diferentes']) . "\n";
    echo "   Suma total: $" . number_format($stats['suma_total'], 2) . "\n";
    echo "   Fecha mínima: {$stats['fecha_min']}\n";
    echo "   Fecha máxima: {$stats['fecha_max']}\n";

    // 6. Información adicional
    echo "\n\n6. Información adicional...\n";
    echo "\n   ✅ IMPORTANTE:\n";
    echo "   - Esta función usa la tabla 'public.lic_pago_alt' (30,547 registros)\n";
    echo "   - Retorna pagos alternativos de licencias\n";
    echo "   - Permite búsqueda por cvepago, licencia o folio\n";
    echo "   - Límite de 100 resultados por consulta\n";
    echo "   - La estructura retornada es:\n";
    echo "     * cvepago: Código de pago\n";
    echo "     * cvecuenta: Número de licencia\n";
    echo "     * folio: Folio de transacción\n";
    echo "     * fecha_pago: Fecha de registro\n";
    echo "     * importe: Importe total\n";
    echo "     * caja: Origen del pago\n";
    echo "     * cajero: Línea de captura\n";
    echo "     * cancelado: NO (conciliado) o PENDIENTE\n\n";
    echo "   📌 Los registros están ordenados por fecha descendente.\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
