<?php
/**
 * Script para desplegar el stored procedure recaudadora_multasfrm
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

    echo "=== DESPLEGANDO STORED PROCEDURE: recaudadora_multasfrm ===\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_multasfrm.sql';

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
        WHERE p.proname = 'recaudadora_multasfrm'
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

    // Probar el SP con datos de prueba
    echo "=== PROBANDO SP Y OBTENIENDO EJEMPLOS ===\n\n";

    // Prueba 1: Búsqueda por nombre "GARCIA"
    echo "EJEMPLO 1: Búsqueda por nombre 'GARCIA'\n";
    echo "==========================================\n";
    $testSql1 = "SELECT * FROM comun.recaudadora_multasfrm('GARCIA') LIMIT 3";
    $stmt1 = $pdo->query($testSql1);
    $results1 = $stmt1->fetchAll(PDO::FETCH_ASSOC);

    if (count($results1) > 0) {
        foreach ($results1 as $i => $row) {
            $num = $i + 1;
            echo "\nRegistro $num:\n";
            echo "  ID Multa: {$row['id_multa']}\n";
            echo "  Folio: {$row['folio']}\n";
            echo "  Año: {$row['anio']}\n";
            echo "  Fecha: {$row['fecha_acta']}\n";
            echo "  Contribuyente: {$row['contribuyente']}\n";
            echo "  Domicilio: {$row['domicilio']}\n";
            echo "  Giro: {$row['giro']}\n";
            echo "  Licencia: {$row['licencia']}\n";
            echo "  Total: \${$row['total']}\n";
            echo "  Estatus: {$row['estatus']}\n";
        }
    }

    // Prueba 2: Búsqueda por folio "711"
    echo "\n\nEJEMPLO 2: Búsqueda por folio '711'\n";
    echo "====================================\n";
    $testSql2 = "SELECT * FROM comun.recaudadora_multasfrm('711') LIMIT 3";
    $stmt2 = $pdo->query($testSql2);
    $results2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    if (count($results2) > 0) {
        foreach ($results2 as $i => $row) {
            $num = $i + 1;
            echo "\nRegistro $num:\n";
            echo "  ID Multa: {$row['id_multa']}\n";
            echo "  Folio: {$row['folio']}\n";
            echo "  Año: {$row['anio']}\n";
            echo "  Fecha: {$row['fecha_acta']}\n";
            echo "  Contribuyente: {$row['contribuyente']}\n";
            echo "  Domicilio: {$row['domicilio']}\n";
            echo "  Giro: {$row['giro']}\n";
            echo "  Total: \${$row['total']}\n";
            echo "  Estatus: {$row['estatus']}\n";
        }
    }

    // Prueba 3: Búsqueda por giro "VENTA"
    echo "\n\nEJEMPLO 3: Búsqueda por giro 'VENTA'\n";
    echo "=====================================\n";
    $testSql3 = "SELECT * FROM comun.recaudadora_multasfrm('VENTA') LIMIT 3";
    $stmt3 = $pdo->query($testSql3);
    $results3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    if (count($results3) > 0) {
        foreach ($results3 as $i => $row) {
            $num = $i + 1;
            echo "\nRegistro $num:\n";
            echo "  ID Multa: {$row['id_multa']}\n";
            echo "  Folio: {$row['folio']}\n";
            echo "  Año: {$row['anio']}\n";
            echo "  Fecha: {$row['fecha_acta']}\n";
            echo "  Contribuyente: {$row['contribuyente']}\n";
            echo "  Domicilio: {$row['domicilio']}\n";
            echo "  Giro: {$row['giro']}\n";
            echo "  Total: \${$row['total']}\n";
            echo "  Estatus: {$row['estatus']}\n";
        }
    }

    // Prueba 4: Sin filtro (primeros 5 registros)
    echo "\n\nPrueba 4: Sin filtro (primeros 5 registros más recientes)\n";
    echo "==========================================================\n";
    $testSql4 = "SELECT * FROM comun.recaudadora_multasfrm('') LIMIT 5";
    $stmt4 = $pdo->query($testSql4);
    $results4 = $stmt4->fetchAll(PDO::FETCH_ASSOC);

    echo "Total de registros devueltos: " . count($results4) . "\n";
    if (count($results4) > 0) {
        echo "\nPrimeros 3 registros:\n";
        foreach (array_slice($results4, 0, 3) as $row) {
            echo "  - ID: {$row['id_multa']}, Folio: {$row['folio']}, Año: {$row['anio']}, Contrib: {$row['contribuyente']}, Total: \${$row['total']}\n";
        }
    }

    echo "\n=== DESPLIEGUE COMPLETADO EXITOSAMENTE ===\n";

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
    exit(1);
}
