<?php
// Script para buscar tablas relacionadas con descuentos en la BD multas_reglamentos

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // Buscar todas las tablas que contengan 'desc' en el esquema public
    echo "=== BUSCANDO TABLAS CON 'DESC' EN ESQUEMA PUBLIC ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename ILIKE '%desc%'
        ORDER BY tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        echo "Tablas encontradas con 'desc':\n";
        foreach ($tables as $table) {
            // Obtener conteo de registros
            try {
                $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM {$table['schemaname']}.{$table['tablename']}");
                $count = $count_stmt->fetch(PDO::FETCH_ASSOC);
                echo "  - {$table['schemaname']}.{$table['tablename']} ({$count['total']} registros)\n";
            } catch (PDOException $e) {
                echo "  - {$table['schemaname']}.{$table['tablename']} (error al contar)\n";
            }
        }
    } else {
        echo "No se encontraron tablas con 'desc' en su nombre.\n";
    }

    // Buscar tablas con 'descuento' o 'descto'
    echo "\n\n=== BUSCANDO TABLAS CON 'DESCUENTO' O 'DESCTO' ===\n\n";

    $stmt = $pdo->query("
        SELECT
            schemaname,
            tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND (tablename ILIKE '%descuento%' OR tablename ILIKE '%descto%')
        ORDER BY tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        echo "Tablas encontradas:\n";
        foreach ($tables as $table) {
            // Obtener conteo de registros
            $count_stmt = $pdo->query("SELECT COUNT(*) as total FROM {$table['schemaname']}.{$table['tablename']}");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC);

            echo "  - {$table['schemaname']}.{$table['tablename']} ({$count['total']} registros)\n";
        }
    } else {
        echo "No se encontraron tablas con 'descuento' o 'descto'.\n";
    }

    // Buscar en la tabla de multas si hay campos relacionados con descuentos
    echo "\n\n=== VERIFICANDO CAMPOS EN publico.multas ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'multas'
        AND (column_name ILIKE '%desc%' OR column_name ILIKE '%bonif%' OR column_name ILIKE '%reduc%')
        ORDER BY ordinal_position
    ");

    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($columns) > 0) {
        echo "Campos relacionados con descuentos en publico.multas:\n";
        foreach ($columns as $col) {
            $type = $col['data_type'];
            if ($col['character_maximum_length']) {
                $type .= "({$col['character_maximum_length']})";
            }
            echo "  - {$col['column_name']}: {$type}\n";
        }
    } else {
        echo "No se encontraron campos relacionados con descuentos en publico.multas.\n";
    }

    // Listar todas las tablas del esquema public para referencia
    echo "\n\n=== TODAS LAS TABLAS EN ESQUEMA PUBLIC (primeras 30) ===\n\n";

    $stmt = $pdo->query("
        SELECT
            tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        ORDER BY tablename
        LIMIT 30
    ");

    $all_tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($all_tables as $table) {
        echo "  - {$table['tablename']}\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
