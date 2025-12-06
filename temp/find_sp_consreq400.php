<?php
/**
 * Script para encontrar el stored procedure RECAUDADORA_CONSREQ400
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== BÚSQUEDA DEL STORED PROCEDURE RECAUDADORA_CONSREQ400 ===\n\n";

    // Buscar el stored procedure
    $sp = $pdo->query("
        SELECT
            n.nspname as schema,
            p.proname as name,
            pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname ILIKE '%consreq400%'
           OR p.proname ILIKE 'recaudadora_consreq400'
    ")->fetchAll(PDO::FETCH_ASSOC);

    if (count($sp) > 0) {
        echo "Stored Procedure encontrado:\n";
        foreach ($sp as $proc) {
            echo "\n";
            echo "Schema: {$proc['schema']}\n";
            echo "Nombre: {$proc['name']}\n";
            echo "Definición:\n";
            echo str_repeat("=", 80) . "\n";
            echo $proc['definition'];
            echo "\n" . str_repeat("=", 80) . "\n\n";

            // Buscar referencias a tablas en la definición
            if (preg_match_all('/FROM\s+([a-z_]+\.[a-z_0-9]+|[a-z_0-9]+)/i', $proc['definition'], $matches)) {
                echo "Tablas referenciadas:\n";
                foreach (array_unique($matches[1]) as $table) {
                    echo "  - $table\n";
                }
            }
        }
    } else {
        echo "No se encontró el stored procedure.\n";
        echo "Buscando en archivos SQL generados...\n\n";

        // Buscar en el archivo SQL generado
        $sqlFile = 'C:/recodeGDL/RefactorX/Base/multas_reglamentos/database/generated/recaudadora_consreq400.sql';
        if (file_exists($sqlFile)) {
            echo "Archivo encontrado: $sqlFile\n";
            echo str_repeat("=", 80) . "\n";
            echo file_get_contents($sqlFile);
            echo "\n" . str_repeat("=", 80) . "\n\n";
        }
    }

} catch (PDOException $e) {
    echo "Error de conexión: " . $e->getMessage() . "\n";
}
