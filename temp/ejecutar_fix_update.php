<?php
/**
 * Fix: sp_catalogogiros_update
 * Permite editar sin cambiar el código cuando ya existe duplicado
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
    echo "APLICANDO FIX A sp_catalogogiros_update\n";
    echo "========================================\n\n";

    $sqlFile = __DIR__ . '/fix_sp_update.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("Archivo SQL no encontrado: $sqlFile");
    }

    echo "📄 Leyendo archivo fix...\n\n";
    $sql = file_get_contents($sqlFile);

    echo "⚙️  Ejecutando fix...\n\n";
    $pdo->exec($sql);

    echo "✅ SP actualizado exitosamente!\n\n";

    // Verificar
    $stmt = $pdo->query("
        SELECT
            proname as sp_name,
            pg_get_function_arguments(oid) as arguments
        FROM pg_proc
        WHERE pronamespace = 'comun'::regnamespace
            AND proname = 'sp_catalogogiros_update'
    ");

    $sp = $stmt->fetch(PDO::FETCH_OBJ);

    if ($sp) {
        echo "✅ SP verificado: {$sp->sp_name}\n\n";
    }

    echo "========================================\n";
    echo "CAMBIO APLICADO\n";
    echo "========================================\n\n";
    echo "Ahora puedes editar giros sin problemas.\n";
    echo "El SP solo valida duplicados si intentas CAMBIAR el código.\n";
    echo "Si mantienes el código original, no dará error.\n\n";

} catch (PDOException $e) {
    echo "\n❌ ERROR DE BASE DE DATOS:\n";
    echo "   " . $e->getMessage() . "\n\n";
    exit(1);
} catch (Exception $e) {
    echo "\n❌ ERROR:\n";
    echo "   " . $e->getMessage() . "\n\n";
    exit(1);
}
