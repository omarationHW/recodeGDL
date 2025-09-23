-- Stored Procedure: sp_tipos_get
-- Tipo: Catalog
-- Descripción: Obtiene un tipo específico por su clave.
-- Generado para formulario: TiposMntto
-- Fecha: 2025-08-27 16:03:12

CREATE OR REPLACE FUNCTION sp_tipos_get(p_tipo integer)
RETURNS TABLE(tipo integer, descripcion varchar) AS $$
BEGIN
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos WHERE tipo = p_tipo;
END;
$$ LANGUAGE plpgsql;