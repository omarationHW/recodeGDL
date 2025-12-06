<?php
/**
 * Script para buscar información de giros en mercados
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

    echo "\n=== BÚSQUEDA DE GIROS EN MERCADOS ===\n\n";

    // 1. Buscar tablas con "giro"
    echo "1. Buscando tablas con 'giro'...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
        SELECT
            table_schema,
            table_name
        FROM information_schema.tables
        WHERE (table_name LIKE '%giro%')
          AND table_schema IN ('public', 'publico', 'comun', 'db_ingresos')
        ORDER BY table_schema, table_name
    ";

    $stmt = $pdo->query($sql);
    $tablas = $stmt->fetchAll();

    if (count($tablas) > 0) {
        echo "Tablas encontradas:\n";
        foreach ($tablas as $t) {
            echo "  - {$t['table_schema']}.{$t['table_name']}\n";
        }
        echo "\n";
    } else {
        echo "❌ No se encontraron tablas con 'giro'\n\n";
    }

    // 2. Buscar columnas 'giro' en tablas de locales
    echo "2. Buscando columnas 'giro' en tablas...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
        SELECT DISTINCT
            table_schema,
            table_name,
            column_name,
            data_type
        FROM information_schema.columns
        WHERE column_name LIKE '%giro%'
          AND table_schema IN ('public', 'publico', 'comun', 'db_ingresos')
        ORDER BY table_schema, table_name
        LIMIT 20
    ";

    $stmt = $pdo->query($sql);
    $columnas = $stmt->fetchAll();

    if (count($columnas) > 0) {
        echo "Columnas encontradas:\n";
        foreach ($columnas as $col) {
            echo "  - {$col['table_schema']}.{$col['table_name']}.{$col['column_name']} ({$col['data_type']})\n";
        }
        echo "\n";
    } else {
        echo "⚠️  No se encontraron columnas con 'giro'\n\n";
    }

    // 3. Buscar SPs con "giro"
    echo "3. Buscando stored procedures con 'giro'...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
        SELECT
            proname as nombre_sp,
            pg_get_function_arguments(oid) as argumentos
        FROM pg_proc
        WHERE proname LIKE '%giro%'
        ORDER BY proname
        LIMIT 20
    ";

    $stmt = $pdo->query($sql);
    $sps = $stmt->fetchAll();

    if (count($sps) > 0) {
        echo "SPs encontrados:\n";
        foreach ($sps as $sp) {
            echo "  - {$sp['nombre_sp']}({$sp['argumentos']})\n";
        }
        echo "\n";
    } else {
        echo "⚠️  No se encontraron SPs con 'giro'\n\n";
    }

    // 4. Revisar estructura de ta_11_locales para ver si tiene giro
    echo "4. Verificando estructura de ta_11_locales...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'publico'
          AND table_name = 'ta_11_locales'
          AND (column_name LIKE '%giro%' OR column_name LIKE '%actividad%' OR column_name LIKE '%comercial%')
        ORDER BY ordinal_position
    ";

    $stmt = $pdo->query($sql);
    $cols_locales = $stmt->fetchAll();

    if (count($cols_locales) > 0) {
        echo "Columnas relacionadas en ta_11_locales:\n";
        foreach ($cols_locales as $col) {
            echo "  - {$col['column_name']}: {$col['data_type']}\n";
        }
        echo "\n";

        // Ver datos de ejemplo
        echo "Datos de ejemplo:\n";
        $sql = "SELECT * FROM publico.ta_11_locales WHERE giro IS NOT NULL LIMIT 5";
        try {
            $stmt = $pdo->query($sql);
            $ejemplos = $stmt->fetchAll();
            if (count($ejemplos) > 0) {
                foreach ($ejemplos as $ej) {
                    echo "  - ID: {$ej['id_local']}, Giro: {$ej['giro']}\n";
                }
            }
        } catch (Exception $e) {
            echo "  ⚠️  Error al obtener ejemplos: " . $e->getMessage() . "\n";
        }
        echo "\n";
    } else {
        echo "⚠️  No se encontraron columnas relacionadas con giro en ta_11_locales\n\n";
    }

    // 5. Buscar tabla de catálogo de giros
    echo "5. Buscando catálogo de giros...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name LIKE '%catalogo%giro%' OR table_name LIKE '%giro%catalogo%'
               OR table_name = 'giros' OR table_name = 'ta_giros')
        ORDER BY table_schema, table_name
    ";

    $stmt = $pdo->query($sql);
    $catalogos = $stmt->fetchAll();

    if (count($catalogos) > 0) {
        echo "Catálogos encontrados:\n";
        foreach ($catalogos as $cat) {
            echo "  - {$cat['table_schema']}.{$cat['table_name']}\n";

            // Ver estructura
            $sql2 = "
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = '{$cat['table_schema']}'
                  AND table_name = '{$cat['table_name']}'
                ORDER BY ordinal_position
                LIMIT 10
            ";
            $stmt2 = $pdo->query($sql2);
            $cols = $stmt2->fetchAll();
            foreach ($cols as $col) {
                echo "      {$col['column_name']}: {$col['data_type']}\n";
            }
            echo "\n";
        }
    } else {
        echo "⚠️  No se encontró catálogo de giros\n\n";
    }

    echo "✅ BÚSQUEDA COMPLETADA\n\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
