<?php
/**
 * Verificar SPs de dictamen en esquema comun
 * Fecha: 2025-11-05
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

    echo "\n========================================\n";
    echo "VERIFICACIÓN DE SPs - DICTAMEN\n";
    echo "========================================\n\n";

    // Buscar SPs en esquema 'comun'
    echo "📋 SPs relacionados con 'dictamen' en esquema 'comun':\n";
    echo str_repeat("-", 120) . "\n";

    $stmt = $pdo->query("
        SELECT
            proname as sp_name,
            pg_get_function_arguments(oid) as arguments,
            pg_get_function_result(oid) as return_type
        FROM pg_proc
        WHERE pronamespace = 'comun'::regnamespace
            AND (proname LIKE '%dictamen%')
        ORDER BY proname
    ");

    $sps_comun = $stmt->fetchAll(PDO::FETCH_OBJ);

    if (count($sps_comun) > 0) {
        foreach ($sps_comun as $sp) {
            echo "✅ {$sp->sp_name}\n";
            echo "   Parámetros: {$sp->arguments}\n";
            echo "   Retorna: " . substr($sp->return_type, 0, 80) . "...\n\n";
        }
    } else {
        echo "❌ No se encontraron SPs relacionados con 'dictamen'\n\n";
    }

    echo "\n========================================\n";
    echo "Total de SPs encontrados: " . count($sps_comun) . "\n";
    echo "========================================\n\n";

    // Verificar cual tabla usar
    echo "📊 COMPARACIÓN DE TABLAS:\n";
    echo str_repeat("-", 80) . "\n";

    $tables = ['dictamen', 'dictamenes'];
    foreach ($tables as $table) {
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM comun.$table");
        $result = $stmt->fetch(PDO::FETCH_OBJ);
        echo "📋 comun.$table: " . number_format($result->total) . " registros\n";
    }

    echo "\n";

} catch (PDOException $e) {
    echo "\n❌ ERROR: " . $e->getMessage() . "\n\n";
    exit(1);
}
