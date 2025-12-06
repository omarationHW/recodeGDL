<?php
/**
 * Script para buscar información de secciones en mercados
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

    echo "\n=== BÚSQUEDA DE SECCIONES EN MERCADOS ===\n\n";

    // 1. Buscar tablas con "seccion"
    echo "1. Buscando tablas con 'seccion'...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
        SELECT
            table_schema,
            table_name
        FROM information_schema.tables
        WHERE (table_name LIKE '%seccion%' OR table_name LIKE '%secc%')
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
        echo "❌ No se encontraron tablas con 'seccion'\n\n";
    }

    // 2. Buscar columnas 'seccion' en tablas de locales
    echo "2. Buscando columnas 'seccion' en tablas...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
        SELECT DISTINCT
            table_schema,
            table_name,
            column_name,
            data_type
        FROM information_schema.columns
        WHERE column_name LIKE '%seccion%'
          AND table_schema IN ('public', 'publico', 'comun', 'db_ingresos')
        ORDER BY table_schema, table_name
        LIMIT 20
    ";

    $stmt = $pdo->query($sql);
    $columnas = $stmt->fetchAll();

    if (count($columnas) > 0) {
        echo "Columnas encontradas:\n";
        foreach ($columnas as $col) {
            echo "  - {$col['table_schema']}.{$col['table_name']}.{$col['column_name']} ({$col['data_type']})\\n";
        }
        echo "\n";
    } else {
        echo "⚠️  No se encontraron columnas con 'seccion'\n\n";
    }

    // 3. Buscar valores únicos de seccion en ta_11_locales
    echo "3. Buscando secciones en ta_11_locales...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
        SELECT
            seccion,
            COUNT(*) as cantidad
        FROM publico.ta_11_locales
        WHERE seccion IS NOT NULL AND seccion != '' AND seccion != '  '
        GROUP BY seccion
        ORDER BY seccion
        LIMIT 30
    ";

    try {
        $stmt = $pdo->query($sql);
        $secciones = $stmt->fetchAll();

        if (count($secciones) > 0) {
            echo "Secciones encontradas en ta_11_locales:\n";
            foreach ($secciones as $s) {
                echo "  - Sección '{$s['seccion']}': {$s['cantidad']} locales\n";
            }
            echo "\nTotal de secciones distintas: " . count($secciones) . "\n\n";
        } else {
            echo "⚠️  No se encontraron secciones en ta_11_locales\n\n";
        }
    } catch (Exception $e) {
        echo "Error al consultar ta_11_locales: " . $e->getMessage() . "\n\n";
    }

    // 4. Buscar tabla de catálogo de secciones
    echo "4. Buscando tabla de catálogo de secciones...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name LIKE '%catalogo%seccion%' OR table_name LIKE '%seccion%catalogo%'
               OR table_name = 'secciones' OR table_name = 'ta_secciones'
               OR table_name = 'ta_11_seccion' OR table_name = 'ta_11_secciones')
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

            // Ver datos de ejemplo
            $sql3 = "SELECT * FROM {$cat['table_schema']}.{$cat['table_name']} LIMIT 5";
            try {
                $stmt3 = $pdo->query($sql3);
                $datos = $stmt3->fetchAll();
                if (count($datos) > 0) {
                    echo "    Datos de ejemplo:\n";
                    foreach ($datos as $d) {
                        echo "      - " . json_encode($d) . "\n";
                    }
                }
            } catch (Exception $e) {
                echo "    Error al leer datos: " . $e->getMessage() . "\n";
            }
            echo "\n";
        }
    } else {
        echo "⚠️  No se encontró catálogo de secciones\n\n";
    }

    // 5. Buscar SPs con "seccion"
    echo "5. Buscando stored procedures con 'seccion'...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
        SELECT
            proname as nombre_sp,
            pg_get_function_arguments(oid) as argumentos
        FROM pg_proc
        WHERE proname LIKE '%seccion%'
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
        echo "⚠️  No se encontraron SPs con 'seccion'\n\n";
    }

    echo "✅ BÚSQUEDA COMPLETADA\n\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
