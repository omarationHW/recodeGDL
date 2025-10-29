-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SQRP_PUBLICOS (EXACTO del archivo original)
-- Archivo: 51_SP_ESTACIONAMIENTOS_SQRP_PUBLICOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sqrp_publicos_report
-- Tipo: Report
-- Descripción: Genera el reporte de estacionamientos públicos con clasificaciones y totales, según el orden solicitado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sqrp_publicos_report(order_by text)
RETURNS TABLE (
    control integer,
    cve_sector varchar,
    cve_categ varchar,
    cve_numero integer,
    nombre varchar,
    telefono varchar,
    calle varchar,
    num varchar,
    cupo integer,
    fecha_alta date,
    fecha_inic date,
    fecha_venci date,
    delas integer,
    alas integer,
    delas1 integer,
    alas1 integer,
    frec_lunes varchar,
    frec_martes varchar,
    frec_miercoles varchar,
    frec_jueves varchar,
    frec_viernes varchar,
    frec_sabado varchar,
    frec_domingo varchar,
    pol_num varchar,
    pol_fec_ven date,
    numlic varchar,
    zona varchar,
    subzona smallint,
    estatus varchar,
    clave smallint,
    j1 integer, j2 integer, j3 integer, j4 integer, jt integer, jm integer, ja integer,
    jc1 integer, jc2 integer, jc3 integer, jc4 integer, jct integer, jcm integer, jca integer,
    h1 integer, h2 integer, h3 integer, h4 integer, ht integer, hm integer, ha integer,
    hc1 integer, hc2 integer, hc3 integer, hc4 integer, hct integer, hcm integer, hca integer,
    l1 integer, l2 integer, l3 integer, l4 integer, lt integer, lm integer, la integer,
    lc1 integer, lc2 integer, lc3 integer, lc4 integer, lct integer, lcm integer, lca integer,
    r1 integer, r2 integer, r3 integer, r4 integer, rt integer, rm integer, ra integer,
    rc1 integer, rc2 integer, rc3 integer, rc4 integer, rct integer, rcm integer, rca integer
) AS $$
DECLARE
    sql text;
