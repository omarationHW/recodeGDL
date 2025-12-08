-- ============================================
-- STORED PROCEDURES IMPLEMENTADOS
-- Componente: ReporteAnunExcelfrm
-- Módulo: padron_licencias
-- Total SPs: 1
-- Fecha: 2025-11-20
-- ============================================

-- ============================================
-- SP: sp_reporte_anuncios_excel
-- Descripción: Genera reporte completo de anuncios para exportación a Excel
--              con filtros avanzados (vigencia, fechas, adeudo, grupos)
-- Tipo: Report/Query
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_reporte_anuncios_excel(
    p_vigencia INT DEFAULT NULL,              -- 1=Vigentes, 2=Cancelados/Baja, 3=Alta, NULL=Todos
    p_tiporep INT DEFAULT 0,                  -- 0=Corte fecha, 1=Rango fechas
    p_fechacons DATE DEFAULT NULL,            -- Fecha de consulta (para tiporep=0)
    p_fechaini DATE DEFAULT NULL,             -- Fecha inicial (para tiporep=1)
    p_fechafin DATE DEFAULT NULL,             -- Fecha final (para tiporep=1)
    p_adeudo INT DEFAULT NULL,                -- 1=Sin adeudo, 2=Con adeudo año, 3=Pagados desde año, 4=Adeudo desde año, 5=Adeudo hasta año, 6=Pagados en rango
    p_axoini INT DEFAULT NULL,                -- Año inicial para filtro adeudo
    p_fechapagoini DATE DEFAULT NULL,         -- Fecha pago inicial (para adeudo=6)
    p_fechapagofin DATE DEFAULT NULL,         -- Fecha pago final (para adeudo=6)
    p_grupoanunid INT DEFAULT NULL            -- ID grupo anuncios (NULL=todos)
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
    adeudo NUMERIC,
    axo INT,
    pago NUMERIC,
    desde INT,
    hasta INT,
    fecha_pago DATE
) AS $$
DECLARE
    v_sql TEXT := '';
    v_select TEXT := '';
    v_from TEXT := '';
    v_where TEXT := '';
    v_groupby TEXT := '';
