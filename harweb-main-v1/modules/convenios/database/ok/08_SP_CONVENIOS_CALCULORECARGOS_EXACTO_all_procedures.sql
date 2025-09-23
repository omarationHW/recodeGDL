-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: CalculoRecargos (EXACTO del archivo original)
-- Archivo: 08_SP_CONVENIOS_CALCULORECARGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_get_contrato
-- Tipo: Catalog
-- Descripción: Obtiene los datos principales del contrato/convenio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_contrato(p_id_convenio INTEGER)
RETURNS TABLE(
    id_convenio INTEGER,
    pago_inicial NUMERIC,
    pago_quincenal NUMERIC,
    pagos_parciales INTEGER,
    fecha_vencimiento DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_convenio, pago_inicial, pago_quincenal, pagos_parciales, fecha_vencimiento
    FROM public.ta_17_convenios
    WHERE id_convenio = p_id_convenio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_get_requerimientos
-- Tipo: Catalog
-- Descripción: Obtiene los requerimientos (apremios) asociados a un contrato
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_requerimientos(p_id_convenio INTEGER)
RETURNS TABLE(
    id_control INTEGER,
    zona SMALLINT,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia VARCHAR,
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    zona_apremio SMALLINT,
    fecha_emision DATE,
    clave_practicado VARCHAR,
    fecha_practicado DATE,
    fecha_entrega1 DATE,
    fecha_entrega2 DATE,
    fecha_citatorio DATE,
    hora TIMESTAMP,
    ejecutor SMALLINT,
    clave_secuestro SMALLINT,
    clave_remate VARCHAR,
    fecha_remate DATE,
    porcentaje_multa SMALLINT,
    observaciones VARCHAR,
    fecha_pago DATE,
    recaudadora SMALLINT,
    caja VARCHAR,
    operacion INTEGER,
    importe_pago NUMERIC,
    vigencia VARCHAR,
    fecha_actualiz DATE,
    usuario INTEGER,
    clave_mov VARCHAR,
    hora_practicado TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public.ta_15_apremios WHERE modulo = 17 AND control_otr = p_id_convenio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_get_recargos
-- Tipo: CRUD
-- Descripción: Obtiene el porcentaje de recargos acumulado para el periodo dado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recargos(
    p_alov INTEGER, p_mesv INTEGER, p_alo INTEGER, p_mes INTEGER, p_dia INTEGER, p_diav INTEGER
) RETURNS NUMERIC AS $$
DECLARE
    mes_limit INTEGER;
    porcentaje NUMERIC;
BEGIN
    IF p_dia <= p_diav THEN
        mes_limit := p_mes - 1;
    ELSE
        mes_limit := p_mes;
    END IF;
    SELECT SUM(porcentaje_parcial) INTO porcentaje
    FROM public.ta_13_recargosrcm
    WHERE (axo = p_alov AND mes >= p_mesv)
      OR (axo = p_alo AND mes <= mes_limit)
      OR (axo > p_alov AND axo < p_alo);
    RETURN COALESCE(porcentaje, 0);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_calcular_recargos
-- Tipo: CRUD
-- Descripción: Calcula el importe de recargos según la lógica del formulario
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_calcular_recargos(
    p_pagos_parciales INTEGER,
    p_pagos_a_realizar INTEGER,
    p_pag_inicio NUMERIC,
    p_pag_parcial NUMERIC,
    p_fecha_vencimiento DATE,
    p_fecha_actual DATE,
    p_requerimientos JSONB,
    p_porcentaje_recargos NUMERIC
) RETURNS TABLE(
    importe_a_pagar NUMERIC,
    importerecargos NUMERIC,
    label_porc TEXT
) AS $$
DECLARE
    importe_a_pagar NUMERIC := p_pag_inicio + p_pag_parcial;
    importerecargos NUMERIC := 0;
    label_porc TEXT := '';
    tiene_requerimientos BOOLEAN := (jsonb_array_length(p_requerimientos) > 0);
BEGIN
    IF p_pagos_a_realizar > p_pagos_parciales THEN
        RAISE EXCEPTION 'Error... Los Pagos a Realizar Exceden de %', p_pagos_parciales;
    END IF;
    IF p_fecha_actual > p_fecha_vencimiento THEN
        IF NOT tiene_requerimientos THEN
            IF p_porcentaje_recargos > 100 THEN
                importerecargos := (importe_a_pagar * 100) / 100;
                label_porc := '100%';
            ELSE
                importerecargos := (importe_a_pagar * p_porcentaje_recargos) / 100;
                label_porc := p_porcentaje_recargos::TEXT || '%';
            END IF;
        ELSE
            IF p_porcentaje_recargos > 250 THEN
                importerecargos := (importe_a_pagar * 250) / 100;
                label_porc := '250%';
            ELSE
                importerecargos := (importe_a_pagar * p_porcentaje_recargos) / 100;
                label_porc := p_porcentaje_recargos::TEXT || '%';
            END IF;
        END IF;
    ELSE
        importerecargos := (importe_a_pagar * p_porcentaje_recargos) / 100;
        label_porc := p_porcentaje_recargos::TEXT || '%';
    END IF;
    IF importerecargos > 0 THEN
        importerecargos := floor(importerecargos * 100) / 100;
    END IF;
    RETURN QUERY SELECT importe_a_pagar, importerecargos, label_porc;
END;
$$ LANGUAGE plpgsql;

-- ============================================