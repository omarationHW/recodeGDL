<?php
/**
 * Script para desplegar SPs de bloqueoDomicilios en servidor correcto
 * Host: 192.168.6.146
 */

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

    echo "✓ Conexión exitosa al servidor: $host\n\n";

    // 1. Eliminar SPs duplicados usando la forma correcta
    echo "1. Limpiando SPs duplicados...\n";

    // Obtener todas las versiones de los SPs
    $stmt = $pdo->query("
        SELECT n.nspname, p.proname, pg_get_function_identity_arguments(p.oid) as args
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname LIKE 'sp_bloqueodomicilios%'
    ");

    $functions = $stmt->fetchAll();
    foreach ($functions as $func) {
        try {
            $dropCmd = "DROP FUNCTION IF EXISTS {$func['nspname']}.{$func['proname']}({$func['args']}) CASCADE";
            $pdo->exec($dropCmd);
            echo "   ✓ Eliminado: {$func['nspname']}.{$func['proname']}\n";
        } catch (Exception $e) {
            echo "   ⚠ Error eliminando {$func['proname']}: " . $e->getMessage() . "\n";
        }
    }

    // 2. Establecer search_path
    echo "\n2. Estableciendo search_path...\n";
    $pdo->exec("SET search_path TO public, comun");
    echo "   ✓ search_path: public, comun\n";

    // 3. Ejecutar script SQL
    echo "\n3. Creando SPs en public...\n";
    $sqlFile = __DIR__ . '/DEPLOY_BLOQUEODOMICILIOS_SPS.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("No se encuentra: $sqlFile");
    }

    $sql = "SET search_path TO public, comun;\n\n" . file_get_contents($sqlFile);
    $pdo->exec($sql);
    echo "   ✓ SPs creados\n";

    // 4. Verificar
    echo "\n4. Verificando SPs en public:\n";
    $stmt = $pdo->query("
        SELECT p.proname
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname LIKE 'sp_bloqueodomicilios%'
        ORDER BY p.proname
    ");

    $procedures = $stmt->fetchAll();
    foreach ($procedures as $proc) {
        echo "   ✓ public.{$proc['proname']}\n";
    }

    // 5. Probar
    echo "\n5. Probando sp_bloqueodomicilios_list...\n";
    try {
        $stmt = $pdo->query("SELECT COUNT(*) as cnt FROM public.sp_bloqueodomicilios_list(1, 10, NULL, NULL)");
        $result = $stmt->fetch();
        echo "   ✓ SP funciona correctamente\n";
    } catch (Exception $e) {
        echo "   ⚠ Error: " . $e->getMessage() . "\n";
    }

    echo "\n✓✓✓ DESPLIEGUE COMPLETADO ✓✓✓\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
