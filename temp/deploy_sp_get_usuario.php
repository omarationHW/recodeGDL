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
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/DatosIndividuales_sp_get_usuario.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando sp_get_usuario...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Probar el SP con un id válido
    echo "=== Probando SP ===\n";
    
    // Obtener un id de usuario válido
    $stmt = $pdo->query("SELECT id FROM public.usuarios LIMIT 1");
    $usuario = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($usuario) {
        $id = $usuario['id'];
        echo "Probando con id_usuario: {$id}\n";
        
        try {
            $stmt2 = $pdo->prepare("SELECT * FROM sp_get_usuario(?)");
            $stmt2->execute([$id]);
            $result = $stmt2->fetch(PDO::FETCH_ASSOC);
            
            if ($result) {
                echo "✓ SP ejecutado correctamente\n";
                echo "  ID: {$result['id']}\n";
                echo "  Usuario: {$result['usuario']}\n";
                echo "  Nombre: {$result['nombre']}\n";
                echo "  Estado: {$result['estado']}\n";
                echo "  ID Rec: {$result['id_rec']}\n";
                echo "  Nivel: {$result['nivel']}\n";
            } else {
                echo "✗ SP ejecutado pero no retornó resultados\n";
            }
        } catch (PDOException $e) {
            echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
        }
    } else {
        echo "No hay usuarios en la tabla para probar\n";
    }

    echo "\n✅ SP desplegado correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
