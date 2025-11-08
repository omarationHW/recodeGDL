-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ReporteAnunExcelfrm
-- Generado: 2025-08-27 19:25:23
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_reporte_anuncios_excel
-- Tipo: Report
-- Descripción: Genera el reporte de anuncios con todos los filtros requeridos para el formulario ReporteAnunExcel.
-- --------------------------------------------

-- Parámetros:
-- p_vigencia INT, p_tiporep INT, p_fechacons DATE, p_fechaini DATE, p_fechafin DATE, p_adeudo INT, p_axoini INT, p_fechapagoini DATE, p_fechapagofin DATE, p_grupoanunid INT
CREATE OR REPLACE FUNCTION sp_reporte_anuncios_excel(
    p_vigencia INT,
    p_tiporep INT,
    p_fechacons DATE,
    p_fechaini DATE,
    p_fechafin DATE,
    p_adeudo INT,
    p_axoini INT,
    p_fechapagoini DATE,
    p_fechapagofin DATE,
    p_grupoanunid INT
)
RETURNS TABLE (
    anuncio INT,
    fecha_otorgamiento DATE,
    propietario TEXT,
    licencia INT,
    empresa INT,
    tipo_anuncio TEXT,
    medidas1 NUMERIC,
    medidas2 NUMERIC,
    area_anuncio NUMERIC,
    num_caras INT,
    ubicacion TEXT,
    numext_ubic TEXT,
    letraext_ubic TEXT,
    numint_ubic TEXT,
    letrain_ubic TEXT,
    colonia_ubic TEXT,
    cp TEXT,
    zona TEXT,
    subzona TEXT,
    vigente TEXT,
    bloqueado TEXT,
    fecha_baja DATE,
    folio_baja TEXT,
    especificaciones TEXT,
    adeudo NUMERIC
) AS $$
DECLARE
    sql TEXT;
