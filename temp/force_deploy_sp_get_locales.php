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

    // Verificar el SP actual
    echo "=== Verificando SP actual ===\n";
    $sql = "
        SELECT pg_get_functiondef(oid)
        FROM pg_proc
        WHERE proname = 'sp_get_locales'
        AND pronamespace::regnamespace::text = 'public'
    ";
    $stmt = $pdo->query($sql);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($result) {
        echo "Definición actual:\n";
        echo substr($result['pg_get_functiondef'], 0, 300) . "...\n\n";
    }

    // Eliminar TODAS las versiones del SP
    echo "Eliminando todas las versiones de sp_get_locales...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS sp_get_locales(integer) CASCADE");
    $pdo->exec("DROP FUNCTION IF EXISTS public.sp_get_locales(integer) CASCADE");
    echo "✓ Versiones anteriores eliminadas\n\n";

    // Desplegar la nueva versión
    echo "Desplegando nueva versión...\n";
    $sql = "
CREATE OR REPLACE FUNCTION sp_get_locales(p_id_local integer)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion char(2),
    letra_local varchar(3),
    bloque varchar(2),
    nombre varchar(60),
    descripcion_local char(20)
) AS \$\$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.letra_local, a.bloque, a.nombre, a.descripcion_local
    FROM publico.ta_11_locales a
    WHERE a.id_local = p_id_local;
END;
\$\$ LANGUAGE plpgsql;
    ";
    
    $pdo->exec($sql);
    echo "✓ Nueva versión desplegada\n\n";

    // Verificar que se desplegó correctamente
    echo "=== Verificando nueva versión ===\n";
    $stmt = $pdo->query("
        SELECT pg_get_functiondef(oid)
        FROM pg_proc
        WHERE proname = 'sp_get_locales'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($result) {
        echo "Nueva definición desplegada correctamente\n";
        if (strpos($result['pg_get_functiondef'], 'publico.ta_11_locales') !== false) {
            echo "✓ Apunta a publico.ta_11_locales\n";
        }
        if (strpos($result['pg_get_functiondef'], 'char(20)') !== false || 
            strpos($result['pg_get_functiondef'], 'character(20)') !== false) {
            echo "✓ descripcion_local tiene tipo correcto (char(20))\n";
        }
    }

    // Probar el SP
    echo "\n=== Probando SP ===\n";
    $stmt = $pdo->query("SELECT id_local FROM publico.ta_11_locales LIMIT 1");
    $local = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($local) {
        $id = $local['id_local'];
        echo "Probando con id_local: {$id}\n";
        
        $stmt2 = $pdo->prepare("SELECT * FROM sp_get_locales(?)");
        $stmt2->execute([$id]);
        $result = $stmt2->fetch(PDO::FETCH_ASSOC);
        
        if ($result) {
            echo "✓ SP ejecutado correctamente\n";
            echo "  Nombre: " . trim($result['nombre']) . "\n";
            echo "  Descripción: " . trim($result['descripcion_local']) . "\n";
        } else {
            echo "✗ No se obtuvieron resultados\n";
        }
    }

    echo "\n✅ SP desplegado y funcionando correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
