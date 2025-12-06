<?php
/**
 * Script para buscar tablas relacionadas con adeudos, pagos y requerimientos de locales
 */

$host = "192.168.6.146";
$port = "5432";
$dbname = "mercados";
$user = "refact";
$password = "FF)-BQk2";

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "\n=== BÚSQUEDA DE TABLAS PARA DETALLE DE LOCALES ===\n\n";

    // 1. Buscar tablas de adeudos
    echo "1. TABLAS DE ADEUDOS:\n";
    echo str_repeat("-", 80) . "\n";
    $sql = "
        SELECT
            schemaname,
            tablename,
            (SELECT count(*) FROM information_schema.columns WHERE table_schema = schemaname AND table_name = tablename) as num_columnas
        FROM pg_tables
        WHERE tablename LIKE '%adeudo%local%'
           OR tablename LIKE '%local%adeudo%'
        ORDER BY schemaname, tablename
    ";
    $stmt = $pdo->query($sql);
    $tablas = $stmt->fetchAll();

    if (count($tablas) > 0) {
        foreach ($tablas as $t) {
            echo "  ✅ {$t['schemaname']}.{$t['tablename']} ({$t['num_columnas']} columnas)\n";
        }
    } else {
        echo "  ⚠️  No se encontraron tablas específicas, buscando alternativas...\n";
        $sql = "
            SELECT schemaname, tablename
            FROM pg_tables
            WHERE tablename LIKE '%adeudo%'
            ORDER BY schemaname, tablename
            LIMIT 10
        ";
        $stmt = $pdo->query($sql);
        $tablas = $stmt->fetchAll();
        foreach ($tablas as $t) {
            echo "  - {$t['schemaname']}.{$t['tablename']}\n";
        }
    }

    // 2. Buscar tablas de pagos
    echo "\n2. TABLAS DE PAGOS:\n";
    echo str_repeat("-", 80) . "\n";
    $sql = "
        SELECT
            schemaname,
            tablename,
            (SELECT count(*) FROM information_schema.columns WHERE table_schema = schemaname AND table_name = tablename) as num_columnas
        FROM pg_tables
        WHERE tablename LIKE '%pago%local%'
           OR tablename LIKE '%local%pago%'
        ORDER BY schemaname, tablename
    ";
    $stmt = $pdo->query($sql);
    $tablas = $stmt->fetchAll();

    if (count($tablas) > 0) {
        foreach ($tablas as $t) {
            echo "  ✅ {$t['schemaname']}.{$t['tablename']} ({$t['num_columnas']} columnas)\n";
        }
    } else {
        echo "  ⚠️  No se encontraron tablas específicas, buscando alternativas...\n";
        $sql = "
            SELECT schemaname, tablename
            FROM pg_tables
            WHERE tablename LIKE '%pago%'
               OR tablename LIKE '%ta_11%'
            ORDER BY schemaname, tablename
            LIMIT 10
        ";
        $stmt = $pdo->query($sql);
        $tablas = $stmt->fetchAll();
        foreach ($tablas as $t) {
            echo "  - {$t['schemaname']}.{$t['tablename']}\n";
        }
    }

    // 3. Buscar tablas de requerimientos
    echo "\n3. TABLAS DE REQUERIMIENTOS:\n";
    echo str_repeat("-", 80) . "\n";
    $sql = "
        SELECT
            schemaname,
            tablename,
            (SELECT count(*) FROM information_schema.columns WHERE table_schema = schemaname AND table_name = tablename) as num_columnas
        FROM pg_tables
        WHERE tablename LIKE '%requerimiento%'
           OR tablename LIKE '%requeri%'
        ORDER BY schemaname, tablename
    ";
    $stmt = $pdo->query($sql);
    $tablas = $stmt->fetchAll();

    if (count($tablas) > 0) {
        foreach ($tablas as $t) {
            echo "  ✅ {$t['schemaname']}.{$t['tablename']} ({$t['num_columnas']} columnas)\n";
        }
    } else {
        echo "  ⚠️  No se encontraron tablas de requerimientos\n";
    }

    // 4. Ver estructura de ta_11_locales para entender las relaciones
    echo "\n4. TABLAS TA_11 DISPONIBLES:\n";
    echo str_repeat("-", 80) . "\n";
    $sql = "
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename LIKE 'ta_11%'
        ORDER BY tablename
        LIMIT 20
    ";
    $stmt = $pdo->query($sql);
    $tablas = $stmt->fetchAll();
    foreach ($tablas as $t) {
        echo "  - {$t['schemaname']}.{$t['tablename']}\n";
    }

    // 5. Buscar columnas id_local en diferentes tablas
    echo "\n5. TABLAS CON CAMPO 'id_local':\n";
    echo str_repeat("-", 80) . "\n";
    $sql = "
        SELECT DISTINCT
            table_schema,
            table_name
        FROM information_schema.columns
        WHERE column_name = 'id_local'
          AND table_schema IN ('public', 'publico', 'comun', 'db_ingresos')
        ORDER BY table_schema, table_name
        LIMIT 20
    ";
    $stmt = $pdo->query($sql);
    $tablas = $stmt->fetchAll();
    foreach ($tablas as $t) {
        echo "  - {$t['table_schema']}.{$t['table_name']}\n";
    }

    echo "\n✅ BÚSQUEDA COMPLETADA\n\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
