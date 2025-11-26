<?php
/**
 * Script para verificar si existe el SP recaudadora_autdescto
 * y en qué esquemas
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Verificando SP recaudadora_autdescto ===\n\n";

    // Buscar en todos los esquemas
    $sql = "
        SELECT
            n.nspname as schema,
            p.proname as sp_name,
            pg_get_function_arguments(p.oid) as arguments,
            pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname ILIKE '%autdescto%'
        ORDER BY n.nspname, p.proname;
    ";

    $stmt = $pdo->query($sql);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (empty($results)) {
        echo "❌ No se encontró ningún SP con 'autdescto' en ningún esquema\n\n";

        // Buscar SPs relacionados con recaudadora
        echo "Buscando otros SPs de recaudadora:\n";
        $sql2 = "
            SELECT
                n.nspname as schema,
                p.proname as sp_name
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE p.proname ILIKE 'recaudadora%'
            ORDER BY n.nspname, p.proname
            LIMIT 20;
        ";
        $stmt2 = $pdo->query($sql2);
        $results2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

        foreach ($results2 as $row) {
            echo "  - {$row['schema']}.{$row['sp_name']}\n";
        }
    } else {
        foreach ($results as $row) {
            echo "✅ Encontrado: {$row['schema']}.{$row['sp_name']}\n";
            echo "Argumentos: {$row['arguments']}\n";
            echo "\nDefinición:\n";
            echo str_repeat("-", 80) . "\n";
            echo $row['definition'] . "\n";
            echo str_repeat("-", 80) . "\n\n";
        }
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
