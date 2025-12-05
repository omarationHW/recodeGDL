<?php
// Verificar si existe el SP y en qué schema
try {
    $pdo = new PDO(
        "pgsql:host=192.168.6.146;dbname=padron_licencias",
        "refact",
        "FF)-BQk2",
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    echo "=== VERIFICANDO SP recaudadora_drecgootrasobligaciones ===\n\n";

    // Buscar el SP en todos los schemas
    $sql = "
        SELECT
            n.nspname as schema_name,
            p.proname as sp_name,
            pg_get_function_arguments(p.oid) as arguments,
            pg_get_function_result(p.oid) as result_type
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname LIKE '%drecgootrasobligaciones%'
        ORDER BY n.nspname, p.proname
    ";

    $stmt = $pdo->query($sql);
    $sps = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($sps) > 0) {
        echo "SPs encontrados:\n\n";
        foreach ($sps as $sp) {
            echo "Schema: {$sp['schema_name']}\n";
            echo "Nombre: {$sp['sp_name']}\n";
            echo "Argumentos: {$sp['arguments']}\n";
            echo "Retorna: {$sp['result_type']}\n";
            echo "---\n\n";
        }
    } else {
        echo "❌ No se encontró el SP en ningún schema\n\n";
    }

    // Buscar tablas relacionadas con otras obligaciones
    echo "=== TABLAS RELACIONADAS CON OTRAS OBLIGACIONES ===\n\n";

    $schemas = ['comun', 'comunX', 'db_ingresos', 'public', 'catastro_gdl'];

    foreach ($schemas as $schema) {
        $sql = "
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = :schema
            AND (
                table_name LIKE '%otrasobligaciones%'
                OR table_name LIKE '%otras_obligaciones%'
                OR table_name LIKE '%contrib%'
                OR table_name LIKE '%rubro%'
            )
            ORDER BY table_name
        ";

        $stmt = $pdo->prepare($sql);
        $stmt->execute(['schema' => $schema]);
        $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($tables) > 0) {
            echo "Schema: $schema\n";
            foreach ($tables as $table) {
                echo "  - {$table['table_name']}\n";
            }
            echo "\n";
        }
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
