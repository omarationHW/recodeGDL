-- Stored Procedure: sp_get_folios_report
-- Tipo: Report
-- Descripción: Consulta folios por año, folio, placa o rango de fechas.
-- Generado para formulario: Acceso
-- Fecha: 2025-08-27 13:19:38

CREATE OR REPLACE FUNCTION sp_get_folios_report(
  p_year INT,
  p_folio INT DEFAULT NULL,
  p_placa TEXT DEFAULT NULL,
  p_date_from DATE DEFAULT NULL,
  p_date_to DATE DEFAULT NULL
)
RETURNS TABLE(
  axo INT, folio INT, placa TEXT, fecha_folio DATE, estado INT, infraccion INT, tarifa NUMERIC, descripcion TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.axo::INT, a.folio::INT, a.placa::TEXT, a.fecha_folio, a.estado::INT, a.infraccion::INT, COALESCE(b.tarifa, 0)::NUMERIC, 'Vigente'::TEXT
  FROM ta14_folios_adeudo a
  LEFT JOIN ta14_tarifas b ON a.infraccion = b.num_clave AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
  WHERE a.axo = p_year
    AND (p_folio IS NULL OR a.folio = p_folio)
    AND (p_placa IS NULL OR a.placa = p_placa)
    AND (p_date_from IS NULL OR a.fecha_folio >= p_date_from)
    AND (p_date_to IS NULL OR a.fecha_folio <= p_date_to)
  ORDER BY a.folio;
END;
$$ LANGUAGE plpgsql;