BEGIN
    sql := '
    SELECT a.*, 
        CASE WHEN (a.cve_categ = ''1'' AND a.cve_sector = ''J'') THEN 1 ELSE 0 END AS j1,
        CASE WHEN (a.cve_categ = ''2'' AND a.cve_sector = ''J'') THEN 1 ELSE 0 END AS j2,
        CASE WHEN (a.cve_categ = ''3'' AND a.cve_sector = ''J'') THEN 1 ELSE 0 END AS j3,
        CASE WHEN (a.cve_categ = ''4'' AND a.cve_sector = ''J'') THEN 1 ELSE 0 END AS j4,
        CASE WHEN (a.cve_categ = ''T'' AND a.cve_sector = ''J'') THEN 1 ELSE 0 END AS jt,
        CASE WHEN (a.cve_categ = ''M'' AND a.cve_sector = ''J'') THEN 1 ELSE 0 END AS jm,
        CASE WHEN (a.cve_categ = ''A'' AND a.cve_sector = ''J'') THEN 1 ELSE 0 END AS ja,
        CASE WHEN (a.cve_categ = ''1'' AND a.cve_sector = ''J'') THEN cupo ELSE 0 END AS jc1,
        CASE WHEN (a.cve_categ = ''2'' AND a.cve_sector = ''J'') THEN cupo ELSE 0 END AS jc2,
        CASE WHEN (a.cve_categ = ''3'' AND a.cve_sector = ''J'') THEN cupo ELSE 0 END AS jc3,
        CASE WHEN (a.cve_categ = ''4'' AND a.cve_sector = ''J'') THEN cupo ELSE 0 END AS jc4,
        CASE WHEN (a.cve_categ = ''T'' AND a.cve_sector = ''J'') THEN cupo ELSE 0 END AS jct,
        CASE WHEN (a.cve_categ = ''M'' AND a.cve_sector = ''J'') THEN cupo ELSE 0 END AS jcm,
        CASE WHEN (a.cve_categ = ''A'' AND a.cve_sector = ''J'') THEN cupo ELSE 0 END AS jca,
        CASE WHEN (a.cve_categ = ''1'' AND a.cve_sector = ''H'') THEN 1 ELSE 0 END AS h1,
        CASE WHEN (a.cve_categ = ''2'' AND a.cve_sector = ''H'') THEN 1 ELSE 0 END AS h2,
        CASE WHEN (a.cve_categ = ''3'' AND a.cve_sector = ''H'') THEN 1 ELSE 0 END AS h3,
        CASE WHEN (a.cve_categ = ''4'' AND a.cve_sector = ''H'') THEN 1 ELSE 0 END AS h4,
        CASE WHEN (a.cve_categ = ''T'' AND a.cve_sector = ''H'') THEN 1 ELSE 0 END AS ht,
        CASE WHEN (a.cve_categ = ''M'' AND a.cve_sector = ''H'') THEN 1 ELSE 0 END AS hm,
        CASE WHEN (a.cve_categ = ''A'' AND a.cve_sector = ''H'') THEN 1 ELSE 0 END AS ha,
        CASE WHEN (a.cve_categ = ''1'' AND a.cve_sector = ''H'') THEN cupo ELSE 0 END AS hc1,
        CASE WHEN (a.cve_categ = ''2'' AND a.cve_sector = ''H'') THEN cupo ELSE 0 END AS hc2,
        CASE WHEN (a.cve_categ = ''3'' AND a.cve_sector = ''H'') THEN cupo ELSE 0 END AS hc3,
        CASE WHEN (a.cve_categ = ''4'' AND a.cve_sector = ''H'') THEN cupo ELSE 0 END AS hc4,
        CASE WHEN (a.cve_categ = ''T'' AND a.cve_sector = ''H'') THEN cupo ELSE 0 END AS hct,
        CASE WHEN (a.cve_categ = ''M'' AND a.cve_sector = ''H'') THEN cupo ELSE 0 END AS hcm,
        CASE WHEN (a.cve_categ = ''A'' AND a.cve_sector = ''H'') THEN cupo ELSE 0 END AS hca,
        CASE WHEN (a.cve_categ = ''1'' AND a.cve_sector = ''L'') THEN 1 ELSE 0 END AS l1,
        CASE WHEN (a.cve_categ = ''2'' AND a.cve_sector = ''L'') THEN 1 ELSE 0 END AS l2,
        CASE WHEN (a.cve_categ = ''3'' AND a.cve_sector = ''L'') THEN 1 ELSE 0 END AS l3,
        CASE WHEN (a.cve_categ = ''4'' AND a.cve_sector = ''L'') THEN 1 ELSE 0 END AS l4,
        CASE WHEN (a.cve_categ = ''T'' AND a.cve_sector = ''L'') THEN 1 ELSE 0 END AS lt,
        CASE WHEN (a.cve_categ = ''M'' AND a.cve_sector = ''L'') THEN 1 ELSE 0 END AS lm,
        CASE WHEN (a.cve_categ = ''A'' AND a.cve_sector = ''L'') THEN 1 ELSE 0 END AS la,
        CASE WHEN (a.cve_categ = ''1'' AND a.cve_sector = ''L'') THEN cupo ELSE 0 END AS lc1,
        CASE WHEN (a.cve_categ = ''2'' AND a.cve_sector = ''L'') THEN cupo ELSE 0 END AS lc2,
        CASE WHEN (a.cve_categ = ''3'' AND a.cve_sector = ''L'') THEN cupo ELSE 0 END AS lc3,
        CASE WHEN (a.cve_categ = ''4'' AND a.cve_sector = ''L'') THEN cupo ELSE 0 END AS lc4,
        CASE WHEN (a.cve_categ = ''T'' AND a.cve_sector = ''L'') THEN cupo ELSE 0 END AS lct,
        CASE WHEN (a.cve_categ = ''M'' AND a.cve_sector = ''L'') THEN cupo ELSE 0 END AS lcm,
        CASE WHEN (a.cve_categ = ''A'' AND a.cve_sector = ''L'') THEN cupo ELSE 0 END AS lca,
        CASE WHEN (a.cve_categ = ''1'' AND a.cve_sector = ''R'') THEN 1 ELSE 0 END AS r1,
        CASE WHEN (a.cve_categ = ''2'' AND a.cve_sector = ''R'') THEN 1 ELSE 0 END AS r2,
        CASE WHEN (a.cve_categ = ''3'' AND a.cve_sector = ''R'') THEN 1 ELSE 0 END AS r3,
        CASE WHEN (a.cve_categ = ''4'' AND a.cve_sector = ''R'') THEN 1 ELSE 0 END AS r4,
        CASE WHEN (a.cve_categ = ''T'' AND a.cve_sector = ''R'') THEN 1 ELSE 0 END AS rt,
        CASE WHEN (a.cve_categ = ''M'' AND a.cve_sector = ''R'') THEN 1 ELSE 0 END AS rm,
        CASE WHEN (a.cve_categ = ''A'' AND a.cve_sector = ''R'') THEN 1 ELSE 0 END AS ra,
        CASE WHEN (a.cve_categ = ''1'' AND a.cve_sector = ''R'') THEN cupo ELSE 0 END AS rc1,
        CASE WHEN (a.cve_categ = ''2'' AND a.cve_sector = ''R'') THEN cupo ELSE 0 END AS rc2,
        CASE WHEN (a.cve_categ = ''3'' AND a.cve_sector = ''R'') THEN cupo ELSE 0 END AS rc3,
        CASE WHEN (a.cve_categ = ''4'' AND a.cve_sector = ''R'') THEN cupo ELSE 0 END AS rc4,
        CASE WHEN (a.cve_categ = ''T'' AND a.cve_sector = ''R'') THEN cupo ELSE 0 END AS rct,
        CASE WHEN (a.cve_categ = ''M'' AND a.cve_sector = ''R'') THEN cupo ELSE 0 END AS rcm,
        CASE WHEN (a.cve_categ = ''A'' AND a.cve_sector = ''R'') THEN cupo ELSE 0 END AS rca
    FROM public.ta_15_publicos a
    WHERE a.estatus <> ''B''
    ORDER BY ' || order_by;
    RETURN QUERY EXECUTE sql;
END;
$$ LANGUAGE plpgsql;

-- ============================================

