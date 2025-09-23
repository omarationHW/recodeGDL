-- Stored Procedure: spd_11_descmultamerc
-- Tipo: CRUD
-- Descripción: Alta y cancelación de descuentos de multas de mercados. Si par_opc=1, inserta; si par_opc=2, cancela.
-- Generado para formulario: DescMultaMercados
-- Fecha: 2025-08-27 00:08:08

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
        INSERT INTO ta_11_descmulta (
            id_local, axoini, mesini, axofin, mesfin, porcentaje, fecha_alta, usu_alta, estado, autoriza
        ) VALUES (
            par_local, par_axoi, par_mesi, par_axof, par_mesf, par_porc, NOW(), par_usuario, 'V', par_autoriza
        ) RETURNING id_descuento INTO control;
    ELSIF par_opc = 2 THEN
        -- Cancelación
        UPDATE ta_11_descmulta
        SET fecha_baja = NOW(), usu_baja = par_usuario, estado = 'C'
        WHERE id_local = par_local AND axoini = par_axoi AND mesini = par_mesi AND axofin = par_axof AND mesfin = par_mesf AND estado = 'V'
        RETURNING id_descuento INTO control;
    END IF;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;