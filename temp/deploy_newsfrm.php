<?php
/**
 * Script para desplegar el stored procedure recaudadora_newsfrm
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

    echo "=== DESPLEGANDO STORED PROCEDURE: recaudadora_newsfrm ===\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_newsfrm.sql';

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
            d.description AS descripcion
        FROM pg_proc p
        LEFT JOIN pg_description d ON p.oid = d.objoid
        WHERE p.proname = 'recaudadora_newsfrm'
        AND p.pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'comun')
    ";

    $stmt = $pdo->query($checkSql);
    $sp = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp) {
        echo "✓ SP encontrado en la base de datos\n";
        echo "  Nombre: {$sp['nombre']}\n";
        echo "  Argumentos: {$sp['argumentos']}\n";
        echo "  Descripción: {$sp['descripcion']}\n\n";
    } else {
        throw new Exception("El SP no se encontró después del despliegue");
    }

    // Probar el SP con ejemplos
    echo "=== PROBANDO SP CON EJEMPLOS ===\n\n";

    // EJEMPLO 1: Sin filtro (multas más recientes)
    echo "EJEMPLO 1: Multas más recientes (sin filtro)\n";
    echo "==============================================\n";
    $testSql1 = "SELECT * FROM comun.recaudadora_newsfrm('', 0, 10)";
    $stmt1 = $pdo->query($testSql1);
    $results1 = $stmt1->fetchAll(PDO::FETCH_ASSOC);

    if (count($results1) > 0) {
        $total = $results1[0]['total_registros'];
        echo "Total de multas en el sistema (1990-2030): $total\n";
        echo "Primeras 10 multas más recientes:\n\n";

        foreach (array_slice($results1, 0, 3) as $i => $row) {
            $num = $i + 1;
            echo "  $num. Folio: {$row['folio']}, Año: {$row['anio']}, Fecha: {$row['fecha_acta']}\n";
            echo "     Contribuyente: {$row['contribuyente']}\n";
            echo "     Total: \${$row['total']}, Estatus: {$row['estatus']}\n\n";
        }
    }

    // EJEMPLO 2: Búsqueda por nombre "GARCIA"
    echo "\n\nEJEMPLO 2: Búsqueda por nombre 'GARCIA'\n";
    echo "=========================================\n";
    $testSql2 = "SELECT * FROM comun.recaudadora_newsfrm('GARCIA', 0, 10)";
    $stmt2 = $pdo->query($testSql2);
    $results2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    if (count($results2) > 0) {
        $total = $results2[0]['total_registros'];
        echo "Total de multas con 'GARCIA': $total\n";
        echo "Primeras 10 multas:\n\n";

        foreach (array_slice($results2, 0, 3) as $i => $row) {
            $num = $i + 1;
            echo "  $num. Folio: {$row['folio']}, Año: {$row['anio']}\n";
            echo "     Contribuyente: {$row['contribuyente']}\n";
            echo "     Total: \${$row['total']}, Estatus: {$row['estatus']}\n\n";
        }
    }

    // EJEMPLO 3: Búsqueda por año "2024"
    echo "\n\nEJEMPLO 3: Búsqueda por año '2024'\n";
    echo "===================================\n";
    $testSql3 = "SELECT * FROM comun.recaudadora_newsfrm('2024', 0, 10)";
    $stmt3 = $pdo->query($testSql3);
    $results3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    if (count($results3) > 0) {
        $total = $results3[0]['total_registros'];
        echo "Total de multas del año 2024: $total\n";
        echo "Primeras 10 multas:\n\n";

        foreach (array_slice($results3, 0, 3) as $i => $row) {
            $num = $i + 1;
            echo "  $num. Folio: {$row['folio']}, Fecha: {$row['fecha_acta']}\n";
            echo "     Contribuyente: {$row['contribuyente']}\n";
            echo "     Total: \${$row['total']}, Estatus: {$row['estatus']}\n\n";
        }
    }

    // Probar paginación
    echo "\n\n=== PROBANDO PAGINACIÓN ===\n\n";

    echo "Página 1 (offset=0, limit=10):\n";
    $page1 = $results1; // Ya tenemos página 1 del ejemplo 1
    echo "  Registros devueltos: " . count($page1) . "\n";
    if (count($page1) > 0) {
        echo "  Total registros: {$page1[0]['total_registros']}\n";
        echo "  Primera multa: Folio {$page1[0]['folio']}, Año {$page1[0]['anio']}\n";
    }

    echo "\nPágina 2 (offset=10, limit=10):\n";
    $testSqlPage2 = "SELECT * FROM comun.recaudadora_newsfrm('', 10, 10)";
    $stmtPage2 = $pdo->query($testSqlPage2);
    $page2 = $stmtPage2->fetchAll(PDO::FETCH_ASSOC);
    echo "  Registros devueltos: " . count($page2) . "\n";
    if (count($page2) > 0) {
        echo "  Primera multa: Folio {$page2[0]['folio']}, Año {$page2[0]['anio']}\n";
    }

    echo "\n=== DESPLIEGUE COMPLETADO EXITOSAMENTE ===\n";

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
    exit(1);
}
