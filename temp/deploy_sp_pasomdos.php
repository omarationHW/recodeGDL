<?php
/**
 * Script para desplegar SP de PasoMdos a padron_licencias
 */

$host = 'localhost';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'postgres';
$password = 'Gdl2024++';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conectado a $dbname\n\n";

    // Leer el archivo SQL
    $sqlFile = 'C:\guadalajara\code\recodeGDLCurrent\recodeGDL\RefactorX\Base\mercados\database\database\PasoMdos_sp_insert_tianguis_padron_corregido.sql';

    if (!file_exists($sqlFile)) {
        die("✗ Error: Archivo SQL no encontrado: $sqlFile\n");
    }

    $sql = file_get_contents($sqlFile);

    echo "Desplegando SPs de PasoMdos...\n";
    echo str_repeat('-', 70) . "\n";

    // Ejecutar el script
    $pdo->exec($sql);

    echo "✓ sp_pasomdos_insert_tianguis desplegado correctamente\n";
    echo "✓ sp_pasomdos_verificar_local desplegado correctamente\n";
    echo str_repeat('-', 70) . "\n";

    // Verificar que existan
    $stmt = $pdo->query("
        SELECT routine_name, routine_type
        FROM information_schema.routines
        WHERE routine_schema = 'public'
        AND routine_name LIKE 'sp_pasomdos%'
        ORDER BY routine_name
    ");

    $routines = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "\nSPs verificados en la BD:\n";
    foreach ($routines as $routine) {
        echo "  ✓ {$routine['routine_name']} ({$routine['routine_type']})\n";
    }

    echo "\n✓ Despliegue completado exitosamente!\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
