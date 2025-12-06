<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Buscando requerimientos existentes ===\n\n";

    // Obtener varios registros
    $stmt = $pdo->query("
        SELECT 
            modulo, 
            folio, 
            control_otr,
            diligencia,
            vigencia,
            fecha_emision,
            importe_global
        FROM publico.ta_15_apremios 
        WHERE vigencia IN ('1', '2', '3')
        ORDER BY fecha_emision DESC
        LIMIT 10
    ");
    
    $registros = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (count($registros) > 0) {
        echo "Encontrados " . count($registros) . " requerimientos:\n\n";
        
        foreach ($registros as $idx => $reg) {
            echo "Opción " . ($idx + 1) . ":\n";
            echo "  Módulo: {$reg['modulo']}\n";
            echo "  Folio: {$reg['folio']}\n";
            echo "  Control OTR: {$reg['control_otr']}\n";
            echo "  Diligencia: '{$reg['diligencia']}'\n";
            echo "  Vigencia: '{$reg['vigencia']}'\n";
            echo "  Fecha Emisión: {$reg['fecha_emision']}\n";
            echo "  Importe Global: \$" . number_format($reg['importe_global'], 2) . "\n";
            echo "\n";
            
            // Probar el SP con este registro
            if ($idx == 0) {
                echo "Probando SP con esta combinación:\n";
                try {
                    $stmt2 = $pdo->prepare("SELECT * FROM sp_get_requerimientos(?, ?, ?)");
                    $stmt2->execute([$reg['modulo'], $reg['folio'], $reg['control_otr']]);
                    $result = $stmt2->fetch(PDO::FETCH_ASSOC);
                    
                    if ($result) {
                        echo "✓ SP retorna datos correctamente\n";
                        echo "  ID Control: {$result['id_control']}\n";
                        echo "  Usuario: {$result['usuario']}\n";
                        if ($result['usuario_1']) {
                            echo "  Nombre Usuario: {$result['nombre']}\n";
                        }
                    } else {
                        echo "✗ SP no retornó datos\n";
                    }
                } catch (PDOException $e) {
                    echo "✗ Error: " . $e->getMessage() . "\n";
                }
                echo "\n";
            }
        }
        
        // Dar una recomendación
        $mejor = $registros[0];
        echo "=========================================\n";
        echo "RECOMENDACIÓN - USA ESTA COMBINACIÓN:\n";
        echo "=========================================\n";
        echo "Módulo: {$mejor['modulo']}\n";
        echo "Folio: {$mejor['folio']}\n";
        echo "Control OTR: {$mejor['control_otr']}\n";
        echo "=========================================\n";
        
    } else {
        echo "No se encontraron requerimientos en la tabla\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
