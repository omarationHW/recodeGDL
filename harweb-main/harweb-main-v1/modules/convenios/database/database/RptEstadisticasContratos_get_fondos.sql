-- Stored Procedure: get_fondos
-- Tipo: Catalog
-- Descripción: Obtiene la lista de fondos/programas disponibles.
-- Generado para formulario: RptEstadisticasContratos
-- Fecha: 2025-08-27 15:38:58

-- PostgreSQL version
CREATE OR REPLACE FUNCTION get_fondos()
RETURNS TABLE(id integer, descripcion varchar) AS $$
BEGIN
    RETURN QUERY SELECT id, descripcion FROM fondos ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;