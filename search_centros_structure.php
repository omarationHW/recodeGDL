<?php
// Script para buscar tablas con campos relacionados a centros

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar tablas que contengan columnas específicas
    echo "=== BUSCANDO TABLAS CON COLUMNAS 'nombre_centro', 'tipo_centro', etc. ===\n";
    $stmt = $pdo->query("
        SELECT DISTINCT table_schema, table_name
        FROM information_schema.columns
        WHERE (column_name ILIKE '%nombre_centro%'
           OR column_name ILIKE '%tipo_centro%'
           OR column_name ILIKE '%clave_centro%'
           OR column_name ILIKE '%responsable%')
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        echo "Tablas encontradas:\n";
        foreach ($tables as $table) {
            echo "  - {$table['table_schema']}.{$table['table_name']}\n";
        }
    } else {
        echo "  (No se encontraron tablas con esas columnas)\n";
    }

    // Buscar tablas que puedan ser de dependencias o instituciones
    echo "\n\n=== BUSCANDO TABLAS CON 'DEPENDENCIA' O 'INSTITUCION' ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name ILIKE '%depend%' OR table_name ILIKE '%institu%')
        AND table_type = 'BASE TABLE'
        AND table_schema IN ('public', 'publico')
        ORDER BY table_schema, table_name
    ");
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            $schema = $table['table_schema'];
            $tableName = $table['table_name'];
            echo "\n{$schema}.{$tableName}:\n";

            // Ver estructura
            $stmt = $pdo->query("
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = '$schema'
                AND table_name = '$tableName'
                ORDER BY ordinal_position
            ");
            $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

            foreach ($columns as $col) {
                echo "  - {$col['column_name']}: {$col['data_type']}\n";
            }

            // Ver datos de ejemplo
            try {
                $stmt = $pdo->query("SELECT * FROM {$schema}.{$tableName} LIMIT 2");
                $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
                if (count($rows) > 0) {
                    echo "  Ejemplo 1: ";
                    $cols = array_slice(array_keys($rows[0]), 0, 3);
                    foreach ($cols as $c) {
                        echo "$c=" . $rows[0][$c] . " ";
                    }
                    echo "\n";
                }
            } catch (Exception $e) {
                echo "  (Error al leer datos)\n";
            }
        }
    } else {
        echo "  (No se encontraron tablas relacionadas)\n";
    }

    // Ver el contenido del stored procedure existente
    echo "\n\n=== CONTENIDO DEL STORED PROCEDURE recaudadora_centrosfrm ===\n";
    $stmt = $pdo->query("
        SELECT pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'recaudadora_centrosfrm'
        AND n.nspname = 'publico'
    ");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo $result['definition'];
        echo "\n";
    } else {
        echo "  (No se encontró el stored procedure)\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
