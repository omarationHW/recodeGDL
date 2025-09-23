-- Stored Procedure: sp_report_folios
-- Tipo: Report
-- Descripción: Reporte de folios capturados por inspector en una fecha dada.
-- Generado para formulario: sfrm_reportescalco
-- Fecha: 2025-08-27 14:22:02

CREATE OR REPLACE FUNCTION sp_report_folios(fechora date)
RETURNS TABLE(
  vigilante integer,
  inspector text,
  folios integer
)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
    SELECT a.vigilante,
           TRIM(COALESCE(c.ap_pater, '.')) || ' ' || TRIM(COALESCE(c.ap_mater, '.')) || ' ' || TRIM(COALESCE(c.nombre, '.')) AS inspector,
           COUNT(a.folio) AS folios
    FROM ta14_folios_adeudo a
    JOIN ta14_personas c ON a.vigilante = c.id_esta_persona
    WHERE a.fecha_folio = fechora
    GROUP BY a.vigilante, inspector
    ORDER BY inspector;
END;
$$;