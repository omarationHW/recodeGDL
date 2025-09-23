-- Stored Procedure: sp_subtipo_conv_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro en ta_17_subtipo_conv
-- Generado para formulario: SubTipoMntto
-- Fecha: 2025-08-27 16:00:28

CREATE OR REPLACE FUNCTION sp_subtipo_conv_create(
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
    IF existe > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe el SubTipo para ese Tipo';
        RETURN;
    END IF;
    INSERT INTO ta_17_subtipo_conv (tipo, subtipo, desc_subtipo, cuenta_ingreso, id_usuario, fecha_actual)
    VALUES (p_tipo, p_subtipo, p_desc_subtipo, p_cuenta_ingreso, p_id_usuario, NOW());
    RETURN QUERY SELECT true, 'SubTipo creado correctamente';
END;
$$ LANGUAGE plpgsql;