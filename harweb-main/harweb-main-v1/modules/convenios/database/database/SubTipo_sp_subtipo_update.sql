-- Stored Procedure: sp_subtipo_update
-- Tipo: CRUD
-- Descripción: Actualiza un subtipo de convenio existente
-- Generado para formulario: SubTipo
-- Fecha: 2025-08-27 15:59:10

CREATE OR REPLACE FUNCTION sp_subtipo_update(
    p_tipo smallint,
    p_subtipo smallint,
    p_desc_subtipo varchar,
    p_cuenta_ingreso integer,
    p_id_usuario integer
) RETURNS TABLE (
    tipo smallint,
    subtipo smallint,
    desc_subtipo varchar,
    cuenta_ingreso integer,
    id_usuario integer,
    fecha_actual timestamp
) AS $$
BEGIN
    UPDATE ta_17_subtipo_conv
    SET desc_subtipo = p_desc_subtipo,
        cuenta_ingreso = p_cuenta_ingreso,
        id_usuario = p_id_usuario,
        fecha_actual = now()
    WHERE tipo = p_tipo AND subtipo = p_subtipo;
    RETURN QUERY
    SELECT tipo, subtipo, desc_subtipo, cuenta_ingreso, id_usuario, fecha_actual
    FROM ta_17_subtipo_conv
    WHERE tipo = p_tipo AND subtipo = p_subtipo;
END;
$$ LANGUAGE plpgsql;