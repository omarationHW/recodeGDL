<?php
// Buscar tablas relacionadas con descuentos en la BD multas_reglamentos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== BUSCANDO TABLAS CON 'DESCUENTO' O 'DESCTO' ===\n\n";

    // Buscar tablas con 'descuento' o 'descto'
    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename,
            (SELECT COUNT(*) FROM information_schema.columns
             WHERE table_schema = schemaname
             AND table_name = tablename) as num_columnas
        FROM pg_tables
        WHERE schemaname IN ('public', 'publico')
        AND (tablename ILIKE '%descuento%' OR tablename ILIKE '%descto%')
        ORDER BY schemaname, tablename
    ");

    $tablas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tablas) > 0) {
        foreach ($tablas as $tabla) {
            echo "Esquema: {$tabla['schemaname']}\n";
            echo "Tabla: {$tabla['tablename']}\n";
            echo "Columnas: {$tabla['num_columnas']}\n";

            // Contar registros
            $tabla_completa = "{$tabla['schemaname']}.{$tabla['tablename']}";
            try {
                $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM $tabla_completa");
                $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
                echo "Registros: " . number_format($count['total']) . "\n";
            } catch (Exception $e) {
                echo "Registros: No se puede contar\n";
            }

            // Mostrar columnas
            $col_stmt = $pdo->prepare("
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = ? AND table_name = ?
                ORDER BY ordinal_position
            ");
            $col_stmt->execute([$tabla['schemaname'], $tabla['tablename']]);
            $columnas = $col_stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "Columnas:\n";
            foreach ($columnas as $col) {
                echo "  - {$col['column_name']} ({$col['data_type']})\n";
            }

            echo "\n" . str_repeat("-", 60) . "\n\n";
        }
    } else {
        echo "No se encontraron tablas con 'descuento' o 'descto'\n\n";
    }

    // Buscar stored procedures existentes
    echo "\n=== STORED PROCEDURES EXISTENTES CON 'DESCTO' ===\n\n";

    $sp_stmt = $pdo->query("
        SELECT
            n.nspname as schema,
            p.proname as name,
            pg_get_function_arguments(p.oid) as arguments
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname IN ('public', 'publico')
        AND p.proname ILIKE '%descto%'
        ORDER BY n.nspname, p.proname
    ");

    $procedures = $sp_stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($procedures) > 0) {
        foreach ($procedures as $proc) {
            echo "Schema: {$proc['schema']}\n";
            echo "Nombre: {$proc['name']}\n";
            echo "Argumentos: {$proc['arguments']}\n\n";
        }
    } else {
        echo "No se encontraron stored procedures con 'descto'\n";
    }

    // Buscar en req_400 si tiene info de descuentos
    echo "\n=== VERIFICANDO COLUMNAS EN req_400 ===\n\n";
    $req_stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'req_400'
        AND column_name ILIKE '%desc%'
        ORDER BY ordinal_position
    ");

    $cols_req = $req_stmt->fetchAll(PDO::FETCH_ASSOC);
    if (count($cols_req) > 0) {
        echo "Columnas relacionadas con descuentos en req_400:\n";
        foreach ($cols_req as $col) {
            echo "  - {$col['column_name']} ({$col['data_type']})\n";
        }
    } else {
        echo "No hay columnas relacionadas con descuentos en req_400\n";
    }

    // Buscar en reqmultas
    echo "\n=== VERIFICANDO COLUMNAS EN reqmultas ===\n\n";
    $reqm_stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'publico' AND table_name = 'reqmultas'
        AND column_name ILIKE '%desc%'
        ORDER BY ordinal_position
    ");

    $cols_reqm = $reqm_stmt->fetchAll(PDO::FETCH_ASSOC);
    if (count($cols_reqm) > 0) {
        echo "Columnas relacionadas con descuentos en reqmultas:\n";
        foreach ($cols_reqm as $col) {
            echo "  - {$col['column_name']} ({$col['data_type']})\n";
        }
    } else {
        echo "No hay columnas relacionadas con descuentos en reqmultas\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
