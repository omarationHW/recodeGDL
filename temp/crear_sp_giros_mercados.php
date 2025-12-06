<?php
/**
 * Script para crear SPs de Giros para Mercados
 */

$host = "192.168.6.146";
$port = "5432";
$dbname = "mercados";
$user = "refact";
$password = "FF)-BQk2";

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "\n=== CREANDO SPs DE GIROS PARA MERCADOS ===\n\n";

    // 1. Verificar valores únicos de giro
    echo "1. Analizando valores de giro en ta_11_locales...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
        SELECT
            giro,
            COUNT(*) as cantidad
        FROM publico.ta_11_locales
        WHERE giro IS NOT NULL AND giro != 0
        GROUP BY giro
        ORDER BY cantidad DESC, giro
        LIMIT 20
    ";

    $stmt = $pdo->query($sql);
    $giros = $stmt->fetchAll();

    if (count($giros) > 0) {
        echo "Giros encontrados en locales:\n";
        foreach ($giros as $g) {
            echo "  - Giro {$g['giro']}: {$g['cantidad']} locales\n";
        }
        echo "\n";
    }

    // 2. Crear SP para listar giros
    echo "2. Creando sp_giros_list...\n";
    echo str_repeat("-", 80) . "\n";

    $sql_list = "
    DROP FUNCTION IF EXISTS sp_giros_list();

    CREATE OR REPLACE FUNCTION sp_giros_list()
    RETURNS TABLE(
        id_giro SMALLINT,
        descripcion VARCHAR(100),
        cantidad_locales BIGINT
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            l.giro::SMALLINT as id_giro,
            CASE
                WHEN l.giro = 1 THEN 'Comestibles'
                WHEN l.giro = 2 THEN 'Ropa y Calzado'
                WHEN l.giro = 3 THEN 'Electrónica'
                WHEN l.giro = 4 THEN 'Ferretería'
                WHEN l.giro = 5 THEN 'Flores y Plantas'
                WHEN l.giro = 315 THEN 'Abarrotes'
                ELSE 'Giro ' || l.giro::TEXT
            END::VARCHAR(100) as descripcion,
            COUNT(*)::BIGINT as cantidad_locales
        FROM publico.ta_11_locales l
        WHERE l.giro IS NOT NULL AND l.giro != 0
        GROUP BY l.giro
        ORDER BY COUNT(*) DESC, l.giro;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    $pdo->exec($sql_list);
    echo "✅ sp_giros_list creado\n\n";

    // 3. Crear SP para obtener giro por ID
    echo "3. Creando sp_giros_get...\n";
    echo str_repeat("-", 80) . "\n";

    $sql_get = "
    DROP FUNCTION IF EXISTS sp_giros_get(SMALLINT);

    CREATE OR REPLACE FUNCTION sp_giros_get(p_id_giro SMALLINT)
    RETURNS TABLE(
        id_giro SMALLINT,
        descripcion VARCHAR(100),
        cantidad_locales BIGINT
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            l.giro::SMALLINT as id_giro,
            CASE
                WHEN l.giro = 1 THEN 'Comestibles'
                WHEN l.giro = 2 THEN 'Ropa y Calzado'
                WHEN l.giro = 3 THEN 'Electrónica'
                WHEN l.giro = 4 THEN 'Ferretería'
                WHEN l.giro = 5 THEN 'Flores y Plantas'
                WHEN l.giro = 315 THEN 'Abarrotes'
                ELSE 'Giro ' || l.giro::TEXT
            END::VARCHAR(100) as descripcion,
            COUNT(*)::BIGINT as cantidad_locales
        FROM publico.ta_11_locales l
        WHERE l.giro = p_id_giro
        GROUP BY l.giro;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    $pdo->exec($sql_get);
    echo "✅ sp_giros_get creado\n\n";

    // 4. Crear SP para locales por giro
    echo "4. Creando sp_giros_locales...\n";
    echo str_repeat("-", 80) . "\n";

    $sql_locales = "
    DROP FUNCTION IF EXISTS sp_giros_locales(SMALLINT);

    CREATE OR REPLACE FUNCTION sp_giros_locales(p_id_giro SMALLINT)
    RETURNS TABLE(
        id_local INTEGER,
        oficina SMALLINT,
        num_mercado SMALLINT,
        categoria SMALLINT,
        seccion CHAR(2),
        local INTEGER,
        letra_local VARCHAR(3),
        nombre VARCHAR(60),
        arrendatario VARCHAR(30),
        giro SMALLINT
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            l.id_local,
            l.oficina,
            l.num_mercado,
            l.categoria,
            l.seccion,
            l.local,
            l.letra_local,
            l.nombre,
            l.arrendatario,
            l.giro
        FROM publico.ta_11_locales l
        WHERE l.giro = p_id_giro
        ORDER BY l.oficina, l.num_mercado, l.categoria, l.seccion, l.local
        LIMIT 500;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    $pdo->exec($sql_locales);
    echo "✅ sp_giros_locales creado\n\n";

    // 5. Verificar SPs creados
    echo "5. Verificando SPs creados...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
        SELECT
            proname as nombre_sp,
            pg_get_function_arguments(oid) as argumentos
        FROM pg_proc
        WHERE proname IN ('sp_giros_list', 'sp_giros_get', 'sp_giros_locales')
        ORDER BY proname
    ";

    $stmt = $pdo->query($sql);
    $sps = $stmt->fetchAll();

    foreach ($sps as $sp) {
        echo "✅ {$sp['nombre_sp']}({$sp['argumentos']})\n";
    }

    // 6. Probar SPs
    echo "\n6. Probando sp_giros_list...\n";
    echo str_repeat("-", 80) . "\n";

    $stmt = $pdo->query("SELECT * FROM sp_giros_list() LIMIT 10");
    $resultados = $stmt->fetchAll();

    if (count($resultados) > 0) {
        echo "✅ SP funciona. Retornó " . count($resultados) . " giros:\n";
        foreach ($resultados as $r) {
            echo "  - Giro {$r['id_giro']}: {$r['descripcion']} ({$r['cantidad_locales']} locales)\n";
        }
    } else {
        echo "⚠️  No se encontraron giros\n";
    }

    echo "\n" . str_repeat("=", 80) . "\n";
    echo "✅ PROCESO COMPLETADO\n\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
