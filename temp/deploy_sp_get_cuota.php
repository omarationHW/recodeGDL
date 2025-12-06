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
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/DatosIndividuales_sp_get_cuota.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando sp_get_cuota...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Probar el SP con valores válidos
    echo "=== Probando SP ===\n";
    
    // Obtener una cuota válida
    $stmt = $pdo->query("SELECT axo, categoria, seccion, clave_cuota, importe_cuota FROM publico.ta_11_cuo_locales LIMIT 1");
    $cuota = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($cuota) {
        $axo = $cuota['axo'];
        $categoria = $cuota['categoria'];
        $seccion = $cuota['seccion'];
        $clave_cuota = $cuota['clave_cuota'];
        
        echo "Probando con: axo={$axo}, categoria={$categoria}, seccion={$seccion}, clave_cuota={$clave_cuota}\n";
        
        try {
            $stmt2 = $pdo->prepare("SELECT * FROM sp_get_cuota(?, ?, ?, ?)");
            $stmt2->execute([$axo, $categoria, $seccion, $clave_cuota]);
            $result = $stmt2->fetch(PDO::FETCH_ASSOC);
            
            if ($result) {
                echo "✓ SP ejecutado correctamente\n";
                echo "  ID Cuotas: {$result['id_cuotas']}\n";
                echo "  Año: {$result['axo']}\n";
                echo "  Categoría: {$result['categoria']}\n";
                echo "  Sección: {$result['seccion']}\n";
                echo "  Clave Cuota: {$result['clave_cuota']}\n";
                echo "  Importe Cuota: \${$result['importe_cuota']}\n";
                echo "  Renta: \${$result['renta']}\n";
            } else {
                echo "✗ SP ejecutado pero no retornó resultados\n";
            }
        } catch (PDOException $e) {
            echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
        }
    } else {
        echo "No hay cuotas en la tabla para probar\n";
    }

    echo "\n✅ SP desplegado correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
