-- Stored Procedure: sp_rpt_altas_conv_div
-- Tipo: Report
-- Descripción: Reporte de altas de convenios diversos por recaudadora y rango de fechas.
-- Generado para formulario: RptAltasConvDiv
-- Fecha: 2025-08-27 15:30:14

-- PostgreSQL stored procedure for Altas de Convenios Diversos
CREATE OR REPLACE FUNCTION sp_rpt_altas_conv_div(
    p_rec VARCHAR(4),
    p_fecha1 DATE,
    p_fecha2 DATE
)
RETURNS TABLE (
    id_conv_diver INTEGER,
    tipo SMALLINT,
    subtipo SMALLINT,
    letras_exp VARCHAR(4),
    numero_exp INTEGER,
    axo_exp SMALLINT,
    nombre VARCHAR(50),
    calle VARCHAR(50),
    num_exterior SMALLINT,
    num_interior SMALLINT,
    inciso VARCHAR(10),
    cantidad_total NUMERIC(18,2),
    desc_subtipo VARCHAR(50),
    fecha_alta DATE,
    vigencia CHAR(1),
    expediente TEXT,
    domicilio TEXT,
    estado TEXT,
    descripcion VARCHAR(50),
    nomtipo TEXT,
    nomsubtipo TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_conv_diver,
        a.tipo,
        a.subtipo,
        a.letras_exp,
        a.numero_exp,
        a.axo_exp,
        b.nombre,
        b.calle,
        b.num_exterior,
        b.num_interior,
        b.inciso,
        b.cantidad_total,
        d.desc_subtipo,
        DATE(a.fecha_actual) AS fecha_alta,
        a.vigencia,
        -- Calculated fields:
        (a.letras_exp || '/' || a.numero_exp::text || '/' || a.axo_exp::text) AS expediente,
        (b.calle || ' ' || COALESCE(b.num_exterior::text,'') || ' ' || COALESCE(b.num_interior::text,'') || ' ' || COALESCE(b.inciso,'')) AS domicilio,
        CASE a.vigencia WHEN 'A' THEN 'VIGENTE' WHEN 'B' THEN 'BAJA' WHEN 'P' THEN 'PAGADO' ELSE '' END AS estado,
        e.descripcion,
        (a.tipo::text || ' - ' || e.descripcion) AS nomtipo,
        (a.subtipo::text || ' - ' || d.desc_subtipo) AS nomsubtipo
    FROM ta_17_conv_diverso a
    JOIN ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_diver = b.id_conv_diver
    JOIN ta_17_subtipo_conv d ON a.tipo = d.tipo AND a.subtipo = d.subtipo
    JOIN ta_17_tipos e ON a.tipo = e.tipo
    WHERE a.letras_exp = p_rec
      AND DATE(a.fecha_actual) BETWEEN p_fecha1 AND p_fecha2
    ORDER BY a.tipo, a.subtipo, a.letras_exp, a.numero_exp, a.axo_exp;
END;
$$ LANGUAGE plpgsql;
