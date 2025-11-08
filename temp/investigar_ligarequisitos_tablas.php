<?php
/**
 * Investigación de tablas para LigaRequisitos
 * Fecha: 2025-11-06
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conectado a servidor real: $host\n\n";

    // 1. Buscar tablas relacionadas con giros
    echo "1. TABLAS RELACIONADAS CON GIROS:\n";
    echo str_repeat("=", 60) . "\n";

    $tablesGiros = "
    SELECT
        schemaname,
        tablename,
        CASE
            WHEN tablename LIKE '%giro%' THEN 'GIRO'
            WHEN tablename LIKE '%requisito%' THEN 'REQUISITO'
            WHEN tablename LIKE '%liga%' THEN 'LIGA'
        END as tipo
    FROM pg_tables
    WHERE schemaname IN ('public', 'comun')
    AND (
        tablename LIKE '%giro%'
        OR tablename LIKE '%requisito%'
        OR tablename LIKE '%liga%'
    )
    ORDER BY tipo, schemaname, tablename
    ";

    $stmt = $pdo->query($tablesGiros);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "  [{$table['tipo']}] {$table['schemaname']}.{$table['tablename']}\n";
    }

    // 2. Buscar tabla específica de liga de requisitos
    echo "\n\n2. ESTRUCTURA DE TABLA DE LIGA (si existe):\n";
    echo str_repeat("=", 60) . "\n";

    $checkLiga = "
    SELECT
        table_schema,
        table_name,
        column_name,
        data_type,
        character_maximum_length
    FROM information_schema.columns
    WHERE table_schema IN ('public', 'comun')
    AND table_name IN ('giro_requisitos', 'requisitos_giro', 'liga_requisitos')
    ORDER BY table_schema, table_name, ordinal_position
    ";

    $stmt = $pdo->query($checkLiga);
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($columns) > 0) {
        $currentTable = '';
        foreach ($columns as $col) {
            $table = $col['table_schema'] . '.' . $col['table_name'];
            if ($table !== $currentTable) {
                echo "\n  TABLA: $table\n";
                $currentTable = $table;
            }
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            echo "    - {$col['column_name']}: {$col['data_type']}$length\n";
        }
    } else {
        echo "  ⚠ No se encontró tabla específica de liga\n";
    }

    // 3. Ver estructura de tabla giros
    echo "\n\n3. ESTRUCTURA DE TABLA GIROS:\n";
    echo str_repeat("=", 60) . "\n";

    $checkGiros = "
    SELECT
        table_schema,
        table_name,
        column_name,
        data_type,
        character_maximum_length
    FROM information_schema.columns
    WHERE table_schema IN ('public', 'comun')
    AND table_name = 'giros'
    ORDER BY ordinal_position
    ";

    $stmt = $pdo->query($checkGiros);
    $girosColumns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($girosColumns) > 0) {
        $table = $girosColumns[0]['table_schema'] . '.' . $girosColumns[0]['table_name'];
        echo "\n  TABLA: $table\n";
        foreach ($girosColumns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            echo "    - {$col['column_name']}: {$col['data_type']}$length\n";
        }
    }

    // 4. Ver estructura de tabla requisitos_doc
    echo "\n\n4. ESTRUCTURA DE TABLA REQUISITOS:\n";
    echo str_repeat("=", 60) . "\n";

    $checkRequisitos = "
    SELECT
        table_schema,
        table_name,
        column_name,
        data_type,
        character_maximum_length
    FROM information_schema.columns
    WHERE table_schema IN ('public', 'comun')
    AND table_name = 'requisitos_doc'
    ORDER BY ordinal_position
    ";

    $stmt = $pdo->query($checkRequisitos);
    $reqColumns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($reqColumns) > 0) {
        $table = $reqColumns[0]['table_schema'] . '.' . $reqColumns[0]['table_name'];
        echo "\n  TABLA: $table\n";
        foreach ($reqColumns as $col) {
            $length = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
            echo "    - {$col['column_name']}: {$col['data_type']}$length\n";
        }
    }

    // 5. Probar datos reales
    echo "\n\n5. DATOS DE PRUEBA:\n";
    echo str_repeat("=", 60) . "\n";

    echo "\n  Giros disponibles (primeros 5):\n";
    $testGiros = $pdo->query("SELECT id_giro, descripcion FROM comun.giros ORDER BY id_giro LIMIT 5");
    $giros = $testGiros->fetchAll(PDO::FETCH_ASSOC);
    foreach ($giros as $giro) {
        echo "    ID: {$giro['id_giro']} - {$giro['descripcion']}\n";
    }

    echo "\n  Requisitos disponibles (primeros 5):\n";
    $testReq = $pdo->query("SELECT id_requisito, descripcion FROM comun.requisitos_doc ORDER BY id_requisito LIMIT 5");
    $requisitos = $testReq->fetchAll(PDO::FETCH_ASSOC);
    foreach ($requisitos as $req) {
        echo "    ID: {$req['id_requisito']} - {$req['descripcion']}\n";
    }

    echo "\n\n✓ Investigación completada\n";

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
