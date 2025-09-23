-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CargaReqPagados
-- Generado: 2025-08-26 23:01:28
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_carga_req_pagados
-- Tipo: CRUD
-- Descripción: Actualiza el requerimiento como pagado en ta_15_apremios para un folio y local dados, registrando los datos de pago.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_carga_req_pagados(
    p_id_local INTEGER,
    p_folio INTEGER,
    p_fecha_pago DATE,
    p_oficina VARCHAR,
    p_caja VARCHAR,
    p_operacion VARCHAR,
    p_folio_pago VARCHAR,
    p_fecha_actualizacion VARCHAR,
    p_usuario VARCHAR,
    p_imp_multa NUMERIC,
    p_imp_gastos NUMERIC,
    p_id_usuario INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE ta_15_apremios
    SET vigencia = '2',
        fecha_pago = p_fecha_pago,
        recaudadora = p_oficina,
        caja = p_caja,
        operacion = p_operacion,
        importe_pago = (
            SELECT COALESCE(importe_gastos, 0) FROM ta_15_apremios
            WHERE modulo = 11 AND control_otr = p_id_local AND folio = p_folio
            LIMIT 1
        ),
        fecha_actualizacion = NOW(),
        usuario = p_usuario,
        imp_multa = p_imp_multa,
        imp_gastos = p_imp_gastos
    WHERE modulo = 11
      AND control_otr = p_id_local
      AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

