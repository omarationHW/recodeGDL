<?php
// Script para desplegar el SP recaudadora_frmpol

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conectado a PostgreSQL\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_frmpol.sql';
    $sql = file_get_contents($sqlFile);

    if ($sql === false) {
        throw new Exception("No se pudo leer el archivo SQL: $sqlFile");
    }

    echo "📄 Ejecutando script SQL...\n\n";

    // Ejecutar el script
    $pdo->exec($sql);

    echo "✅ SP 'db_ingresos.recaudadora_frmpol' desplegado exitosamente\n\n";

    // Verificar que existe
    $check = $pdo->query("
        SELECT routine_name, routine_schema
        FROM information_schema.routines
        WHERE routine_name = 'recaudadora_frmpol'
        AND routine_schema = 'db_ingresos'
    ");

    $exists = $check->fetch(PDO::FETCH_ASSOC);

    if ($exists) {
        echo "✓ Verificado: El SP existe en el esquema db_ingresos\n";
        echo "  Schema: {$exists['routine_schema']}\n";
        echo "  Nombre: {$exists['routine_name']}\n\n";

        // Probar el SP con un ejemplo
        echo "🧪 Probando el SP con datos de ejemplo...\n\n";

        $testParams = json_encode([
            'fecha' => '2025-12-02',
            'recaudadora' => 'CENTRO',
            'tipo' => 'Diaria'
        ]);

        $stmt = $pdo->prepare("SELECT * FROM db_ingresos.recaudadora_frmpol(:params)");
        $stmt->execute(['params' => $testParams]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "Resultado:\n";
        echo "  Status: " . $result['status'] . "\n";
        echo "  Message: " . $result['message'] . "\n";
        echo "  Received Params: " . $result['received_params'] . "\n";
        echo "  Fecha Proceso: " . $result['fecha_proceso'] . "\n";
        echo "  Póliza Info: " . $result['poliza_info'] . "\n";
        echo "  Usuario: " . $result['user_info'] . "\n";

        echo "\n✅ Prueba exitosa!\n";
    } else {
        echo "⚠️ Advertencia: No se encontró el SP después de desplegarlo\n";
    }

} catch (PDOException $e) {
    echo "❌ Error de base de datos: " . $e->getMessage() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
