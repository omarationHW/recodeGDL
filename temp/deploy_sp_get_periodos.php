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
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/DatosRequerimientos_sp_get_periodos.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando sp_get_periodos...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Probar el SP con un control_otr válido
    echo "=== Probando SP ===\n";
    
    // Usar el control_otr que ya sabemos que tiene datos
    $control_otr = 31299;
    
    echo "Probando con control_otr: {$control_otr}\n";
    
    try {
        $stmt = $pdo->prepare("SELECT * FROM sp_get_periodos(?)");
        $stmt->execute([$control_otr]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        if (count($results) > 0) {
            echo "✓ SP ejecutado correctamente\n";
            echo "  Registros retornados: " . count($results) . "\n\n";
            
            echo "Primeros 3 periodos:\n";
            foreach (array_slice($results, 0, 3) as $row) {
                echo "  - Año: {$row['ayo']}, Periodo: {$row['periodo']}, Importe: \${$row['importe']}, Recargos: \${$row['recargos']}\n";
            }
        } else {
            echo "✗ SP ejecutado pero no retornó resultados\n";
        }
    } catch (PDOException $e) {
        echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
    }

    echo "\n✅ SP desplegado correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
