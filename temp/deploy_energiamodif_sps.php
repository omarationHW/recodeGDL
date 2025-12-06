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
    echo "DESPLEGANDO SPs DE ENERGIA MODIF\n";
    echo "=================================================\n\n";

    // Leer el archivo SQL
    $sql = file_get_contents(__DIR__ . '/EnergiaModif_SPs_corregidos.sql');

    // Limpiar comandos de conexión de psql
    $sql = preg_replace('/\\\\c\s+\w+;?/', '', $sql);

    echo "Ejecutando script SQL...\n\n";

    // Ejecutar todo el script
    $pdo->exec($sql);

    echo "✓ Script ejecutado exitosamente\n\n";

    // Verificar que los 2 SPs fueron creados
    echo "Verificando SPs creados:\n";

    $sps = [
        'sp_energia_modif_buscar',
        'sp_energia_modif_modificar'
    ];

    foreach ($sps as $sp_name) {
        $stmt = $pdo->prepare("
            SELECT routine_name, routine_type
            FROM information_schema.routines
            WHERE routine_schema = 'public'
            AND routine_name = :sp_name
        ");
        $stmt->execute([':sp_name' => $sp_name]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            echo "  ✓ $sp_name: {$result['routine_type']}\n";
        } else {
            echo "  ✗ $sp_name: NO ENCONTRADO\n";
        }
    }

    echo "\n=================================================\n";
    echo "DESPLIEGUE COMPLETADO\n";
    echo "=================================================\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
