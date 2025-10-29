-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: DescMultaTrans (Descuentos Multa Transmisiones)
-- Generado: 2025-08-27 00:17:36
-- Total SPs: 3
-- ============================================

-- SP 1/3: calc_desctransmul
-- Tipo: CRUD
-- Descripción: Calcula y aplica el descuento de multa de transmisión patrimonial. Actualiza los importes y recalcula si es necesario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION calc_desctransmul(par_folio INTEGER, par_Opc INTEGER)
RETURNS VOID AS $$
DECLARE
    v_porcentaje FLOAT;
    v_multa_original FLOAT;
BEGIN
    -- par_Opc: 1 = aplicar descuento, 2 = cancelar descuento
    
    IF par_Opc = 1 THEN
        -- Obtener el porcentaje del descuento vigente
        SELECT porcentaje INTO v_porcentaje
        FROM public.descmultatrans 
        WHERE folio = par_folio AND estado = 'V' 
        ORDER BY id_descmultatrans DESC 
        LIMIT 1;
        
        IF v_porcentaje IS NOT NULL THEN
            -- Actualizar los importes de la multa con el descuento
            UPDATE public.impuestoTransp 
            SET multaimpuesto = multaimpuesto - (v_porcentaje * multaimpuesto / 100)
            WHERE folio = par_folio;
        END IF;
        
    ELSIF par_Opc = 2 THEN
        -- Cancelar el descuento (restaurar importe original)
        SELECT multaimpuesto INTO v_multa_original
        FROM public.impuestoTransp_backup 
        WHERE folio = par_folio;
        
        IF v_multa_original IS NOT NULL THEN
            UPDATE public.impuestoTransp 
            SET multaimpuesto = v_multa_original
            WHERE folio = par_folio;
        END IF;
        
    ELSE
        RAISE EXCEPTION 'Operación no válida. Use 1 para aplicar descuento, 2 para cancelar';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_descmultatrans_alta
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro de descuento de multa de transmisión patrimonial.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descmultatrans_alta(
    p_folio INTEGER,
    p_porcentaje FLOAT,
    p_captalta VARCHAR(50),
    p_autoriza INTEGER,
    p_observaciones VARCHAR(250)
) RETURNS TABLE(result TEXT) AS $$
DECLARE
    v_exists INTEGER;
    v_id INTEGER;
BEGIN
    -- Verificar si ya existe un descuento vigente para este folio
    SELECT COUNT(*) INTO v_exists 
    FROM public.descmultatrans 
    WHERE folio = p_folio AND estado = 'V';
    
    IF v_exists > 0 THEN
        -- Cancelar descuentos anteriores vigentes
        UPDATE public.descmultatrans 
        SET estado = 'C', 
            fecbaja = CURRENT_DATE, 
            captbaja = p_captalta
        WHERE folio = p_folio AND estado = 'V';
    END IF;
    
    -- Crear respaldo del importe original antes de aplicar descuento
    INSERT INTO public.impuestoTransp_backup (folio, multaimpuesto, fecha_backup)
    SELECT folio, multaimpuesto, CURRENT_TIMESTAMP
    FROM public.impuestoTransp 
    WHERE folio = p_folio
    ON CONFLICT (folio) DO NOTHING;
    
    -- Insertar nuevo descuento
    INSERT INTO public.descmultatrans (
        folio, porcentaje, fecalta, captalta, fecbaja, captbaja, 
        estado, cvepago, autoriza, observaciones
    )
    VALUES (
        p_folio, p_porcentaje, CURRENT_DATE, p_captalta, NULL, NULL, 
        'V', NULL, p_autoriza, p_observaciones
    )
    RETURNING id_descmultatrans INTO v_id;
    
    RETURN QUERY SELECT 'OK'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_descmultatrans_cancelar
-- Tipo: CRUD
-- Descripción: Cancela un descuento de multa de transmisión patrimonial.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_descmultatrans_cancelar(
    p_id_descmultatrans INTEGER,
    p_folio INTEGER,
    p_captbaja VARCHAR(50)
) RETURNS TABLE(result TEXT) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Actualizar estado del descuento
    UPDATE public.descmultatrans
    SET estado = 'C', 
        fecbaja = CURRENT_DATE, 
        captbaja = p_captbaja
    WHERE folio = p_folio 
      AND id_descmultatrans = p_id_descmultatrans
      AND estado = 'V'; -- Solo cancelar si está vigente
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    
    IF v_count = 0 THEN
        RAISE EXCEPTION 'No se encontró descuento vigente con folio % e ID %', p_folio, p_id_descmultatrans;
    END IF;
    
    -- Restaurar importe original
    PERFORM calc_desctransmul(p_folio, 2);
    
    RETURN QUERY SELECT 'OK'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================