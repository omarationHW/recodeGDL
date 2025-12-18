<?php
// Verificar estructura para modificación masiva

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICACIÓN PARA MODIFICACIÓN MASIVA ===\n\n";

    // 1. Ver estructura de reqbfpredial
    echo "1. Tabla: public.reqbfpredial (118,842 registros)\n";
    echo "   Campos relevantes para modificación masiva:\n";
    echo "   - cvecuenta (cuenta catastral - usar como 'folio')\n";
    echo "   - recaud (recaudadora 1-10)\n";
    echo "   - vigencia (V=Vigente/Activo, C=Cancelado, P=Pagado)\n";
    echo "   - total (monto total)\n";
    echo "   - fecemi (fecha de emisión)\n\n";

    // 2. Ver distribución por vigencia
    echo "2. Distribución por vigencia (estado):\n";
    $stmt = $pdo->query("
        SELECT
            vigencia,
            COUNT(*) as total
        FROM public.reqbfpredial
        GROUP BY vigencia
        ORDER BY total DESC
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $estado = $row['vigencia'] == 'V' ? 'Vigente/Activo' :
                 ($row['vigencia'] == 'C' ? 'Cancelado' :
                 ($row['vigencia'] == 'P' ? 'Pagado' : $row['vigencia']));
        echo "   {$estado} ({$row['vigencia']}): " . number_format($row['total']) . "\n";
    }

    // 3. Ver distribución por recaudadora
    echo "\n3. Distribución por recaudadora:\n";
    $stmt = $pdo->query("
        SELECT
            recaud,
            COUNT(*) as total
        FROM public.reqbfpredial
        GROUP BY recaud
        ORDER BY recaud
    ");

    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        echo "   Recaudadora {$row['recaud']}: " . number_format($row['total']) . "\n";
    }

    // 4. Simulación de búsqueda por rango de cuentas
    echo "\n4. Simulación: Buscar cuentas entre 5000 y 5200 en recaudadora 1:\n";
    $stmt = $pdo->query("
        SELECT
            cvecuenta,
            recaud,
            vigencia,
            total,
            fecemi
        FROM public.reqbfpredial
        WHERE recaud = 1
          AND cvecuenta BETWEEN 5000 AND 5200
          AND vigencia = 'V'
        ORDER BY cvecuenta
        LIMIT 10
    ");

    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($results) . " requerimientos\n\n";

    foreach ($results as $i => $row) {
        echo "   " . ($i + 1) . ". Cuenta: {$row['cvecuenta']}, Total: $" . number_format($row['total'], 2) . ", Fecha: {$row['fecemi']}\n";
    }

    // 5. Mapeo propuesto
    echo "\n\n5. Mapeo propuesto para ModifMasiva:\n";
    echo "   folio → cvecuenta (cuenta catastral)\n";
    echo "   recaudadora → recaud\n";
    echo "   estado 'ACTIVO' → vigencia 'V'\n";
    echo "   estado 'CANCELADO' → vigencia 'C'\n";
    echo "   estado 'PAGADO' → vigencia 'P'\n";

    echo "\n✅ Verificación completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
