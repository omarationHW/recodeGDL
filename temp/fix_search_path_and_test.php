<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Verificando search_path actual ===\n";
    $stmt = $pdo->query("SHOW search_path");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Search path actual: " . $result['search_path'] . "\n\n";

    // Asegurar que public está al inicio del search_path
    echo "Configurando search_path con public al inicio...\n";
    $pdo->exec("ALTER DATABASE mercados SET search_path TO public, publico, comun, comunX, db_ingresos, catastro_gdl");
    echo "✓ Search path actualizado para la base de datos\n\n";

    // Reconectar para aplicar el cambio
    $pdo = null;
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Verificando nuevo search_path ===\n";
    $stmt = $pdo->query("SHOW search_path");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Nuevo search path: " . $result['search_path'] . "\n\n";

    // Verificar que el SP correcto se encuentra primero
    echo "=== Verificando qué SP se encuentra ===\n";
    $stmt = $pdo->query("
        SELECT 
            n.nspname as schema_name,
            p.proname as function_name,
            pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'sp_get_locales'
        ORDER BY 
            CASE 
                WHEN n.nspname = 'public' THEN 1
                WHEN n.nspname = 'publico' THEN 2
                ELSE 3
            END
    ");
    
    $functions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($functions as $func) {
        echo "Schema: {$func['schema_name']}\n";
        
        // Verificar si usa comun o publico
        if (strpos($func['definition'], 'comun.ta_11_locales') !== false) {
            echo "  ✗ ERROR: Usa comun.ta_11_locales (INCORRECTO)\n";
        } elseif (strpos($func['definition'], 'publico.ta_11_locales') !== false) {
            echo "  ✓ Usa publico.ta_11_locales (CORRECTO)\n";
        }
        
        // Verificar tipo de descripcion_local
        if (strpos($func['definition'], 'character(20)') !== false) {
            echo "  ✓ descripcion_local es character(20) (CORRECTO)\n";
        } elseif (strpos($func['definition'], 'character varying') !== false && 
                  strpos($func['definition'], 'descripcion_local') !== false) {
            echo "  ✗ descripcion_local es character varying (INCORRECTO)\n";
        }
        echo "\n";
    }

    // Probar llamada directa
    echo "=== Probando llamada al SP ===\n";
    $stmt = $pdo->query("SELECT id_local FROM publico.ta_11_locales LIMIT 1");
    $local = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($local) {
        $id = $local['id_local'];
        echo "Probando sp_get_locales({$id})...\n";
        
        try {
            // Probar sin especificar schema (usa search_path)
            $stmt2 = $pdo->prepare("SELECT * FROM sp_get_locales(?)");
            $stmt2->execute([$id]);
            $result = $stmt2->fetch(PDO::FETCH_ASSOC);
            
            if ($result) {
                echo "✓ Llamada sin schema exitosa\n";
                echo "  Nombre: " . trim($result['nombre']) . "\n";
            }
        } catch (PDOException $e) {
            echo "✗ Error: " . $e->getMessage() . "\n";
        }
    }

    echo "\n✅ Configuración completada\n";
    echo "\nIMPORTANTE: Reinicia el servidor Laravel/PHP-FPM para aplicar los cambios\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