BEGIN
    -- ============================================
    -- CONSTRUCCIÓN DEL SELECT DINÁMICO
    -- ============================================

    v_select := 'SELECT a.anuncio,
                        a.fecha_otorgamiento,
                        TRIM(COALESCE(l.primer_ap,'''') || '' '' || COALESCE(l.segundo_ap,'''') || '' '' || COALESCE(l.propietario, '''')) AS propietario,
                        l.licencia,
                        l.empresa,
                        c.descripcion AS tipo_anuncio,
                        a.medidas1,
                        a.medidas2,
                        a.area_anuncio,
                        a.num_caras,
                        a.ubicacion,
                        a.numext_ubic,
                        a.letraext_ubic,
                        a.numint_ubic,
                        a.letraint_ubic AS letrain_ubic,
                        a.colonia_ubic,
                        a.cp,
                        a.zona,
                        a.subzona,
                        a.vigente,
                        a.bloqueado,
                        a.fecha_baja,
                        a.folio_baja,
                        a.espubic AS especificaciones';

    -- ============================================
    -- CAMPOS ADICIONALES SEGÚN TIPO DE ADEUDO
    -- ============================================

    IF p_adeudo = 1 THEN
        -- Sin adeudo
        v_select := v_select || ', 0::NUMERIC AS adeudo,
                                   NULL::INT AS axo,
                                   NULL::NUMERIC AS pago,
                                   NULL::INT AS desde,
                                   NULL::INT AS hasta,
                                   NULL::DATE AS fecha_pago';

    ELSIF p_adeudo = 2 THEN
        -- Con adeudo en año específico
        v_select := v_select || ', (SELECT SUM(d.saldo)
                                      FROM comun.detsal_lic d
                                      WHERE d.cvepago = 0
                                        AND d.id_anuncio = a.id_anuncio
                                        AND d.id_licencia = a.id_licencia
                                        AND d.axo = ' || COALESCE(p_axoini::TEXT, 'NULL') || ') AS adeudo,
                                   NULL::INT AS axo,
                                   NULL::NUMERIC AS pago,
                                   NULL::INT AS desde,
                                   NULL::INT AS hasta,
                                   NULL::DATE AS fecha_pago';

    ELSIF p_adeudo = 3 THEN
        -- Pagados desde año
        v_select := v_select || ', NULL::NUMERIC AS adeudo,
                                   d.axo,
                                   SUM(d.saldo) AS pago,
                                   NULL::INT AS desde,
                                   NULL::INT AS hasta,
                                   NULL::DATE AS fecha_pago';

    ELSIF p_adeudo IN (4, 5) THEN
        -- Adeudos desde/hasta año
        v_select := v_select || ', SUM(d.saldo) AS adeudo,
                                   NULL::INT AS axo,
                                   NULL::NUMERIC AS pago,
                                   MIN(d.axo) AS desde,
                                   MAX(d.axo) AS hasta,
                                   NULL::DATE AS fecha_pago';

    ELSIF p_adeudo = 6 THEN
        -- Pagados en rango de fechas
        v_select := v_select || ', NULL::NUMERIC AS adeudo,
                                   NULL::INT AS axo,
                                   SUM(d.saldo) AS pago,
                                   NULL::INT AS desde,
                                   NULL::INT AS hasta,
                                   p.fecha AS fecha_pago';

    ELSE
        -- Sin filtro de adeudo
        v_select := v_select || ', NULL::NUMERIC AS adeudo,
                                   NULL::INT AS axo,
                                   NULL::NUMERIC AS pago,
                                   NULL::INT AS desde,
                                   NULL::INT AS hasta,
                                   NULL::DATE AS fecha_pago';
    END IF;

    -- ============================================
    -- CONSTRUCCIÓN DEL FROM CON JOINS
    -- ============================================

    v_from := ' FROM comun.anuncios a
                LEFT JOIN comun.licencias l ON l.id_licencia = a.id_licencia
                INNER JOIN comun.c_giros c ON c.id_giro = a.id_giro';

    -- Joins específicos según tipo de adeudo
    IF p_adeudo = 1 THEN
        -- Sin adeudo: debe existir en detsal_lic pero suma debe ser NULL
        v_from := v_from || ' INNER JOIN comun.detsal_lic d
                               ON d.id_anuncio = a.id_anuncio
                              AND d.id_licencia = a.id_licencia
                              AND (SELECT SUM(x.saldo)
                                   FROM comun.detsal_lic x
                                   WHERE x.cvepago = 0
                                     AND x.id_anuncio = a.id_anuncio
                                     AND x.id_licencia = a.id_licencia) IS NULL';

    ELSIF p_adeudo = 2 THEN
        -- Con adeudo en año específico
        v_from := v_from || ' INNER JOIN comun.detsal_lic d
                               ON d.id_anuncio = a.id_anuncio
                              AND d.id_licencia = a.id_licencia
                              AND d.cvepago = 0
                              AND (SELECT SUM(x.saldo)
                                   FROM comun.detsal_lic x
                                   WHERE x.cvepago = 0
                                     AND x.id_anuncio = a.id_anuncio
                                     AND x.id_licencia = a.id_licencia) > 0
                              AND (SELECT MIN(x.axo)
                                   FROM comun.detsal_lic x
                                   WHERE x.cvepago = 0
                                     AND x.id_anuncio = a.id_anuncio
                                     AND x.id_licencia = a.id_licencia) = ' || COALESCE(p_axoini::TEXT, 'NULL');

    ELSIF p_adeudo = 3 THEN
        -- Pagados desde año
        v_from := v_from || ' INNER JOIN comun.detsal_lic d
                               ON d.id_anuncio = a.id_anuncio
                              AND d.id_licencia = a.id_licencia
                              AND d.cvepago > 0
                              AND d.axo >= ' || COALESCE(p_axoini::TEXT, 'NULL');

    ELSIF p_adeudo = 4 THEN
        -- Adeudo desde año (año mínimo <= año indicado)
        v_from := v_from || ' INNER JOIN comun.detsal_lic d
                               ON d.id_anuncio = a.id_anuncio
                              AND d.id_licencia = a.id_licencia
                              AND d.cvepago = 0
                              AND (SELECT MIN(x.axo)
                                   FROM comun.detsal_lic x
                                   WHERE x.cvepago = 0
                                     AND x.id_anuncio = a.id_anuncio
                                     AND x.id_licencia = a.id_licencia) <= ' || COALESCE(p_axoini::TEXT, 'NULL');

    ELSIF p_adeudo = 5 THEN
        -- Adeudo hasta año (solo adeudos <= año indicado)
        v_from := v_from || ' INNER JOIN comun.detsal_lic d
                               ON d.id_anuncio = a.id_anuncio
                              AND d.id_licencia = a.id_licencia
                              AND d.cvepago = 0
                              AND d.axo <= ' || COALESCE(p_axoini::TEXT, 'NULL') || '
                              AND (SELECT MIN(x.axo)
                                   FROM comun.detsal_lic x
                                   WHERE x.cvepago = 0
                                     AND x.id_anuncio = a.id_anuncio
                                     AND x.id_licencia = a.id_licencia) <= ' || COALESCE(p_axoini::TEXT, 'NULL');

    ELSIF p_adeudo = 6 THEN
        -- Pagados en rango de fechas
        v_from := v_from || ' INNER JOIN comun.pagos p
                               ON p.fecha BETWEEN ''' || p_fechapagoini || ''' AND ''' || p_fechapagofin || '''
                              AND p.cvecanc IS NULL
                              AND p.cveconcepto = 8
                              AND p.cvecuenta = l.id_licencia
                             INNER JOIN comun.detsal_lic d
                               ON d.id_anuncio = a.id_anuncio
                              AND d.id_licencia = a.id_licencia
                              AND d.cvepago = p.cvepago';
    END IF;

    -- ============================================
    -- CONSTRUCCIÓN DEL WHERE
    -- ============================================

    v_where := ' WHERE a.anuncio > 0';

    -- Filtro por vigencia
    IF p_vigencia = 1 THEN
        v_where := v_where || ' AND a.vigente = ''V''';
    ELSIF p_vigencia = 2 THEN
        v_where := v_where || ' AND a.vigente IN (''C'', ''B'')';
    ELSIF p_vigencia = 3 THEN
        v_where := v_where || ' AND a.vigente = ''A''';
    END IF;

    -- Filtro por tipo de reporte y fechas
    IF p_tiporep = 0 THEN
        -- Corte a fecha específica
        IF p_fechacons IS NOT NULL THEN
            IF p_vigencia = 2 THEN
                v_where := v_where || ' AND a.fecha_baja <= ''' || p_fechacons || '''';
            ELSE
                v_where := v_where || ' AND a.fecha_otorgamiento <= ''' || p_fechacons || '''';
            END IF;
        END IF;
    ELSIF p_tiporep = 1 THEN
        -- Rango de fechas
        IF p_fechaini IS NOT NULL AND p_fechafin IS NOT NULL THEN
            IF p_vigencia = 2 THEN
                v_where := v_where || ' AND a.fecha_baja BETWEEN ''' || p_fechaini || ''' AND ''' || p_fechafin || '''';
            ELSE
                v_where := v_where || ' AND a.fecha_otorgamiento BETWEEN ''' || p_fechaini || ''' AND ''' || p_fechafin || '''';
            END IF;
        END IF;
    END IF;

    -- Filtro por grupo de anuncios
    IF p_grupoanunid IS NOT NULL AND p_grupoanunid > 0 THEN
        v_where := v_where || ' AND a.anuncio IN (
                                    SELECT d.anuncio
                                    FROM comun.anuncios_grupos g
                                    INNER JOIN comun.anuncios_detgrupo d
                                      ON d.anuncios_grupos_id = g.id
                                     AND g.id = ' || p_grupoanunid || ')';
    END IF;

    -- ============================================
    -- CONSTRUCCIÓN DEL GROUP BY
    -- ============================================

    IF p_adeudo IN (1, 2) THEN
        v_groupby := ' GROUP BY a.anuncio, a.fecha_otorgamiento, l.primer_ap, l.segundo_ap, l.propietario,
                                l.licencia, l.empresa, c.descripcion, a.medidas1, a.medidas2, a.area_anuncio,
                                a.num_caras, a.ubicacion, a.numext_ubic, a.letraext_ubic, a.numint_ubic,
                                a.letraint_ubic, a.colonia_ubic, a.cp, a.zona, a.subzona, a.vigente,
                                a.bloqueado, a.fecha_baja, a.folio_baja, a.espubic, a.id_anuncio, a.id_licencia';

    ELSIF p_adeudo = 3 THEN
        v_groupby := ' GROUP BY a.anuncio, a.fecha_otorgamiento, l.primer_ap, l.segundo_ap, l.propietario,
                                l.licencia, l.empresa, c.descripcion, a.medidas1, a.medidas2, a.area_anuncio,
                                a.num_caras, a.ubicacion, a.numext_ubic, a.letraext_ubic, a.numint_ubic,
                                a.letraint_ubic, a.colonia_ubic, a.cp, a.zona, a.subzona, a.vigente,
                                a.bloqueado, a.fecha_baja, a.folio_baja, a.espubic, d.axo';

    ELSIF p_adeudo IN (4, 5) THEN
        v_groupby := ' GROUP BY a.anuncio, a.fecha_otorgamiento, l.primer_ap, l.segundo_ap, l.propietario,
                                l.licencia, l.empresa, c.descripcion, a.medidas1, a.medidas2, a.area_anuncio,
                                a.num_caras, a.ubicacion, a.numext_ubic, a.letraext_ubic, a.numint_ubic,
                                a.letraint_ubic, a.colonia_ubic, a.cp, a.zona, a.subzona, a.vigente,
                                a.bloqueado, a.fecha_baja, a.folio_baja, a.espubic, a.id_anuncio, a.id_licencia';

    ELSIF p_adeudo = 6 THEN
        v_groupby := ' GROUP BY a.anuncio, a.fecha_otorgamiento, l.primer_ap, l.segundo_ap, l.propietario,
                                l.licencia, l.empresa, c.descripcion, a.medidas1, a.medidas2, a.area_anuncio,
                                a.num_caras, a.ubicacion, a.numext_ubic, a.letraext_ubic, a.numint_ubic,
                                a.letraint_ubic, a.colonia_ubic, a.cp, a.zona, a.subzona, a.vigente,
                                a.bloqueado, a.fecha_baja, a.folio_baja, a.espubic, p.fecha';
    END IF;

    -- ============================================
    -- ORDEN DE RESULTADOS
    -- ============================================

    v_sql := v_select || v_from || v_where || v_groupby || ' ORDER BY a.fecha_otorgamiento DESC, a.anuncio';

    -- ============================================
    -- EJECUCIÓN DE LA CONSULTA DINÁMICA
    -- ============================================

    RETURN QUERY EXECUTE v_sql;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en sp_reporte_anuncios_excel: % - %', SQLERRM, SQLSTATE;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMENTARIOS Y DOCUMENTACIÓN
-- ============================================

COMMENT ON FUNCTION comun.sp_reporte_anuncios_excel IS 'Genera reporte completo de anuncios para exportación a Excel con filtros avanzados (vigencia, fechas, adeudo, grupos).
Parámetros:
- p_vigencia: 1=Vigentes, 2=Cancelados/Baja, 3=Alta, NULL=Todos
- p_tiporep: 0=Corte fecha, 1=Rango fechas
- p_fechacons: Fecha de consulta (para tiporep=0)
- p_fechaini/p_fechafin: Rango de fechas (para tiporep=1)
- p_adeudo: 1=Sin adeudo, 2=Con adeudo año, 3=Pagados desde año, 4=Adeudo desde año, 5=Adeudo hasta año, 6=Pagados en rango
- p_axoini: Año inicial para filtros de adeudo
- p_fechapagoini/p_fechapagofin: Rango fechas pago (para adeudo=6)
- p_grupoanunid: ID grupo de anuncios (NULL=todos)';

-- ============================================
-- FIN DEL SCRIPT
-- ============================================
