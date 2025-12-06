<?php
// Verificar existencia del SP sp_insert_cuota_energia

try {
    $conn = pg_connect("host=192.168.6.146 port=5432 dbname=mercados user=refact password=FF)-BQk2");

    if (!$conn) {
        echo "❌ Error de conexión\n";
        exit(1);
    }

    echo "=== VERIFICANDO SP sp_insert_cuota_energia ===\n\n";

    // Buscar el SP en todos los schemas
    $query = "
        SELECT
            n.nspname as schema,
            p.proname as function_name,
            pg_get_function_arguments(p.oid) as arguments
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'sp_insert_cuota_energia'
        ORDER BY n.nspname;
    ";

    $result = pg_query($conn, $query);

    if (!$result) {
        echo "❌ Error en consulta: " . pg_last_error($conn) . "\n";
        exit(1);
    }

    $count = pg_num_rows($result);

    if ($count === 0) {
        echo "❌ SP NO ENCONTRADO en ningún schema\n\n";

        // Verificar tabla ta_11_kilowhatts
        echo "=== VERIFICANDO TABLA ta_11_kilowhatts ===\n\n";

        $tableQuery = "
            SELECT
                schemaname,
                tablename
            FROM pg_tables
            WHERE tablename LIKE '%kilowhatts%'
            OR tablename LIKE '%11%'
            ORDER BY schemaname;
        ";

        $tableResult = pg_query($conn, $tableQuery);

        if ($tableResult && pg_num_rows($tableResult) > 0) {
            echo "Tablas encontradas:\n";
            while ($row = pg_fetch_assoc($tableResult)) {
                echo "  - {$row['schemaname']}.{$row['tablename']}\n";
            }
        } else {
            echo "No se encontró la tabla ta_11_kilowhatts\n";
        }

        echo "\n=== NECESITA DESPLIEGUE ===\n";

    } else {
        echo "✅ SP ENCONTRADO en {$count} schema(s):\n\n";

        while ($row = pg_fetch_assoc($result)) {
            echo "Schema: {$row['schema']}\n";
            echo "Función: {$row['function_name']}\n";
            echo "Argumentos: {$row['arguments']}\n";
            echo str_repeat("-", 80) . "\n";
        }
    }

    // Buscar también sp_list_cuotas_energia para comparar
    echo "\n=== VERIFICANDO sp_list_cuotas_energia ===\n\n";

    $query2 = "
        SELECT
            n.nspname as schema,
            p.proname as function_name
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'sp_list_cuotas_energia'
        ORDER BY n.nspname;
    ";

    $result2 = pg_query($conn, $query2);

    if ($result2 && pg_num_rows($result2) > 0) {
        echo "✅ sp_list_cuotas_energia ENCONTRADO en:\n";
        while ($row = pg_fetch_assoc($result2)) {
            echo "  - {$row['schema']}.{$row['function_name']}\n";
        }
    } else {
        echo "❌ sp_list_cuotas_energia NO ENCONTRADO\n";
    }

    pg_close($conn);

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
