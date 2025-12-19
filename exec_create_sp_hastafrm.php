<?php
$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CREANDO STORED PROCEDURE recaudadora_hastafrm ===\n\n";

    // Leer el archivo SQL
    $sql = file_get_contents(__DIR__ . '/create_sp_recaudadora_hastafrm.sql');

    // Ejecutar el SQL
    $pdo->exec($sql);

    echo "✓ Stored Procedure creado exitosamente\n\n";

    // Verificar que se creó
    $stmt = $pdo->query("
        SELECT p.proname, pg_catalog.pg_get_function_arguments(p.oid) as args
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'publico'
        AND p.proname = 'recaudadora_hastafrm'
    ");

    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "✓ Verificación exitosa:\n";
        echo "   Nombre: " . $result['proname'] . "\n";
        echo "   Argumentos: " . $result['args'] . "\n";
    } else {
        echo "✗ No se pudo verificar la creación del SP\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
