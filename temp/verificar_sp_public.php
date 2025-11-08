<?php
// Verificar si los SPs de tipobloqueo existen en el esquema 'public'

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICAR SPs EN ESQUEMA 'public' ===\n\n";

    // Buscar SPs en el esquema 'public'
    $stmt = $db->query("
        SELECT
            p.proname as nombre,
            pg_get_function_arguments(p.oid) as parametros
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
          AND p.proname LIKE '%tipobloqueo%'
        ORDER BY p.proname
    ");
    $sps_public = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "📋 SPs en esquema 'public':\n";
    echo str_repeat("-", 80) . "\n";
    if (count($sps_public) > 0) {
        foreach ($sps_public as $sp) {
            echo "✅ public.{$sp['nombre']}\n";
            echo "   Parámetros: {$sp['parametros']}\n\n";
        }
    } else {
        echo "❌ NO se encontraron SPs en el esquema 'public'\n";
    }
    echo str_repeat("-", 80) . "\n\n";

    // Buscar SPs en el esquema 'comun'
    $stmt = $db->query("
        SELECT
            p.proname as nombre,
            pg_get_function_arguments(p.oid) as parametros
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun'
          AND p.proname LIKE '%tipobloqueo%'
        ORDER BY p.proname
    ");
    $sps_comun = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "📋 SPs en esquema 'comun':\n";
    echo str_repeat("-", 80) . "\n";
    if (count($sps_comun) > 0) {
        foreach ($sps_comun as $sp) {
            echo "✅ comun.{$sp['nombre']}\n";
            echo "   Parámetros: {$sp['parametros']}\n\n";
        }
    } else {
        echo "❌ NO se encontraron SPs en el esquema 'comun'\n";
    }
    echo str_repeat("-", 80) . "\n\n";

    // Probar llamar al SP en public si existe
    if (count($sps_public) > 0) {
        echo "🧪 Probando llamada a public.sp_tipobloqueo_list():\n";
        echo str_repeat("-", 80) . "\n";
        try {
            $stmt = $db->query('SELECT * FROM public.sp_tipobloqueo_list() LIMIT 5');
            $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo "✅ SP ejecutado correctamente\n";
            echo "📊 Registros encontrados: " . count($results) . "\n\n";
            if (count($results) > 0) {
                echo "Primeros 3 registros:\n";
                print_r(array_slice($results, 0, 3));
            }
        } catch (PDOException $e) {
            echo "❌ Error al ejecutar SP: " . $e->getMessage() . "\n";
        }
        echo str_repeat("-", 80) . "\n\n";
    }

    // Verificar tabla en public
    echo "📊 Verificando tabla en 'public':\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $db->query("
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name LIKE '%tipobloqueo%'
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "✅ public.{$table['table_name']}\n";
        }

        // Contar registros
        $stmt = $db->query("SELECT COUNT(*) as total FROM public.c_tipobloqueo");
        $count = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
        echo "📊 Total registros en public.c_tipobloqueo: {$count}\n";
    } else {
        echo "❌ NO se encontró tabla en 'public'\n";
    }
    echo str_repeat("-", 80) . "\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
