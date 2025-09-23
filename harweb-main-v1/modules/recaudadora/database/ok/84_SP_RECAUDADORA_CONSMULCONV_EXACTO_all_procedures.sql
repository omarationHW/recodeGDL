-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSMULCONV (EXACTO del archivo original)
-- Archivo: 84_SP_RECAUDADORA_CONSMULCONV_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_get_convenios_by_multa
-- Tipo: Report
-- Descripción: Obtiene los convenios asociados a una multa por id_multa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_convenios_by_multa(p_id_multa INTEGER)
RETURNS TABLE(
    id_conv_diver INTEGER,
    letras_exp VARCHAR,
    axo_exp INTEGER,
    numero_exp INTEGER,
    referencia VARCHAR,
    axo_desde INTEGER,
    bim_desde INTEGER,
    axo_hasta INTEGER,
    bim_hasta INTEGER,
    impuesto NUMERIC,
    recargos NUMERIC,
    gastos NUMERIC,
    multa NUMERIC,
    total NUMERIC,
    nombre VARCHAR,
    fecha_inicio DATE,
    fecha_venc DATE,
    vigencia VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id_conv_diver,
        c.letras_exp,
        c.axo_exp,
        c.numero_exp,
        c.referencia,
        c.axo_desde,
        c.bim_desde,
        c.axo_hasta,
        c.bim_hasta,
        c.impuesto,
        c.recargos,
        c.gastos,
        c.multa,
        c.total,
        c.nombre,
        c.fecha_inicio,
        c.fecha_venc,
        c.vigencia
    FROM public c
    WHERE c.id_multa = p_id_multa;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSMULCONV (EXACTO del archivo original)
-- Archivo: 84_SP_RECAUDADORA_CONSMULCONV_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_get_convenios_by_range
-- Tipo: Report
-- Descripción: Obtiene los convenios por rango de fechas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_convenios_by_range(p_fecha_inicio DATE, p_fecha_fin DATE)
RETURNS TABLE(
    id_conv_diver INTEGER,
    letras_exp VARCHAR,
    axo_exp INTEGER,
    numero_exp INTEGER,
    referencia VARCHAR,
    axo_desde INTEGER,
    bim_desde INTEGER,
    axo_hasta INTEGER,
    bim_hasta INTEGER,
    impuesto NUMERIC,
    recargos NUMERIC,
    gastos NUMERIC,
    multa NUMERIC,
    total NUMERIC,
    nombre VARCHAR,
    fecha_inicio DATE,
    fecha_venc DATE,
    vigencia VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id_conv_diver,
        c.letras_exp,
        c.axo_exp,
        c.numero_exp,
        c.referencia,
        c.axo_desde,
        c.bim_desde,
        c.axo_hasta,
        c.bim_hasta,
        c.impuesto,
        c.recargos,
        c.gastos,
        c.multa,
        c.total,
        c.nombre,
        c.fecha_inicio,
        c.fecha_venc,
        c.vigencia
    FROM public c
    WHERE c.fecha_inicio >= p_fecha_inicio
      AND c.fecha_venc <= p_fecha_fin;
END;
$$ LANGUAGE plpgsql;

-- ============================================

