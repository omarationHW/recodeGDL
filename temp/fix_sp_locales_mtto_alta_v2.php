<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== Eliminando TODAS las versiones del SP ===\n";

// Buscar todas las versiones del SP
$stmt = $pdo->query("
    SELECT p.oid, pg_get_function_identity_arguments(p.oid) as args
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public' AND p.proname = 'sp_locales_mtto_alta'
");

$versions = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "Versiones encontradas: " . count($versions) . "\n";

foreach ($versions as $v) {
    $dropSql = "DROP FUNCTION IF EXISTS public.sp_locales_mtto_alta({$v['args']})";
    echo "Eliminando: $dropSql\n";
    $pdo->exec($dropSql);
}

echo "\nCreando SP limpio...\n";

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
RETURNS TABLE(success BOOLEAN, message VARCHAR, id_local INTEGER) AS \$\$
DECLARE
    v_id INTEGER;
BEGIN
    -- Insertar local
    INSERT INTO comun.ta_11_locales (
        oficina, num_mercado, categoria, seccion, local, letra_local, bloque,
        id_contribuy_prop, id_contribuy_renta, nombre, arrendatario, domicilio,
        sector, zona, descripcion_local, superficie, giro, fecha_alta, fecha_baja,
        fecha_modificacion, vigencia, id_usuario, clave_cuota, bloqueo, observacion
    ) VALUES (
        p_oficina::SMALLINT, p_num_mercado::SMALLINT, p_categoria::SMALLINT,
        p_seccion::CHAR, p_local, NULLIF(p_letra_local, ''), NULLIF(p_bloque, ''),
        1, NULL, p_nombre, NULL, p_domicilio,
        p_sector::CHAR, p_zona::SMALLINT, p_descripcion_local::CHAR, p_superficie,
        p_giro::SMALLINT, p_fecha_alta, NULL,
        NOW(), 'A', p_id_usuario, p_clave_cuota::SMALLINT, 0,
        'Memo: ' || p_numero_memo::VARCHAR
    ) RETURNING comun.ta_11_locales.id_local INTO v_id;

    RETURN QUERY SELECT TRUE, 'Local dado de alta correctamente'::VARCHAR, v_id;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, SQLERRM::VARCHAR, 0;
END;
\$\$ LANGUAGE plpgsql;
");

echo "SP creado exitosamente\n";

// Verificar que solo hay una versión
$stmt = $pdo->query("
    SELECT COUNT(*) as cnt
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public' AND p.proname = 'sp_locales_mtto_alta'
");
$row = $stmt->fetch(PDO::FETCH_ASSOC);
echo "\nVersiones después de limpieza: {$row['cnt']}\n";
