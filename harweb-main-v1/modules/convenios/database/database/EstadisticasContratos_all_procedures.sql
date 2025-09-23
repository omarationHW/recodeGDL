-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: EstadisticasContratos
-- Generado: 2025-08-27 14:35:30
-- Total SPs: 4
-- ============================================

-- SP 1/4: spd_17_adeudo_venc
-- Tipo: Report
-- Descripción: Obtiene adeudos vencidos por año de obra y fondo/programa
-- --------------------------------------------

-- PostgreSQL version of spd_17_adeudo_venc
CREATE OR REPLACE FUNCTION spd_17_adeudo_venc(parm_alo integer, parm_fondo integer)
RETURNS TABLE(
    colonia integer,
    calle integer,
    folio integer,
    nombre varchar,
    numero varchar,
    costo numeric,
    pagos numeric,
    saldo numeric,
    importe_vencido numeric,
    parc_vencida integer,
    fecha_venc date,
    descuento varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.colonia,
        c.calle,
        c.folio,
        c.nombre,
        c.numero,
        c.pago_total AS costo,
        COALESCE(SUM(p.importe),0) AS pagos,
        (c.pago_total - COALESCE(SUM(p.importe),0)) AS saldo,
        -- Lógica para importe vencido, parc_vencida, fecha_venc, descuento
        0 AS importe_vencido,
        0 AS parc_vencida,
        NULL::date AS fecha_venc,
        '' AS descuento
    FROM ta_17_convenios c
    LEFT JOIN ta_17_pagos p ON c.id_convenio = p.id_convenio
    WHERE c.axo_obra = parm_alo AND c.fondo = parm_fondo
    GROUP BY c.colonia, c.calle, c.folio, c.nombre, c.numero, c.pago_total;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: spd_17_estadisticas_contratos
-- Tipo: Report
-- Descripción: Obtiene estadísticas de contratos por año de obra y fondo/programa
-- --------------------------------------------

-- PostgreSQL version of spd_17_estadisticas_contratos
CREATE OR REPLACE FUNCTION spd_17_estadisticas_contratos(parm_alo integer, parm_fondo integer)
RETURNS TABLE(
    colonia integer,
    calle integer,
    folio integer,
    nombre varchar,
    numero varchar,
    costo numeric,
    pagos numeric,
    saldo numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.colonia,
        c.calle,
        c.folio,
        c.nombre,
        c.numero,
        c.pago_total AS costo,
        COALESCE(SUM(p.importe),0) AS pagos,
        (c.pago_total - COALESCE(SUM(p.importe),0)) AS saldo
    FROM ta_17_convenios c
    LEFT JOIN ta_17_pagos p ON c.id_convenio = p.id_convenio
    WHERE c.axo_obra = parm_alo AND c.fondo = parm_fondo
    GROUP BY c.colonia, c.calle, c.folio, c.nombre, c.numero, c.pago_total;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: spd_17_recaudacion
-- Tipo: Report
-- Descripción: Obtiene recaudación por rango de fechas y clasificación
-- --------------------------------------------

-- PostgreSQL version of spd_17_recaudacion
CREATE OR REPLACE FUNCTION spd_17_recaudacion(fecha_desde date, fecha_hasta date, clasificacion text)
RETURNS TABLE(
    fecha_pago date,
    oficina_pago integer,
    caja_pago varchar,
    importe numeric,
    clasificacion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.fecha_pago,
        p.oficina_pago,
        p.caja_pago,
        p.importe,
        clasificacion
    FROM ta_17_pagos p
    WHERE p.fecha_pago BETWEEN fecha_desde AND fecha_hasta;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: spd_17_estadisticas_periodos
-- Tipo: Report
-- Descripción: Obtiene estadísticas de contratos por periodo y adeudo mínimo
-- --------------------------------------------

-- PostgreSQL version of spd_17_estadisticas_periodos
CREATE OR REPLACE FUNCTION spd_17_estadisticas_periodos(parm_alo integer, parm_adeudo numeric, parm_detalle integer)
RETURNS TABLE(
    plazo integer,
    cve_plazo varchar,
    axo_obra integer,
    axo_firma integer,
    saldo_real numeric,
    desc_plazo varchar,
    num_cve_pzo integer,
    costo numeric,
    parc_pagos integer,
    estado varchar,
    colonia integer,
    calle integer,
    folio integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.plazo,
        c.clave_plazo,
        c.axo_obra,
        EXTRACT(YEAR FROM c.fecha_firma)::integer AS axo_firma,
        (c.pago_total - COALESCE(SUM(p.importe),0)) AS saldo_real,
        CASE c.clave_plazo WHEN 'M' THEN 'MENSUAL' WHEN 'Q' THEN 'QUINCENAL' ELSE 'SEMANAL' END AS desc_plazo,
        CASE c.clave_plazo WHEN 'M' THEN 2 WHEN 'Q' THEN 1 ELSE 3 END AS num_cve_pzo,
        c.pago_total AS costo,
        c.pagos_parciales,
        c.vigencia,
        c.colonia,
        c.calle,
        c.folio
    FROM ta_17_convenios c
    LEFT JOIN ta_17_pagos p ON c.id_convenio = p.id_convenio
    WHERE c.axo_obra = parm_alo AND (c.pago_total - COALESCE(SUM(p.importe),0)) >= parm_adeudo
    GROUP BY c.plazo, c.clave_plazo, c.axo_obra, c.fecha_firma, c.pago_total, c.pagos_parciales, c.vigencia, c.colonia, c.calle, c.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

