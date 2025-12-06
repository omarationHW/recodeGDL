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
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/DatosRequerimientos_sp_get_requerimientos.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando sp_get_requerimientos...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Verificar tipos de retorno
    echo "=== Verificando tipos de retorno ===\n";
    $stmt = $pdo->query("
        SELECT 
            a.attname AS column_name,
            format_type(a.atttypid, a.atttypmod) AS data_type
        FROM pg_proc p
        JOIN pg_type t ON p.prorettype = t.oid
        JOIN pg_attribute a ON a.attrelid = t.typrelid
        WHERE p.proname = 'sp_get_requerimientos'
        AND p.pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
        AND a.attnum > 0
        ORDER BY a.attnum
        LIMIT 10
    ");
    
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($columns as $col) {
        $check = '';
        if ($col['column_name'] == 'diligencia' && strpos($col['data_type'], 'character(1)') !== false) {
            $check = ' ✓';
        } elseif ($col['column_name'] == 'diligencia') {
            $check = ' ✗';
        }
        echo "  {$col['column_name']}: {$col['data_type']}{$check}\n";
    }
    echo "\n";

    // Probar el SP
    echo "=== Probando SP ===\n";
    $stmt = $pdo->query("SELECT modulo, folio, control_otr FROM publico.ta_15_apremios LIMIT 1");
    $requerimiento = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($requerimiento) {
        $modulo = $requerimiento['modulo'];
        $folio = $requerimiento['folio'];
        $control = $requerimiento['control_otr'];
        
        echo "Probando con: modulo={$modulo}, folio={$folio}, control_otr={$control}\n";
        
        try {
            $stmt2 = $pdo->prepare("SELECT * FROM sp_get_requerimientos(?, ?, ?)");
            $stmt2->execute([$modulo, $folio, $control]);
            $result = $stmt2->fetch(PDO::FETCH_ASSOC);
            
            if ($result) {
                echo "✓ SP ejecutado correctamente\n";
                echo "  ID Control: {$result['id_control']}\n";
                echo "  Módulo: {$result['modulo']}\n";
                echo "  Folio: {$result['folio']}\n";
                echo "  Diligencia: '{$result['diligencia']}'\n";
                echo "  Vigencia: '{$result['vigencia']}'\n";
            } else {
                echo "✓ SP ejecutado, pero no retornó resultados\n";
            }
        } catch (PDOException $e) {
            echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
        }
    } else {
        echo "No hay registros en ta_15_apremios para probar\n";
    }

    echo "\n✅ SP desplegado correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
