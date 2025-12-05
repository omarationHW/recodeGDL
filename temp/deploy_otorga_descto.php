<?php
/**
 * Script para desplegar el stored procedure recaudadora_otorga_descto
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

    echo "=== DESPLEGANDO STORED PROCEDURE: recaudadora_otorga_descto ===\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_otorga_descto.sql';

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
        WHERE p.proname = 'recaudadora_otorga_descto'
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

    // Probar el SP con los 3 ejemplos
    echo "=== PROBANDO SP CON EJEMPLOS ===\n\n";

    // EJEMPLO 1: Cuenta 7569004, Año 2013 (9 descuentos)
    echo "EJEMPLO 1: Cuenta 7569004, Año 2013\n";
    echo "====================================\n";
    $testSql1 = "SELECT * FROM comun.recaudadora_otorga_descto('7569004', 2013, 0, 10)";
    $stmt1 = $pdo->query($testSql1);
    $results1 = $stmt1->fetchAll(PDO::FETCH_ASSOC);

    if (count($results1) > 0) {
        $total = $results1[0]['total_registros'];
        echo "Total de descuentos: $total\n";
        echo "Primeros 10 descuentos:\n\n";

        foreach (array_slice($results1, 0, 3) as $i => $row) {
            $num = $i + 1;
            echo "  $num. Folio: {$row['folio']}, Año: {$row['anio']}\n";
            echo "     Contribuyente: {$row['contribuyente']}\n";
            echo "     Monto Multa: \${$row['monto_multa']}\n";
            echo "     Descuento: {$row['porcentaje_descto']}% = \${$row['importe_descto']}\n";
            echo "     Estado: {$row['estado']}\n\n";
        }
    } else {
        echo "  No se encontraron descuentos\n";
    }

    // EJEMPLO 2: Cuenta 9252925, Año 2015 (4 descuentos)
    echo "\n\nEJEMPLO 2: Cuenta 9252925, Año 2015\n";
    echo "====================================\n";
    $testSql2 = "SELECT * FROM comun.recaudadora_otorga_descto('9252925', 2015, 0, 10)";
    $stmt2 = $pdo->query($testSql2);
    $results2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    if (count($results2) > 0) {
        $total = $results2[0]['total_registros'];
        echo "Total de descuentos: $total\n";
        echo "Descuentos encontrados:\n\n";

        foreach ($results2 as $i => $row) {
            $num = $i + 1;
            echo "  $num. Folio: {$row['folio']}, Año: {$row['anio']}\n";
            echo "     Contribuyente: {$row['contribuyente']}\n";
            echo "     Monto Multa: \${$row['monto_multa']}\n";
            echo "     Descuento: {$row['porcentaje_descto']}% = \${$row['importe_descto']}\n";
            echo "     Estado: {$row['estado']}\n\n";
        }
    } else {
        echo "  No se encontraron descuentos\n";
    }

    // EJEMPLO 3: Cuenta 7617361, Año 2013 (2 descuentos)
    echo "\n\nEJEMPLO 3: Cuenta 7617361, Año 2013\n";
    echo "====================================\n";
    $testSql3 = "SELECT * FROM comun.recaudadora_otorga_descto('7617361', 2013, 0, 10)";
    $stmt3 = $pdo->query($testSql3);
    $results3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    if (count($results3) > 0) {
        $total = $results3[0]['total_registros'];
        echo "Total de descuentos: $total\n";
        echo "Descuentos encontrados:\n\n";

        foreach ($results3 as $i => $row) {
            $num = $i + 1;
            echo "  $num. Folio: {$row['folio']}, Año: {$row['anio']}\n";
            echo "     Contribuyente: {$row['contribuyente']}\n";
            echo "     Monto Multa: \${$row['monto_multa']}\n";
            echo "     Descuento: {$row['porcentaje_descto']}% = \${$row['importe_descto']}\n";
            echo "     Estado: {$row['estado']}\n\n";
        }
    } else {
        echo "  No se encontraron descuentos\n";
    }

    // Probar paginación
    echo "\n\n=== PROBANDO PAGINACIÓN ===\n\n";

    echo "Página 1 del Ejemplo 1 (offset=0, limit=10):\n";
    echo "  Registros devueltos: " . count($results1) . "\n";
    if (count($results1) > 0) {
        echo "  Total registros: {$results1[0]['total_registros']}\n";
        echo "  Primer descuento: Folio {$results1[0]['folio']}, Año {$results1[0]['anio']}\n";
    }

    echo "\n=== DESPLIEGUE COMPLETADO EXITOSAMENTE ===\n";

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
    exit(1);
}
