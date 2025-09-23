-- Stored Procedure: get_ta_catalog
-- Tipo: Catalog
-- Descripción: Devuelve todos los registros de la tabla ta (catálogo de contratos de recolección).
-- Generado para formulario: ActCont_CR
-- Fecha: 2025-08-27 13:33:30

CREATE OR REPLACE FUNCTION get_ta_catalog()
RETURNS TABLE (
    id integer,
    tipo_aseo integer,
    descripcion text,
    -- Agregar aquí los campos reales de la tabla ta
    -- Ejemplo:
    -- contrato_id integer,
    -- nombre_cliente text,
    -- cantidad integer
    -- ...
    dummy integer
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM ta;
END;
$$ LANGUAGE plpgsql;