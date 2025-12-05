<?php
/**
 * Script para desplegar el stored procedure recaudadora_multas_dm
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "=== DESPLEGANDO STORED PROCEDURE: recaudadora_multas_dm ===\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_multas_dm.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("Archivo SQL no encontrado: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    echo "Ejecutando SQL...\n";
    $pdo->exec($sql);

    echo "✓ Stored Procedure desplegado exitosamente!\n\n";

    // Verificar que el SP existe
    echo "=== VERIFICANDO SP ===\n";
    $checkSql = "
        SELECT
            p.proname AS nombre,
            pg_get_function_arguments(p.oid) AS argumentos,
            pg_get_function_result(p.oid) AS retorno,
            d.description AS descripcion
        FROM pg_proc p
        LEFT JOIN pg_description d ON p.oid = d.objoid
        WHERE p.proname = 'recaudadora_multas_dm'
        AND p.pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'comun')
    ";

    $stmt = $pdo->query($checkSql);
    $sp = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp) {
        echo "✓ SP encontrado en la base de datos\n";
        echo "  Nombre: {$sp['nombre']}\n";
        echo "  Argumentos: {$sp['argumentos']}\n";
        echo "  Retorno: {$sp['retorno']}\n";
        echo "  Descripción: {$sp['descripcion']}\n\n";
    } else {
        throw new Exception("El SP no se encontró después del despliegue");
    }

    // Probar el SP con datos de prueba
    echo "=== PROBANDO SP ===\n\n";

    // Prueba 1: Sin filtros (primeros 10 registros)
    echo "Prueba 1: Sin filtros (primeros 10 registros)\n";
    $testSql = "SELECT * FROM comun.recaudadora_multas_dm('', 0, 0, 10)";
    $stmt = $pdo->query($testSql);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Total de registros encontrados: " . (count($results) > 0 ? $results[0]['total_registros'] : 0) . "\n";
    echo "Registros devueltos: " . count($results) . "\n";

    if (count($results) > 0) {
        echo "\nPrimeros 3 registros:\n";
        foreach (array_slice($results, 0, 3) as $row) {
            echo "  - Cuenta: {$row['clave_cuenta']}, Folio: {$row['folio']}, Ejercicio: {$row['ejercicio']}, Importe: \${$row['importe']}, Estatus: {$row['estatus']}\n";
        }
    }

    // Prueba 2: Filtro por ejercicio
    echo "\n\nPrueba 2: Filtro por ejercicio 1992\n";
    $testSql2 = "SELECT * FROM comun.recaudadora_multas_dm('', 1992, 0, 10)";
    $stmt2 = $pdo->query($testSql2);
    $results2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    echo "Total de registros encontrados: " . (count($results2) > 0 ? $results2[0]['total_registros'] : 0) . "\n";
    echo "Registros devueltos: " . count($results2) . "\n";

    if (count($results2) > 0) {
        echo "\nPrimeros 3 registros:\n";
        foreach (array_slice($results2, 0, 3) as $row) {
            echo "  - Cuenta: {$row['clave_cuenta']}, Folio: {$row['folio']}, Ejercicio: {$row['ejercicio']}, Importe: \${$row['importe']}, Estatus: {$row['estatus']}\n";
        }
    }

    // Prueba 3: Filtro por cuenta (buscar una cuenta que exista)
    echo "\n\nPrueba 3: Filtro por cuenta '3647829' (del ejemplo visto)\n";
    $testSql3 = "SELECT * FROM comun.recaudadora_multas_dm('3647829', 0, 0, 10)";
    $stmt3 = $pdo->query($testSql3);
    $results3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    echo "Total de registros encontrados: " . (count($results3) > 0 ? $results3[0]['total_registros'] : 0) . "\n";
    echo "Registros devueltos: " . count($results3) . "\n";

    if (count($results3) > 0) {
        echo "\nRegistros encontrados:\n";
        foreach ($results3 as $row) {
            echo "  - Cuenta: {$row['clave_cuenta']}, Folio: {$row['folio']}, Ejercicio: {$row['ejercicio']}, Importe: \${$row['importe']}, Estatus: {$row['estatus']}\n";
        }
    }

    echo "\n=== DESPLIEGUE COMPLETADO EXITOSAMENTE ===\n";

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
    exit(1);
}
