-- Stored Procedure: sp_condonacion_listar_condonados
-- Tipo: CRUD
-- Descripción: Lista los adeudos condonados de un local.
-- Generado para formulario: Condonacion
-- Fecha: 2025-08-26 19:19:54

CREATE OR REPLACE FUNCTION sp_condonacion_listar_condonados(p_id_local integer)
RETURNS TABLE (
    id_cancelacion integer,
    id_local integer,
    axo integer,
    periodo integer,
    importe numeric,
    clave_canc varchar,
    observacion varchar,
    fecha_alta timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_cancelacion, id_local, axo, periodo, importe, clave_canc, observacion, fecha_alta, id_usuario
    FROM ta_11_ade_loc_canc
    WHERE id_local = p_id_local
    ORDER BY axo, periodo;
END;
$$ LANGUAGE plpgsql;