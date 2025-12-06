<?php
/**
 * Deploy SPs para LocalesMtto - Altas de Locales
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado a $dbname\n\n";

    // SP para obtener secciones
    echo "Creando sp_get_secciones...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS public.sp_get_secciones()");
    $pdo->exec("
    CREATE OR REPLACE FUNCTION public.sp_get_secciones()
    RETURNS TABLE(
        seccion VARCHAR,
        descripcion VARCHAR
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT s.seccion::VARCHAR, s.descripcion::VARCHAR
        FROM db_ingresos.ta_11_secciones s
        ORDER BY s.seccion;
    END;
    \$\$ LANGUAGE plpgsql;
    ");
    echo "sp_get_secciones creado\n";

    // SP para obtener zonas
    echo "Creando sp_get_zonas...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS public.sp_get_zonas()");
    $pdo->exec("
    CREATE OR REPLACE FUNCTION public.sp_get_zonas()
    RETURNS TABLE(
        id_zona INTEGER,
        zona VARCHAR
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT z.id_zona::INTEGER, z.zona::VARCHAR
        FROM db_ingresos.ta_11_zonas z
        ORDER BY z.id_zona;
    END;
    \$\$ LANGUAGE plpgsql;
    ");
    echo "sp_get_zonas creado\n";

    // SP para buscar si existe local
    echo "Creando sp_locales_mtto_buscar...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS public.sp_locales_mtto_buscar(INTEGER, INTEGER, INTEGER, VARCHAR, INTEGER, VARCHAR, VARCHAR)");
    $pdo->exec("
    CREATE OR REPLACE FUNCTION public.sp_locales_mtto_buscar(
        p_oficina INTEGER,
        p_num_mercado INTEGER,
        p_categoria INTEGER,
        p_seccion VARCHAR,
        p_local INTEGER,
        p_letra_local VARCHAR,
        p_bloque VARCHAR
    )
    RETURNS TABLE(
        id_local INTEGER,
        existe BOOLEAN
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT l.id_local::INTEGER, TRUE
        FROM comun.ta_11_locales l
        WHERE l.oficina = p_oficina
          AND l.num_mercado = p_num_mercado
          AND l.categoria = p_categoria
          AND l.seccion = p_seccion::character(2)
          AND l.local = p_local
          AND (p_letra_local IS NULL OR l.letra_local = p_letra_local::character(1))
          AND (p_bloque IS NULL OR l.bloque = p_bloque::character(1));

        IF NOT FOUND THEN
            RETURN QUERY SELECT 0::INTEGER, FALSE;
        END IF;
    END;
    \$\$ LANGUAGE plpgsql;
    ");
    echo "sp_locales_mtto_buscar creado\n";

    // SP para alta de local
    echo "Creando sp_locales_mtto_alta...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS public.sp_locales_mtto_alta(INTEGER, INTEGER, INTEGER, VARCHAR, INTEGER, VARCHAR, VARCHAR, VARCHAR, INTEGER, VARCHAR, VARCHAR, INTEGER, VARCHAR, NUMERIC, INTEGER, DATE, INTEGER, INTEGER)");
    $pdo->exec("
    CREATE OR REPLACE FUNCTION public.sp_locales_mtto_alta(
        p_oficina INTEGER,
        p_num_mercado INTEGER,
        p_categoria INTEGER,
        p_seccion VARCHAR,
        p_local INTEGER,
        p_letra_local VARCHAR,
        p_bloque VARCHAR,
        p_nombre VARCHAR,
        p_giro INTEGER,
        p_sector VARCHAR,
        p_domicilio VARCHAR,
        p_zona INTEGER,
        p_descripcion_local VARCHAR,
        p_superficie NUMERIC,
        p_clave_cuota INTEGER,
        p_fecha_alta DATE,
        p_numero_memo INTEGER,
        p_id_usuario INTEGER
    )
    RETURNS TABLE(
        success BOOLEAN,
        message VARCHAR,
        id_local INTEGER
    ) AS \$\$
    DECLARE
        v_id INTEGER;
    BEGIN
        -- Insertar local
        INSERT INTO comun.ta_11_locales (
            oficina, num_mercado, categoria, seccion, local, letra_local, bloque,
            id_contribuy_prop, id_contribuy_renta, nombre, arrendatario, domicilio,
            sector, zona, descripcion_local, superficie, giro, fecha_alta, fecha_baja,
            fecha_modificacion, vigencia, id_usuario, clave_cuota, id_licencia
        ) VALUES (
            p_oficina, p_num_mercado, p_categoria, p_seccion, p_local,
            NULLIF(p_letra_local, ''), NULLIF(p_bloque, ''),
            1, NULL, p_nombre, NULL, p_domicilio,
            p_sector, p_zona, p_descripcion_local, p_superficie, p_giro, p_fecha_alta, NULL,
            NOW(), 'A', p_id_usuario, p_clave_cuota, 0
        ) RETURNING comun.ta_11_locales.id_local INTO v_id;

        RETURN QUERY SELECT TRUE, 'Local dado de alta correctamente'::VARCHAR, v_id;
    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM::VARCHAR, 0;
    END;
    \$\$ LANGUAGE plpgsql;
    ");
    echo "sp_locales_mtto_alta creado\n";

    // Test secciones
    echo "\n=== Test sp_get_secciones ===\n";
    $stmt = $pdo->query("SELECT * FROM sp_get_secciones() LIMIT 5");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($rows as $row) {
        echo "  {$row['seccion']}: {$row['descripcion']}\n";
    }

    // Test zonas
    echo "\n=== Test sp_get_zonas ===\n";
    $stmt = $pdo->query("SELECT * FROM sp_get_zonas() LIMIT 5");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($rows as $row) {
        echo "  {$row['id_zona']}: {$row['zona']}\n";
    }

} catch (PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    exit(1);
}

echo "\nSPs desplegados correctamente!\n";
