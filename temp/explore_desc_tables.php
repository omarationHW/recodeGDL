<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    $tables = ['descmultalic', 'h_descmultampal', 'temp_descmulta', 'ta_16_descmulta'];

    foreach ($tables as $table) {
        echo "=== TABLA: comun.$table ===\n\n";
        
        // Columnas
        $sqlCols = "
            SELECT
                column_name,
                data_type
            FROM information_schema.columns
            WHERE table_schema = 'comun'
            AND table_name = '$table'
            ORDER BY ordinal_position
        ";
        
        try {
            $stmt = $pdo->query($sqlCols);
            $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo "Columnas:\n";
            foreach ($cols as $col) {
                echo "  - {$col['column_name']} ({$col['data_type']})\n";
            }
            
            // Contar registros
            $countSql = "SELECT COUNT(*) as total FROM comun.$table";
            $stmt = $pdo->query($countSql);
            $count = $stmt->fetch(PDO::FETCH_ASSOC);
            echo "\nTotal registros: {$count['total']}\n";
            
            if ($count['total'] > 0) {
                // Obtener ejemplo
                $exampleSql = "SELECT * FROM comun.$table LIMIT 1";
                $stmt = $pdo->query($exampleSql);
                $example = $stmt->fetch(PDO::FETCH_ASSOC);
                
                echo "\nEjemplo de datos:\n";
                foreach ($example as $key => $val) {
                    echo "  $key: $val\n";
                }
            }
            
            echo "\n" . str_repeat("=", 60) . "\n\n";
            
        } catch (Exception $e) {
            echo "ERROR: " . $e->getMessage() . "\n\n";
        }
    }

    // Buscar la tabla más apropiada para descuentos
    echo "\n=== BUSCANDO DESCUENTOS POR CUENTA Y EJERCICIO ===\n\n";
    
    // Intentar con h_descmultampal
    echo "Probando h_descmultampal:\n";
    $sql = "
        SELECT *
        FROM comun.h_descmultampal
        WHERE cvepago IS NOT NULL
        LIMIT 5
    ";
    
    try {
        $stmt = $pdo->query($sql);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "Registros encontrados: " . count($results) . "\n\n";
        
        foreach ($results as $i => $r) {
            echo "Ejemplo " . ($i + 1) . ":\n";
            foreach ($r as $key => $val) {
                echo "  $key: $val\n";
            }
            echo "\n";
        }
    } catch (Exception $e) {
        echo "ERROR: " . $e->getMessage() . "\n";
    }

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
