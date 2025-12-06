<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Verificando tablas de usuarios ===\n\n";

    // Buscar ta_12_passwords
    $sql = "SELECT table_schema FROM information_schema.tables WHERE table_name = 'ta_12_passwords'";
    $stmt = $pdo->query($sql);
    $schemas = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    if (count($schemas) > 0) {
        echo "ta_12_passwords encontrada en: " . implode(", ", $schemas) . "\n";
    } else {
        echo "ta_12_passwords NO encontrada\n";
    }

    // Buscar usuarios
    $sql = "SELECT table_schema FROM information_schema.tables WHERE table_name = 'usuarios'";
    $stmt = $pdo->query($sql);
    $schemas = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    if (count($schemas) > 0) {
        echo "usuarios encontrada en: " . implode(", ", $schemas) . "\n\n";
        
        echo "Estructura de public.usuarios:\n";
        $sql = "
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_name = 'usuarios'
            AND table_schema = 'public'
            ORDER BY ordinal_position
        ";
        
        $stmt = $pdo->query($sql);
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($columns as $col) {
            $type = $col['data_type'];
            if ($col['character_maximum_length']) {
                $type .= "({$col['character_maximum_length']})";
            }
            echo "  {$col['column_name']}: {$type}\n";
        }
    } else {
        echo "usuarios NO encontrada\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
