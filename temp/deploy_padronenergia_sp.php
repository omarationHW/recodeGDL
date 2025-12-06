<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "=================================================\n";
    echo "DESPLEGANDO SP DE PADRON ENERGIA\n";
    echo "=================================================\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/RptPadronEnergia_rpt_padron_energia_FINAL.sql';
    $sql = file_get_contents($sqlFile);

    // Limpiar comandos de conexión de psql
    $sql = preg_replace('/\\\\c\s+\w+;?/', '', $sql);

    echo "Ejecutando script SQL...\n\n";

    // Ejecutar el script
    $pdo->exec($sql);

    echo "✓ Script ejecutado exitosamente\n\n";

    // Verificar que el SP fue creado
    echo "Verificando SP creado:\n";

    $stmt = $pdo->prepare("
        SELECT routine_name, routine_type
        FROM information_schema.routines
        WHERE routine_schema = 'public'
        AND routine_name = 'rpt_padron_energia'
    ");
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "  ✓ rpt_padron_energia: {$result['routine_type']}\n";
    } else {
        echo "  ✗ rpt_padron_energia: NO ENCONTRADO\n";
    }

    echo "\n=================================================\n";
    echo "DESPLIEGUE COMPLETADO\n";
    echo "=================================================\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
