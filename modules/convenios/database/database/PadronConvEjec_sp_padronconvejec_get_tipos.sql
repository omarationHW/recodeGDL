-- Stored Procedure: sp_padronconvejec_get_tipos
-- Tipo: Catalog
-- Descripción: Obtiene los tipos de convenio disponibles.
-- Generado para formulario: PadronConvEjec
-- Fecha: 2025-08-27 15:03:48

CREATE OR REPLACE FUNCTION sp_padronconvejec_get_tipos()
RETURNS TABLE(tipo smallint, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos ORDER BY tipo;
END; $$ LANGUAGE plpgsql;