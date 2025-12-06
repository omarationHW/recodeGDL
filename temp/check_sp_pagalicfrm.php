<?php
/**
 * Verificar existencia del SP recaudadora_pagalicfrm
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    echo "=================================================\n";
    echo "VERIFICANDO SP: recaudadora_pagalicfrm\n";
    echo "=================================================\n\n";

    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Buscar el SP en todos los esquemas
    $sql = "
        SELECT
            n.nspname AS schema_name,
            p.proname AS function_name,
            pg_get_function_arguments(p.oid) AS arguments,
            pg_get_function_result(p.oid) AS return_type,
            d.description
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        LEFT JOIN pg_description d ON p.oid = d.objoid
        WHERE p.proname = 'recaudadora_pagalicfrm'
        ORDER BY n.nspname
    ";

    $stmt = $pdo->query($sql);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (empty($results)) {
        echo "❌ SP NO ENCONTRADO en ningún esquema\n\n";
        echo "El SP debe desplegarse ejecutando:\n";
        echo "  php RefactorX/BackEnd/deploy_sp_pagalicfrm_optimized.php\n\n";
    } else {
        echo "✅ SP ENCONTRADO:\n\n";
        foreach ($results as $result) {
            echo "Esquema: {$result['schema_name']}\n";
            echo "Función: {$result['function_name']}\n";
            echo "Argumentos: {$result['arguments']}\n";
            echo "Retorna: {$result['return_type']}\n";
            echo "Descripción: " . ($result['description'] ?? 'N/A') . "\n";
            echo str_repeat("-", 50) . "\n";
        }

        // Verificar tablas que usa
        echo "\n📊 TABLAS QUE USA EL SP:\n";
        $tablesSql = "
            SELECT schemaname, tablename
            FROM pg_tables
            WHERE tablename IN ('licencias', 'detsal_lic')
            AND schemaname IN ('public', 'comun', 'multas_reglamentos')
            ORDER BY schemaname, tablename
        ";

        $tablesStmt = $pdo->query($tablesSql);
        $tables = $tablesStmt->fetchAll(PDO::FETCH_ASSOC);

        if (empty($tables)) {
            echo "⚠ No se encontraron las tablas necesarias\n";
        } else {
            foreach ($tables as $table) {
                echo "  ✓ {$table['schemaname']}.{$table['tablename']}\n";
            }
        }
    }

    echo "\n=================================================\n";

} catch (PDOException $e) {
    echo "\n❌ ERROR DE BASE DE DATOS:\n";
    echo "Mensaje: " . $e->getMessage() . "\n";
    echo "Código: " . $e->getCode() . "\n";
    exit(1);
}
