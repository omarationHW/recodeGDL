-- Stored Procedure: sp_catalogo_giros
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de giros vigentes
-- Generado para formulario: SGCv2
-- Fecha: 2025-08-26 18:12:43

CREATE OR REPLACE FUNCTION sp_catalogo_giros()
RETURNS TABLE(id_giro integer, descripcion text, vigente text) AS $$
BEGIN
    RETURN QUERY SELECT id_giro, descripcion, vigente FROM c_giros WHERE vigente = 'V' ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;