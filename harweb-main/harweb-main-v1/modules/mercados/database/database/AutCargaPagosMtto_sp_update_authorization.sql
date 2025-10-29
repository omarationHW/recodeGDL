-- Stored Procedure: sp_update_authorization
-- Tipo: CRUD
-- Descripción: Actualiza una autorización existente de fecha de ingreso.
-- Generado para formulario: AutCargaPagosMtto
-- Fecha: 2025-08-26 18:53:38

CREATE OR REPLACE FUNCTION sp_update_authorization(
    p_fecha_ingreso DATE,
    p_oficina SMALLINT,
    p_autorizar CHAR(1),
    p_fecha_limite DATE,
    p_id_usupermiso INTEGER,
    p_comentarios TEXT,
    p_id_usuario INTEGER
) RETURNS TABLE(result TEXT) AS $$
BEGIN
    UPDATE ta_11_autcargapag
    SET autorizar = p_autorizar,
        fecha_limite = p_fecha_limite,
        id_usupermiso = p_id_usupermiso,
        comentarios = p_comentarios,
        id_usuario = p_id_usuario,
        actualizacion = NOW()
    WHERE fecha_ingreso = p_fecha_ingreso AND oficina = p_oficina;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;