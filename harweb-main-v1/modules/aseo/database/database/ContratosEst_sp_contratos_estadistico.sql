-- Stored Procedure: sp_contratos_estadistico
-- Tipo: Report
-- Descripción: Genera el estadístico de contratos y adeudos agrupados por tipo de aseo, vigencia, oficina, periodo, etc.
-- Generado para formulario: ContratosEst
-- Fecha: 2025-08-27 14:09:52

-- PostgreSQL stored procedure for estadístico de contratos
CREATE OR REPLACE FUNCTION sp_contratos_estadistico(
    p_vigencia VARCHAR,
    p_oficina INTEGER,
    p_tipo_aseo INTEGER,
    p_vig_adeudos VARCHAR,
    p_grupo_adeudos INTEGER,
    p_periodo_inicio VARCHAR,
    p_periodo_fin VARCHAR,
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_adeudos_visual INTEGER
)
RETURNS TABLE(
    tipo_aseo VARCHAR,
    contratos_totales INTEGER,
    contratos_vigentes INTEGER,
    contratos_cancelados INTEGER,
    adeudos_totales INTEGER,
    adeudos_vigentes INTEGER,
    adeudos_cancelados INTEGER,
    adeudos_pagados INTEGER,
    adeudos_suspendidos INTEGER
    -- ... agregar más columnas según necesidad ...
) AS $$
DECLARE
BEGIN
    -- Ejemplo de lógica, debe ajustarse a la estructura real
    RETURN QUERY
    SELECT
        ta.tipo_aseo,
        COUNT(DISTINCT c.control_contrato) AS contratos_totales,
        COUNT(DISTINCT CASE WHEN c.status_vigencia = 'V' THEN c.control_contrato END) AS contratos_vigentes,
        COUNT(DISTINCT CASE WHEN c.status_vigencia = 'C' THEN c.control_contrato END) AS contratos_cancelados,
        COUNT(a.id_adeudo) AS adeudos_totales,
        COUNT(CASE WHEN a.status_vigencia = 'V' THEN 1 END) AS adeudos_vigentes,
        COUNT(CASE WHEN a.status_vigencia = 'C' THEN 1 END) AS adeudos_cancelados,
        COUNT(CASE WHEN a.status_vigencia = 'P' THEN 1 END) AS adeudos_pagados,
        COUNT(CASE WHEN a.status_vigencia = 'S' THEN 1 END) AS adeudos_suspendidos
    FROM ta_16_contratos c
    JOIN ta_16_tipo_aseo ta ON ta.ctrol_aseo = c.ctrol_aseo
    LEFT JOIN ta_16_pagos a ON a.control_contrato = c.control_contrato
    WHERE
        (p_vigencia = 'T' OR c.status_vigencia = p_vigencia)
        AND (p_oficina = 0 OR c.id_rec = p_oficina)
        AND (p_tipo_aseo = 999 OR c.ctrol_aseo = p_tipo_aseo)
        -- Adeudos visual: 0=con adeudos, 1=sin adeudos
        AND (
            (p_adeudos_visual = 0 AND EXISTS (SELECT 1 FROM ta_16_pagos ap WHERE ap.control_contrato = c.control_contrato))
            OR (p_adeudos_visual = 1 AND NOT EXISTS (SELECT 1 FROM ta_16_pagos ap WHERE ap.control_contrato = c.control_contrato))
        )
        -- Grupo de adeudos: 0=por periodo, 1=por fecha, 2=histórico
        AND (
            (p_grupo_adeudos = 0 AND (a.aso_mes_pago::text BETWEEN p_periodo_inicio AND p_periodo_fin))
            OR (p_grupo_adeudos = 1 AND (a.fecha_hora_pago BETWEEN p_fecha_inicio AND p_fecha_fin))
            OR (p_grupo_adeudos = 2)
        )
        AND (p_vig_adeudos = 'T' OR a.status_vigencia = p_vig_adeudos)
    GROUP BY ta.tipo_aseo
    ORDER BY ta.tipo_aseo;
END;
$$ LANGUAGE plpgsql;