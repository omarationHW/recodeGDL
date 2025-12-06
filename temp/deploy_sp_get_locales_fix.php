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

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/DatosRequerimientos_sp_get_locales.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando sp_get_locales...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Probar el SP con un ID real
    echo "Probando el SP...\n";
    
    // Primero obtener un ID válido
    $stmt = $pdo->query("SELECT id_local FROM publico.ta_11_locales LIMIT 1");
    $local = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($local) {
        $id = $local['id_local'];
        echo "Probando con id_local: {$id}\n";
        
        $stmt2 = $pdo->prepare("SELECT * FROM sp_get_locales(?)");
        $stmt2->execute([$id]);
        $result = $stmt2->fetch(PDO::FETCH_ASSOC);
        
        if ($result) {
            echo "✓ SP ejecutado correctamente\n";
            echo "  ID: {$result['id_local']}\n";
            echo "  Oficina: {$result['oficina']}\n";
            echo "  Mercado: {$result['num_mercado']}\n";
            echo "  Categoría: {$result['categoria']}\n";
            echo "  Sección: {$result['seccion']}\n";
            echo "  Nombre: {$result['nombre']}\n";
            echo "  Descripción: {$result['descripcion_local']}\n";
        } else {
            echo "✗ No se obtuvieron resultados\n";
        }
    } else {
        echo "✗ No hay locales en la tabla para probar\n";
    }

    echo "\n✅ SP desplegado y probado correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
