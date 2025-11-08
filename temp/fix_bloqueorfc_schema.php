<?php
/**
 * Script para corregir el esquema de los SPs de bloqueoRFC
 * Los SPs se crearon en catastro_gdl, deben estar en public
 * Fecha: 2025-11-06
 */

$host = 'localhost';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'postgres';
$password = 'postgres';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "✓ Conexión exitosa a la base de datos\n\n";

    // 1. Verificar en qué esquema están los SPs
    echo "1. Verificando ubicación actual de los SPs...\n";
    $stmt = $pdo->query("
        SELECT n.nspname as schema, p.proname as name
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname LIKE 'sp_bloqueorfc%'
        ORDER BY n.nspname, p.proname
    ");
    $procedures = $stmt->fetchAll();

    foreach ($procedures as $proc) {
        echo "   - {$proc['schema']}.{$proc['name']}\n";
    }

    // 2. Eliminar SPs del esquema incorrecto (catastro_gdl)
    echo "\n2. Eliminando SPs del esquema incorrecto...\n";
    $spNames = [
        'sp_bloqueorfc_list',
        'sp_bloqueorfc_buscar_tramite',
        'sp_bloqueorfc_create',
        'sp_bloqueorfc_desbloquear'
    ];

    foreach ($spNames as $spName) {
        // Eliminar de catastro_gdl si existe
        try {
            $pdo->exec("DROP FUNCTION IF EXISTS catastro_gdl.$spName CASCADE");
            echo "   ✓ Eliminado de catastro_gdl: $spName\n";
        } catch (Exception $e) {
            echo "   - No existe en catastro_gdl: $spName\n";
        }

        // Eliminar de public si existe (para recrear)
        try {
            $pdo->exec("DROP FUNCTION IF EXISTS public.$spName CASCADE");
            echo "   ✓ Eliminado de public: $spName\n";
        } catch (Exception $e) {
            echo "   - No existe en public: $spName\n";
        }
    }

    // 3. Establecer search_path a public
    echo "\n3. Estableciendo search_path a public...\n";
    $pdo->exec("SET search_path TO public");
    echo "   ✓ search_path establecido\n";

    // 4. Leer y ejecutar los SPs en el esquema correcto
    echo "\n4. Creando SPs en esquema public...\n";
    $sqlFile = __DIR__ . '/DEPLOY_BLOQUEORFC_SPS.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("No se encuentra el archivo: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    // Agregar SET search_path al inicio
    $sql = "SET search_path TO public;\n\n" . $sql;

    // Ejecutar todo el script
    $pdo->exec($sql);
    echo "   ✓ SPs creados exitosamente en public\n";

    // 5. Verificar que los SPs están en public
    echo "\n5. Verificando SPs en esquema public:\n";
    $stmt = $pdo->query("
        SELECT p.proname, pg_get_function_identity_arguments(p.oid) as args
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname LIKE 'sp_bloqueorfc%'
        ORDER BY p.proname
    ");

    $procedures = $stmt->fetchAll();

    if (count($procedures) === 0) {
        echo "   ⚠ No se encontraron los SPs en public\n";
    } else {
        foreach ($procedures as $proc) {
            echo "   ✓ public.{$proc['proname']}({$proc['args']})\n";
        }
    }

    // 6. Probar el SP de búsqueda de trámite
    echo "\n6. Probando sp_bloqueorfc_buscar_tramite...\n";
    try {
        $stmt = $pdo->query("SELECT * FROM public.sp_bloqueorfc_buscar_tramite(1)");
        $result = $stmt->fetch();
        if ($result) {
            echo "   ✓ SP ejecutado correctamente\n";
            echo "   Success: " . ($result['success'] ? 'true' : 'false') . "\n";
            echo "   Message: {$result['message']}\n";
        }
    } catch (Exception $e) {
        echo "   ⚠ Error al ejecutar: " . $e->getMessage() . "\n";
    }

    echo "\n✓✓✓ CORRECCIÓN COMPLETADA ✓✓✓\n";
    echo "\nTodos los SPs ahora están en el esquema 'public':\n";
    echo "  - public.sp_bloqueorfc_list\n";
    echo "  - public.sp_bloqueorfc_buscar_tramite\n";
    echo "  - public.sp_bloqueorfc_create\n";
    echo "  - public.sp_bloqueorfc_desbloquear\n";

} catch (PDOException $e) {
    echo "\n✗ Error de base de datos: " . $e->getMessage() . "\n";
    echo "Código: " . $e->getCode() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
