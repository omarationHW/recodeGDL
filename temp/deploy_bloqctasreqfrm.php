<?php
/**
 * Script para desplegar el SP recaudadora_bloqctasreqfrm en la base de datos
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Desplegando SP recaudadora_bloqctasreqfrm ===\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/multas_reglamentos/database/generated/recaudadora_bloqctasreqfrm.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("No se encontró el archivo SQL: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    echo "Ejecutando SQL...\n";
    echo str_repeat("-", 80) . "\n";

    // Ejecutar el SQL
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
        WHERE p.proname = 'recaudadora_bloqctasreqfrm';
    ";

    $stmt = $pdo->query($verify);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "=== Verificación ===\n";
        echo "Schema: {$result['schema']}\n";
        echo "SP Name: {$result['sp_name']}\n";
        echo "Arguments: {$result['arguments']}\n";
        echo "\n✅ El SP existe en la base de datos\n";
    } else {
        echo "❌ El SP no se encontró después del despliegue\n";
    }

    // Probar el SP con una cuenta de ejemplo
    echo "\n" . str_repeat("=", 80) . "\n";
    echo "=== Probando SP con cuenta de ejemplo ===\n\n";

    // Obtener una cuenta que tenga bloqueos
    $sql2 = "SELECT DISTINCT cvecuenta FROM catastro_gdl.norequeribles LIMIT 5";
    $stmt2 = $pdo->query($sql2);
    $cuentas = $stmt2->fetchAll(PDO::FETCH_COLUMN);

    if (!empty($cuentas)) {
        $cuenta = $cuentas[0];
        echo "Probando con cuenta: $cuenta\n";

        $stmt3 = $pdo->prepare("SELECT * FROM recaudadora_bloqctasreqfrm(:cuenta)");
        $stmt3->execute(['cuenta' => $cuenta]);
        $results = $stmt3->fetchAll(PDO::FETCH_ASSOC);

        echo "✅ SP ejecutado correctamente\n";
        echo "Resultados: " . count($results) . " registros\n";

        if (count($results) > 0) {
            echo "\nPrimer registro:\n";
            foreach ($results[0] as $key => $value) {
                $value = trim($value ?? '');
                if ($value !== '') {
                    echo "  $key: $value\n";
                }
            }
        }
    } else {
        echo "No se encontraron cuentas con bloqueos para probar\n";
    }

} catch (PDOException $e) {
    echo "❌ Error de BD: " . $e->getMessage() . "\n";
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
