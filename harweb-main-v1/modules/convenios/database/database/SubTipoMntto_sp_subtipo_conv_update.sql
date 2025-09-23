-- Stored Procedure: sp_subtipo_conv_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro existente en ta_17_subtipo_conv
-- Generado para formulario: SubTipoMntto
-- Fecha: 2025-08-27 16:00:28

CREATE OR REPLACE FUNCTION sp_subtipo_conv_update(
    p_tipo integer,
    p_subtipo integer,
    p_desc_subtipo varchar,
    p_cuenta_ingreso integer,
    p_id_usuario integer
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    existe integer;
BEGIN
    SELECT COUNT(*) INTO existe FROM ta_17_subtipo_conv WHERE tipo = p_tipo AND subtipo = p_subtipo;
    IF existe = 0 THEN
        RETURN QUERY SELECT false, 'No existe el SubTipo para ese Tipo';
        RETURN;
    END IF;
    UPDATE ta_17_subtipo_conv
    SET desc_subtipo = p_desc_subtipo,
        cuenta_ingreso = p_cuenta_ingreso,
        id_usuario = p_id_usuario,
        fecha_actual = NOW()
    WHERE tipo = p_tipo AND subtipo = p_subtipo;
    RETURN QUERY SELECT true, 'SubTipo actualizado correctamente';
END;
$$ LANGUAGE plpgsql;