<?php
try {
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Buscando funciones relacionadas con 'codifica' o 'encode' ===\n\n";

    // Buscar funciones con "codifica" o "encode"
    $stmt = $pdo->query("
        SELECT
            n.nspname as schema_name,
            p.proname as function_name,
            pg_get_function_arguments(p.oid) as arguments,
            pg_get_function_result(p.oid) as result_type
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname IN ('public', 'comun', 'catastro_gdl', 'db_ingresos')
        AND (p.proname ILIKE '%codif%' OR p.proname ILIKE '%encod%' OR p.proname ILIKE '%barr%' OR p.proname ILIKE '%hash%')
        ORDER BY n.nspname, p.proname
    ");

    $functions = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($functions) > 0) {
        echo "Funciones encontradas:\n";
        foreach ($functions as $func) {
            echo "\n{$func['schema_name']}.{$func['function_name']}({$func['arguments']})\n";
            echo "  Returns: {$func['result_type']}\n";
        }
    } else {
        echo "No se encontraron funciones de codificación.\n";
    }

    echo "\n\n=== Buscando tablas relacionadas con códigos de barras ===\n\n";

    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_schema IN ('catastro_gdl', 'public', 'comun', 'db_ingresos')
        AND (table_name ILIKE '%barr%' OR table_name ILIKE '%codif%' OR table_name ILIKE '%codigo%')
        ORDER BY table_schema, table_name
        LIMIT 20
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        echo "Tablas encontradas:\n";
        foreach ($tables as $table) {
            echo "- {$table['table_schema']}.{$table['table_name']}\n";
        }
    } else {
        echo "No se encontraron tablas relacionadas.\n";
    }

    // Ver funciones built-in de PostgreSQL para encoding
    echo "\n\n=== Funciones de PostgreSQL disponibles para encoding ===\n";
    echo "- encode(bytea, text) - Codifica datos binarios a texto\n";
    echo "- decode(text, text) - Decodifica texto a binarios\n";
    echo "- md5(text) - Hash MD5\n";
    echo "- sha256(bytea) - Hash SHA256 (si está disponible)\n";
    echo "- to_hex(integer) - Convierte a hexadecimal\n";

} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
