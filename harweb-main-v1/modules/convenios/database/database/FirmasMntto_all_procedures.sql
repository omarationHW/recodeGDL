-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: FirmasMntto
-- Generado: 2025-08-27 14:39:01
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_firmas_create
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro de firmas en ta_17_firmaconv
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_firmas_create(
    p_recaudadora INTEGER,
    p_titular VARCHAR,
    p_cargotitular VARCHAR,
    p_recaudador VARCHAR,
    p_cargorecaudador VARCHAR,
    p_testigo1 VARCHAR,
    p_testigo2 VARCHAR,
    p_letras VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ta_17_firmaconv (
        recaudadora, titular, cargotitular, recaudador, cargorecaudador, testigo1, testigo2, letras
    ) VALUES (
        p_recaudadora, p_titular, p_cargotitular, p_recaudador, p_cargorecaudador, p_testigo1, p_testigo2, p_letras
    );
END;
$$;

-- ============================================

-- SP 2/3: sp_firmas_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro de firmas en ta_17_firmaconv
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_firmas_update(
    p_recaudadora INTEGER,
    p_titular VARCHAR,
    p_cargotitular VARCHAR,
    p_recaudador VARCHAR,
    p_cargorecaudador VARCHAR,
    p_testigo1 VARCHAR,
    p_testigo2 VARCHAR,
    p_letras VARCHAR
)
LANGUAGE plpgsql
AS $$
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
END;
$$;

-- ============================================

-- SP 3/3: sp_firmas_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de firmas en ta_17_firmaconv
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_firmas_delete(
    p_recaudadora INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM ta_17_firmaconv WHERE recaudadora = p_recaudadora;
END;
$$;

-- ============================================

