-- Stored Procedure: sp_afecta_pagadmin_listar
-- Tipo: Report
-- Descripción: Lista los pagos de convenios diversos para una fecha dada
-- Generado para formulario: AfectaPagADMIN
-- Fecha: 2025-08-27 13:39:58

CREATE OR REPLACE FUNCTION sp_afecta_pagadmin_listar(p_fecha DATE)
RETURNS TABLE (
    id_convenio INT,
    parcialidad INT,
    total_parc INT,
    imp_parcialidad NUMERIC,
    rec_conveniado NUMERIC,
    rec_parcialidad NUMERIC,
    intereses NUMERIC,
    id_recibo INT,
    cvepago INT,
    fecha DATE,
    reca INT,
    caja VARCHAR,
    operacion INT,
    estado VARCHAR,
    cveconcepto INT,
    tipo SMALLINT,
    subtipo SMALLINT,
    id_referencia INT,
    urbrus VARCHAR,
    modulo SMALLINT,
    usuario VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_convenio, a.parcialidad, a.total_parc, a.imp_parcialidad, a.rec_conveniado, a.rec_parcialidad, a.intereses, a.id_recibo, a.cvepago, a.fecha, a.reca, a.caja, a.operacion, a.estado, a.cveconcepto, c.tipo, c.subtipo, d.id_referencia, SUBSTRING(d.referencia,3,1) AS urbrus, d.modulo, a.usuario
    FROM pagos_admin a
    JOIN ta_17_conv_d_resto b ON b.id_conv_resto = a.id_convenio
    JOIN ta_17_conv_diverso c ON c.id_conv_diver = b.id_conv_diver AND c.tipo = b.tipo
    JOIN ta_17_referencia d ON d.id_conv_resto = b.id_conv_resto
    WHERE a.cveconcepto = 18 AND a.fecha = p_fecha
    ORDER BY a.fecha, a.reca, a.caja, a.operacion;
END;
$$ LANGUAGE plpgsql;