<?php
// Script para desplegar el SP recaudadora_gastos_transmision

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
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_gastos_transmision.sql';
    $sql = file_get_contents($sqlFile);

    if ($sql === false) {
        throw new Exception("No se pudo leer el archivo SQL: $sqlFile");
    }

    echo "📄 Ejecutando script SQL...\n\n";

    // Ejecutar el script
    $pdo->exec($sql);

    echo "✅ SP 'db_ingresos.recaudadora_gastos_transmision' desplegado exitosamente\n\n";

    // Verificar que existe
    $check = $pdo->query("
        SELECT routine_name, routine_schema
        FROM information_schema.routines
        WHERE routine_name = 'recaudadora_gastos_transmision'
        AND routine_schema = 'db_ingresos'
    ");

    $exists = $check->fetch(PDO::FETCH_ASSOC);

    if ($exists) {
        echo "✓ Verificado: El SP existe en el esquema db_ingresos\n";
        echo "  Schema: {$exists['routine_schema']}\n";
        echo "  Nombre: {$exists['routine_name']}\n\n";

        // Probar el SP con ejemplo 1: Sin filtros
        echo "🧪 Prueba 1: Búsqueda sin filtros (todas las cuentas, año 2025)...\n\n";

        $stmt = $pdo->prepare("SELECT * FROM db_ingresos.recaudadora_gastos_transmision(:cuenta, :ejercicio)");
        $stmt->execute(['cuenta' => '', 'ejercicio' => 2025]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "Registros encontrados: " . count($results) . "\n";
        if (count($results) > 0) {
            echo "Primer registro:\n";
            echo "  Cuenta: " . $results[0]['clave_cuenta'] . "\n";
            echo "  Concepto: " . $results[0]['concepto'] . "\n";
            echo "  Importe: $" . number_format($results[0]['importe'], 2) . "\n";
            echo "  Fecha: " . $results[0]['fecha'] . "\n";
        }

        echo "\n🧪 Prueba 2: Búsqueda con cuenta específica (TRANS-1234, año 2024)...\n\n";

        $stmt = $pdo->prepare("SELECT * FROM db_ingresos.recaudadora_gastos_transmision(:cuenta, :ejercicio)");
        $stmt->execute(['cuenta' => 'TRANS-1234', 'ejercicio' => 2024]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "Registros encontrados: " . count($results) . "\n";
        if (count($results) > 0) {
            echo "Desglose de gastos:\n";
            foreach ($results as $row) {
                echo "  - {$row['concepto']}: $" . number_format($row['importe'], 2) . " ({$row['fecha']})\n";
            }
        }

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
