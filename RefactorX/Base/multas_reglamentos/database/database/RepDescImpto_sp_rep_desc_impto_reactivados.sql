-- Stored Procedure: sp_rep_desc_impto_reactivados
-- Tipo: Report
-- Descripción: Obtiene los descuentos de impuesto predial reactivados, filtrando por fechas, recaudadora y tipo de descuento.
-- Generado para formulario: RepDescImpto
-- Fecha: 2025-08-27 14:24:09

CREATE OR REPLACE FUNCTION sp_rep_desc_impto_reactivados(
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
    id_recau INTEGER,
    foliodesc INTEGER,
    status TEXT,
    identificacion TEXT,
    fecnac DATE,
    institucion TEXT,
    recaud INTEGER,
    urbrus TEXT,
    cuenta INTEGER,
    descripcion TEXT,
    axodescto SMALLINT,
    adeudo NUMERIC,
    vigen TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.cvecuenta, d.cvedescuento, bimini, bimfin, fecalta, nombres AS usualta,
        (SELECT nombres FROM usuarios WHERE usuario=capbaja) AS usubaja,
        (SELECT CASE WHEN razonsocial<>'' THEN razonsocial ELSE (TRIM(paterno)||' '|| TRIM(materno)||' '||TRIM(nombres)) END FROM uem3 WHERE cvectacat=d.cvecuenta) AS propie,
        solicitante, observaciones, s.id_recau, d.rowid AS foliodesc, status, identificacion, fecnac, i.institucion,
        c.recaud, c.urbrus, c.cuenta, e.descripcion, e.axodescto,
        COALESCE((SELECT SUM(impfac-impvir-imppag) FROM detsaldos WHERE cvecuenta= d.cvecuenta AND cvedescuento=d.cvedescuento),0) AS adeudo,
        CASE WHEN d.capbaja<>'' THEN 'C' WHEN (SELECT COALESCE(SUM(impfac-impvir-imppag),0) FROM detsaldos WHERE cvecuenta= d.cvecuenta AND cvedescuento=d.cvedescuento) = 0 THEN 'P' ELSE 'A' END AS vigen
    FROM descpred_reactiva d
    JOIN convcta c ON d.cvecuenta=c.cvecuenta
    JOIN c_descpred e ON d.cvedescuento=e.cvedescuento
    LEFT JOIN c_instituciones i ON d.institucion=i.cveinst
    JOIN usuarios u ON d.captalta=u.usuario
    JOIN deptos s ON u.cvedepto=s.cvedepto
    WHERE 1=1
    AND (
        p_tipo_fecha = 0 OR
        (p_tipo_fecha = 1 AND d.fecalta BETWEEN p_fecha1 AND p_fecha2 AND d.capbaja IS NULL) OR
        (p_tipo_fecha = 2 AND d.capbaja <> '')
    )
    AND (p_recaudadora IS NULL OR d.recaud = p_recaudadora)
    AND (p_tipo_descuento IS NULL OR d.cvedescuento = p_tipo_descuento);
END;
$$ LANGUAGE plpgsql;