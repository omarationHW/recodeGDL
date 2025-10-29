-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: DrecgoMercado
-- Generado: 2025-08-27 00:55:25
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_ins_recarmerc
-- Tipo: CRUD
-- Descripción: Inserta o cancela un descuento de recargos para un local de mercado. Si par_opc=1 inserta, si par_opc=2 cancela.
-- --------------------------------------------

-- PostgreSQL stored procedure for inserting/cancelling recargo discount in Mercado
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
BEGIN
    IF par_opc = 1 THEN
        -- Insertar descuento
        INSERT INTO descrecmerc (
            id_local, axoini, mesini, axofin, mesfin, porcentaje, fecha_alta, usu_alta, estado, autoriza
        ) VALUES (
            par_local, par_axoi, par_mesi, par_axof, par_mesf, par_porc, NOW(), par_usuario, 'V', par_autoriza
        ) RETURNING id_descuento INTO v_control;
        RETURN v_control;
    ELSIF par_opc = 2 THEN
        -- Cancelar descuento vigente
        UPDATE descrecmerc
        SET estado = 'C', fecha_baja = NOW(), usu_baja = par_usuario
        WHERE id_local = par_local AND axoini = par_axoi AND mesini = par_mesi AND axofin = par_axof AND mesfin = par_mesf AND estado = 'V';
        RETURN 1;
    ELSE
        RAISE EXCEPTION 'Operación no soportada';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

