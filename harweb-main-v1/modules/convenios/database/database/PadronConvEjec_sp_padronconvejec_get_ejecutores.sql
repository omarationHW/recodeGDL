-- Stored Procedure: sp_padronconvejec_get_ejecutores
-- Tipo: Catalog
-- Descripción: Obtiene la lista de ejecutores activos.
-- Generado para formulario: PadronConvEjec
-- Fecha: 2025-08-27 15:03:48

CREATE OR REPLACE FUNCTION sp_padronconvejec_get_ejecutores()
RETURNS TABLE(cveejecutor smallint, ejecutor varchar) AS $$
BEGIN
  RETURN QUERY SELECT cveejecutor, trim(paterno)||' '||trim(materno)||' '||trim(nombres) as ejecutor FROM ejecutor WHERE vigencia='V' ORDER BY cveejecutor;
END; $$ LANGUAGE plpgsql;