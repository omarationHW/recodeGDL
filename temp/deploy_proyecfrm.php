<?php
// Desplegar Stored Procedure: recaudadora_proyecfrm
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLEGANDO SP: recaudadora_proyecfrm ===\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/recaudadora_proyecfrm.sql';
    if (!file_exists($sqlFile)) {
        die("Error: No se encontró el archivo $sqlFile\n");
    }

    $sql = file_get_contents($sqlFile);

    // Ejecutar el SQL
    $pdo->exec($sql);

    echo "✅ Stored Procedure 'recaudadora_proyecfrm' desplegado exitosamente\n\n";

    // Verificar que se creó correctamente
    $checkSql = "
        SELECT p.proname, pg_get_function_arguments(p.oid) as arguments
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'recaudadora_proyecfrm'
        AND n.nspname = 'public'
    ";

    $stmt = $pdo->query($checkSql);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "✅ Verificación exitosa:\n";
        echo "   Función: {$result['proname']}\n";
        echo "   Argumentos: {$result['arguments']}\n\n";
    } else {
        echo "❌ No se pudo verificar la creación del SP\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
