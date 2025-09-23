-- Stored Procedure: sp_update_autcargapag
-- Tipo: CRUD
-- Descripción: Actualiza un registro de autorización de carga de pagos.
-- Generado para formulario: AutCargaPagosMtto
-- Fecha: 2025-08-26 22:48:05

CREATE OR REPLACE FUNCTION sp_update_autcargapag(
  p_fecha_ingreso date,
  p_oficina smallint,
  p_autorizar char(1),
  p_fecha_limite date,
  p_id_usupermiso integer,
  p_comentarios text,
  p_id_usuario integer,
  p_actualizacion timestamp
) RETURNS TABLE(result text) AS $$
BEGIN
  UPDATE ta_11_autcargapag
  SET autorizar = p_autorizar,
      fecha_limite = p_fecha_limite,
      id_usupermiso = p_id_usupermiso,
      comentarios = p_comentarios,
      id_usuario = p_id_usuario,
      actualizacion = p_actualizacion
  WHERE fecha_ingreso = p_fecha_ingreso AND oficina = p_oficina;
  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;