<?php
/**
 * Script para desplegar el SP sp_get_pagos_loc_grl
 */

$host = 'localhost';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'postgres';
$password = 'postgres';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "📡 Conectado a la base de datos: $dbname\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/PagosLocGrl_sp_get_pagos_loc_grl.sql';

    if (!file_exists($sqlFile)) {
        die("❌ ERROR: No se encontró el archivo SQL: $sqlFile\n");
    }

    $sql = file_get_contents($sqlFile);

    echo "📄 Archivo SQL leído correctamente\n";
    echo "📦 Desplegando sp_get_pagos_loc_grl...\n\n";

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
        echo "   - Base: padron_licencias\n\n";

        // Probar el SP con parámetros de ejemplo
        echo "🧪 Probando el SP con datos de ejemplo...\n";

        $stmt = $pdo->prepare("SELECT * FROM sp_get_pagos_loc_grl(?, ?, ?)");
        $stmt->execute([
            1, // p_mercado
            '2024-01-01', // p_fecha_desde
            '2024-12-31'  // p_fecha_hasta
        ]);

        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "   Registros encontrados: " . count($rows) . "\n";

        if (count($rows) > 0) {
            echo "\n📊 Ejemplo de primer registro:\n";
            foreach (array_slice($rows[0], 0, 5, true) as $col => $val) {
                echo "   - $col: $val\n";
            }
        }

        echo "\n✅ SP funcionando correctamente\n";
    } else {
        echo "❌ ERROR: El SP no se encontró después del despliegue\n";
    }

} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
