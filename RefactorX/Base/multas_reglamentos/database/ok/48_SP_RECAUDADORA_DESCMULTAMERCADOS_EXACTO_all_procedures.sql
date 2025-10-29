-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DESCMULTAMERCADOS (EXACTO del archivo original)
-- Archivo: 48_SP_RECAUDADORA_DESCMULTAMERCADOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: spd_11_descmultamerc
-- Tipo: CRUD
-- Descripción: Alta y cancelación de descuentos de multas de public. Si par_opc=1, inserta; si par_opc=2, cancela.
-- --------------------------------------------

-- PostgreSQL stored procedure for alta/cancelación de descuentos de multas de mercados
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
BEGIN
    IF par_opc = 1 THEN
        -- Alta
        INSERT INTO public.ta_11_descmulta (
            id_local, axoini, mesini, axofin, mesfin, porcentaje, fecha_alta, usu_alta, estado, autoriza
        ) VALUES (
            par_local, par_axoi, par_mesi, par_axof, par_mesf, par_porc, NOW(), par_usuario, 'V', par_autoriza
        ) RETURNING id_descuento INTO control;
    ELSIF par_opc = 2 THEN
        -- Cancelación
        UPDATE public.ta_11_descmulta
        SET fecha_baja = NOW(), usu_baja = par_usuario, estado = 'C'
        WHERE id_local = par_local AND axoini = par_axoi AND mesini = par_mesi AND axofin = par_axof AND mesfin = par_mesf AND estado = 'V'
        RETURNING id_descuento INTO control;
    END IF;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

