-- Stored Procedure: sp_condonacion_adeudos_local
-- Tipo: CRUD
-- Descripción: Devuelve los adeudos vigentes de un local.
-- Generado para formulario: Condonacion
-- Fecha: 2025-08-26 19:19:54

CREATE OR REPLACE FUNCTION sp_condonacion_adeudos_local(p_id_local integer)
RETURNS TABLE (
    axo integer,
    periodo integer,
    importe numeric,
    observacion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT axo, periodo, importe, '' as observacion
    FROM ta_11_adeudo_local
    WHERE id_local = p_id_local
    ORDER BY axo, periodo;
END;
$$ LANGUAGE plpgsql;