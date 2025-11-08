-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ActCont_CR (EXACTO del archivo original)
-- Archivo: 19_SP_ASEO_ACTCONT_CR_EXACTO_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 1 (EXACTO)
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
    RETURN QUERY SELECT * FROM public.ta;
END;
$$ LANGUAGE plpgsql;

-- ============================================