<?php
/**
 * Script de despliegue de Stored Procedures para BloquearAnunciorm
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

    // 1. Verificar tabla bloqueos_anuncios
    echo "1. Verificando tabla bloqueos_anuncios...\n";

    $checkTable = "SELECT EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'comun'
        AND table_name = 'bloqueos_anuncios'
    )";

    $result = $pdo->query($checkTable)->fetch();

    if (!$result[0]) {
        echo "   ⚠ Tabla no existe. Creando...\n";

        $createTable = "
        CREATE TABLE comun.bloqueos_anuncios (
            id_bloqueo SERIAL PRIMARY KEY,
            anuncio INTEGER NOT NULL,
            tipo VARCHAR(50) NOT NULL,
            motivo_bloqueo TEXT NOT NULL,
            fecha_bloqueo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            usuario_bloqueo VARCHAR(50) NOT NULL,
            motivo_desbloqueo TEXT,
            fecha_desbloqueo TIMESTAMP,
            usuario_desbloqueo VARCHAR(50),
            activo BOOLEAN DEFAULT TRUE
        );

        COMMENT ON TABLE comun.bloqueos_anuncios IS 'Registro de bloqueos y desbloqueos de anuncios publicitarios';
        CREATE INDEX idx_bloqueos_anuncios_anuncio ON comun.bloqueos_anuncios(anuncio);
        CREATE INDEX idx_bloqueos_anuncios_activo ON comun.bloqueos_anuncios(activo);
        ";

        $pdo->exec($createTable);
        echo "   ✓ Tabla creada exitosamente\n";
    } else {
        echo "   ✓ Tabla existe\n";
    }

    // 2. Listar SPs existentes
    echo "\n2. Verificando SPs existentes en el servidor real...\n";

    $checkSPs = "
    SELECT n.nspname as schema, p.proname as nombre
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE p.proname LIKE 'sp_bloquearanuncio_%'
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

    // 3. Eliminar SPs existentes
    echo "\n3. Eliminando SPs existentes...\n";

    $dropSPs = [
        "DROP FUNCTION IF EXISTS public.sp_bloquearanuncio_get_anuncio(INTEGER) CASCADE",
        "DROP FUNCTION IF EXISTS public.sp_bloquearanuncio_get_bloqueos(INTEGER) CASCADE",
        "DROP FUNCTION IF EXISTS public.sp_bloquearanuncio_bloquear(INTEGER, VARCHAR, TEXT, VARCHAR) CASCADE",
        "DROP FUNCTION IF EXISTS public.sp_bloquearanuncio_desbloquear(INTEGER, TEXT, VARCHAR) CASCADE"
    ];

    foreach ($dropSPs as $drop) {
        try {
            $pdo->exec($drop);
            echo "   ✓ " . str_replace("DROP FUNCTION IF EXISTS ", "Eliminado: ", explode(" CASCADE", $drop)[0]) . "\n";
        } catch (Exception $e) {
            // Ignorar errores si no existe
        }
    }

    // 4. Establecer search_path
    echo "\n4. Estableciendo search_path a public...\n";
    $pdo->exec("SET search_path TO public, comun");
    echo "   ✓ search_path establecido a 'public, comun'\n";

    // 5. Leer y ejecutar SQL
    echo "\n5. Creando Stored Procedures en esquema public...\n";

    $sqlFile = __DIR__ . '/DEPLOY_BLOQUEARANUNCIO_SPS.sql';
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

    // 6. Verificar SPs creados
    echo "\n6. Verificando SPs creados en public:\n";

    $verifySPs = "
    SELECT
        p.proname as nombre,
        pg_get_function_identity_arguments(p.oid) as argumentos
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
    AND p.proname LIKE 'sp_bloquearanuncio_%'
    ORDER BY p.proname
    ";

    $stmt = $pdo->query($verifySPs);
    $verifiedSPs = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($verifiedSPs as $sp) {
        echo "   ✓ public.{$sp['nombre']}({$sp['argumentos']})\n";
    }

    // 7. Probar SP de obtener anuncio
    echo "\n7. Probando sp_bloquearanuncio_get_anuncio...\n";

    try {
        // Buscar un anuncio de ejemplo
        $findAnunStmt = $pdo->query("SELECT anuncio FROM comun.anuncios WHERE anuncio > 0 LIMIT 1");
        $testAnun = $findAnunStmt->fetch();
        $anuncioTest = $testAnun ? $testAnun[0] : 1;

        $testStmt = $pdo->query("SELECT * FROM public.sp_bloquearanuncio_get_anuncio($anuncioTest)");
        $testResult = $testStmt->fetch(PDO::FETCH_ASSOC);

        if ($testResult) {
            echo "   ✓ SP ejecutado correctamente\n";
            echo "   Anuncio: " . ($testResult['anuncio'] ?? 'N/A') . "\n";
            echo "   Licencia: " . ($testResult['licencia'] ?? 'N/A') . "\n";
            echo "   Propietario: " . ($testResult['propietario'] ?? 'N/A') . "\n";
        } else {
            echo "   ⚠ SP ejecutado pero no retornó datos (Anuncio test: $anuncioTest)\n";
        }
    } catch (Exception $e) {
        echo "   ✗ Error al probar SP: " . $e->getMessage() . "\n";
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
