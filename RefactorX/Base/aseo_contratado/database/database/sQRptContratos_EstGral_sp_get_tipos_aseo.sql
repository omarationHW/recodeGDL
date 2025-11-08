-- Stored Procedure: sp_get_tipos_aseo
-- Tipo: Catalog
-- Descripción: Obtiene todos los tipos de aseo activos
-- Generado para formulario: sQRptContratos_EstGral
-- Fecha: 2025-08-27 15:32:18

CREATE OR REPLACE FUNCTION sp_get_tipos_aseo()
RETURNS TABLE(ctrol_aseo integer, tipo_aseo text, descripcion text, cta_aplicacion integer) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion FROM ta_16_tipo_aseo WHERE ctrol_aseo <> 0;
END;
$$ LANGUAGE plpgsql;