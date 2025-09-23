-- Stored Procedure: sp_reporte_edocta_lic
-- Tipo: Report
-- Descripción: Reporte de estado de cuenta de licencia/anuncio
-- Generado para formulario: dderechosLic
-- Fecha: 2025-08-26 23:58:23

CREATE OR REPLACE FUNCTION sp_reporte_edocta_lic(p_tipo TEXT, p_numero INTEGER)
RETURNS TABLE(
  concepto TEXT,
  importe NUMERIC,
  periodo TEXT,
  propietario TEXT,
  ubicacion TEXT,
  giro TEXT,
  actividad TEXT
) AS $$
BEGIN
  -- Ejemplo, debe ajustarse a la estructura real
  RETURN QUERY
    SELECT 'Derechos', SUM(derechos), CONCAT(axoini,'-',axofin), propietario, ubicacion, giro, actividad
    FROM saldos_lic
    WHERE (CASE WHEN p_tipo='L' THEN id_licencia=p_numero ELSE id_anuncio=p_numero END)
    GROUP BY axoini, axofin, propietario, ubicacion, giro, actividad;
END;
$$ LANGUAGE plpgsql;