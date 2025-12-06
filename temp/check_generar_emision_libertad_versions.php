<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== Versiones del SP generar_emision_libertad ===\n\n";

$sql = "
    SELECT
        p.proname as function_name,
        pg_get_function_arguments(p.oid) as arguments,
        pg_get_function_result(p.oid) as return_type,
        n.nspname as schema_name
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE p.proname = 'generar_emision_libertad'
    ORDER BY n.nspname, p.oid
";

$stmt = $pdo->query($sql);
$functions = $stmt->fetchAll(PDO::FETCH_ASSOC);

if (count($functions) > 0) {
    echo "Encontradas " . count($functions) . " versiones:\n\n";

    foreach ($functions as $i => $func) {
        echo "Versión " . ($i + 1) . ":\n";
        echo "  Schema: {$func['schema_name']}\n";
        echo "  Nombre: {$func['function_name']}\n";
        echo "  Argumentos: {$func['arguments']}\n";
        echo "  Retorno: {$func['return_type']}\n";
        echo "\n";

        // Generar comando DROP
        echo "  DROP: DROP FUNCTION IF EXISTS {$func['schema_name']}.generar_emision_libertad({$func['arguments']});\n";
        echo "\n";
    }

    echo "\n=== Script para limpiar versiones antiguas ===\n\n";
    echo "-- Eliminar TODAS las versiones\n";
    foreach ($functions as $func) {
        echo "DROP FUNCTION IF EXISTS {$func['schema_name']}.generar_emision_libertad({$func['arguments']});\n";
    }

} else {
    echo "No se encontraron versiones del SP\n";
}
