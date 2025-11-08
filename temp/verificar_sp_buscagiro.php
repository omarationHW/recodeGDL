<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "BUSCAR SP: buscagiro\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Buscar SPs relacionados con buscagiro
    $stmt = $pdo->query("
        SELECT
            n.nspname as schema,
            p.proname as name,
            pg_get_function_arguments(p.oid) as arguments
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname ILIKE '%buscagiro%'
        OR p.proname ILIKE '%busca_giro%'
        ORDER BY n.nspname, p.proname
    ");

    $procedures = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($procedures) > 0) {
        echo "SPs encontrados:\n\n";
        foreach ($procedures as $proc) {
            echo "  • {$proc['schema']}.{$proc['name']}\n";
            echo "    Parámetros: {$proc['arguments']}\n\n";
        }
    } else {
        echo "❌ No se encontraron SPs relacionados con 'buscagiro'\n\n";
        echo "Necesitamos crear un SP nuevo para búsqueda de giros.\n";
    }

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
