<?php
/**
 * Script de despliegue de Stored Procedures para LigaRequisitos
 * Fecha: 2025-11-06
 * Servidor: 192.168.6.146
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa al servidor REAL: $host\n\n";

    // 1. Listar SPs existentes
    echo "1. Verificando SPs existentes en el servidor real...\n";

    $checkSPs = "
    SELECT n.nspname as schema, p.proname as nombre
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE p.proname LIKE 'sp_ligarequisitos_%'
    ORDER BY n.nspname, p.proname
    ";

    $stmt = $pdo->query($checkSPs);
    $existingSPs = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($existingSPs) > 0) {
        echo "   SPs encontrados:\n";
        foreach ($existingSPs as $sp) {
            echo "   - {$sp['schema']}.{$sp['nombre']}\n";
        }
    } else {
        echo "   ⚠ No se encontraron SPs previos\n";
    }

    // 2. Eliminar SPs existentes
    echo "\n2. Eliminando SPs existentes...\n";

    $dropSPs = [
        "DROP FUNCTION IF EXISTS public.sp_ligarequisitos_giros() CASCADE",
        "DROP FUNCTION IF EXISTS public.sp_ligarequisitos_list(INTEGER) CASCADE",
        "DROP FUNCTION IF EXISTS public.sp_ligarequisitos_available(INTEGER) CASCADE",
        "DROP FUNCTION IF EXISTS public.sp_ligarequisitos_add(INTEGER, INTEGER) CASCADE",
        "DROP FUNCTION IF EXISTS public.sp_ligarequisitos_remove(INTEGER, INTEGER) CASCADE"
    ];

    foreach ($dropSPs as $drop) {
        try {
            $pdo->exec($drop);
            echo "   ✓ " . str_replace("DROP FUNCTION IF EXISTS ", "Eliminado: ", explode(" CASCADE", $drop)[0]) . "\n";
        } catch (Exception $e) {
            // Ignorar errores si no existe
        }
    }

    // 3. Establecer search_path
    echo "\n3. Estableciendo search_path a public...\n";
    $pdo->exec("SET search_path TO public, comun");
    echo "   ✓ search_path establecido a 'public, comun'\n";

    // 4. Leer y ejecutar SQL
    echo "\n4. Creando Stored Procedures en esquema public...\n";

    $sqlFile = __DIR__ . '/DEPLOY_LIGAREQUISITOS_SPS.sql';
    if (!file_exists($sqlFile)) {
        throw new Exception("No se encontró el archivo SQL: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    // Limpiar comentarios
    $sql = preg_replace('/--[^\n]*\n/', "\n", $sql);

    try {
        $pdo->exec($sql);
        echo "   ✓ SPs creados exitosamente\n";
    } catch (Exception $e) {
        echo "   ✗ Error al crear SPs: " . $e->getMessage() . "\n";
        throw $e;
    }

    // 5. Verificar SPs creados
    echo "\n5. Verificando SPs creados en public:\n";

    $verifySPs = "
    SELECT
        p.proname as nombre,
        pg_get_function_identity_arguments(p.oid) as argumentos
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
    AND p.proname LIKE 'sp_ligarequisitos_%'
    ORDER BY p.proname
    ";

    $stmt = $pdo->query($verifySPs);
    $verifiedSPs = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($verifiedSPs as $sp) {
        echo "   ✓ public.{$sp['nombre']}({$sp['argumentos']})\n";
    }

    // 6. Probar SPs
    echo "\n6. Probando SPs...\n";

    // Probar listado de giros
    echo "\n   6.1. sp_ligarequisitos_giros:\n";
    try {
        $testStmt = $pdo->query("SELECT * FROM public.sp_ligarequisitos_giros() LIMIT 5");
        $testResults = $testStmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($testResults) > 0) {
            echo "       ✓ SP ejecutado correctamente\n";
            echo "       Giros encontrados: " . count($testResults) . "\n";
            echo "       Primer giro: ID " . $testResults[0]['id_giro'] . " - " . trim($testResults[0]['descripcion']) . "\n";
        } else {
            echo "       ⚠ SP ejecutado pero no retornó datos\n";
        }
    } catch (Exception $e) {
        echo "       ✗ Error: " . $e->getMessage() . "\n";
    }

    // Probar listado de requisitos asignados (usar giro 501 que tiene datos)
    echo "\n   6.2. sp_ligarequisitos_list (giro 501):\n";
    try {
        $testStmt = $pdo->query("SELECT * FROM public.sp_ligarequisitos_list(501)");
        $testResults = $testStmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($testResults) > 0) {
            echo "       ✓ SP ejecutado correctamente\n";
            echo "       Requisitos asignados: " . count($testResults) . "\n";
            echo "       Primer requisito: ID " . $testResults[0]['req'] . " - " . trim($testResults[0]['descripcion']) . "\n";
        } else {
            echo "       ✓ SP ejecutado correctamente (giro sin requisitos asignados)\n";
        }
    } catch (Exception $e) {
        echo "       ✗ Error: " . $e->getMessage() . "\n";
    }

    // Probar listado de requisitos disponibles
    echo "\n   6.3. sp_ligarequisitos_available (giro 501):\n";
    try {
        $testStmt = $pdo->query("SELECT * FROM public.sp_ligarequisitos_available(501) LIMIT 5");
        $testResults = $testStmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($testResults) > 0) {
            echo "       ✓ SP ejecutado correctamente\n";
            echo "       Requisitos disponibles: " . count($testResults) . "+\n";
            echo "       Primer disponible: ID " . $testResults[0]['req'] . " - " . trim($testResults[0]['descripcion']) . "\n";
        } else {
            echo "       ✓ SP ejecutado correctamente (todos los requisitos asignados)\n";
        }
    } catch (Exception $e) {
        echo "       ✗ Error: " . $e->getMessage() . "\n";
    }

    echo "\n✓✓✓ DESPLIEGUE COMPLETADO EN SERVIDOR REAL ✓✓✓\n\n";
    echo "Servidor: $host\n";
    echo "Base de datos: $dbname\n";
    echo "Usuario: $user\n\n";
    echo "SPs disponibles en public:\n";
    foreach ($verifiedSPs as $sp) {
        echo "  - public.{$sp['nombre']}\n";
    }
    echo "\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
    exit(1);
}