BEGIN
    sql := 'SELECT a.anuncio, a.fecha_otorgamiento, ' ||
           'TRIM(COALESCE(l.primer_ap,'''') || '' '' || COALESCE(l.segundo_ap,'''') || '' '' || COALESCE(l.propietario, '''')) AS propietario, ' ||
           'l.licencia, l.empresa, c.descripcion AS tipo_anuncio, a.medidas1, a.medidas2, a.area_anuncio, a.num_caras, a.ubicacion, ' ||
           'a.numext_ubic, a.letraext_ubic, a.numint_ubic, a.letraint_ubic, a.colonia_ubic, a.cp, a.zona, a.subzona, a.vigente, a.bloqueado, a.fecha_baja, a.folio_baja, a.espubic AS especificaciones';

    -- Adeudo
    IF p_adeudo = 1 THEN
        sql := sql || ', 0 AS adeudo';
    ELSIF p_adeudo = 2 THEN
        sql := sql || ', (SELECT SUM(d.saldo) FROM detsal_lic d WHERE d.cvepago = 0 AND d.id_anuncio = a.id_anuncio AND d.id_licencia = a.id_licencia AND d.axo = ' || p_axoini || ') AS adeudo';
    ELSIF p_adeudo = 3 THEN
        sql := sql || ', d.axo AS axo, SUM(d.saldo) AS pago';
    ELSIF p_adeudo IN (4,5) THEN
        sql := sql || ', SUM(d.saldo) AS adeudo, MIN(d.axo) AS desde, MAX(d.axo) AS hasta';
    ELSIF p_adeudo = 6 THEN
        sql := sql || ', p.fecha AS fecha_pago, SUM(d.saldo) AS pago';
    END IF;

    sql := sql || ' FROM anuncios a ' ||
        'LEFT JOIN licencias l ON l.id_licencia = a.id_licencia ' ||
        'INNER JOIN c_giros c ON c.id_giro = a.id_giro ';

    -- Adeudo joins
    IF p_adeudo = 1 THEN
        sql := sql || 'INNER JOIN detsal_lic d ON d.id_anuncio = a.id_anuncio AND d.id_licencia = a.id_licencia AND (SELECT SUM(x.saldo) FROM detsal_lic x WHERE x.cvepago = 0 AND x.id_anuncio = a.id_anuncio AND x.id_licencia = a.id_licencia) IS NULL ';
    ELSIF p_adeudo = 2 THEN
        sql := sql || 'INNER JOIN detsal_lic d ON d.id_anuncio = a.id_anuncio AND d.id_licencia = a.id_licencia AND d.cvepago = 0 AND (SELECT SUM(x.saldo) FROM detsal_lic x WHERE x.cvepago = 0 AND x.id_anuncio = a.id_anuncio AND x.id_licencia = a.id_licencia) > 0 AND (SELECT MIN(x.axo) FROM detsal_lic x WHERE x.cvepago = 0 AND x.id_anuncio = a.id_anuncio AND x.id_licencia = a.id_licencia) = ' || p_axoini || ' ';
    ELSIF p_adeudo = 3 THEN
        sql := sql || 'INNER JOIN detsal_lic d ON d.id_anuncio = a.id_anuncio AND d.id_licencia = a.id_licencia AND d.cvepago > 0 AND d.axo >= ' || p_axoini || ' ';
    ELSIF p_adeudo = 4 THEN
        sql := sql || 'INNER JOIN detsal_lic d ON d.id_anuncio = a.id_anuncio AND d.id_licencia = a.id_licencia AND d.cvepago = 0 AND (SELECT MIN(x.axo) FROM detsal_lic x WHERE x.cvepago = 0 AND x.id_anuncio = a.id_anuncio AND x.id_licencia = a.id_licencia) <= ' || p_axoini || ' ';
    ELSIF p_adeudo = 5 THEN
        sql := sql || 'INNER JOIN detsal_lic d ON d.id_anuncio = a.id_anuncio AND d.id_licencia = a.id_licencia AND d.cvepago = 0 AND d.axo <= ' || p_axoini || ' AND (SELECT MIN(x.axo) FROM detsal_lic x WHERE x.cvepago = 0 AND x.id_anuncio = a.id_anuncio AND x.id_licencia = a.id_licencia) <= ' || p_axoini || ' ';
    ELSIF p_adeudo = 6 THEN
        sql := sql || 'INNER JOIN pagos p ON p.fecha BETWEEN ''' || p_fechapagoini || ''' AND ''' || p_fechapagofin || ''' AND p.cvecanc IS NULL AND cveconcepto = 8 AND p.cvecuenta = l.id_licencia INNER JOIN detsal_lic d ON d.id_anuncio = a.id_anuncio AND d.id_licencia = a.id_licencia AND d.cvepago = p.cvepago ';
    END IF;

    sql := sql || ' WHERE a.anuncio > 0 ';

    -- Vigencia
    IF p_vigencia = 1 THEN
        sql := sql || ' AND a.vigente = ''V'' ';
    ELSIF p_vigencia = 2 THEN
        sql := sql || ' AND a.vigente IN (''C'',''B'') ';
    ELSIF p_vigencia = 3 THEN
        sql := sql || ' AND a.vigente = ''A'' ';
    END IF;

    -- Tipo de reporte y fechas
    IF p_tiporep = 0 THEN
        IF p_vigencia = 2 THEN
            sql := sql || ' AND a.fecha_baja <= ''' || p_fechacons || '''';
        ELSE
            sql := sql || ' AND a.fecha_otorgamiento <= ''' || p_fechacons || '''';
        END IF;
    ELSIF p_tiporep = 1 THEN
        IF p_vigencia = 2 THEN
            sql := sql || ' AND a.fecha_baja BETWEEN ''' || p_fechaini || ''' AND ''' || p_fechafin || '''';
        ELSE
            sql := sql || ' AND a.fecha_otorgamiento BETWEEN ''' || p_fechaini || ''' AND ''' || p_fechafin || '''';
        END IF;
    END IF;

    -- Grupo de anuncios
    IF p_grupoanunid IS NOT NULL AND p_grupoanunid > 0 THEN
        sql := sql || ' AND a.anuncio IN (SELECT d.anuncio FROM anuncios_grupos g INNER JOIN anuncios_detgrupo d ON d.anuncios_grupos_id = g.id AND g.id = ' || p_grupoanunid || ') ';
    END IF;

    -- Agrupaciones
    IF p_adeudo IN (1,2) THEN
        sql := sql || ' GROUP BY a.anuncio, a.fecha_otorgamiento, l.primer_ap, l.segundo_ap, l.propietario, l.licencia, l.empresa, c.descripcion, a.medidas1, a.medidas2, a.area_anuncio, a.num_caras, a.ubicacion, a.numext_ubic, a.letraext_ubic, a.numint_ubic, a.letraint_ubic, a.colonia_ubic, a.cp, a.zona, a.subzona, a.vigente, a.bloqueado, a.fecha_baja, a.folio_baja, a.espubic';
    ELSIF p_adeudo IN (3,4,5,6) THEN
        sql := sql || ' GROUP BY a.anuncio, a.fecha_otorgamiento, l.primer_ap, l.segundo_ap, l.propietario, l.licencia, l.empresa, c.descripcion, a.medidas1, a.medidas2, a.area_anuncio, a.num_caras, a.ubicacion, a.numext_ubic, a.letraext_ubic, a.numint_ubic, a.letraint_ubic, a.colonia_ubic, a.cp, a.zona, a.subzona, a.vigente, a.bloqueado, a.fecha_baja, a.folio_baja, a.espubic, d.axo';
    END IF;

    RETURN QUERY EXECUTE sql;
END;
$$ LANGUAGE plpgsql;

-- ============================================

