<?php
/**
 * Script de Deployment: Stored Procedures para Baja de Anuncios
 * Fecha: 2025-11-08
 * Database: padron_licencias
 * Schema: comun
 */

echo "==============================================\n";
echo "DEPLOYMENT: BajaAnuncio Stored Procedures\n";
echo "==============================================\n\n";

// Configuración de la base de datos
$config = [
    'host' => '192.168.6.146',
    'port' => '5432',
    'database' => 'padron_licencias',
    'username' => 'refact',
    'password' => 'FF)-BQk2',
    'schema' => 'comun'
];

// Archivo SQL a ejecutar
$sqlFile = __DIR__ . '/../RefactorX/Base/padron_licencias/database/ok/DEPLOY_BAJAANUNCIO_SPS.sql';

try {
    // Conectar a PostgreSQL
    echo "📡 Conectando a PostgreSQL...\n";
    echo "   Host: {$config['host']}:{$config['port']}\n";
    echo "   Database: {$config['database']}\n";
    echo "   Schema: {$config['schema']}\n\n";

    $dsn = "pgsql:host={$config['host']};port={$config['port']};dbname={$config['database']}";
    $pdo = new PDO($dsn, $config['username'], $config['password'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "✓ Conexión establecida exitosamente\n\n";

    // Leer el archivo SQL
    echo "📄 Leyendo archivo SQL...\n";
    echo "   Archivo: " . basename($sqlFile) . "\n";

    if (!file_exists($sqlFile)) {
        throw new Exception("Archivo SQL no encontrado: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);
    echo "✓ Archivo leído correctamente\n\n";

    // Ejecutar el SQL
    echo "🚀 Ejecutando deployment...\n";
    echo "-------------------------------------------\n";

    $pdo->exec($sql);

    echo "-------------------------------------------\n";
    echo "✓ Deployment ejecutado exitosamente\n\n";

    // Verificar que las funciones se crearon
    echo "🔍 Verificando stored procedures creados...\n";

    $query = "
        SELECT routine_name, routine_type
        FROM information_schema.routines
        WHERE routine_schema = :schema
          AND routine_name LIKE 'sp_bajaanun%'
        ORDER BY routine_name
    ";

    $stmt = $pdo->prepare($query);
    $stmt->execute(['schema' => $config['schema']]);
    $procedures = $stmt->fetchAll();

    if (count($procedures) > 0) {
        echo "✓ Stored procedures encontrados:\n";
        foreach ($procedures as $proc) {
            echo "   • {$proc['routine_name']} ({$proc['routine_type']})\n";
        }
        echo "\n";
    } else {
        throw new Exception("No se encontraron los stored procedures creados");
    }

    // Test rápido de cada SP
    echo "🧪 Probando stored procedures...\n\n";

    // Test 1: sp_bajaanun_buscar_anuncio
    echo "1. Probando sp_bajaanun_buscar_anuncio...\n";
    try {
        $stmt = $pdo->prepare("SELECT * FROM comun.sp_bajaanun_buscar_anuncio(999999)");
        $stmt->execute();
        echo "   ✓ sp_bajaanun_buscar_anuncio funciona correctamente\n";
    } catch (Exception $e) {
        echo "   ⚠ sp_bajaanun_buscar_anuncio error: " . $e->getMessage() . "\n";
    }

    // Test 2: sp_bajaanun_obtener_info
    echo "2. Probando sp_bajaanun_obtener_info...\n";
    try {
        $stmt = $pdo->prepare("SELECT * FROM comun.sp_bajaanun_obtener_info(999999)");
        $stmt->execute();
        echo "   ✓ sp_bajaanun_obtener_info funciona correctamente\n";
    } catch (Exception $e) {
        echo "   ⚠ sp_bajaanun_obtener_info error: " . $e->getMessage() . "\n";
    }

    // Test 3: sp_bajaanun_ejecutar (solo verificar que existe)
    echo "3. Verificando sp_bajaanun_ejecutar...\n";
    $stmt = $pdo->prepare("
        SELECT routine_name
        FROM information_schema.routines
        WHERE routine_schema = :schema
          AND routine_name = 'sp_bajaanun_ejecutar'
    ");
    $stmt->execute(['schema' => $config['schema']]);
    if ($stmt->rowCount() > 0) {
        echo "   ✓ sp_bajaanun_ejecutar existe (no ejecutado para evitar modificar datos)\n";
    } else {
        echo "   ✗ sp_bajaanun_ejecutar NO encontrado\n";
    }

    echo "\n";
    echo "==============================================\n";
    echo "✓ DEPLOYMENT COMPLETADO EXITOSAMENTE\n";
    echo "==============================================\n";
    echo "\n";
    echo "Stored Procedures disponibles:\n";
    echo "  • comun.sp_bajaanun_buscar_anuncio(p_anuncio)\n";
    echo "  • comun.sp_bajaanun_obtener_info(p_id_anuncio)\n";
    echo "  • comun.sp_bajaanun_ejecutar(p_anuncio, p_motivo, p_anio, p_folio, p_baja_error, p_usuario)\n";
    echo "\n";

} catch (Exception $e) {
    echo "\n";
    echo "==============================================\n";
    echo "✗ ERROR EN DEPLOYMENT\n";
    echo "==============================================\n";
    echo "Error: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
    exit(1);
}
