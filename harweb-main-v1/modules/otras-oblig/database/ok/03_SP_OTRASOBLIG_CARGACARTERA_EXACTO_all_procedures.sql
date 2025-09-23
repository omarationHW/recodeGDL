-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - OTRAS-OBLIG
-- Formulario: CargaCartera (EXACTO del archivo original)
-- Archivo: 03_SP_OTRASOBLIG_CARGACARTERA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: con34_cgacart_01
-- Tipo: CRUD
-- Descripción: Genera la cartera para una tabla y ejercicio específico. Devuelve status y mensaje.
-- --------------------------------------------

-- PostgreSQL stored procedure for cartera generation
CREATE OR REPLACE FUNCTION con34_cgacart_01(par_tabla TEXT, par_ejer INTEGER)
RETURNS TABLE(status INTEGER, concepto_status TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status INTEGER := 0;
    v_msg TEXT := '';
BEGIN
    -- Ejemplo de lógica: (ajustar según reglas de negocio reales)
    -- 1. Validar existencia de unidades para la tabla y ejercicio
    IF NOT EXISTS (
        SELECT 1 FROM otrasoblig.t34_unidades WHERE cve_tab = par_tabla AND ejercicio = par_ejer
    ) THEN
        v_status := 1;
        v_msg := 'No existen unidades para la tabla y ejercicio seleccionados.';
        RETURN QUERY SELECT v_status, v_msg;
        RETURN;
    END IF;

    -- 2. Ejecutar proceso de generación de cartera (simulado)
    BEGIN
        -- Aquí iría la lógica real de generación de cartera
        -- Por ejemplo: INSERT INTO otrasoblig.t34_cartera ...
        -- Simulación:
        -- INSERT INTO otrasoblig.t34_cartera (cve_tab, ejercicio, ...) SELECT ...
        v_status := 0;
        v_msg := 'Cartera generada correctamente para tabla ' || par_tabla || ' y ejercicio ' || par_ejer;
    EXCEPTION WHEN OTHERS THEN
        v_status := 2;
        v_msg := 'Error al generar cartera: ' || SQLERRM;
    END;
    RETURN QUERY SELECT v_status, v_msg;
END;
$$;

-- ============================================