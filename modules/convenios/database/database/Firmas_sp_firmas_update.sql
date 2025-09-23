-- Stored Procedure: sp_firmas_update
-- Tipo: CRUD
-- Descripción: Actualiza una firma de convenio existente
-- Generado para formulario: Firmas
-- Fecha: 2025-08-27 14:37:21

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