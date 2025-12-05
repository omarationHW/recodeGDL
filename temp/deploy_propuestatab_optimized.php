<?php
// Desplegar SP optimizado recaudadora_propuestatab
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLEGANDO SP OPTIMIZADO recaudadora_propuestatab ===\n\n";

    // Leer el archivo SQL
    $sql = file_get_contents(__DIR__ . '/recaudadora_propuestatab_optimized.sql');

    if ($sql === false) {
        throw new Exception("No se pudo leer el archivo SQL");
    }

    // Ejecutar el SQL
    $pdo->exec($sql);

    echo "✓ SP optimizado creado exitosamente\n\n";

    // Probar con los 3 ejemplos
    echo "=== PROBANDO SP OPTIMIZADO ===\n\n";

    $ejemplos = [
        ['filtro' => '', 'descripcion' => 'Sin filtro (más recientes)'],
        ['filtro' => '260676', 'descripcion' => 'Buscar por cuenta 260676'],
        ['filtro' => '7530946', 'descripcion' => 'Buscar por folio 7530946'],
        ['filtro' => 'ODOO', 'descripcion' => 'Buscar por cajero ODOO']
    ];

    foreach ($ejemplos as $idx => $ejemplo) {
        echo "--- PRUEBA " . ($idx + 1) . ": {$ejemplo['descripcion']} ---\n\n";

        $start = microtime(true);

        $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_propuestatab(:filtro)");
        $stmt->execute(['filtro' => $ejemplo['filtro']]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $end = microtime(true);
        $tiempo = round(($end - $start) * 1000, 2);

        echo "Tiempo de ejecución: {$tiempo}ms\n";
        echo "Registros encontrados: " . count($results) . "\n";

        if (!empty($results)) {
            echo "\nPrimer registro:\n";
            foreach ($results[0] as $key => $value) {
                echo "  $key: $value\n";
            }
        } else {
            echo "No se encontraron registros\n";
        }

        echo "\n" . str_repeat("-", 60) . "\n\n";
    }

} catch (PDOException $e) {
    echo "Error de BD: " . $e->getMessage() . "\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
