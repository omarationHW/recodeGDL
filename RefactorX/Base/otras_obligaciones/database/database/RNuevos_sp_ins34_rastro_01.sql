-- Stored Procedure: sp_ins34_rastro_01
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro de local/concesión en t34_datos para el Rastro. Valida unicidad de control.
-- Generado para formulario: RNuevos
-- Fecha: 2025-08-28 13:43:14

-- PostgreSQL stored procedure for inserting new local/concession
CREATE OR REPLACE FUNCTION sp_ins34_rastro_01(
    par_tabla INTEGER,
    par_control VARCHAR,
    par_conces VARCHAR,
    par_ubica VARCHAR,
    par_sup NUMERIC,
    par_Axo_Ini INTEGER,
    par_Mes_Ini INTEGER,
    par_ofna INTEGER,
    par_sector VARCHAR,
    par_zona INTEGER,
    par_lic INTEGER,
    par_Descrip VARCHAR
) RETURNS TABLE(expression INTEGER, expression_1 VARCHAR) AS $$
DECLARE
    v_exists INTEGER;
    v_id_unidad INTEGER;
    v_id_stat INTEGER := 1; -- VIGENTE
BEGIN
    SELECT COUNT(*) INTO v_exists FROM t34_datos WHERE control = par_control;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 1::INTEGER AS expression, 'Ya existe LOCAL con este dato, intentalo de nuevo'::VARCHAR AS expression_1;
        RETURN;
    END IF;
    -- Buscar id_unidad por descripcion (cve_tab es character, par_tabla es integer)
    SELECT id_34_unidad INTO v_id_unidad FROM t34_unidades WHERE descripcion = par_Descrip AND cve_tab = par_tabla::varchar LIMIT 1;
    IF v_id_unidad IS NULL THEN
        v_id_unidad := 1; -- fallback
    END IF;
    INSERT INTO t34_datos (
        cve_tab, control, concesionario, ubicacion, superficie, fecha_inicio, id_recaudadora, sector, id_zona, licencia, id_unidad, id_stat
    ) VALUES (
        par_tabla, par_control, par_conces, par_ubica, par_sup, make_date(par_Axo_Ini, par_Mes_Ini, 1), par_ofna, par_sector, par_zona, par_lic, v_id_unidad, v_id_stat
    );
    RETURN QUERY SELECT 0::INTEGER AS expression, 'Se ejecutó correctamente la creación del Local/Concesión'::VARCHAR AS expression_1;
END;
$$ LANGUAGE plpgsql;