<?php
/**
 * Script para ejecutar los SPs en el SERVIDOR CORRECTO
 * Host: 192.168.6.146
 * User: refact
 * Fecha: 2025-11-06
 */

// Configuración del servidor REAL (del .env del backend)
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    // Conectar a PostgreSQL
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "✓ Conexión exitosa al servidor REAL: $host\n\n";

    // 1. Verificar si existen los SPs
    echo "1. Verificando SPs existentes en el servidor real...\n";
    $stmt = $pdo->query("
        SELECT n.nspname as schema, p.proname as nombre
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname LIKE 'sp_bloqueorfc%'
        ORDER BY n.nspname, p.proname
    ");
    $procedures = $stmt->fetchAll();

    if (count($procedures) > 0) {
        echo "   SPs encontrados:\n";
        foreach ($procedures as $proc) {
            echo "   - {$proc['schema']}.{$proc['nombre']}\n";
        }
    } else {
        echo "   ⚠ No se encontraron SPs\n";
    }

    // 2. Eliminar SPs existentes
    echo "\n2. Eliminando SPs existentes...\n";
    $spNames = [
        'sp_bloqueorfc_list',
        'sp_bloqueorfc_buscar_tramite',
        'sp_bloqueorfc_create',
        'sp_bloqueorfc_desbloquear'
    ];

    foreach ($spNames as $spName) {
        try {
            $pdo->exec("DROP FUNCTION IF EXISTS public.$spName CASCADE");
            echo "   ✓ Eliminado: public.$spName\n";
        } catch (Exception $e) {
            echo "   - No existe: public.$spName\n";
        }

        // También intentar eliminar de catastro_gdl
        try {
            $pdo->exec("DROP FUNCTION IF EXISTS catastro_gdl.$spName CASCADE");
            echo "   ✓ Eliminado: catastro_gdl.$spName\n";
        } catch (Exception $e) {
            // Ignorar si no existe
        }
    }

    // 3. Verificar si existe la tabla bloqueo_rfc_lic
    echo "\n3. Verificando tabla bloqueo_rfc_lic...\n";
    $stmt = $pdo->query("
        SELECT EXISTS (
            SELECT FROM information_schema.tables
            WHERE table_schema = 'comun'
            AND table_name = 'bloqueo_rfc_lic'
        )
    ");
    $exists = $stmt->fetchColumn();

    if (!$exists) {
        echo "   ⚠ Tabla no existe. Creando en esquema 'comun'...\n";

        // Crear esquema comun si no existe
        $pdo->exec("CREATE SCHEMA IF NOT EXISTS comun");

        // Crear tabla
        $pdo->exec("
            CREATE TABLE comun.bloqueo_rfc_lic (
                rfc VARCHAR(13) NOT NULL,
                id_tramite INTEGER,
                licencia INTEGER,
                hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                vig CHAR(1) DEFAULT 'V',
                observacion VARCHAR(255),
                capturista VARCHAR(10),
                PRIMARY KEY (rfc, hora)
            )
        ");

        echo "   ✓ Tabla creada exitosamente\n";
    } else {
        echo "   ✓ Tabla existe\n";
    }

    // 4. Establecer search_path a public
    echo "\n4. Estableciendo search_path a public...\n";
    $pdo->exec("SET search_path TO public, comun");
    echo "   ✓ search_path establecido a 'public, comun'\n";

    // 5. Leer y ejecutar los SPs
    echo "\n5. Creando Stored Procedures en esquema public...\n";
    $sqlFile = __DIR__ . '/DEPLOY_BLOQUEORFC_SPS.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("No se encuentra el archivo: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    // Agregar SET search_path al inicio para asegurar
    $sql = "SET search_path TO public, comun;\n\n" . $sql;

    // Ejecutar todo el script
    $pdo->exec($sql);
    echo "   ✓ SPs creados exitosamente\n";

    // 6. Verificar que los SPs se crearon en public
    echo "\n6. Verificando SPs creados en public:\n";
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
        echo "   ⚠ NO SE ENCONTRARON los SPs en public\n";
    } else {
        foreach ($procedures as $proc) {
            echo "   ✓ public.{$proc['proname']}({$proc['args']})\n";
        }
    }

    // 7. Probar el SP de búsqueda
    echo "\n7. Probando sp_bloqueorfc_buscar_tramite...\n";
    try {
        $stmt = $pdo->query("SELECT * FROM public.sp_bloqueorfc_buscar_tramite(1)");
        $result = $stmt->fetch();
        if ($result) {
            echo "   ✓ SP ejecutado correctamente\n";
            echo "   Success: " . ($result['success'] ? 'true' : 'false') . "\n";
            echo "   Message: {$result['message']}\n";
        }
    } catch (Exception $e) {
        echo "   ⚠ Error: " . $e->getMessage() . "\n";
    }

    echo "\n✓✓✓ DESPLIEGUE COMPLETADO EN SERVIDOR REAL ✓✓✓\n";
    echo "\nServidor: $host\n";
    echo "Base de datos: $dbname\n";
    echo "Usuario: $user\n";
    echo "\nSPs disponibles en public:\n";
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
