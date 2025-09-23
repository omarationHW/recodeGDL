-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: DescMultaMercados (Descuentos Multas Mercados)
-- Generado: 2025-08-27 00:08:08
-- Total SPs: 1
-- ============================================

-- SP 1/1: spd_11_descmultamerc
-- Tipo: CRUD
-- Descripción: Alta y cancelación de descuentos de multas de public. Si par_opc=1, inserta; si par_opc=2, cancela.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spd_11_descmultamerc(
    par_local INTEGER,
    par_axoi INTEGER,
    par_mesi INTEGER,
    par_axof INTEGER,
    par_mesf INTEGER,
    par_usuario VARCHAR,
    par_porc INTEGER,
    par_autoriza INTEGER,
    par_opc INTEGER
) RETURNS TABLE(control INTEGER) AS $$
DECLARE
    v_id INTEGER;
    v_count INTEGER;
BEGIN
    -- Validar operación
    IF par_opc NOT IN (1, 2) THEN
        RAISE EXCEPTION 'Operación no soportada. Use 1 para alta, 2 para cancelación';
    END IF;
    
    IF par_opc = 1 THEN
        -- Alta de descuento
        INSERT INTO public.ta_11_descmulta (
            id_local, axoini, mesini, axofin, mesfin, porcentaje, 
            fecha_alta, usu_alta, estado, autoriza
        ) VALUES (
            par_local, par_axoi, par_mesi, par_axof, par_mesf, par_porc, 
            NOW(), par_usuario, 'V', par_autoriza
        ) RETURNING id_descuento INTO v_id;
        
        control := v_id;
        RETURN NEXT;
        
    ELSIF par_opc = 2 THEN
        -- Cancelación de descuento
        UPDATE public.ta_11_descmulta
        SET fecha_baja = NOW(), 
            usu_baja = par_usuario, 
            estado = 'C'
        WHERE id_local = par_local 
          AND axoini = par_axoi 
          AND mesini = par_mesi 
          AND axofin = par_axof 
          AND mesfin = par_mesf 
          AND estado = 'V'
        RETURNING id_descuento INTO v_id;
        
        -- Verificar si se actualizó algún registro
        GET DIAGNOSTICS v_count = ROW_COUNT;
        
        IF v_count = 0 THEN
            RAISE EXCEPTION 'No se encontró descuento vigente para cancelar con los parámetros especificados';
        END IF;
        
        control := v_id;
        RETURN NEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================