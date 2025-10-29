-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ActCont_CR
-- Generado: 2025-08-27 13:33:30
-- Total SPs: 1
-- ============================================

-- SP 1/1: get_ta_catalog
-- Tipo: Catalog
-- Descripción: Devuelve todos los registros de la tabla ta (catálogo de contratos de recolección).
-- --------------------------------------------

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

-- ============================================

