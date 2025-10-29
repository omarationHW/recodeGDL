-- Stored Procedure: sp_get_inspectors
-- Tipo: Catalog
-- Descripción: Obtiene la lista de inspectores/vigilantes disponibles.
-- Generado para formulario: sfrm_rep_folio
-- Fecha: 2025-08-27 14:30:56

CREATE OR REPLACE FUNCTION sp_get_inspectors()
RETURNS TABLE(id_esta_persona INTEGER, inspector TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT b.id_esta_persona,
           TRIM(b.ap_pater) || ' ' || TRIM(b.ap_mater) || ' ' || TRIM(b.nombre) AS inspector
      FROM ta14_agentes a
      JOIN ta14_personas b ON a.id_esta_persona = b.id_esta_persona;
END;
$$ LANGUAGE plpgsql;