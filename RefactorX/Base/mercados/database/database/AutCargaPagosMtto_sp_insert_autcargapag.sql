-- Stored Procedure: sp_insert_autcargapag
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro de autorización de carga de pagos.
-- Generado para formulario: AutCargaPagosMtto
-- Fecha: 2025-08-26 22:48:05

CREATE OR REPLACE FUNCTION sp_insert_autcargapag(
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
  INSERT INTO ta_11_autcargapag (
    fecha_ingreso, oficina, autorizar, fecha_limite, id_usupermiso, comentarios, id_usuario, actualizacion
  ) VALUES (
    p_fecha_ingreso, p_oficina, p_autorizar, p_fecha_limite, p_id_usupermiso, p_comentarios, p_id_usuario, p_actualizacion
  );
  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;