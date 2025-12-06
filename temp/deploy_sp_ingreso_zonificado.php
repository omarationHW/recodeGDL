<?php
/**
 * Script de despliegue para sp_ingreso_zonificado
 * Base: mercados
 */

$host = '192.168.214.133';
$port = '5432';
$database = 'mercados';
$user = 'postgres';
$password = 'sistemas2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$database";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "Conectado a la base de datos mercados\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/ok/94_SP_MERCADOS_RPTINGRESOZONIFICADO_EXACTO_all_procedures.sql';
    $sql = file_get_contents($sqlFile);

    // Remover comandos psql
    $sql = preg_replace('/^\\\c\s+\w+;/m', '', $sql);
    $sql = preg_replace('/^SET\s+search_path\s+TO\s+\w+;/m', '', $sql);

    // Establecer search_path
    $pdo->exec("SET search_path TO public");

    // Ejecutar el SQL
    $pdo->exec($sql);

    echo "✓ SP sp_ingreso_zonificado desplegado correctamente\n";

    // Verificar el SP
    $stmt = $pdo->query("
        SELECT
            p.proname,
            pg_catalog.pg_get_function_arguments(p.oid) as args,
            pg_catalog.pg_get_function_result(p.oid) as result
        FROM pg_proc p
        WHERE p.proname = 'sp_ingreso_zonificado'
    ");
    $sp = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp) {
        echo "\n✓ SP verificado:\n";
        echo "  Nombre: {$sp['proname']}\n";
        echo "  Argumentos: {$sp['args']}\n";
        echo "  Retorna: {$sp['result']}\n";
    } else {
        echo "\n✗ No se pudo verificar el SP\n";
        exit(1);
    }

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
