-- Stored Procedure: spd_17_parcvencida
-- Tipo: Report
-- Descripción: Obtiene la lista de convenios con parcialidades vencidas, incluyendo adeudo, intereses, recargos y totales.
-- Generado para formulario: ParcialidadesVencidas
-- Fecha: 2025-08-27 15:07:59

-- PostgreSQL version of spd_17_parcvencida
CREATE OR REPLACE FUNCTION spd_17_parcvencida()
RETURNS TABLE (
    convenio VARCHAR(15),
    nombre VARCHAR(60),
    domicilio VARCHAR(60),
    subtipo VARCHAR(30),
    fechaconv DATE,
    totalconv NUMERIC(18,2),
    periodos VARCHAR(100),
    parcconv INTEGER,
    registro VARCHAR(30),
    parcvenc VARCHAR(10),
    adeudo NUMERIC(18,2),
    intereses NUMERIC(18,2),
    recargos NUMERIC(18,2),
    total NUMERIC(18,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        (c.letras_exp || '-' || c.numero_exp::text || '-' || c.axo_exp::text) AS convenio,
        r.nombre,
        (r.calle || ' ' || COALESCE(r.num_exterior::text, '') || ' ' || COALESCE(r.num_interior::text, '') || ' ' || COALESCE(r.inciso, '')) AS domicilio,
        st.desc_subtipo AS subtipo,
        r.fecha_inicio AS fechaconv,
        r.cantidad_total AS totalconv,
        -- periodos: ejemplo '01/2022 - 12/2022'
        (LPAD(r.mes_desde::text,2,'0') || '/' || r.axo_desde::text || ' - ' || LPAD(r.mes_hasta::text,2,'0') || '/' || r.axo_hasta::text) AS periodos,
        r.total_pagos AS parcconv,
        r.referencia AS registro,
        -- parc vencidas: contar cuántas parcialidades están vencidas
        (SELECT COUNT(*) FROM ta_17_adeudos_div ad WHERE ad.id_conv_resto = r.id_conv_resto AND ad.fecha_venc < CURRENT_DATE AND ad.clave_pago IS DISTINCT FROM 'P')::text AS parcvenc,
        -- adeudo: suma de importes vencidos no pagados
        COALESCE((SELECT SUM(ad.importe) FROM ta_17_adeudos_div ad WHERE ad.id_conv_resto = r.id_conv_resto AND ad.fecha_venc < CURRENT_DATE AND ad.clave_pago IS DISTINCT FROM 'P'),0) AS adeudo,
        -- intereses: suma de intereses vencidos no pagados
        COALESCE((SELECT SUM(ad.interes) FROM ta_17_adeudos_div ad WHERE ad.id_conv_resto = r.id_conv_resto AND ad.fecha_venc < CURRENT_DATE AND ad.clave_pago IS DISTINCT FROM 'P'),0) AS intereses,
        -- recargos: suma de recargos vencidos no pagados
        COALESCE((SELECT SUM(ad.recargo) FROM ta_17_adeudos_div ad WHERE ad.id_conv_resto = r.id_conv_resto AND ad.fecha_venc < CURRENT_DATE AND ad.clave_pago IS DISTINCT FROM 'P'),0) AS recargos,
        -- total: suma de adeudo + intereses + recargos
        (
            COALESCE((SELECT SUM(ad.importe) FROM ta_17_adeudos_div ad WHERE ad.id_conv_resto = r.id_conv_resto AND ad.fecha_venc < CURRENT_DATE AND ad.clave_pago IS DISTINCT FROM 'P'),0) +
            COALESCE((SELECT SUM(ad.interes) FROM ta_17_adeudos_div ad WHERE ad.id_conv_resto = r.id_conv_resto AND ad.fecha_venc < CURRENT_DATE AND ad.clave_pago IS DISTINCT FROM 'P'),0) +
            COALESCE((SELECT SUM(ad.recargo) FROM ta_17_adeudos_div ad WHERE ad.id_conv_resto = r.id_conv_resto AND ad.fecha_venc < CURRENT_DATE AND ad.clave_pago IS DISTINCT FROM 'P'),0)
        ) AS total
    FROM ta_17_conv_diverso c
    JOIN ta_17_conv_d_resto r ON c.id_conv_diver = r.id_conv_diver
    LEFT JOIN ta_17_subtipo_conv st ON c.tipo = st.tipo AND c.subtipo = st.subtipo
    WHERE r.vigencia = 'A' -- solo convenios vigentes
      AND EXISTS (
        SELECT 1 FROM ta_17_adeudos_div ad WHERE ad.id_conv_resto = r.id_conv_resto AND ad.fecha_venc < CURRENT_DATE AND ad.clave_pago IS DISTINCT FROM 'P'
      )
    ORDER BY r.fecha_inicio DESC;
END;
$$ LANGUAGE plpgsql;
