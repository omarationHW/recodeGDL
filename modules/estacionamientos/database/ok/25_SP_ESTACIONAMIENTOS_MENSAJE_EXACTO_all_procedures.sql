-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: MENSAJE (EXACTO del archivo original)
-- Archivo: 25_SP_ESTACIONAMIENTOS_MENSAJE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_mensaje_show
-- Tipo: CRUD
-- Descripción: Registra o procesa la visualización de un mensaje del sistema. Puede ser extendido para logging o auditoría.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_mensaje_show(tipo TEXT, msg TEXT, icono TEXT)
RETURNS TABLE(tipo TEXT, msg TEXT, icono TEXT) AS $$
BEGIN
    -- Aquí se podría registrar el mensaje en una tabla de logs si se desea
    -- Por ejemplo:
    -- INSERT INTO mensaje_log(tipo, msg, icono, fecha) VALUES (tipo, msg, icono, NOW());
    RETURN QUERY SELECT tipo, msg, icono;
END;
$$ LANGUAGE plpgsql;

-- ============================================

