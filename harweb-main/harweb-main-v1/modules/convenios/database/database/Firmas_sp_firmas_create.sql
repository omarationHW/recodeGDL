-- Stored Procedure: sp_firmas_create
-- Tipo: CRUD
-- Descripción: Crea una nueva firma de convenio
-- Generado para formulario: Firmas
-- Fecha: 2025-08-27 14:37:21

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