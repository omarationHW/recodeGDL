<?php
/**
 * Verificar SPs de dictamenes en ambos esquemas
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
    echo "VERIFICACIÓN DE SPs - DICTAMENES\n";
    echo "========================================\n\n";

    // Buscar SPs en esquema 'guadalajara'
    echo "📋 SPs en esquema 'guadalajara':\n";
    echo str_repeat("-", 80) . "\n";

    $stmt = $pdo->query("
        SELECT
            proname as sp_name,
            pg_get_function_arguments(oid) as arguments
        FROM pg_proc
        WHERE pronamespace = 'guadalajara'::regnamespace
            AND proname LIKE '%dictamen%'
        ORDER BY proname
    ");

    $sps_guadalajara = $stmt->fetchAll(PDO::FETCH_OBJ);

    if (count($sps_guadalajara) > 0) {
        foreach ($sps_guadalajara as $sp) {
            echo "✅ {$sp->sp_name}\n";
            echo "   Parámetros: {$sp->arguments}\n\n";
        }
    } else {
        echo "❌ No se encontraron SPs en esquema 'guadalajara'\n\n";
    }

    // Buscar SPs en esquema 'comun'
    echo "\n📋 SPs en esquema 'comun':\n";
    echo str_repeat("-", 80) . "\n";

    $stmt = $pdo->query("
        SELECT
            proname as sp_name,
            pg_get_function_arguments(oid) as arguments
        FROM pg_proc
        WHERE pronamespace = 'comun'::regnamespace
            AND proname LIKE '%dictamen%'
        ORDER BY proname
    ");

    $sps_comun = $stmt->fetchAll(PDO::FETCH_OBJ);

    if (count($sps_comun) > 0) {
        foreach ($sps_comun as $sp) {
            echo "✅ {$sp->sp_name}\n";
            echo "   Parámetros: {$sp->arguments}\n\n";
        }
    } else {
        echo "❌ No se encontraron SPs en esquema 'comun'\n\n";
    }

    echo "\n========================================\n";
    echo "RESUMEN\n";
    echo "========================================\n";
    echo "SPs en 'guadalajara': " . count($sps_guadalajara) . "\n";
    echo "SPs en 'comun': " . count($sps_comun) . "\n\n";

} catch (PDOException $e) {
    echo "\n❌ ERROR DE BASE DE DATOS:\n";
    echo "   " . $e->getMessage() . "\n\n";
    exit(1);
}
