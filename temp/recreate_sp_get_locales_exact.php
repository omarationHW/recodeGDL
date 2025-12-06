<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Recreando sp_get_locales con tipos exactos ===\n\n";

    // Eliminar completamente
    echo "Eliminando versión anterior...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS public.sp_get_locales(integer) CASCADE");
    echo "✓ Eliminada\n\n";

    // Crear con tipos EXACTOS usando CAST para asegurar los tipos
    echo "Creando nueva versión con CAST...\n";
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
        a.id_local::integer, 
        a.oficina::smallint, 
        a.num_mercado::smallint, 
        a.categoria::smallint, 
        a.seccion::character(2), 
        a.letra_local::character varying(3), 
        a.bloque::character varying(2), 
        a.nombre::character varying(60), 
        a.descripcion_local::character(20)
    FROM publico.ta_11_locales a
    WHERE a.id_local = p_id_local;
END;
\$function\$;
    ";
    
    $pdo->exec($sql);
    echo "✓ Función creada con CAST explícitos\n\n";

    // Verificar los tipos de retorno
    echo "=== Verificando tipos de retorno ===\n";
    $stmt = $pdo->query("
        SELECT 
            a.attname AS column_name,
            format_type(a.atttypid, a.atttypmod) AS data_type
        FROM pg_proc p
        JOIN pg_type t ON p.prorettype = t.oid
        JOIN pg_attribute a ON a.attrelid = t.typrelid
        WHERE p.proname = 'sp_get_locales'
        AND p.pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
        ORDER BY a.attnum
    ");
    
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    foreach ($columns as $col) {
        $check = '';
        if ($col['column_name'] == 'descripcion_local') {
            if (strpos($col['data_type'], 'character(20)') !== false) {
                $check = ' ✓';
            } else {
                $check = ' ✗ INCORRECTO';
            }
        }
        echo "  {$col['column_name']}: {$col['data_type']}{$check}\n";
    }
    echo "\n";

    // Probar
    echo "=== Probando SP ===\n";
    $stmt = $pdo->query("SELECT id_local FROM publico.ta_11_locales LIMIT 1");
    $local = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($local) {
        $id = $local['id_local'];
        echo "Probando con id_local: {$id}\n";
        
        try {
            $stmt2 = $pdo->prepare("SELECT * FROM sp_get_locales(?)");
            $stmt2->execute([$id]);
            $result = $stmt2->fetch(PDO::FETCH_ASSOC);
            
            if ($result) {
                echo "✓ SP ejecutado correctamente\n";
                echo "  Nombre: " . trim($result['nombre']) . "\n";
                echo "  Descripción: '" . $result['descripcion_local'] . "'\n";
                echo "  Longitud descripción: " . strlen($result['descripcion_local']) . " caracteres\n";
            }
        } catch (PDOException $e) {
            echo "✗ Error: " . $e->getMessage() . "\n";
        }
    }

    echo "\n✅ SP recreado exitosamente\n";
    echo "\nIMPORTANTE: Si el error persiste:\n";
    echo "1. Reinicia el servidor backend Laravel\n";
    echo "2. Limpia el caché de Laravel: php artisan cache:clear\n";
    echo "3. Reinicia PHP-FPM si aplica\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
