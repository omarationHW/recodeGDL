<?php
/**
 * Script de Deployment: Stored Procedures para Baja de Licencias
 * Fecha: 2025-11-08
 * Database: padron_licencias
 * Schema: comun
 */

echo "==============================================\n";
echo "DEPLOYMENT: BajaLicencia Stored Procedures\n";
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
$sqlFile = __DIR__ . '/../RefactorX/Base/padron_licencias/database/ok/DEPLOY_BAJALICENCIA_SPS.sql';

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
          AND routine_name LIKE 'sp_bajalic%'
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

    // Test 1: sp_bajalic_buscar_licencia
    echo "1. Probando sp_bajalic_buscar_licencia...\n";
    try {
        $stmt = $pdo->prepare("SELECT * FROM comun.sp_bajalic_buscar_licencia(999999)");
        $stmt->execute();
        echo "   ✓ sp_bajalic_buscar_licencia funciona correctamente\n";
    } catch (Exception $e) {
        echo "   ⚠ sp_bajalic_buscar_licencia error: " . $e->getMessage() . "\n";
    }

    // Test 2: sp_bajalic_obtener_anuncios
    echo "2. Probando sp_bajalic_obtener_anuncios...\n";
    try {
        $stmt = $pdo->prepare("SELECT * FROM comun.sp_bajalic_obtener_anuncios(999999)");
        $stmt->execute();
        echo "   ✓ sp_bajalic_obtener_anuncios funciona correctamente\n";
    } catch (Exception $e) {
        echo "   ⚠ sp_bajalic_obtener_anuncios error: " . $e->getMessage() . "\n";
    }

    // Test 3: sp_bajalic_ejecutar (solo verificar que existe, no ejecutar)
    echo "3. Verificando sp_bajalic_ejecutar...\n";
    $stmt = $pdo->prepare("
        SELECT routine_name
        FROM information_schema.routines
        WHERE routine_schema = :schema
          AND routine_name = 'sp_bajalic_ejecutar'
    ");
    $stmt->execute(['schema' => $config['schema']]);
    if ($stmt->rowCount() > 0) {
        echo "   ✓ sp_bajalic_ejecutar existe (no ejecutado para evitar modificar datos)\n";
    } else {
        echo "   ✗ sp_bajalic_ejecutar NO encontrado\n";
    }

    echo "\n";
    echo "==============================================\n";
    echo "✓ DEPLOYMENT COMPLETADO EXITOSAMENTE\n";
    echo "==============================================\n";
    echo "\n";
    echo "Stored Procedures disponibles:\n";
    echo "  • comun.sp_bajalic_buscar_licencia(p_licencia)\n";
    echo "  • comun.sp_bajalic_obtener_anuncios(p_id_licencia)\n";
    echo "  • comun.sp_bajalic_ejecutar(p_licencia, p_motivo, p_anio, p_folio, p_baja_error, p_usuario)\n";
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
