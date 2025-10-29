-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: drecgoAseo (Descuentos Recargos Aseo)
-- Generado: 2025-08-27 00:34:16
-- Total SPs: 1
-- ============================================

-- SP 1/1: ins_recaraseo
-- Tipo: CRUD
-- Descripción: Inserta o cancela un descuento de recargos de aseo contratado. Si par_opc=1 inserta, si par_opc=2 cancela.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION ins_recaraseo(
    par_control integer,
    par_axoi integer,
    par_mesi integer,
    par_axof integer,
    par_mesf integer,
    par_usuario varchar,
    par_porc integer,
    par_opc integer
) RETURNS integer AS $$
DECLARE
    v_control integer;
    v_count integer;
    v_exists integer;
BEGIN
    -- Validar operación
    IF par_opc NOT IN (1, 2) THEN
        RAISE EXCEPTION 'Operación no soportada. Use 1 para alta, 2 para cancelación';
    END IF;
    
    IF par_opc = 1 THEN
        -- Verificar si ya existe un descuento vigente para el mismo período
        SELECT COUNT(*) INTO v_exists 
        FROM public.t34_descrecaseo 
        WHERE id_contrato = par_control 
          AND axo_ini = par_axoi 
          AND mes_ini = par_mesi
          AND axo_fin = par_axof 
          AND mes_fin = par_mesf
          AND vigencia = 'V';
        
        IF v_exists > 0 THEN
            RAISE EXCEPTION 'Ya existe un descuento vigente para este período y contrato';
        END IF;
        
        -- Alta de descuento
        INSERT INTO public.t34_descrecaseo (
            id_contrato, axo_ini, mes_ini, axo_fin, mes_fin, 
            fecha_alta, usuario_alta, vigencia, porc
        ) VALUES (
            par_control, par_axoi, par_mesi, par_axof, par_mesf, 
            NOW(), par_usuario, 'V', par_porc
        ) RETURNING id_descto INTO v_control;
        
        RETURN v_control;
        
    ELSIF par_opc = 2 THEN
        -- Cancelación de descuento
        UPDATE public.t34_descrecaseo
        SET fecha_baja = NOW(), 
            usuario_baja = par_usuario, 
            vigencia = 'C'
        WHERE id_contrato = par_control
          AND axo_ini = par_axoi 
          AND mes_ini = par_mesi
          AND axo_fin = par_axof 
          AND mes_fin = par_mesf
          AND porc = par_porc 
          AND vigencia = 'V';
        
        GET DIAGNOSTICS v_count = ROW_COUNT;
        
        IF v_count = 0 THEN
            RAISE EXCEPTION 'No se encontró descuento vigente para cancelar con los parámetros especificados';
        END IF;
        
        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================