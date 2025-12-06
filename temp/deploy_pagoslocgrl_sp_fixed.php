<?php
/**
 * Script para desplegar el SP sp_get_pagos_loc_grl
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "📡 Conectado a la base de datos: $dbname @ $host\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/PagosLocGrl_sp_get_pagos_loc_grl.sql';

    if (!file_exists($sqlFile)) {
        die("❌ ERROR: No se encontró el archivo SQL: $sqlFile\n");
    }

    $sql = file_get_contents($sqlFile);

    echo "📄 Archivo SQL leído correctamente\n";
    echo "📦 Desplegando sp_get_pagos_loc_grl en base 'mercados'...\n\n";

    // Ejecutar el SQL
    $pdo->exec($sql);

    echo "✅ SP desplegado exitosamente\n\n";

    // Verificar que el SP existe
    $check = $pdo->query("
        SELECT routine_name, routine_type
        FROM information_schema.routines
        WHERE routine_schema = 'public'
          AND routine_name = 'sp_get_pagos_loc_grl'
    ");

    $result = $check->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "✅ Verificación exitosa:\n";
        echo "   - Nombre: {$result['routine_name']}\n";
        echo "   - Tipo: {$result['routine_type']}\n";
        echo "   - Esquema: public\n";
        echo "   - Base: mercados\n\n";

        // Probar el SP con parámetros de ejemplo
        echo "🧪 Probando el SP con datos de ejemplo...\n";
        echo "   Parámetros: mercado=1, desde=2024-01-01, hasta=2024-12-31\n\n";

        $stmt = $pdo->prepare("SELECT * FROM sp_get_pagos_loc_grl(?, ?, ?)");
        $stmt->execute([
            1, // p_mercado
            '2024-01-01', // p_fecha_desde
            '2024-12-31'  // p_fecha_hasta
        ]);

        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "   ✅ Registros encontrados: " . count($rows) . "\n";

        if (count($rows) > 0) {
            echo "\n📊 Ejemplo de primer registro:\n";
            $first = $rows[0];
            echo "   - Mercado: {$first['num_mercado']}\n";
            echo "   - Sección: {$first['seccion']}\n";
            echo "   - Local: {$first['local']}\n";
            echo "   - Fecha Pago: {$first['fecha_pago']}\n";
            echo "   - Importe: {$first['importe_pago']}\n";
        }

        echo "\n✅ SP funcionando correctamente\n";
    } else {
        echo "❌ ERROR: El SP no se encontró después del despliegue\n";
    }

} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
