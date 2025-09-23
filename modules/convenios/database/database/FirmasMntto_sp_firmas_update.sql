-- Stored Procedure: sp_firmas_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro de firmas en ta_17_firmaconv
-- Generado para formulario: FirmasMntto
-- Fecha: 2025-08-27 14:39:01

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