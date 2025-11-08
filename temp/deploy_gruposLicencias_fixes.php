<?php
// Script para desplegar correcciones de gruposLicencias SPs
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'postgres';
$password = 'Obelisco6146#';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "✓ Conectado a PostgreSQL\n\n";

    $sql = file_get_contents(__DIR__ . '/fix_gruposLicencias_all_issues.sql');

    $pdo->exec($sql);

    echo "✓ Stored Procedures corregidos exitosamente\n\n";

    // Verificar que funcionan
    echo "Verificando SPs:\n";

    $tests = [
        "SELECT * FROM get_grupos_licencias(NULL) LIMIT 1",
        "SELECT * FROM get_giros() LIMIT 1",
    ];

    foreach ($tests as $test) {
        $stmt = $pdo->query($test);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "  ✓ " . substr($test, 0, 50) . "... OK\n";
    }

    echo "\n✓ Todos los SPs están funcionando correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
