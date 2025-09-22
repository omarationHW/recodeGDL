-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: REPDESCIMPTO (EXACTO del archivo original)
-- Archivo: 67_SP_RECAUDADORA_REPDESCIMPTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_rep_desc_impto_aplicados
-- Tipo: Report
-- Descripción: Obtiene los descuentos de impuesto predial aplicados, filtrando por fechas, recaudadora y tipo de descuento.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rep_desc_impto_aplicados(
    p_tipo_fecha INTEGER DEFAULT 0, -- 0: todos, 1: alta, 2: baja
    p_fecha1 DATE DEFAULT NULL,
    p_fecha2 DATE DEFAULT NULL,
    p_recaudadora INTEGER DEFAULT NULL,
    p_tipo_descuento INTEGER DEFAULT NULL
) RETURNS TABLE(
    cvecuenta INTEGER,
    cvedescuento INTEGER,
    bimini SMALLINT,
    bimfin SMALLINT,
    fecalta DATE,
    usualta TEXT,
    fecbaja DATE,
    usubaja TEXT,
    propie TEXT,
    solicitante TEXT,
    observaciones TEXT,
    recaud INTEGER,
    foliodesc INTEGER,
    status TEXT,
    identificacion TEXT,
    fecnac DATE,
    institucion TEXT,
    recaud_1 INTEGER,
    urbrus TEXT,
    cuenta INTEGER,
    descripcion TEXT,
    axodescto SMALLINT,
    adeudo NUMERIC,
    vigen TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.cvecuenta, d.cvedescuento, bimini, bimfin, fecalta, 
        (SELECT nombres FROM usuarios WHERE usuario=captalta) AS usualta,
        fecbaja, (SELECT nombres FROM usuarios WHERE usuario=captbaja) AS usubaja,
        propie, solicitante, observaciones, d.recaud, foliodesc, status, identificacion, fecnac, i.institucion,
        c.recaud AS recaud_1, c.urbrus, c.cuenta, e.descripcion, e.axodescto,
        COALESCE((SELECT SUM(impfac-impvir-imppag) FROM detsaldos WHERE cvecuenta= d.cvecuenta AND cvedescuento=d.cvedescuento),0) AS adeudo,
        CASE WHEN d.fecbaja IS NOT NULL THEN 'C' WHEN (SELECT COALESCE(SUM(impfac-impvir-imppag),0) FROM detsaldos WHERE cvecuenta= d.cvecuenta AND cvedescuento=d.cvedescuento) = 0 THEN 'P' ELSE 'A' END AS vigen
    FROM descpred d
    JOIN convcta c ON d.cvecuenta=c.cvecuenta
    JOIN c_descpred e ON d.cvedescuento=e.cvedescuento
    LEFT JOIN c_instituciones i ON d.institucion=i.cveinst
    WHERE 1=1
    AND (
        p_tipo_fecha = 0 OR
        (p_tipo_fecha = 1 AND d.fecalta BETWEEN p_fecha1 AND p_fecha2 AND d.fecbaja IS NULL) OR
        (p_tipo_fecha = 2 AND d.fecbaja BETWEEN p_fecha1 AND p_fecha2)
    )
    AND (p_recaudadora IS NULL OR d.recaud = p_recaudadora)
    AND (p_tipo_descuento IS NULL OR d.cvedescuento = p_tipo_descuento);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: REPDESCIMPTO (EXACTO del archivo original)
-- Archivo: 67_SP_RECAUDADORA_REPDESCIMPTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

