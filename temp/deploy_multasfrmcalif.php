<?php
/**
 * Script para desplegar el stored procedure recaudadora_multasfrmcalif
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

    echo "=== DESPLEGANDO STORED PROCEDURE: recaudadora_multasfrmcalif ===\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_multasfrmcalif.sql';

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
        WHERE p.proname = 'recaudadora_multasfrmcalif'
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

    // Obtener 3 cuentas de ejemplo
    echo "=== OBTENIENDO CUENTAS DE EJEMPLO ===\n\n";

    $ejemplosSql = "
        SELECT
            cvepago,
            COUNT(*) as total_multas,
            SUM(total) as suma_total
        FROM comun.multas
        WHERE cvepago IS NOT NULL
        AND cvepago > 0
        GROUP BY cvepago
        HAVING COUNT(*) >= 1
        ORDER BY COUNT(*) DESC
        LIMIT 3
    ";

    $stmt = $pdo->query($ejemplosSql);
    $cuentasEjemplo = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Cuentas de ejemplo encontradas:\n";
    foreach ($cuentasEjemplo as $i => $cuenta) {
        echo "  " . ($i + 1) . ". Cuenta: {$cuenta['cvepago']}, Multas: {$cuenta['total_multas']}, Total: \${$cuenta['suma_total']}\n";
    }

    // Probar el SP con los 3 ejemplos
    echo "\n\n=== PROBANDO SP CON EJEMPLOS ===\n\n";

    foreach ($cuentasEjemplo as $i => $cuenta) {
        $num = $i + 1;
        $claveCuenta = $cuenta['cvepago'];

        echo "EJEMPLO $num: Cuenta $claveCuenta\n";
        echo "=====================================\n";

        // Prueba con paginación (primera página)
        $testSql = "SELECT * FROM comun.recaudadora_multasfrmcalif('$claveCuenta', 0, 10)";
        $stmt = $pdo->query($testSql);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($results) > 0) {
            $totalRegistros = $results[0]['total_registros'];
            echo "Total de multas para esta cuenta: $totalRegistros\n";
            echo "Registros en primera página: " . count($results) . "\n\n";

            // Mostrar primeros 3 registros de la página
            echo "Primeros 3 registros:\n";
            foreach (array_slice($results, 0, 3) as $row) {
                echo "  - Folio: {$row['folio']}, Año: {$row['anio']}, Fecha: {$row['fecha_acta']}\n";
                echo "    Contribuyente: {$row['contribuyente']}\n";
                echo "    Calificación: \${$row['calificacion']}, Multa: \${$row['multa']}, Total: \${$row['total']}\n";
                echo "    Estatus: {$row['estatus']}\n";
                if ($row['observacion']) {
                    echo "    Observación: {$row['observacion']}\n";
                }
                echo "\n";
            }
        } else {
            echo "No se encontraron multas para esta cuenta.\n\n";
        }
    }

    // Probar paginación con la primera cuenta
    if (count($cuentasEjemplo) > 0) {
        $cuentaPaginacion = $cuentasEjemplo[0]['cvepago'];

        echo "\n=== PROBANDO PAGINACIÓN CON CUENTA: $cuentaPaginacion ===\n\n";

        // Primera página
        echo "Página 1 (offset=0, limit=10):\n";
        $testSql1 = "SELECT * FROM comun.recaudadora_multasfrmcalif('$cuentaPaginacion', 0, 10)";
        $stmt1 = $pdo->query($testSql1);
        $page1 = $stmt1->fetchAll(PDO::FETCH_ASSOC);
        echo "  Registros devueltos: " . count($page1) . "\n";
        if (count($page1) > 0) {
            echo "  Total registros: {$page1[0]['total_registros']}\n";
            echo "  Primer registro: Folio {$page1[0]['folio']}, Fecha {$page1[0]['fecha_acta']}\n";
        }

        // Segunda página
        echo "\nPágina 2 (offset=10, limit=10):\n";
        $testSql2 = "SELECT * FROM comun.recaudadora_multasfrmcalif('$cuentaPaginacion', 10, 10)";
        $stmt2 = $pdo->query($testSql2);
        $page2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);
        echo "  Registros devueltos: " . count($page2) . "\n";
        if (count($page2) > 0) {
            echo "  Primer registro: Folio {$page2[0]['folio']}, Fecha {$page2[0]['fecha_acta']}\n";
        }
    }

    echo "\n=== DESPLIEGUE COMPLETADO EXITOSAMENTE ===\n";

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
    exit(1);
}
