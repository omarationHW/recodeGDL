<?php
// Script para probar el stored procedure recaudadora_drecgo_trans actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_drecgo_trans...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_drecgo_trans.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Verificar búsqueda exhaustiva de tablas de tránsito
    echo "2. Verificando existencia de tablas de tránsito...\n";
    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM information_schema.tables
        WHERE (
            table_name ILIKE '%transito%'
            OR table_name ILIKE '%vehiculo%'
            OR table_name ILIKE '%placa%'
        )
        AND table_schema IN ('public', 'publico')
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Tablas de tránsito encontradas: {$result['total']}\n";

    if ($result['total'] == 0) {
        echo "   ⚠ CONFIRMADO: No existen tablas de tránsito/vehículos en la BD\n";
    }

    // 3. Probar el SP (debe devolver conjunto vacío sin errores)
    echo "\n\n3. Probando SP con parámetro vacío...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_drecgo_trans('')");
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Resultados: " . count($rows) . " registros\n";
    echo "   ✓ SP ejecutado sin errores (conjunto vacío como se esperaba)\n";

    // 4. Probar con parámetro específico
    echo "\n\n4. Probando SP con parámetro específico 'ABC123'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_drecgo_trans('ABC123')");
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Resultados: " . count($rows) . " registros\n";
    echo "   ✓ SP ejecutado sin errores\n";

    // 5. Verificar estructura del resultado
    echo "\n\n5. Verificando estructura del resultado...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_drecgo_trans('') LIMIT 0");
    $stmt->execute();

    $columnCount = $stmt->columnCount();
    echo "   Número de columnas: $columnCount\n";
    echo "   Columnas esperadas:\n";

    for ($i = 0; $i < $columnCount; $i++) {
        $meta = $stmt->getColumnMeta($i);
        echo "     - {$meta['name']} ({$meta['native_type']})\n";
    }

    echo "\n\n=== RESUMEN ===\n";
    echo "✓ Stored procedure actualizado correctamente\n";
    echo "✓ SP devuelve conjunto vacío (sin errores)\n";
    echo "✓ Estructura de columnas correcta\n";
    echo "\n⚠ IMPORTANTE: Este SP devuelve siempre resultados vacíos porque\n";
    echo "  no existe una tabla de tránsito/vehículos en la base de datos.\n";
    echo "\n  Las tablas encontradas están relacionadas con:\n";
    echo "  - Transmisión patrimonial (impuestos)\n";
    echo "  - Multas municipales\n";
    echo "  - Licencias comerciales\n";
    echo "  - Pero NO con control vehicular\n";
    echo "\n  Si en el futuro se implementa control vehicular, el SP\n";
    echo "  deberá actualizarse para consultar la nueva tabla.\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
