<?php

$host = 'localhost';
$port = '5432';
$dbname = 'prueba2';
$user = 'postgres';
$password = 'Lmolina.2024';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "✓ Conexión establecida\n\n";

    // Leer el archivo SQL
    $sqlFile = 'C:/recodeGDL/RefactorX/Base/multas_reglamentos/database/generated/recaudadora_listana.sql';

    if (!file_exists($sqlFile)) {
        die("✗ Error: No se encuentra el archivo SQL\n");
    }

    $sql = file_get_contents($sqlFile);

    echo "Desplegando SP recaudadora_listana...\n";

    // Ejecutar el SQL
    $pdo->exec($sql);

    echo "✓ SP desplegado exitosamente\n\n";

    // Verificar que el SP existe
    $stmt = $pdo->query("
        SELECT
            n.nspname as schema,
            p.proname as name,
            pg_get_function_arguments(p.oid) as arguments
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'recaudadora_listana'
        AND n.nspname = 'db_ingresos'
    ");

    $result = $stmt->fetch();

    if ($result) {
        echo "✓ SP verificado:\n";
        echo "  Schema: {$result['schema']}\n";
        echo "  Nombre: {$result['name']}\n";
        echo "  Argumentos: {$result['arguments']}\n\n";
    } else {
        echo "✗ No se pudo verificar el SP\n";
    }

    // Probar con datos reales
    echo "Probando SP con datos reales:\n";
    echo str_repeat("=", 80) . "\n\n";

    // Test 1: Sin filtro, primeros 10 registros
    echo "TEST 1: Sin filtro (primeros 10 registros)\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $pdo->query("SELECT * FROM db_ingresos.recaudadora_listana('', 0, 10)");
    $rows = $stmt->fetchAll();

    if (count($rows) > 0) {
        echo "Total count: " . $rows[0]['total_count'] . "\n";
        echo "Registros obtenidos: " . count($rows) . "\n\n";

        foreach (array_slice($rows, 0, 3) as $i => $row) {
            echo "Registro " . ($i + 1) . ":\n";
            echo "  Folio: {$row['folio']}\n";
            echo "  Fecha: {$row['fecha_acta']}\n";
            echo "  Contribuyente: {$row['contribuyente']}\n";
            echo "  Domicilio: {$row['domicilio']}\n";
            echo "  Dependencia: {$row['dependencia']}\n";
            echo "  Zona/Subzona: {$row['zona_subzona']}\n";
            echo "  Calificación: $" . number_format($row['calificacion'], 2) . "\n";
            echo "  Multa: $" . number_format($row['multa'], 2) . "\n";
            echo "  Gastos: $" . number_format($row['gastos'], 2) . "\n";
            echo "  Total: $" . number_format($row['total'], 2) . "\n";
            echo "  Tipo: {$row['tipo']}\n";
            echo "  Estado: {$row['estado']}\n";
            echo "\n";
        }
    } else {
        echo "✗ No se encontraron registros\n";
    }

    echo "\n" . str_repeat("=", 80) . "\n\n";

    // Test 2: Con filtro por año
    echo "TEST 2: Filtro por año '2024'\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $pdo->query("SELECT * FROM db_ingresos.recaudadora_listana('2024', 0, 5)");
    $rows = $stmt->fetchAll();

    if (count($rows) > 0) {
        echo "Total count: " . $rows[0]['total_count'] . "\n";
        echo "Registros obtenidos: " . count($rows) . "\n\n";

        foreach ($rows as $i => $row) {
            echo "Registro " . ($i + 1) . ":\n";
            echo "  Folio: {$row['folio']}\n";
            echo "  Contribuyente: {$row['contribuyente']}\n";
            echo "  Total: $" . number_format($row['total'], 2) . "\n";
            echo "  Estado: {$row['estado']}\n";
            echo "\n";
        }
    } else {
        echo "✗ No se encontraron registros con ese filtro\n";
    }

    echo "\n" . str_repeat("=", 80) . "\n\n";

    // Test 3: Buscar por nombre
    echo "TEST 3: Buscar en contribuyente\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $pdo->query("SELECT * FROM db_ingresos.recaudadora_listana('MARIA', 0, 5)");
    $rows = $stmt->fetchAll();

    if (count($rows) > 0) {
        echo "Total count: " . $rows[0]['total_count'] . "\n";
        echo "Registros obtenidos: " . count($rows) . "\n\n";

        foreach ($rows as $i => $row) {
            echo "Registro " . ($i + 1) . ":\n";
            echo "  Folio: {$row['folio']}\n";
            echo "  Contribuyente: {$row['contribuyente']}\n";
            echo "  Dependencia: {$row['dependencia']}\n";
            echo "  Total: $" . number_format($row['total'], 2) . "\n";
            echo "  Estado: {$row['estado']}\n";
            echo "\n";
        }
    } else {
        echo "✗ No se encontraron registros con ese filtro\n";
    }

    echo "\n✅ Despliegue y pruebas completadas exitosamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
