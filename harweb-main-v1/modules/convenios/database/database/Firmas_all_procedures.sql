-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Firmas
-- Generado: 2025-08-27 14:37:21
-- Total SPs: 5
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
    FROM ta_17_firmaconv
    ORDER BY recaudadora;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_firmas_create
-- Tipo: CRUD
-- Descripción: Crea una nueva firma de convenio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_firmas_create(
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
    INSERT INTO ta_17_firmaconv (
        recaudadora, titular, cargotitular, recaudador, cargorecaudador, testigo1, testigo2, letras
    ) VALUES (
        p_recaudadora, p_titular, p_cargotitular, p_recaudador, p_cargorecaudador, p_testigo1, p_testigo2, p_letras
    );
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

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
    UPDATE ta_17_firmaconv SET
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

-- SP 4/5: sp_firmas_delete
-- Tipo: CRUD
-- Descripción: Elimina una firma de convenio por recaudadora
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_firmas_delete(
    p_recaudadora integer
) RETURNS TABLE (result text) AS $$
BEGIN
    DELETE FROM ta_17_firmaconv WHERE recaudadora = p_recaudadora;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

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
    FROM ta_17_firmaconv
    WHERE recaudadora = p_recaudadora;
END;
$$ LANGUAGE plpgsql;

-- ============================================

