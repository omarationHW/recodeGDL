-- Stored Procedure: sp_update_req_pagado
-- Tipo: CRUD
-- Descripción: Actualiza el requerimiento como pagado en ta_15_apremios, usando los datos del pago y folio.
-- Generado para formulario: CargaReqPagados
-- Fecha: 2025-08-26 20:00:45

--
-- sp_update_req_pagado
-- Actualiza el requerimiento como pagado en ta_15_apremios
CREATE OR REPLACE FUNCTION sp_update_req_pagado(
    p_modulo integer,
    p_control_otr integer,
    p_folio integer,
    p_vigencia integer,
    p_fecha_pago date,
    p_recaudadora varchar,
    p_caja varchar,
    p_operacion integer,
    p_folio_pago varchar,
    p_fecha_actualizacion timestamp,
    p_usuario varchar,
    p_imp_multa numeric,
    p_imp_gastos numeric,
    p_importe_pago numeric,
    p_id_usuario integer
) RETURNS void AS $$
BEGIN
    UPDATE ta_15_apremios
    SET vigencia = p_vigencia::varchar,
        fecha_pago = p_fecha_pago,
        recaudadora = p_recaudadora,
        caja = p_caja,
        operacion = p_operacion,
        folio = p_folio_pago,
        fecha_actualiz = p_fecha_actualizacion,
        usuario = p_usuario,
        importe_multa = p_imp_multa,
        importe_gastos = p_imp_gastos,
        importe_pago = COALESCE(p_importe_pago, importe_gastos)
    WHERE modulo = p_modulo
      AND control_otr = p_control_otr
      AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;
