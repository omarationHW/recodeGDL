-- Stored Procedure: sp_get_predio_by_id
-- Tipo: Catalog
-- Descripción: Obtiene los datos completos del predio/convenio por id_conv_predio
-- Generado para formulario: IndividualPredios
-- Fecha: 2025-08-27 14:45:56

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