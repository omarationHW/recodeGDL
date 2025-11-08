-- Stored Procedure: sp_get_autcargapag_by_fecha
-- Tipo: CRUD
-- Descripción: Obtiene el registro de autorización de carga de pagos por fecha de ingreso.
-- Generado para formulario: AutCargaPagosMtto
-- Fecha: 2025-08-26 22:48:05

CREATE OR REPLACE FUNCTION sp_get_autcargapag_by_fecha(p_fecha date)
RETURNS TABLE(
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
  RETURN QUERY
    SELECT fecha_ingreso, oficina, autorizar, fecha_limite, id_usupermiso, comentarios, id_usuario, actualizacion
    FROM ta_11_autcargapag
    WHERE fecha_ingreso = p_fecha;
END;
$$ LANGUAGE plpgsql;