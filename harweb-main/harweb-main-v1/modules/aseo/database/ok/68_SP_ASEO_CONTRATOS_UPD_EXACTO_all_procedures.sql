-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONTRATOS_UPD (EXACTO del archivo original)
-- Archivo: 68_SP_ASEO_CONTRATOS_UPD_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp16_contratos_upd
-- Tipo: CRUD
-- Descripción: Actualiza los datos principales de un contrato (cantidad de recolección, domicilio, sector, zona, recaudadora, inicio de obligación) y registra el documento de soporte.
-- --------------------------------------------

-- PostgreSQL stored procedure for updating contract data
CREATE OR REPLACE FUNCTION sp16_contratos_upd(
    p_control_contrato INTEGER,
    p_cantidad_recolec INTEGER,
    p_domicilio VARCHAR,
    p_sector VARCHAR,
    p_ctrol_zona INTEGER,
    p_id_rec INTEGER,
    p_aso_mes_oblig DATE,
    p_documento VARCHAR,
    p_descripcion_docto VARCHAR,
    p_usuario INTEGER
) RETURNS TABLE(status INTEGER, leyenda VARCHAR) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM public.ta_16_contratos WHERE control_contrato = p_control_contrato;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT 1, 'Contrato no encontrado';
        RETURN;
    END IF;
    -- Actualizar contrato
    UPDATE public.ta_16_contratos
    SET cantidad_recolec = p_cantidad_recolec,
        domicilio = p_domicilio,
        sector = p_sector,
        ctrol_zona = p_ctrol_zona,
        id_rec = p_id_rec,
        aso_mes_oblig = p_aso_mes_oblig,
        usuario = p_usuario
    WHERE control_contrato = p_control_contrato;
    -- Registrar documento en historial
    INSERT INTO public.ta_16_contratos_historial (control_contrato, documento, descripcion, id_usuario, fecha_movto)
    VALUES (p_control_contrato, p_documento, p_descripcion_docto, p_usuario, NOW());
    RETURN QUERY SELECT 0, 'Contrato actualizado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

