-- Stored Procedure: sp_adeudos_pagmult_pagar_adeudos
-- Tipo: CRUD
-- Descripción: Marca como pagados los adeudos seleccionados, actualizando los campos de pago.
-- Generado para formulario: Adeudos_PagMult
-- Fecha: 2025-08-27 13:51:30

CREATE OR REPLACE FUNCTION sp_adeudos_pagmult_pagar_adeudos(
    p_adeudos jsonb,
    p_fecha_pagado timestamp,
    p_id_rec integer,
    p_caja varchar,
    p_consec_operacion integer,
    p_folio_rcbo varchar,
    p_usuario integer
) RETURNS void AS $$
DECLARE
    ad jsonb;
    r record;
BEGIN
    FOR ad IN SELECT * FROM jsonb_array_elements(p_adeudos) LOOP
        SELECT control_contrato, aso_mes_pago, ctrol_operacion INTO r
        FROM jsonb_to_record(ad) AS x(control_contrato integer, aso_mes_pago date, ctrol_operacion integer);
        UPDATE ta_16_pagos
        SET status_vigencia = 'P',
            fecha_hora_pago = p_fecha_pagado,
            id_rec = p_id_rec,
            caja = p_caja,
            consec_operacion = p_consec_operacion,
            folio_rcbo = p_folio_rcbo,
            usuario = p_usuario
        WHERE control_contrato = r.control_contrato
          AND aso_mes_pago = r.aso_mes_pago
          AND ctrol_operacion = r.ctrol_operacion
          AND status_vigencia = 'V';
    END LOOP;
END;
$$ LANGUAGE plpgsql;