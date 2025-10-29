-- Stored Procedure: get_anios_obra
-- Tipo: Catalog
-- Descripción: Obtiene los años de obra disponibles en la base de datos.
-- Generado para formulario: RptEstadisticasContratos
-- Fecha: 2025-08-27 15:38:58

-- PostgreSQL version
CREATE OR REPLACE FUNCTION get_anios_obra()
RETURNS TABLE(axo_obra integer) AS $$
BEGIN
    RETURN QUERY SELECT DISTINCT axo_obra FROM ta_17_calles ORDER BY axo_obra DESC;
END;
$$ LANGUAGE plpgsql;