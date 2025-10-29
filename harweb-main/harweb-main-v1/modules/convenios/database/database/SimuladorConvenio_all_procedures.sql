-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: SimuladorConvenio
-- Generado: 2025-08-27 15:57:10
-- Total SPs: 2
-- ============================================

-- SP 1/2: spd_17_buscaregistro
-- Tipo: CRUD
-- Descripción: Busca un registro de acuerdo al módulo y parámetros variables (Predial, Licencias, Mercados, etc.) y retorna el id_registro y datos principales.
-- --------------------------------------------

-- PostgreSQL version of spd_17_buscaregistro
CREATE OR REPLACE FUNCTION spd_17_buscaregistro(
    pmod integer,
    p1 text, p2 text, p3 text, p4 text, p5 text, p6 text, p7 text
) RETURNS TABLE(
    id_registro integer,
    id_control integer,
    nombre text,
    calle text,
    exterior text,
    interior text,
    recaudadora integer,
    zona integer,
    axodsd integer,
    mesdsd integer,
    axohst integer,
    meshst integer
) AS $$
BEGIN
    -- Ejemplo para Predial (modulo=5)
    IF pmod = 5 THEN
        RETURN QUERY
        SELECT id_registro, id_control, nombre, calle, exterior, interior, recaudadora, zona, axodsd, mesdsd, axohst, meshst
        FROM ta_11_predial
        WHERE rec = p1::int AND ur = p2 AND cuenta = p3::int
        LIMIT 1;
    ELSIF pmod = 9 THEN
        RETURN QUERY
        SELECT id_registro, id_control, nombre, calle, exterior, interior, recaudadora, zona, axodsd, mesdsd, axohst, meshst
        FROM ta_11_licencias
        WHERE licencia = p1::int
        LIMIT 1;
    ELSIF pmod = 10 THEN
        RETURN QUERY
        SELECT id_registro, id_control, nombre, calle, exterior, interior, recaudadora, zona, axodsd, mesdsd, axohst, meshst
        FROM ta_11_anuncios
        WHERE anuncio = p1::int
        LIMIT 1;
    -- ... otros módulos ...
    ELSE
        RETURN QUERY SELECT NULL::integer, NULL::integer, NULL::text, NULL::text, NULL::text, NULL::text, NULL::integer, NULL::integer, NULL::integer, NULL::integer, NULL::integer, NULL::integer;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: spd_17_liqtotgral
-- Tipo: CRUD
-- Descripción: Calcula los totales de un convenio simulado (importe, recargos, gastos, multa, total, etc.) para un registro y periodo.
-- --------------------------------------------

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

-- ============================================

