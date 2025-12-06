<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Simulando llamada desde Laravel ===\n\n";

    // Simular los parámetros que vienen del frontend
    $parametros = [
        ['Nombre' => 'p_id_local', 'Valor' => 1]
    ];

    echo "Parámetros recibidos del frontend:\n";
    print_r($parametros);
    echo "\n";

    // Extraer el valor del parámetro (como lo haría Laravel)
    $id_local = null;
    foreach ($parametros as $param) {
        if ($param['Nombre'] === 'p_id_local') {
            $id_local = $param['Valor'];
            break;
        }
    }

    echo "ID Local extraído: {$id_local}\n\n";

    // Llamar al SP
    echo "Llamando al SP con id_local = {$id_local}\n";
    $stmt = $pdo->prepare("SELECT * FROM sp_get_datos_individuales(?)");
    $stmt->execute([$id_local]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($result) > 0) {
        echo "✓ SP ejecutado correctamente\n";
        echo "  Registros retornados: " . count($result) . "\n\n";
        
        $datos = $result[0];
        echo "Datos retornados:\n";
        echo "  id_local: {$datos['id_local']}\n";
        echo "  oficina: {$datos['oficina']}\n";
        echo "  num_mercado: {$datos['num_mercado']}\n";
        echo "  nombre: " . trim($datos['nombre']) . "\n";
        
        // Verificar si existe la clave 'p_id_local' en el resultado
        if (isset($datos['p_id_local'])) {
            echo "\n✗ ERROR: El resultado contiene una clave 'p_id_local' (NO DEBERÍA)\n";
        } else {
            echo "\n✓ OK: El resultado NO contiene 'p_id_local' (correcto)\n";
        }
        
        // Verificar todas las claves retornadas
        echo "\nTodas las claves retornadas:\n";
        foreach (array_keys($datos) as $key) {
            echo "  - {$key}\n";
        }
    } else {
        echo "✗ No se obtuvieron resultados\n";
    }

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
