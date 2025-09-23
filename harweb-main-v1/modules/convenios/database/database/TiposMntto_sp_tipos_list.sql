-- Stored Procedure: sp_tipos_list
-- Tipo: Catalog
-- Descripción: Devuelve todos los registros del catálogo de tipos.
-- Generado para formulario: TiposMntto
-- Fecha: 2025-08-27 16:03:12

CREATE OR REPLACE FUNCTION sp_tipos_list()
RETURNS TABLE(tipo integer, descripcion varchar) AS $$
BEGIN
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos ORDER BY tipo;
END;
$$ LANGUAGE plpgsql;