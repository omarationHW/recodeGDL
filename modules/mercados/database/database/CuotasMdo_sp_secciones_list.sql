-- Stored Procedure: sp_secciones_list
-- Tipo: Catalog
-- Descripción: Lista todas las secciones de mercado
-- Generado para formulario: CuotasMdo
-- Fecha: 2025-08-26 23:34:39

CREATE OR REPLACE FUNCTION sp_secciones_list()
RETURNS TABLE (seccion VARCHAR(10), descripcion VARCHAR(100)) AS $$
BEGIN
    RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones ORDER BY seccion;
END;
$$ LANGUAGE plpgsql;