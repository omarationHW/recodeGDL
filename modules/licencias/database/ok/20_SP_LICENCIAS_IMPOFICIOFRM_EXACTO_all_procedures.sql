-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: IMPOFICIOFRM (EXACTO del archivo original)
-- Archivo: 20_SP_LICENCIAS_IMPOFICIOFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_imp_oficio_register
-- Tipo: CRUD
-- Descripción: Registra la decisión del usuario sobre el tipo de oficio a imprimir para un trámite improcedente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_imp_oficio_register(
    p_tramite_id INTEGER,
    p_oficio_type INTEGER,
    p_usuario_id INTEGER,
    p_observaciones TEXT DEFAULT NULL
) RETURNS TABLE(result TEXT) AS $$
DECLARE
    v_tipo_oficio TEXT;
BEGIN
    -- Validación básica
    IF p_oficio_type NOT IN (1,2,3,4) THEN
        RAISE EXCEPTION 'Tipo de oficio inválido';
    END IF;
    -- Determinar tipo de oficio
    CASE p_oficio_type
        WHEN 1 THEN v_tipo_oficio := 'Uno';
        WHEN 2 THEN v_tipo_oficio := 'Dos';
        WHEN 3 THEN v_tipo_oficio := 'M24BIS';
        WHEN 4 THEN v_tipo_oficio := 'Informativo';
    END CASE;
    -- Registrar la decisión en una tabla de bitácora
    INSERT INTO imp_oficio_bitacora(tramite_id, oficio_type, oficio_label, usuario_id, observaciones, fecha)
    VALUES (p_tramite_id, p_oficio_type, v_tipo_oficio, p_usuario_id, p_observaciones, NOW());
    -- Aquí se podría invocar la lógica de impresión o generación de PDF
    RETURN QUERY SELECT 'Oficio registrado: ' || v_tipo_oficio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: IMPOFICIOFRM (EXACTO del archivo original)
-- Archivo: 20_SP_LICENCIAS_IMPOFICIOFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

