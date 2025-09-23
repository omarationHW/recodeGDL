-- Stored Procedure: sp_listar_tipos_convenio_diversos
-- Tipo: Catalog
-- Descripción: Lista los tipos de convenio diversos
-- Generado para formulario: ModifConvDiversos
-- Fecha: 2025-08-27 20:52:39

CREATE OR REPLACE FUNCTION sp_listar_tipos_convenio_diversos() RETURNS TABLE (
    tipo INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos ORDER BY tipo;
END;
$$ LANGUAGE plpgsql;