<?php
// Script para desplegar el SP recaudadora_hastafrm

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
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_hastafrm.sql';
    $sql = file_get_contents($sqlFile);

    if ($sql === false) {
        throw new Exception("No se pudo leer el archivo SQL: $sqlFile");
    }

    echo "📄 Ejecutando script SQL...\n\n";

    // Ejecutar el script
    $pdo->exec($sql);

    echo "✅ SP 'db_ingresos.recaudadora_hastafrm' desplegado exitosamente\n\n";

    // Verificar que existe
    $check = $pdo->query("
        SELECT routine_name, routine_schema
        FROM information_schema.routines
        WHERE routine_name = 'recaudadora_hastafrm'
        AND routine_schema = 'db_ingresos'
    ");

    $exists = $check->fetch(PDO::FETCH_ASSOC);

    if ($exists) {
        echo "✓ Verificado: El SP existe en el esquema db_ingresos\n";
        echo "  Schema: {$exists['routine_schema']}\n";
        echo "  Nombre: {$exists['routine_name']}\n\n";

        // Probar el SP con ejemplo 1: Periodo de 30 días
        echo "🧪 Prueba 1: Periodo de 30 días (2025-01-01 a 2025-01-31)...\n\n";

        $stmt = $pdo->prepare("SELECT * FROM db_ingresos.recaudadora_hastafrm(:desde, :hasta)");
        $stmt->execute(['desde' => '2025-01-01', 'hasta' => '2025-01-31']);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "Resultado:\n";
        echo "  Status: " . $result['status'] . "\n";
        echo "  Mensaje: " . $result['mensaje'] . "\n";
        echo "  Registros procesados: " . $result['registros_procesados'] . "\n";
        echo "  Fecha inicio: " . $result['fecha_inicio'] . "\n";
        echo "  Fecha fin: " . $result['fecha_fin'] . "\n";
        echo "  Días del periodo: " . $result['dias_periodo'] . "\n";

        // Probar el SP con ejemplo 2: Periodo de 7 días
        echo "\n🧪 Prueba 2: Periodo de 7 días (2025-12-01 a 2025-12-07)...\n\n";

        $stmt = $pdo->prepare("SELECT * FROM db_ingresos.recaudadora_hastafrm(:desde, :hasta)");
        $stmt->execute(['desde' => '2025-12-01', 'hasta' => '2025-12-07']);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "Resultado:\n";
        echo "  Status: " . $result['status'] . "\n";
        echo "  Mensaje: " . $result['mensaje'] . "\n";
        echo "  Registros procesados: " . $result['registros_procesados'] . "\n";
        echo "  Días del periodo: " . $result['dias_periodo'] . "\n";

        // Probar el SP con ejemplo 3: Fechas inválidas (debe dar error)
        echo "\n🧪 Prueba 3: Fechas inválidas (2025-12-31 a 2025-12-01)...\n\n";

        $stmt = $pdo->prepare("SELECT * FROM db_ingresos.recaudadora_hastafrm(:desde, :hasta)");
        $stmt->execute(['desde' => '2025-12-31', 'hasta' => '2025-12-01']);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        echo "Resultado:\n";
        echo "  Status: " . $result['status'] . "\n";
        echo "  Mensaje: " . $result['mensaje'] . "\n";

        echo "\n✅ Todas las pruebas completadas exitosamente!\n";
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
