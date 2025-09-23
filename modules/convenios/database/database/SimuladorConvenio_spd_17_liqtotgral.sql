-- Stored Procedure: spd_17_liqtotgral
-- Tipo: CRUD
-- Descripción: Calcula los totales de un convenio simulado (importe, recargos, gastos, multa, total, etc.) para un registro y periodo.
-- Generado para formulario: SimuladorConvenio
-- Fecha: 2025-08-27 15:57:10

-- PostgreSQL version of spd_17_liqtotgral
CREATE OR REPLACE FUNCTION spd_17_liqtotgral(
    pmod integer,
    pid integer,
    paxo integer,
    pmes integer
) RETURNS TABLE(
    nombre text,
    calle text,
    exterior text,
    interior text,
    recaudadora integer,
    zona integer,
    axodsd integer,
    mesdsd integer,
    axohst integer,
    meshst integer,
    importe numeric,
    fvgiros numeric,
    anuncios numeric,
    fvanuncios numeric,
    impreso numeric,
    recargos numeric,
    actualizacion numeric,
    gastos numeric,
    multa numeric,
    total numeric,
    status integer,
    mensaje text,
    actualizacion_anun numeric
) AS $$
BEGIN
    -- Ejemplo para Predial (modulo=5)
    IF pmod = 5 THEN
        RETURN QUERY
        SELECT nombre, calle, exterior, interior, recaudadora, zona, axodsd, mesdsd, axohst, meshst,
               importe, 0, 0, 0, 0, recargos, actualizacion, gastos, multa, (importe+recargos+actualizacion+gastos+multa), 0, '', 0
        FROM ta_11_predial
        WHERE id_registro = pid
        LIMIT 1;
    -- ... otros módulos ...
    ELSE
        RETURN QUERY SELECT NULL::text, NULL::text, NULL::text, NULL::text, NULL::integer, NULL::integer, NULL::integer, NULL::integer, NULL::integer, NULL::integer, NULL::numeric, NULL::numeric, NULL::numeric, NULL::numeric, NULL::numeric, NULL::numeric, NULL::numeric, NULL::numeric, NULL::numeric, 1, 'No implementado', NULL::numeric;
    END IF;
END;
$$ LANGUAGE plpgsql;