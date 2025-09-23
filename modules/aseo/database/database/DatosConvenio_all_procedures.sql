-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: DatosConvenio
-- Generado: 2025-08-27 14:34:07
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_get_datos_convenio
-- Tipo: Catalog
-- Descripción: Obtiene los datos generales de un convenio, incluyendo nombre, dirección, periodos, fechas y montos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_datos_convenio(p_id_conv_resto INTEGER)
RETURNS TABLE (
    nombre VARCHAR(50),
    calle VARCHAR(50),
    num_exterior SMALLINT,
    num_interior SMALLINT,
    inciso VARCHAR(10),
    vigencia CHAR(1),
    periodos VARCHAR(165),
    fecha_inicio DATE,
    fecha_venc DATE,
    tipo_pago CHAR(1),
    impuesto NUMERIC(18,2),
    recargos NUMERIC(18,2),
    gastos NUMERIC(18,2),
    multa NUMERIC(18,2),
    total NUMERIC(18,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.nombre, a.calle, a.num_exterior, a.num_interior, a.inciso, a.vigencia,
        (b.mes_desde || '/' || b.axo_desde || ' - ' || b.mes_hasta || '/' || b.axo_hasta) AS periodos,
        a.fecha_inicio, a.fecha_venc, a.tipo_pago,
        b.impuesto, b.recargos, b.gastos, b.multa, b.total
    FROM ta_17_conv_d_resto a
    JOIN ta_17_referencia b ON b.id_conv_resto = a.id_conv_resto
    WHERE a.id_conv_resto = p_id_conv_resto;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_get_parcialidades_convenio
-- Tipo: Catalog
-- Descripción: Obtiene las parcialidades (adeudos parciales) de un convenio, incluyendo información de pago.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_parcialidades_convenio(p_id_conv_resto INTEGER)
RETURNS TABLE (
    parcial SMALLINT,
    impuesto_adeudo NUMERIC(18,2),
    periodos VARCHAR(165),
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago CHAR(2),
    operacion_pago INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.pago_parcial AS parcial,
        a.importe AS impuesto_adeudo,
        (a.mes_desde || '/' || a.axo_desde || ' - ' || a.mes_hasta || '/' || a.axo_hasta) AS periodos,
        b.fecha_pago, b.oficina_pago, b.caja_pago, b.operacion_pago
    FROM ta_17_adeudos_div a
    LEFT JOIN ta_17_conv_pagos b
      ON b.id_conv_resto = a.id_conv_resto AND b.pago_parcial = a.pago_parcial
    WHERE a.id_conv_resto = p_id_conv_resto;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_get_pago_parcialidad
-- Tipo: Catalog
-- Descripción: Obtiene el registro de pago de una parcialidad específica de un convenio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_pago_parcialidad(p_id_conv_resto INTEGER, p_parcial INTEGER)
RETURNS TABLE (
    id_conv_resto INTEGER,
    pago_parcial SMALLINT,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago CHAR(2),
    operacion_pago INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_conv_resto, pago_parcial, fecha_pago, oficina_pago, caja_pago, operacion_pago
    FROM ta_17_conv_pagos
    WHERE id_conv_resto = p_id_conv_resto AND pago_parcial = p_parcial;
END;
$$ LANGUAGE plpgsql;

-- ============================================

