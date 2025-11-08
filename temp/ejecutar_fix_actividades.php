<?php
/**
 * Script para ejecutar fix de Catálogo de Actividades
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "=== EJECUTANDO FIX CATÁLOGO DE ACTIVIDADES ===\n\n";

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✅ Conexión exitosa\n\n";

    // Leer el SQL
    $sql = file_get_contents(__DIR__ . '/fix_catalogo_actividades_real.sql');

    echo "📝 Ejecutando SQL...\n";
    $pdo->exec($sql);
    echo "✅ SPs creados exitosamente\n\n";

    // Verificar que los SPs se crearon
    echo "🔍 Verificando SPs creados:\n";
    $check = $pdo->query("
        SELECT routine_name
        FROM information_schema.routines
        WHERE routine_schema = 'comun' AND routine_name LIKE 'catalogo_actividades%'
        ORDER BY routine_name
    ");

    $sps = $check->fetchAll(PDO::FETCH_COLUMN);

    if (count($sps) > 0) {
        foreach ($sps as $sp) {
            echo "   ✅ $sp\n";
        }
    } else {
        echo "   ⚠️  No se encontraron los SPs\n";
    }

    echo "\n✅ FIX COMPLETADO\n";

} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
