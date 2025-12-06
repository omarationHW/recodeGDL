<?php
/**
 * Deploy fix para sp_get_mercados_by_recaudadora
 * Elimina duplicados y crea versión correcta
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    // Conectar a PostgreSQL
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "✓ Conectado a PostgreSQL\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/fix_sp_get_mercados_by_recaudadora.sql';
    $sql = file_get_contents($sqlFile);

    if ($sql === false) {
        throw new Exception("No se pudo leer el archivo: $sqlFile");
    }

    echo "✓ Archivo SQL leído\n";
    echo "\n--- Desplegando corrección ---\n\n";

    // Ejecutar el script completo
    $pdo->exec($sql);

    echo "✓ Script ejecutado exitosamente\n\n";

    // Verificar que solo existe una versión del SP
    $checkQuery = "
        SELECT
            p.proname AS function_name,
            pg_catalog.pg_get_function_arguments(p.oid) AS arguments,
            pg_catalog.pg_get_function_result(p.oid) AS return_type
        FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE p.proname = 'sp_get_mercados_by_recaudadora'
        ORDER BY p.proname, arguments;
    ";

    $stmt = $pdo->query($checkQuery);
    $functions = $stmt->fetchAll();

    echo "--- Versiones del SP en la base de datos ---\n";
    echo "Total encontrado: " . count($functions) . "\n\n";

    foreach ($functions as $func) {
        echo "Función: {$func['function_name']}\n";
        echo "Parámetros: {$func['arguments']}\n";
        echo "Retorno: {$func['return_type']}\n";
        echo "---\n";
    }

    if (count($functions) === 1) {
        echo "\n✅ ÉXITO: Solo existe UNA versión del SP\n";
        echo "El problema de ambigüedad ha sido resuelto\n";
    } else {
        echo "\n⚠️  ADVERTENCIA: Aún existen " . count($functions) . " versiones\n";
    }

} catch (PDOException $e) {
    echo "❌ Error de base de datos: " . $e->getMessage() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

echo "\n✓ Despliegue completado\n";
