<?php
// Desplegar SP recaudadora_propuestatab
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLEGANDO SP recaudadora_propuestatab ===\n\n";

    // Leer el archivo SQL
    $sql = file_get_contents(__DIR__ . '/recaudadora_propuestatab.sql');

    if ($sql === false) {
        throw new Exception("No se pudo leer el archivo SQL");
    }

    // Ejecutar el SQL
    $pdo->exec($sql);

    echo "✓ SP creado exitosamente\n\n";

    // Verificar que el SP existe
    echo "=== VERIFICANDO SP ===\n\n";

    $checkSql = "
        SELECT
            p.proname as nombre,
            pg_get_function_arguments(p.oid) as argumentos,
            pg_get_function_result(p.oid) as retorna
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'recaudadora_propuestatab'
        AND n.nspname = 'public'
    ";

    $stmt = $pdo->query($checkSql);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "Nombre: {$result['nombre']}\n";
        echo "Argumentos: {$result['argumentos']}\n";
        echo "Retorna: {$result['retorna']}\n";
        echo "\n✓ Verificación exitosa\n";
    } else {
        echo "✗ Error: No se encontró el SP después de crearlo\n";
    }

} catch (PDOException $e) {
    echo "Error de BD: " . $e->getMessage() . "\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
