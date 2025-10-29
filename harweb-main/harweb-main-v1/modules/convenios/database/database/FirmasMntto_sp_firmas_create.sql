-- Stored Procedure: sp_firmas_create
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro de firmas en ta_17_firmaconv
-- Generado para formulario: FirmasMntto
-- Fecha: 2025-08-27 14:39:01

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