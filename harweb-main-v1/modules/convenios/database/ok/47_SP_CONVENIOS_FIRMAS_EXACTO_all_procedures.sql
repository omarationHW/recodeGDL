-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: FIRMAS (EXACTO del archivo original)
-- Archivo: 47_SP_CONVENIOS_FIRMAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: sp_firmas_list
-- Tipo: Catalog
-- Descripción: Devuelve todas las firmas de convenios
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_firmas_list()
RETURNS TABLE (
    recaudadora integer,
    titular varchar,
    cargotitular varchar,
    recaudador varchar,
    cargorecaudador varchar,
    testigo1 varchar,
    testigo2 varchar,
    letras varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT recaudadora, titular, cargotitular, recaudador, cargorecaudador, testigo1, testigo2, letras
    FROM public.ta_17_firmaconv
    ORDER BY recaudadora;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: FIRMAS (EXACTO del archivo original)
-- Archivo: 47_SP_CONVENIOS_FIRMAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 3/5: sp_firmas_update
-- Tipo: CRUD
-- Descripción: Actualiza una firma de convenio existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_firmas_update(
    p_recaudadora integer,
    p_titular varchar,
    p_cargotitular varchar,
    p_recaudador varchar,
    p_cargorecaudador varchar,
    p_testigo1 varchar,
    p_testigo2 varchar,
    p_letras varchar
) RETURNS TABLE (result text) AS $$
BEGIN
    UPDATE public.ta_17_firmaconv SET
        titular = p_titular,
        cargotitular = p_cargotitular,
        recaudador = p_recaudador,
        cargorecaudador = p_cargorecaudador,
        testigo1 = p_testigo1,
        testigo2 = p_testigo2,
        letras = p_letras
    WHERE recaudadora = p_recaudadora;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: FIRMAS (EXACTO del archivo original)
-- Archivo: 47_SP_CONVENIOS_FIRMAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 5/5: sp_firmas_get
-- Tipo: Catalog
-- Descripción: Obtiene una firma de convenio por recaudadora
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_firmas_get(
    p_recaudadora integer
) RETURNS TABLE (
    recaudadora integer,
    titular varchar,
    cargotitular varchar,
    recaudador varchar,
    cargorecaudador varchar,
    testigo1 varchar,
    testigo2 varchar,
    letras varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT recaudadora, titular, cargotitular, recaudador, cargorecaudador, testigo1, testigo2, letras
    FROM public.ta_17_firmaconv
    WHERE recaudadora = p_recaudadora;
END;
$$ LANGUAGE plpgsql;

-- ============================================

