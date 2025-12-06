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
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/DatosRequerimientos_sp_get_mercado.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando sp_get_mercado...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Probar el SP con valores válidos
    echo "=== Probando SP ===\n";
    
    // Obtener una oficina y mercado válidos
    $stmt = $pdo->query("SELECT oficina, num_mercado_nvo FROM public.ta_11_mercados LIMIT 1");
    $mercado = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($mercado) {
        $oficina = $mercado['oficina'];
        $num_mercado = $mercado['num_mercado_nvo'];
        
        echo "Probando con: oficina={$oficina}, num_mercado_nvo={$num_mercado}\n";
        
        try {
            $stmt2 = $pdo->prepare("SELECT * FROM sp_get_mercado(?, ?)");
            $stmt2->execute([$oficina, $num_mercado]);
            $result = $stmt2->fetch(PDO::FETCH_ASSOC);
            
            if ($result) {
                echo "✓ SP ejecutado correctamente\n";
                echo "  ID Mercado: {$result['id_mercado']}\n";
                echo "  Oficina: {$result['oficina']}\n";
                echo "  Num Mercado Nuevo: {$result['num_mercado_nvo']}\n";
                echo "  Descripción: " . trim($result['descripcion']) . "\n";
                echo "  Domicilio: " . trim($result['domicilio']) . "\n";
                echo "  Zona: {$result['zona']}\n";
            } else {
                echo "✗ SP ejecutado pero no retornó resultados\n";
            }
        } catch (PDOException $e) {
            echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
        }
    } else {
        echo "No hay mercados en la tabla para probar\n";
    }

    echo "\n✅ SP desplegado correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
