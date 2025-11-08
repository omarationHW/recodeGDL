-- Stored Procedure: sp_list_autcargapag
-- Tipo: Catalog
-- Descripción: Lista todas las fechas de autorización de carga de pagos para una oficina.
-- Generado para formulario: AutCargaPagosMtto
-- Fecha: 2025-08-26 22:48:05

CREATE OR REPLACE FUNCTION sp_list_autcargapag(p_oficina integer)
RETURNS TABLE(
  fecha_ingreso date,
  oficina smallint,
  autorizar char(1),
  fecha_limite date,
  id_usupermiso integer,
  comentarios text,
  id_usuario integer,
  actualizacion timestamp,
  nombre text
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.fecha_ingreso, a.oficina, a.autorizar, a.fecha_limite, a.id_usupermiso, a.comentarios, a.id_usuario, a.actualizacion, b.nombre
    FROM ta_11_autcargapag a
    JOIN ta_12_passwords b ON b.id_usuario = a.id_usupermiso
    WHERE a.oficina = p_oficina
    ORDER BY a.fecha_ingreso DESC;
END;
$$ LANGUAGE plpgsql;