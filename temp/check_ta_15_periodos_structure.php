<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Buscando tabla ta_15_periodos ===\n";
    $sql = "SELECT table_schema FROM information_schema.tables WHERE table_name = 'ta_15_periodos'";
    $stmt = $pdo->query($sql);
    $schemas = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    if (count($schemas) > 0) {
        echo "Encontrada en schemas: " . implode(", ", $schemas) . "\n\n";
        
        $schema = $schemas[0];
        echo "Estructura de {$schema}.ta_15_periodos:\n";
        
        $sql = "
            SELECT column_name, data_type, character_maximum_length, numeric_precision, numeric_scale
            FROM information_schema.columns
            WHERE table_name = 'ta_15_periodos'
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
                $type .= "({$col['numeric_precision']}";
                if ($col['numeric_scale']) {
                    $type .= ",{$col['numeric_scale']}";
                }
                $type .= ")";
            }
            echo "  {$col['column_name']}: {$type}\n";
        }
        
        // Verificar si hay datos
        echo "\n=== Verificando datos ===\n";
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM {$schema}.ta_15_periodos");
        $count = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "Total de registros: {$count['count']}\n";
        
        if ($count['count'] > 0) {
            echo "\nPrimeros 3 registros:\n";
            $stmt = $pdo->query("SELECT * FROM {$schema}.ta_15_periodos LIMIT 3");
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            foreach ($rows as $idx => $row) {
                echo "  Registro " . ($idx+1) . ":\n";
                echo "    control_otr: {$row['control_otr']}\n";
                echo "    ayo: {$row['ayo']}\n";
                echo "    periodo: {$row['periodo']}\n";
                echo "    importe: {$row['importe']}\n\n";
            }
        }
        
    } else {
        echo "No se encontró la tabla\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
