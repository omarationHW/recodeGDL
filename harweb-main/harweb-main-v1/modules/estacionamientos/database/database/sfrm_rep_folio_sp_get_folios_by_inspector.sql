-- Stored Procedure: sp_get_folios_by_inspector
-- Tipo: Report
-- Descripción: Obtiene el conteo de folios hechos por cada inspector en una fecha dada.
-- Generado para formulario: sfrm_rep_folio
-- Fecha: 2025-08-27 14:30:56

CREATE OR REPLACE FUNCTION sp_get_folios_by_inspector(p_fecha DATE)
RETURNS TABLE(
  vigilante INTEGER,
  inspector TEXT,
  folios INTEGER
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.vigilante,
           TRIM(COALESCE(c.ap_pater, '.')) || ' ' || TRIM(COALESCE(c.ap_mater, '.')) || ' ' || TRIM(COALESCE(c.nombre, '.')) AS inspector,
           COUNT(a.folio) AS folios
      FROM ta14_folios_adeudo a
      JOIN ta14_personas c ON a.vigilante = c.id_esta_persona
      WHERE a.fecha_folio = p_fecha
      GROUP BY a.vigilante, inspector
      ORDER BY inspector;
END;
$$ LANGUAGE plpgsql;