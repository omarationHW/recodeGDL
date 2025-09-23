-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ImpOficiofrm
-- Generado: 2025-08-27 18:30:26
-- Total SPs: 2
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

-- SP 2/2: sp_get_tramite_info
-- Tipo: Catalog
-- Descripción: Obtiene la información básica de un trámite por su ID.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tramite_info(p_tramite_id INTEGER)
RETURNS TABLE(
    id_tramite INTEGER,
    propietario TEXT,
    ubicacion TEXT,
    estatus TEXT,
    tipo_tramite TEXT,
    fecha TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id_tramite, t.propietario, t.ubicacion, t.estatus, t.tipo_tramite, t.feccap
    FROM tramites t
    WHERE t.id_tramite = p_tramite_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

