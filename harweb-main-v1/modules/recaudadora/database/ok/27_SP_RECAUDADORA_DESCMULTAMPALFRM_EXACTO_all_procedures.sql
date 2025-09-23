-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: descmultampalfrm (Descuentos Multa Municipal Principal)
-- Generado: 2025-08-27 00:12:03
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_descmultampal_agregar
-- Tipo: CRUD
-- Descripción: Agrega un nuevo descuento a multa municipal principal
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descmultampal_agregar(
    p_id_multa INTEGER,
    p_tipo_descto CHAR(1),
    p_valor NUMERIC,
    p_autoriza INTEGER,
    p_observacion TEXT,
    p_usuario INTEGER
) RETURNS TABLE(id_descmultampal INTEGER, estado TEXT) AS $$
DECLARE
    v_id INTEGER;
    v_count INTEGER;
BEGIN
    -- Solo puede haber un descuento vigente por multa - cancelar anteriores
    UPDATE public.descmultampal 
    SET estado = 'C' 
    WHERE id_multa = p_id_multa AND estado = 'V';
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    
    -- Insertar nuevo descuento
    INSERT INTO public.descmultampal (
        id_multa, tipo_descto, valor, autoriza, observacion, 
        estado, feccap, capturista
    ) VALUES (
        p_id_multa, p_tipo_descto, p_valor, p_autoriza, p_observacion, 
        'V', NOW(), p_usuario
    ) RETURNING id_descmultampal INTO v_id;
    
    RETURN QUERY SELECT v_id, 'V'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_descmultampal_editar
-- Tipo: CRUD
-- Descripción: Edita un descuento vigente de multa municipal principal
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descmultampal_editar(
    p_id_descmultampal INTEGER,
    p_tipo_descto CHAR(1),
    p_valor NUMERIC,
    p_autoriza INTEGER,
    p_observacion TEXT,
    p_usuario INTEGER
) RETURNS TABLE(id_descmultampal INTEGER, estado TEXT) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    UPDATE public.descmultampal SET
        tipo_descto = p_tipo_descto,
        valor = p_valor,
        autoriza = p_autoriza,
        observacion = p_observacion,
        feccap = NOW(),
        capturista = p_usuario
    WHERE id_descmultampal = p_id_descmultampal
      AND estado = 'V'; -- Solo permitir editar descuentos vigentes
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    
    IF v_count = 0 THEN
        RAISE EXCEPTION 'No se encontró descuento vigente con ID: %', p_id_descmultampal;
    END IF;
    
    RETURN QUERY SELECT p_id_descmultampal, 'V'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_descmultampal_cancelar
-- Tipo: CRUD
-- Descripción: Cancela un descuento vigente de multa municipal principal
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descmultampal_cancelar(
    p_id_descmultampal INTEGER,
    p_motivo TEXT,
    p_usuario INTEGER
) RETURNS TABLE(id_descmultampal INTEGER, estado TEXT) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    UPDATE public.descmultampal SET
        estado = 'C',
        observacion = COALESCE(observacion, '') || E'\nCANCELADO: ' || p_motivo,
        feccap = NOW(),
        capturista = p_usuario
    WHERE id_descmultampal = p_id_descmultampal
      AND estado = 'V'; -- Solo permitir cancelar descuentos vigentes
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    
    IF v_count = 0 THEN
        RAISE EXCEPTION 'No se encontró descuento vigente con ID: %', p_id_descmultampal;
    END IF;
    
    RETURN QUERY SELECT p_id_descmultampal, 'C'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================