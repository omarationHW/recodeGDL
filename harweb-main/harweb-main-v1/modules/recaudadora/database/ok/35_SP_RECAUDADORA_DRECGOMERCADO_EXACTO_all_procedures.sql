-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: DrecgoMercado (Descuentos Recargos Mercado)
-- Generado: 2025-08-27 00:55:25
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_ins_recarmerc
-- Tipo: CRUD
-- Descripción: Inserta o cancela un descuento de recargos para un local de mercado. Si par_opc=1 inserta, si par_opc=2 cancela.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ins_recarmerc(
    par_local integer,
    par_axoi integer,
    par_mesi integer,
    par_axof integer,
    par_mesf integer,
    par_usuario varchar,
    par_porc integer,
    par_autoriza integer,
    par_opc integer
) RETURNS integer AS $$
DECLARE
    v_control integer;
    v_count integer;
    v_exists integer;
BEGIN
    -- Validar operación
    IF par_opc NOT IN (1, 2) THEN
        RAISE EXCEPTION 'Operación no soportada. Use 1 para insertar, 2 para cancelar';
    END IF;
    
    IF par_opc = 1 THEN
        -- Verificar si ya existe un descuento vigente para el mismo período
        SELECT COUNT(*) INTO v_exists 
        FROM public.descrecmerc 
        WHERE id_local = par_local 
          AND axoini = par_axoi 
          AND mesini = par_mesi
          AND axofin = par_axof 
          AND mesfin = par_mesf
          AND estado = 'V';
        
        IF v_exists > 0 THEN
            RAISE EXCEPTION 'Ya existe un descuento vigente para este local y período';
        END IF;
        
        -- Insertar descuento
        INSERT INTO public.descrecmerc (
            id_local, axoini, mesini, axofin, mesfin, porcentaje, 
            fecha_alta, usu_alta, estado, autoriza
        ) VALUES (
            par_local, par_axoi, par_mesi, par_axof, par_mesf, par_porc, 
            NOW(), par_usuario, 'V', par_autoriza
        ) RETURNING id_descuento INTO v_control;
        
        RETURN v_control;
        
    ELSIF par_opc = 2 THEN
        -- Cancelar descuento vigente
        UPDATE public.descrecmerc
        SET estado = 'C', 
            fecha_baja = NOW(), 
            usu_baja = par_usuario
        WHERE id_local = par_local 
          AND axoini = par_axoi 
          AND mesini = par_mesi 
          AND axofin = par_axof 
          AND mesfin = par_mesf 
          AND estado = 'V';
        
        GET DIAGNOSTICS v_count = ROW_COUNT;
        
        IF v_count = 0 THEN
            RAISE EXCEPTION 'No se encontró descuento vigente para cancelar con los parámetros especificados';
        END IF;
        
        RETURN 1;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================