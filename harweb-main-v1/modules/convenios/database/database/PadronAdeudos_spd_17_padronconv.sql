-- Stored Procedure: spd_17_padronconv
-- Tipo: Report
-- Descripción: Obtiene el padrón de convenios vigentes de la recaudadora seleccionada, incluyendo totales de pagos, adeudos y vigencia.
-- Generado para formulario: PadronAdeudos
-- Fecha: 2025-08-27 15:01:50

-- PostgreSQL stored procedure for Padron de Adeudos
CREATE OR REPLACE FUNCTION spd_17_padronconv(prec integer)
RETURNS TABLE (
    tipo varchar(30),
    subtipo varchar(30),
    convenio varchar(50),
    nombre varchar(60),
    vigencia varchar(10),
    fecha_otorg date,
    plazo smallint,
    tipo_plazo varchar(20),
    cantidad numeric(18,2),
    primer_pago date,
    importe_primerpago numeric(18,2),
    pagos_realizados smallint,
    importe_pagado numeric(18,2),
    parc_adeudo smallint,
    importe_adeudo numeric(18,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.descripcion AS tipo,
        st.desc_subtipo AS subtipo,
        (cd.letras_exp || '-' || cd.numero_exp::text || '-' || cd.axo_exp::text) AS convenio,
        cd.nombre,
        CASE WHEN cr.vigencia = 'A' THEN 'VIGENTE' WHEN cr.vigencia = 'B' THEN 'BAJA' ELSE 'PAGADO' END AS vigencia,
        cr.fecha_inicio AS fecha_otorg,
        cr.total_pagos AS plazo,
        CASE cr.tipo_pago WHEN 'M' THEN 'MENSUAL' WHEN 'Q' THEN 'QUINCENAL' WHEN 'S' THEN 'SEMANAL' ELSE cr.tipo_pago END AS tipo_plazo,
        cr.cantidad_total AS cantidad,
        (SELECT MIN(fecha_pago) FROM ta_17_conv_pagos WHERE id_conv_resto = cr.id_conv_resto) AS primer_pago,
        (SELECT importe_pago FROM ta_17_conv_pagos WHERE id_conv_resto = cr.id_conv_resto ORDER BY fecha_pago ASC LIMIT 1) AS importe_primerpago,
        (SELECT COUNT(*) FROM ta_17_conv_pagos WHERE id_conv_resto = cr.id_conv_resto) AS pagos_realizados,
        (SELECT COALESCE(SUM(importe_pago),0) FROM ta_17_conv_pagos WHERE id_conv_resto = cr.id_conv_resto) AS importe_pagado,
        GREATEST(0, cr.total_pagos - (SELECT COUNT(*) FROM ta_17_conv_pagos WHERE id_conv_resto = cr.id_conv_resto)) AS parc_adeudo,
        GREATEST(0, cr.cantidad_total - (SELECT COALESCE(SUM(importe_pago),0) FROM ta_17_conv_pagos WHERE id_conv_resto = cr.id_conv_resto)) AS importe_adeudo
    FROM ta_17_conv_diverso cd
    JOIN ta_17_conv_d_resto cr ON cd.tipo = cr.tipo AND cd.id_conv_diver = cr.id_conv_diver
    JOIN ta_17_tipos t ON cd.tipo = t.tipo
    JOIN ta_17_subtipo_conv st ON cd.tipo = st.tipo AND cd.subtipo = st.subtipo
    WHERE cd.letras_exp = (
        SELECT CASE prec
            WHEN 1 THEN 'ZC1'
            WHEN 2 THEN 'ZO2'
            WHEN 3 THEN 'ZO3'
            WHEN 4 THEN 'ZM4'
            WHEN 5 THEN 'ZC5'
            ELSE '' END
    )
    AND cr.vigencia = 'A'
    ORDER BY tipo, subtipo, convenio;
END;
$$ LANGUAGE plpgsql;