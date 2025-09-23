-- Stored Procedure: sp_catalog_inspectors
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de inspectores (id y nombre completo).
-- Generado para formulario: sfrm_reportescalco
-- Fecha: 2025-08-27 14:22:02

CREATE OR REPLACE FUNCTION sp_catalog_inspectors()
RETURNS TABLE(id_esta_persona integer, inspector text)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
    SELECT b.id_esta_persona,
           TRIM(COALESCE(b.ap_pater, '')) || ' ' || TRIM(COALESCE(b.ap_mater, '')) || ' ' || TRIM(COALESCE(b.nombre, '')) AS inspector
    FROM ta14_agentes a
    JOIN ta14_personas b ON a.id_esta_persona = b.id_esta_persona;
END;
$$;