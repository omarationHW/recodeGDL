-- Stored Procedure: sp_get_vencimiento_rec
-- Tipo: Catalog
-- Descripción: Obtiene la fecha de vencimiento de recargos para un mes
-- Generado para formulario: RptCaratulaDatos
-- Fecha: 2025-08-27 00:44:44

CREATE OR REPLACE FUNCTION sp_get_vencimiento_rec(p_mes SMALLINT)
RETURNS TABLE(
  mes SMALLINT,
  fecha_recargos DATE,
  fecha_descuento DATE,
  fecha_alta TIMESTAMP,
  id_usuario INTEGER,
  trimestre SMALLINT,
  sabados SMALLINT,
  sabadosacum SMALLINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT mes, fecha_recargos, fecha_descuento, fecha_alta, id_usuario, trimestre, sabados, sabadosacum
  FROM ta_11_fecha_desc WHERE mes = p_mes;
END;
$$ LANGUAGE plpgsql;