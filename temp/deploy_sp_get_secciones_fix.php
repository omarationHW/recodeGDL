<?php
// Script para desplegar sp_get_secciones corregido

$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conectado a base de datos mercados\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/ModuloBD_sp_get_secciones.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando sp_get_secciones...\n";

    // Ejecutar el SQL
    $pdo->exec($sql);

    echo "✓ SP desplegado exitosamente\n\n";

    // Probar el SP
    echo "Probando el SP...\n";
    $stmt = $pdo->query("SELECT * FROM sp_get_secciones()");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "✓ SP ejecutado correctamente\n";
    echo "  Registros retornados: " . count($results) . "\n";

    if (count($results) > 0) {
        echo "\nPrimeros registros:\n";
        foreach (array_slice($results, 0, 5) as $row) {
            echo "  - Sección: {$row['seccion']}, Descripción: {$row['descripcion']}\n";
        }
    }

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
