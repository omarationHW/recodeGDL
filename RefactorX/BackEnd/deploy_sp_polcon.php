<?php
/**
 * Script para desplegar el stored procedure recaudadora_polcon
 */

try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias",
        "refact",
        "FF)-BQk2"
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== DESPLEGANDO SP: recaudadora_polcon ===\n\n";

    $sqlFile = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_polcon.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("Archivo SQL no encontrado: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    echo "1. Ejecutando SQL...\n";
    $pdo->exec($sql);
    echo "   ✓ SQL ejecutado correctamente\n\n";

    echo "2. Verificando creación del SP...\n";
    $stmt = $pdo->query("
        SELECT proname, pronargs, pg_get_function_arguments(oid) as args
        FROM pg_proc
        WHERE proname = 'recaudadora_polcon'
        AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'db_ingresos')
    ");
    $sp = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp) {
        echo "   ✓ SP creado correctamente:\n";
        echo "     Nombre: {$sp['proname']}\n";
        echo "     Argumentos: {$sp['args']}\n\n";
    } else {
        throw new Exception("El SP no fue creado");
    }

    echo "3. Probando el SP con rango de fechas 2012-01-01 a 2012-12-31...\n";
    $stmt = $pdo->prepare("SELECT * FROM db_ingresos.recaudadora_polcon(:fecha_desde, :fecha_hasta)");
    $stmt->execute([
        'fecha_desde' => '2012-01-01',
        'fecha_hasta' => '2012-12-31'
    ]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($results) {
        echo "   ✓ Consulta exitosa - " . count($results) . " registro(s) encontrado(s)\n";
        echo "\n   Primeros 5 registros:\n";
        foreach (array_slice($results, 0, 5) as $i => $row) {
            echo "\n   Registro " . ($i + 1) . ":\n";
            foreach ($row as $key => $value) {
                $val = $value ?? 'NULL';
                if (is_numeric($val) && strpos($val, '.') !== false) {
                    $val = number_format($val, 2);
                }
                echo "     $key: $val\n";
            }
        }

        echo "\n   Totales globales:\n";
        $totalPartidas = array_sum(array_column($results, 'totpar'));
        $totalSuma = array_sum(array_column($results, 'suma'));
        $totalMovimientos = array_sum(array_column($results, 'num_movimientos'));
        echo "     Total Partidas: " . number_format($totalPartidas) . "\n";
        echo "     Total Suma: $" . number_format($totalSuma, 2) . "\n";
        echo "     Total Movimientos: " . number_format($totalMovimientos) . "\n";
    } else {
        echo "   ⚠ Consulta ejecutada pero sin resultados\n";
    }

    echo "\n4. Probando con rango 2013-01-01 a 2013-12-31...\n";
    $stmt = $pdo->prepare("SELECT * FROM db_ingresos.recaudadora_polcon(:fecha_desde, :fecha_hasta)");
    $stmt->execute([
        'fecha_desde' => '2013-01-01',
        'fecha_hasta' => '2013-12-31'
    ]);
    $results2013 = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Registros encontrados: " . count($results2013) . "\n";

    if ($results2013) {
        echo "   Primer registro de ejemplo:\n";
        foreach ($results2013[0] as $key => $value) {
            $val = $value ?? 'NULL';
            if (is_numeric($val) && strpos($val, '.') !== false) {
                $val = number_format($val, 2);
            }
            echo "     $key: $val\n";
        }
    }

    echo "\n=== DESPLIEGUE COMPLETADO EXITOSAMENTE ===\n";

} catch (PDOException $e) {
    echo "\n❌ ERROR PDO: " . $e->getMessage() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "\n❌ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
