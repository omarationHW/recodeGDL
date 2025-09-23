-- Stored Procedure: sp_pagar_apremio
-- Tipo: CRUD
-- Descripción: Marca un apremio como pagado, actualizando los campos de pago.
-- Generado para formulario: ReqsCons
-- Fecha: 2025-08-27 20:45:14

CREATE OR REPLACE PROCEDURE sp_pagar_apremio(
    p_fecha DATE,
    p_id_rec INTEGER,
    p_caja VARCHAR,
    p_operacion INTEGER,
    p_importe_gastos NUMERIC,
    p_id_control INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ta_15_apremios
    SET fecha_pago = p_fecha,
        recaudadora = p_id_rec,
        caja = p_caja,
        operacion = p_operacion,
        vigencia = '2',
        clave_mov = 'P',
        importe_pago = p_importe_gastos
    WHERE id_control = p_id_control;
END;
$$;