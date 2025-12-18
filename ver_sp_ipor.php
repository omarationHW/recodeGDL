<?php
// Ver el stored procedure actual de ipor

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CONTENIDO DEL STORED PROCEDURE recaudadora_ipor ===\n\n";

    // Buscar el SP
    $stmt = $pdo->query("
        SELECT
            n.nspname as schema,
            p.proname as name,
            pg_get_function_arguments(p.oid) as arguments,
            pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'publico'
        AND p.proname = 'recaudadora_ipor'
    ");

    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "Schema: {$result['schema']}\n";
        echo "Nombre: {$result['name']}\n";
        echo "Argumentos: {$result['arguments']}\n\n";
        echo "Definición:\n";
        echo $result['definition'];
    } else {
        echo "No se encontró el stored procedure.\n";
    }

    // Buscar tablas que puedan relacionarse con IPOR
    echo "\n\n=== BUSCANDO TABLAS POSIBLES ===\n\n";

    $stmt2 = $pdo->query("
        SELECT
            schemaname,
            tablename,
            (SELECT COUNT(*) FROM information_schema.columns
             WHERE table_schema = schemaname
             AND table_name = tablename) as num_columnas
        FROM pg_tables
        WHERE schemaname IN ('public', 'publico')
        AND (tablename ILIKE '%ipor%' OR tablename ILIKE '%por%')
        ORDER BY schemaname, tablename
        LIMIT 10
    ");

    $tablas = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    if (count($tablas) > 0) {
        foreach ($tablas as $tabla) {
            echo "- {$tabla['schemaname']}.{$tabla['tablename']} ({$tabla['num_columnas']} columnas)\n";
        }
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
