-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: mensaje
-- Generado: 2025-08-27 13:51:13
-- Total SPs: 1
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

