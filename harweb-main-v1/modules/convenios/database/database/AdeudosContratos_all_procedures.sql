-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: AdeudosContratos
-- Generado: 2025-08-27 13:38:13
-- Total SPs: 6
-- ============================================

-- SP 1/6: sp_adeudos_contratos_listado_todos
-- Tipo: Report
-- Descripción: Listado de todos los convenios vigentes por colonia y calle
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_contratos_listado_todos(p_colonia integer, p_calle integer)
RETURNS TABLE(
    id_convenio integer,
    colonia integer,
    calle integer,
    folio integer,
    nombre text,
    pago_total numeric,
    pagos numeric,
    desc_calle text,
    descripcion text,
    devolucion numeric,
    concepto text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total,
           COALESCE(SUM(b.importe),0) AS pagos, c.desc_calle, d.descripcion,
           (SELECT COALESCE(SUM(importe),0) FROM ta_17_devoluciones WHERE id_convenio=a.id_convenio) AS devolucion,
           CASE WHEN (a.pago_total - (COALESCE(SUM(b.importe),0) - (SELECT COALESCE(SUM(importe),0) FROM ta_17_devoluciones WHERE id_convenio=a.id_convenio))) > 0 THEN 'ADE'
                WHEN (a.pago_total - (COALESCE(SUM(b.importe),0) - (SELECT COALESCE(SUM(importe),0) FROM ta_17_devoluciones WHERE id_convenio=a.id_convenio))) = 0 THEN 'LIQ'
                ELSE 'SAF' END AS concepto
    FROM ta_17_convenios a
    LEFT JOIN ta_17_pagos b ON a.id_convenio = b.id_convenio AND b.fecha_pago >= a.fecha_firma
    JOIN ta_17_calles c ON a.colonia = c.colonia AND a.calle = c.calle
    JOIN ta_17_colonias d ON a.colonia = d.colonia
    WHERE a.colonia = p_colonia AND a.calle = p_calle AND a.vigencia = 'A'
    GROUP BY a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total, c.desc_calle, d.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/6: sp_adeudos_contratos_listado_adeudos
-- Tipo: Report
-- Descripción: Listado de contratos vigentes con adeudos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_contratos_listado_adeudos(p_colonia integer, p_calle integer)
RETURNS TABLE(
    id_convenio integer,
    colonia integer,
    calle integer,
    folio integer,
    nombre text,
    pago_total numeric,
    pagos numeric,
    desc_calle text,
    descripcion text,
    devolucion numeric,
    concepto text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total,
           COALESCE(SUM(b.importe),0) AS pagos, c.desc_calle, d.descripcion,
           (SELECT COALESCE(SUM(importe),0) FROM ta_17_devoluciones WHERE id_convenio=a.id_convenio) AS devolucion,
           'ADE' AS concepto
    FROM ta_17_convenios a
    LEFT JOIN ta_17_pagos b ON a.id_convenio = b.id_convenio AND b.fecha_pago >= a.fecha_firma
    JOIN ta_17_calles c ON a.colonia = c.colonia AND a.calle = c.calle
    JOIN ta_17_colonias d ON a.colonia = d.colonia
    WHERE a.colonia = p_colonia AND a.calle = p_calle AND a.vigencia = 'A'
    GROUP BY a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total, c.desc_calle, d.descripcion
    HAVING (a.pago_total - (COALESCE(SUM(b.importe),0) - (SELECT COALESCE(SUM(importe),0) FROM ta_17_devoluciones WHERE id_convenio=a.id_convenio))) > 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/6: sp_adeudos_contratos_listado_saldos_favor
-- Tipo: Report
-- Descripción: Listado de contratos vigentes con saldos a favor
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_contratos_listado_saldos_favor(p_colonia integer, p_calle integer)
RETURNS TABLE(
    id_convenio integer,
    colonia integer,
    calle integer,
    folio integer,
    nombre text,
    pago_total numeric,
    pagos numeric,
    desc_calle text,
    descripcion text,
    devolucion numeric,
    concepto text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total,
           COALESCE(SUM(b.importe),0) AS pagos, c.desc_calle, d.descripcion,
           (SELECT COALESCE(SUM(importe),0) FROM ta_17_devoluciones WHERE id_convenio=a.id_convenio) AS devolucion,
           'SAF' AS concepto
    FROM ta_17_convenios a
    LEFT JOIN ta_17_pagos b ON a.id_convenio = b.id_convenio AND b.fecha_pago >= a.fecha_firma
    JOIN ta_17_calles c ON a.colonia = c.colonia AND a.calle = c.calle
    JOIN ta_17_colonias d ON a.colonia = d.colonia
    WHERE a.colonia = p_colonia AND a.calle = p_calle AND a.vigencia = 'A'
    GROUP BY a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total, c.desc_calle, d.descripcion
    HAVING (a.pago_total - (COALESCE(SUM(b.importe),0) - (SELECT COALESCE(SUM(importe),0) FROM ta_17_devoluciones WHERE id_convenio=a.id_convenio))) < 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/6: sp_adeudos_contratos_listado_pagos_descuento
-- Tipo: Report
-- Descripción: Listado de contratos que pagaron con descuento
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_contratos_listado_pagos_descuento(p_colonia integer)
RETURNS TABLE(
    colonia integer,
    calle integer,
    folio integer,
    fecha_pago date,
    oficina_pago integer,
    caja_pago text,
    operacion_pago integer,
    pago_parcial integer,
    total_parciales integer,
    importe numeric,
    cve_descuento integer,
    cve_bonificacion integer,
    descripcion text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.colonia, a.calle, a.folio, b.fecha_pago, b.oficina_pago, b.caja_pago, b.operacion_pago,
           b.pago_parcial, b.total_parciales, b.importe, b.cve_descuento, b.cve_bonificacion, c.descripcion
    FROM ta_17_convenios a
    JOIN ta_17_pagos b ON a.id_convenio = b.id_convenio
    JOIN ta_17_colonias c ON a.colonia = c.colonia
    WHERE a.colonia = p_colonia AND b.cve_descuento > 0
    ORDER BY a.colonia, a.calle, a.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/6: sp_adeudos_contratos_listado_liquidados_col_calle
-- Tipo: Report
-- Descripción: Listado de contratos vigentes liquidados por colonia y calle
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_contratos_listado_liquidados_col_calle(p_colonia integer, p_calle integer)
RETURNS TABLE(
    id_convenio integer,
    colonia integer,
    calle integer,
    folio integer,
    nombre text,
    pago_total numeric,
    pagos numeric,
    desc_calle text,
    descripcion text,
    devolucion numeric,
    concepto text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total,
           COALESCE(SUM(b.importe),0) AS pagos, c.desc_calle, d.descripcion,
           (SELECT COALESCE(SUM(importe),0) FROM ta_17_devoluciones WHERE id_convenio=a.id_convenio) AS devolucion,
           'LIQ' AS concepto
    FROM ta_17_convenios a
    LEFT JOIN ta_17_pagos b ON a.id_convenio = b.id_convenio AND b.fecha_pago >= a.fecha_firma
    JOIN ta_17_calles c ON a.colonia = c.colonia AND a.calle = c.calle
    JOIN ta_17_colonias d ON a.colonia = d.colonia
    WHERE a.colonia = p_colonia AND a.calle = p_calle AND a.vigencia = 'A'
    GROUP BY a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total, c.desc_calle, d.descripcion
    HAVING (a.pago_total - (COALESCE(SUM(b.importe),0) - (SELECT COALESCE(SUM(importe),0) FROM ta_17_devoluciones WHERE id_convenio=a.id_convenio))) <= 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: sp_adeudos_contratos_listado_liquidados_col
-- Tipo: Report
-- Descripción: Listado de contratos vigentes liquidados por colonia y saldo menor o igual a importe
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_contratos_listado_liquidados_col(p_colonia integer, p_importe numeric)
RETURNS TABLE(
    id_convenio integer,
    colonia integer,
    calle integer,
    folio integer,
    nombre text,
    pago_total numeric,
    pagos numeric,
    desc_calle text,
    descripcion text,
    devolucion numeric,
    concepto text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total,
           COALESCE(SUM(b.importe),0) AS pagos, c.desc_calle, d.descripcion,
           (SELECT COALESCE(SUM(importe),0) FROM ta_17_devoluciones WHERE id_convenio=a.id_convenio) AS devolucion,
           'LIQ' AS concepto
    FROM ta_17_convenios a
    LEFT JOIN ta_17_pagos b ON a.id_convenio = b.id_convenio AND b.fecha_pago >= a.fecha_firma
    JOIN ta_17_calles c ON a.colonia = c.colonia AND a.calle = c.calle
    JOIN ta_17_colonias d ON a.colonia = d.colonia
    WHERE a.colonia = p_colonia AND a.vigencia = 'A'
    GROUP BY a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total, c.desc_calle, d.descripcion
    HAVING (a.pago_total - (COALESCE(SUM(b.importe),0) - (SELECT COALESCE(SUM(importe),0) FROM ta_17_devoluciones WHERE id_convenio=a.id_convenio))) <= p_importe;
END;
$$ LANGUAGE plpgsql;

-- ============================================

