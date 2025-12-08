<?php
/**
 * Fix ABC_Gastos - Drop old PROCEDURES and create FUNCTIONS
 */

$host = '192.168.6.146';
$db = 'padron_licencias';
$user = 'refact';
$pass = 'FF)-BQk2';

echo "Fixing ABC_Gastos...\n";

$connString = "host={$host} dbname={$db} user={$user} password={$pass}";
$conn = @pg_connect($connString);

if (!$conn) {
    die("ERROR: No se pudo conectar\n");
}

// First, drop the old PROCEDURES
echo "Dropping old PROCEDURES...\n";

$dropSql = <<<'SQL'
DROP PROCEDURE IF EXISTS public.sp_gastos_insert(NUMERIC, NUMERIC, NUMERIC, NUMERIC);
DROP PROCEDURE IF EXISTS public.sp_gastos_delete_all();
DROP FUNCTION IF EXISTS public.sp_gastos_list();
DROP FUNCTION IF EXISTS public.sp_gastos_get();
DROP FUNCTION IF EXISTS public.sp_gastos_insert(NUMERIC, NUMERIC, NUMERIC, NUMERIC);
DROP FUNCTION IF EXISTS public.sp_gastos_update(INTEGER, NUMERIC, NUMERIC, NUMERIC, NUMERIC);
DROP FUNCTION IF EXISTS public.sp_gastos_delete_all();
SQL;

$result = pg_query($conn, $dropSql);
if ($result === false) {
    echo "Warning during drop: " . pg_last_error($conn) . "\n";
} else {
    echo "✓ Old procedures dropped\n";
}

// Now create the FUNCTIONS
echo "Creating new FUNCTIONS...\n";

$createSql = <<<'SQL'
CREATE OR REPLACE FUNCTION public.sp_gastos_list()
RETURNS TABLE (
    ctrol_gasto INTEGER,
    sdzmg NUMERIC,
    porc1_req NUMERIC,
    porc2_embargo NUMERIC,
    porc3_secuestro NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT g.ctrol_gasto, g.sdzmg, g.porc1_req, g.porc2_embargo, g.porc3_secuestro
    FROM ta_16_gastos g
    ORDER BY g.ctrol_gasto;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION public.sp_gastos_list() TO PUBLIC;

CREATE OR REPLACE FUNCTION public.sp_gastos_get()
RETURNS TABLE (
    ctrol_gasto INTEGER,
    sdzmg NUMERIC,
    porc1_req NUMERIC,
    porc2_embargo NUMERIC,
    porc3_secuestro NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT g.ctrol_gasto, g.sdzmg, g.porc1_req, g.porc2_embargo, g.porc3_secuestro
    FROM ta_16_gastos g
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION public.sp_gastos_get() TO PUBLIC;

CREATE OR REPLACE FUNCTION public.sp_gastos_insert(
    p_sdzmg NUMERIC,
    p_porc1_req NUMERIC,
    p_porc2_embargo NUMERIC,
    p_porc3_secuestro NUMERIC
)
RETURNS TABLE (success BOOLEAN, message TEXT, ctrol_gasto INTEGER) AS $$
DECLARE
    v_count INTEGER;
    v_new_id INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ta_16_gastos;
    IF v_count > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe un registro de gastos. Use UPDATE para modificarlo.'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;
    INSERT INTO ta_16_gastos (sdzmg, porc1_req, porc2_embargo, porc3_secuestro)
    VALUES (p_sdzmg, p_porc1_req, p_porc2_embargo, p_porc3_secuestro)
    RETURNING ta_16_gastos.ctrol_gasto INTO v_new_id;
    RETURN QUERY SELECT true, 'Registro de gastos creado correctamente'::TEXT, v_new_id;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION public.sp_gastos_insert(NUMERIC, NUMERIC, NUMERIC, NUMERIC) TO PUBLIC;

CREATE OR REPLACE FUNCTION public.sp_gastos_update(
    p_ctrol_gasto INTEGER,
    p_sdzmg NUMERIC,
    p_porc1_req NUMERIC,
    p_porc2_embargo NUMERIC,
    p_porc3_secuestro NUMERIC
)
RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_id_to_update INTEGER;
BEGIN
    IF p_ctrol_gasto IS NULL THEN
        SELECT g.ctrol_gasto INTO v_id_to_update FROM ta_16_gastos g LIMIT 1;
    ELSE
        v_id_to_update := p_ctrol_gasto;
    END IF;
    IF v_id_to_update IS NULL THEN
        RETURN QUERY SELECT false, 'No existe ningún registro de gastos para actualizar'::TEXT;
        RETURN;
    END IF;
    UPDATE ta_16_gastos g
    SET sdzmg = p_sdzmg,
        porc1_req = p_porc1_req,
        porc2_embargo = p_porc2_embargo,
        porc3_secuestro = p_porc3_secuestro
    WHERE g.ctrol_gasto = v_id_to_update;
    IF FOUND THEN
        RETURN QUERY SELECT true, 'Registro de gastos actualizado correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No se encontró el registro de gastos'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION public.sp_gastos_update(INTEGER, NUMERIC, NUMERIC, NUMERIC, NUMERIC) TO PUBLIC;

CREATE OR REPLACE FUNCTION public.sp_gastos_delete_all()
RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ta_16_gastos;
    DELETE FROM ta_16_gastos;
    RETURN QUERY SELECT true, ('Se eliminaron ' || v_count || ' registro(s) de gastos')::TEXT;
END;
$$ LANGUAGE plpgsql;
GRANT EXECUTE ON FUNCTION public.sp_gastos_delete_all() TO PUBLIC;
SQL;

$result = pg_query($conn, $createSql);
if ($result === false) {
    echo "✗ ERROR: " . pg_last_error($conn) . "\n";
    exit(1);
} else {
    echo "✓ Functions created successfully\n";
}

pg_close($conn);
echo "\n✓ ABC_Gastos fixed successfully!\n";
exit(0);
