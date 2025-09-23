-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: IndividualPredios
-- Generado: 2025-08-27 14:45:56
-- Total SPs: 6
-- ============================================

-- SP 1/6: sp_get_predio_by_id
-- Tipo: Catalog
-- Descripción: Obtiene los datos completos del predio/convenio por id_conv_predio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_predio_by_id(p_id_conv_predio INTEGER)
RETURNS TABLE (
    id_conv_predio INTEGER,
    tipo SMALLINT,
    subtipo SMALLINT,
    manzana VARCHAR,
    lote INTEGER,
    letra VARCHAR,
    id_usuario INTEGER,
    fecha_actual TIMESTAMP,
    id_conv_resto INTEGER,
    tipo_1 SMALLINT,
    id_conv_diver INTEGER,
    id_referencia INTEGER,
    id_rec SMALLINT,
    id_zona INTEGER,
    nombre VARCHAR,
    calle VARCHAR,
    num_exterior SMALLINT,
    num_interior SMALLINT,
    inciso VARCHAR,
    fecha_inicio DATE,
    fecha_venc DATE,
    cantidad_total NUMERIC,
    cantidad_inicio NUMERIC,
    pago_parcial NUMERIC,
    pago_final NUMERIC,
    total_pagos SMALLINT,
    metros FLOAT,
    tipo_pago VARCHAR,
    observaciones VARCHAR,
    vigencia VARCHAR,
    usuario VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_conv_predio, a.tipo, a.subtipo, a.manzana, a.lote, a.letra, a.id_usuario, a.fecha_actual,
           b.id_conv_resto, b.tipo AS tipo_1, b.id_conv_diver, b.id_referencia, b.id_rec, b.id_zona, b.nombre, b.calle,
           b.num_exterior, b.num_interior, b.inciso, b.fecha_inicio, b.fecha_venc, b.cantidad_total, b.cantidad_inicio,
           b.pago_parcial, b.pago_final, b.total_pagos, b.metros, b.tipo_pago, b.observaciones, b.vigencia, e.usuario
    FROM ta_17_con_reg_pred a
    JOIN ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_predio = b.id_conv_diver
    JOIN ta_12_passwords e ON b.id_usuario = e.id_usuario
    WHERE a.id_conv_predio = p_id_conv_predio
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/6: sp_get_adeudos_by_predio
-- Tipo: Catalog
-- Descripción: Obtiene los adeudos vencidos de un predio/convenio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_adeudos_by_predio(p_id_conv_resto INTEGER, p_fecha DATE)
RETURNS TABLE (
    id_conv_resto INTEGER,
    pago_parcial SMALLINT,
    importe NUMERIC,
    fecha_venc DATE,
    recargos NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT ad.id_conv_resto, ad.pago_parcial, ad.importe, ad.fecha_venc,
           COALESCE(sp_calc_recargos_adeudo(ad.id_conv_resto, ad.importe, ad.fecha_venc, p_fecha), 0) AS recargos
    FROM ta_17_adeudos_div ad
    WHERE ad.id_conv_resto = p_id_conv_resto
      AND ad.fecha_venc < p_fecha
      AND ad.clave_pago IS NULL
    ORDER BY ad.id_conv_resto, ad.pago_parcial;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/6: sp_get_tot_pagado_by_predio
-- Tipo: Report
-- Descripción: Obtiene el total pagado por un predio/convenio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tot_pagado_by_predio(p_id_conv_resto INTEGER)
RETURNS TABLE (
    importe_pago NUMERIC,
    cve_descuento SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT importe_pago, cve_descuento
    FROM ta_17_conv_pagos
    WHERE id_conv_resto = p_id_conv_resto
      AND cve_bonificacion IS NULL;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/6: sp_calc_recargos_adeudo
-- Tipo: CRUD
-- Descripción: Calcula el recargo para un adeudo de predio/convenio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_calc_recargos_adeudo(
    p_id_conv_resto INTEGER,
    p_importe NUMERIC,
    p_fecha_venc DATE,
    p_fecha_actual DATE
) RETURNS NUMERIC AS $$
DECLARE
    alov INTEGER;
    mesv INTEGER;
    diav INTEGER;
    alo INTEGER;
    mes INTEGER;
    dia INTEGER;
    dvenc INTEGER;
    porc FLOAT;
    recargo NUMERIC := 0;
    v_porcentaje FLOAT;
BEGIN
    SELECT EXTRACT(YEAR FROM p_fecha_venc), EXTRACT(MONTH FROM p_fecha_venc), EXTRACT(DAY FROM p_fecha_venc)
      INTO alov, mesv, diav;
    SELECT EXTRACT(YEAR FROM p_fecha_actual), EXTRACT(MONTH FROM p_fecha_actual), EXTRACT(DAY FROM p_fecha_actual)
      INTO alo, mes, dia;
    -- Buscar día de vencimiento
    SELECT COALESCE(day(fecha_venc), diav) INTO dvenc
      FROM ta_17_adeudos_div
      WHERE id_conv_resto = p_id_conv_resto
        AND EXTRACT(YEAR FROM fecha_venc) = alo
        AND EXTRACT(MONTH FROM fecha_venc) = mes
      LIMIT 1;
    -- Calcular porcentaje
    SELECT COALESCE(SUM(porcentaje_parcial), 0) INTO v_porcentaje
      FROM ta_13_recargosrcm
      WHERE (axo = alov AND mes >= mesv)
        OR (axo = alo AND mes <= CASE WHEN dia <= dvenc THEN mes-1 ELSE mes END)
        OR (axo > alov AND axo < alo);
    recargo := (p_importe * v_porcentaje) / 100.0;
    IF recargo > 0 THEN
        recargo := trunc(recargo * 100) / 100.0;
    END IF;
    RETURN recargo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/6: sp_get_dia_vencimiento
-- Tipo: Catalog
-- Descripción: Obtiene el día de vencimiento para un predio/convenio en un año y mes dados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_dia_vencimiento(p_id_conv_resto INTEGER, p_anio INTEGER, p_mes INTEGER)
RETURNS TABLE (dia_venc SMALLINT) AS $$
BEGIN
    RETURN QUERY
    SELECT EXTRACT(DAY FROM fecha_venc)::SMALLINT AS dia_venc
    FROM ta_17_adeudos_div
    WHERE id_conv_resto = p_id_conv_resto
      AND EXTRACT(YEAR FROM fecha_venc) = p_anio
      AND EXTRACT(MONTH FROM fecha_venc) = p_mes
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: sp_get_dias_inhabiles
-- Tipo: Catalog
-- Descripción: Obtiene los días inhábiles para una fecha dada
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_dias_inhabiles(p_fecha DATE)
RETURNS TABLE (fecha DATE) AS $$
BEGIN
    RETURN QUERY
    SELECT fecha FROM ta_12_diasinhabil WHERE fecha = p_fecha;
END;
$$ LANGUAGE plpgsql;

-- ============================================

