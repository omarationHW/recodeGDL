-- Stored Procedure: sp_autcargapag_update
-- Tipo: CRUD
-- Descripción: Actualiza una autorización de carga de pagos existente.
-- Generado para formulario: AutCargaPagos
-- Fecha: 2025-08-26 22:46:42

CREATE OR REPLACE FUNCTION sp_autcargapag_update(
    p_fecha_ingreso date,
    p_oficina smallint,
    p_autorizar char(1),
    p_fecha_limite date,
    p_id_usupermiso integer,
    p_comentarios text,
    p_id_usuario integer
) RETURNS TABLE (
    fecha_ingreso date,
    oficina smallint,
    autorizar char(1),
    fecha_limite date,
    id_usupermiso integer,
    comentarios text,
    id_usuario integer,
    actualizacion timestamp
) AS $$
BEGIN
    UPDATE ta_11_autcargapag
    SET autorizar = p_autorizar,
        fecha_limite = p_fecha_limite,
        id_usupermiso = p_id_usupermiso,
        comentarios = p_comentarios,
        id_usuario = p_id_usuario,
        actualizacion = NOW()
    WHERE fecha_ingreso = p_fecha_ingreso AND oficina = p_oficina;
    RETURN QUERY SELECT fecha_ingreso, oficina, autorizar, fecha_limite, id_usupermiso, comentarios, id_usuario, actualizacion
    FROM ta_11_autcargapag
    WHERE fecha_ingreso = p_fecha_ingreso AND oficina = p_oficina;
END;
$$ LANGUAGE plpgsql;