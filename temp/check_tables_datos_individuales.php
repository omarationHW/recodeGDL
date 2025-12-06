<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Buscando tabla ta_11_mercados ===\n";
    $sql = "SELECT table_schema FROM information_schema.tables WHERE table_name = 'ta_11_mercados'";
    $stmt = $pdo->query($sql);
    $schemas = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    if (count($schemas) > 0) {
        echo "Encontrada en schemas: " . implode(", ", $schemas) . "\n\n";
        
        $schema = $schemas[0];
        echo "Estructura de {$schema}.ta_11_mercados:\n";
        
        $sql = "
            SELECT column_name, data_type, character_maximum_length, numeric_precision
            FROM information_schema.columns
            WHERE table_name = 'ta_11_mercados'
            AND table_schema = '$schema'
            ORDER BY ordinal_position
        ";
        
        $stmt = $pdo->query($sql);
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($columns as $col) {
            $type = $col['data_type'];
            if ($col['character_maximum_length']) {
                $type .= "({$col['character_maximum_length']})";
            } elseif ($col['numeric_precision']) {
                $type .= "({$col['numeric_precision']})";
            }
            echo "  {$col['column_name']}: {$type}\n";
        }
    } else {
        echo "No se encontró la tabla ta_11_mercados\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
