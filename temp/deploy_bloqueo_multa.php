<?php
/**
 * Script para desplegar y probar el SP recaudadora_bloqueo_multa
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Desplegando SP recaudadora_bloqueo_multa ===\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_bloqueo_multa.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("No se encontró el archivo SQL: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);
    echo "Ejecutando SQL...\n";
    $pdo->exec($sql);
    echo "✅ SP desplegado correctamente\n\n";

    // Verificar que se creó
    $verify = "
        SELECT
            n.nspname as schema,
            p.proname as sp_name,
            pg_get_function_arguments(p.oid) as arguments
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'recaudadora_bloqueo_multa';
    ";

    $stmt = $pdo->query($verify);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "=== Verificación ===\n";
        echo "Schema: {$result['schema']}\n";
        echo "SP Name: {$result['sp_name']}\n";
        echo "Arguments: {$result['arguments']}\n";
        echo "\n✅ El SP existe en la base de datos\n";
    }

    // Probar el SP
    echo "\n" . str_repeat("=", 80) . "\n";
    echo "=== Probando SP ===\n\n";

    // Obtener año actual
    $anio = date('Y');

    echo "Probando con ejercicio: $anio\n";
    echo "Probando con cuenta vacía (para obtener todos)\n\n";

    $stmt = $pdo->prepare("SELECT * FROM recaudadora_bloqueo_multa('', :ejercicio, 0, 5)");
    $stmt->execute(['ejercicio' => $anio]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "✅ SP ejecutado correctamente\n";
    echo "Resultados: " . count($results) . " registros\n\n";

    if (count($results) > 0) {
        echo "Primeros registros:\n";
        echo str_repeat("-", 80) . "\n";
        foreach (array_slice($results, 0, 2) as $idx => $row) {
            echo "\nRegistro " . ($idx + 1) . ":\n";
            foreach ($row as $key => $value) {
                $value = trim($value ?? '');
                if ($value !== '') {
                    echo "  $key: $value\n";
                }
            }
        }
    } else {
        echo "No se encontraron registros para el ejercicio $anio\n";

        // Intentar con años anteriores
        echo "\nBuscando en años anteriores...\n";
        for ($i = 1; $i <= 5; $i++) {
            $anioAnterior = $anio - $i;
            $stmt2 = $pdo->prepare("SELECT COUNT(*) as count FROM catastro_gdl.reqmultas WHERE axoreq = :anio");
            $stmt2->execute(['anio' => $anioAnterior]);
            $count = $stmt2->fetch(PDO::FETCH_ASSOC)['count'];
            echo "  Año $anioAnterior: $count registros\n";

            if ($count > 0) {
                echo "\nProbando con año $anioAnterior:\n";
                $stmt3 = $pdo->prepare("SELECT * FROM recaudadora_bloqueo_multa('', :ejercicio, 0, 2)");
                $stmt3->execute(['ejercicio' => $anioAnterior]);
                $results3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

                if (!empty($results3)) {
                    echo "Primer registro del año $anioAnterior:\n";
                    foreach ($results3[0] as $key => $value) {
                        $value = trim($value ?? '');
                        if ($value !== '') {
                            echo "  $key: $value\n";
                        }
                    }
                }
                break;
            }
        }
    }

} catch (PDOException $e) {
    echo "❌ Error de BD: " . $e->getMessage() . "\n";
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
