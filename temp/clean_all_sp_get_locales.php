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

    // Buscar TODAS las versiones de sp_get_locales en TODOS los schemas
    echo "=== Buscando todas las versiones de sp_get_locales ===\n";
    $sql = "
        SELECT 
            n.nspname as schema_name,
            p.proname as function_name,
            pg_get_function_identity_arguments(p.oid) as arguments,
            p.oid
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'sp_get_locales'
    ";
    
    $stmt = $pdo->query($sql);
    $functions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    if (count($functions) > 0) {
        echo "Encontradas " . count($functions) . " versiones:\n";
        foreach ($functions as $func) {
            echo "  - {$func['schema_name']}.{$func['function_name']}({$func['arguments']})\n";
        }
        echo "\n";
        
        // Eliminar cada versión encontrada
        echo "Eliminando todas las versiones...\n";
        foreach ($functions as $func) {
            $dropSql = "DROP FUNCTION IF EXISTS {$func['schema_name']}.sp_get_locales({$func['arguments']}) CASCADE";
            echo "  Ejecutando: {$dropSql}\n";
            try {
                $pdo->exec($dropSql);
                echo "  ✓ Eliminada\n";
            } catch (PDOException $e) {
                echo "  ✗ Error: " . $e->getMessage() . "\n";
            }
        }
        echo "\n";
    } else {
        echo "No se encontraron versiones de sp_get_locales\n\n";
    }

    // Crear la versión correcta SOLAMENTE en el schema public
    echo "=== Creando versión correcta en schema public ===\n";
    $sql = "
CREATE FUNCTION public.sp_get_locales(p_id_local integer)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion character(2),
    letra_local character varying(3),
    bloque character varying(2),
    nombre character varying(60),
    descripcion_local character(20)
) 
LANGUAGE plpgsql
AS \$function\$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_local, 
        a.oficina, 
        a.num_mercado, 
        a.categoria, 
        a.seccion, 
        a.letra_local, 
        a.bloque, 
        a.nombre, 
        a.descripcion_local
    FROM publico.ta_11_locales a
    WHERE a.id_local = p_id_local;
END;
\$function\$;
    ";
    
    $pdo->exec($sql);
    echo "✓ Función creada en public schema\n\n";

    // Verificar la nueva función
    echo "=== Verificando función creada ===\n";
    $stmt = $pdo->query("
        SELECT 
            n.nspname as schema_name,
            p.proname as function_name,
            pg_get_function_identity_arguments(p.oid) as arguments
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'sp_get_locales'
    ");
    $functions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($functions as $func) {
        echo "  ✓ {$func['schema_name']}.{$func['function_name']}({$func['arguments']})\n";
    }
    echo "\n";

    // Probar la función
    echo "=== Probando función ===\n";
    $stmt = $pdo->query("SELECT id_local FROM publico.ta_11_locales LIMIT 1");
    $local = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($local) {
        $id = $local['id_local'];
        echo "Probando con id_local: {$id}\n";
        
        try {
            $stmt2 = $pdo->prepare("SELECT * FROM public.sp_get_locales(?)");
            $stmt2->execute([$id]);
            $result = $stmt2->fetch(PDO::FETCH_ASSOC);
            
            if ($result) {
                echo "✓ Función ejecutada correctamente\n";
                echo "  ID: {$result['id_local']}\n";
                echo "  Nombre: " . trim($result['nombre']) . "\n";
                echo "  Descripción: '" . trim($result['descripcion_local']) . "'\n";
                echo "  Tipo descripción recibido: " . gettype($result['descripcion_local']) . "\n";
            } else {
                echo "✗ No se obtuvieron resultados\n";
            }
        } catch (PDOException $e) {
            echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
        }
    }

    echo "\n✅ Proceso completado\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
