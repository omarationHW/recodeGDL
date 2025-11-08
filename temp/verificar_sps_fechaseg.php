<?php
// Verificar si existen los SPs de fechaseg (CREATE, UPDATE, DELETE)

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICAR STORED PROCEDURES DE FECHASEG ===\n\n";

    // Buscar funciones en el schema comun que contengan 'fechaseg'
    $stmt = $db->query("
        SELECT
            routine_name,
            routine_type,
            data_type as return_type
        FROM information_schema.routines
        WHERE routine_schema = 'comun'
        AND routine_name LIKE '%fechaseg%'
        ORDER BY routine_name
    ");

    $funciones = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "📋 Funciones encontradas en schema 'comun':\n";
    echo str_repeat("-", 80) . "\n";

    if (count($funciones) > 0) {
        foreach ($funciones as $func) {
            echo "  ✓ {$func['routine_name']} ({$func['routine_type']})";
            if ($func['return_type']) {
                echo " -> {$func['return_type']}";
            }
            echo "\n";
        }
    } else {
        echo "  ❌ No se encontraron funciones con 'fechaseg'\n";
    }
    echo str_repeat("-", 80) . "\n\n";

    // Verificar específicamente los SPs que necesitamos
    $sps_requeridos = [
        'sp_fechaseg_list',
        'sp_fechaseg_create',
        'sp_fechaseg_update',
        'sp_fechaseg_delete'
    ];

    echo "📝 Verificando SPs requeridos:\n";
    echo str_repeat("-", 80) . "\n";

    foreach ($sps_requeridos as $sp) {
        $stmt = $db->prepare("
            SELECT EXISTS (
                SELECT 1
                FROM information_schema.routines
                WHERE routine_schema = 'comun'
                AND routine_name = :sp_name
            ) as existe
        ");
        $stmt->execute(['sp_name' => $sp]);
        $existe = $stmt->fetch(PDO::FETCH_ASSOC)['existe'];

        if ($existe === 't' || $existe === true) {
            echo "  ✅ $sp - EXISTE\n";
        } else {
            echo "  ❌ $sp - NO EXISTE (CREAR)\n";
        }
    }
    echo str_repeat("-", 80) . "\n\n";

    // Si sp_fechaseg_list existe, mostrar su definición
    echo "📖 Definición de sp_fechaseg_list:\n";
    echo str_repeat("-", 80) . "\n";
    $stmt = $db->query("
        SELECT pg_get_functiondef(oid) as definition
        FROM pg_proc
        WHERE proname = 'sp_fechaseg_list'
        AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'comun')
        LIMIT 1
    ");
    $def = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($def) {
        echo $def['definition'] . "\n";
    } else {
        echo "No se pudo obtener la definición\n";
    }
    echo str_repeat("-", 80) . "\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
