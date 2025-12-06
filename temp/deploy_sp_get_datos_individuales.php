<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conectado a base de datos mercados\n\n";

    // Leer y desplegar el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/DatosIndividuales_sp_get_datos_individuales.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando sp_get_datos_individuales...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Probar el SP con un id_local válido
    echo "=== Probando SP ===\n";
    
    // Obtener un id_local válido
    $stmt = $pdo->query("SELECT id_local FROM publico.ta_11_locales LIMIT 1");
    $local = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($local) {
        $id_local = $local['id_local'];
        echo "Probando con id_local: {$id_local}\n";
        
        try {
            $stmt2 = $pdo->prepare("SELECT * FROM sp_get_datos_individuales(?)");
            $stmt2->execute([$id_local]);
            $result = $stmt2->fetch(PDO::FETCH_ASSOC);
            
            if ($result) {
                echo "✓ SP ejecutado correctamente\n";
                echo "  ID Local: {$result['id_local']}\n";
                echo "  Oficina: {$result['oficina']}\n";
                echo "  Num Mercado: {$result['num_mercado']}\n";
                echo "  Categoría: {$result['categoria']}\n";
                echo "  Sección: {$result['seccion']}\n";
                echo "  Nombre: " . trim($result['nombre']) . "\n";
                echo "  Descripción: " . trim($result['descripcion_local']) . "\n";
                if ($result['num_mercado_nvo']) {
                    echo "  Num Mercado Nuevo: {$result['num_mercado_nvo']}\n";
                }
            } else {
                echo "✗ SP ejecutado pero no retornó resultados\n";
            }
        } catch (PDOException $e) {
            echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
        }
    } else {
        echo "No hay locales en la tabla para probar\n";
    }

    echo "\n✅ SP desplegado correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
