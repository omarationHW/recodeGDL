-- Stored Procedure: spd_11_descderechosmerc
-- Tipo: CRUD
-- Descripción: Alta y cancelación de descuentos en renta (derechos) de mercados. Si par_opc=1: alta, par_opc=2: cancelación.
-- Generado para formulario: DescDerechosMerc
-- Fecha: 2025-08-27 00:01:33

-- PostgreSQL stored procedure for alta/cancelación de descuentos en mercados
CREATE OR REPLACE FUNCTION spd_11_descderechosmerc(
    par_local INTEGER,
    par_axoi INTEGER,
    par_mesi INTEGER,
    par_axof INTEGER,
    par_mesf INTEGER,
    par_usuario VARCHAR,
    par_porc INTEGER,
    par_autoriza INTEGER,
    par_opc INTEGER, -- 1=alta, 2=cancela
    OUT control INTEGER
) RETURNS INTEGER AS $$
DECLARE
    v_id INTEGER;
BEGIN
    IF par_opc = 1 THEN
        -- Alta
        INSERT INTO ta_11_descderechos (
            id_local, axoini, mesini, axofin, mesfin, porcentaje, fecha_alta, usu_alta, estado, autoriza
        ) VALUES (
            par_local, par_axoi, par_mesi, par_axof, par_mesf, par_porc, NOW(), par_usuario, 'V', par_autoriza
        ) RETURNING id_descuento INTO v_id;
        control := v_id;
        RETURN v_id;
    ELSIF par_opc = 2 THEN
        -- Cancelación
        UPDATE ta_11_descderechos
        SET estado = 'C', fecha_baja = NOW(), usu_baja = par_usuario
        WHERE id_local = par_local AND axoini = par_axoi AND mesini = par_mesi AND axofin = par_axof AND mesfin = par_mesf AND estado = 'V';
        control := 0;
        RETURN 0;
    ELSE
        RAISE EXCEPTION 'Operación no soportada';
    END IF;
END;
$$ LANGUAGE plpgsql;