-- Stored Procedure: spd_11_condonacion
-- Tipo: CRUD
-- Descripción: Devuelve los adeudos de un local para condonación.
-- Generado para formulario: Condonacion
-- Fecha: 2025-08-26 23:10:57

CREATE OR REPLACE FUNCTION spd_11_condonacion(
    p_idlocal integer,
    p_idusu integer
) RETURNS TABLE (
    expression integer,
    expression_1 smallint,
    expression_2 smallint,
    expression_3 numeric,
    expression_4 varchar,
    expression_5 smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, axo, periodo, importe, 'Adeudo de renta'::varchar, 0
    FROM ta_11_adeudo_local
    WHERE id_local = p_idlocal;
END;
$$ LANGUAGE plpgsql;