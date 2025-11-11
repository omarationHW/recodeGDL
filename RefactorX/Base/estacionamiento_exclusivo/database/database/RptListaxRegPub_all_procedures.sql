-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptListaxRegPub
-- Generado: 2025-08-27 14:53:31
-- Total SPs: 2
-- ============================================

-- SP 1/2: rpt_listaxregpub_get_report
-- Tipo: Report
-- Descripción: Obtiene el listado de registros públicos con requerimientos, filtrando por vigencia, clave_practicado y numesta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_listaxregpub_get_report(
    p_vigencia TEXT,
    p_clave_practicado TEXT,
    p_numesta TEXT,
    p_usuario_id_rec INTEGER
)
RETURNS TABLE (
    id INTEGER,
    pubcategoria_id INTEGER,
    numesta INTEGER,
    sector TEXT,
    zona INTEGER,
    subzona INTEGER,
    numlicencia INTEGER,
    axolicencias INTEGER,
    cvecuenta INTEGER,
    nombre TEXT,
    calle TEXT,
    numext TEXT,
    telefono TEXT,
    cupo INTEGER,
    fecha_at DATE,
    fecha_inicial DATE,
    fecha_vencimiento DATE,
    rfc TEXT,
    solicitud INTEGER,
    control INTEGER,
    movtos_no INTEGER,
    movto_cve TEXT,
    movto_usr INTEGER,
    folio_baja INTEGER,
    fecha_baja DATE,
    id_control INTEGER,
    zona_1 SMALLINT,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia TEXT,
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    zona_apremio SMALLINT,
    fecha_emision DATE,
    clave_practicado TEXT,
    fecha_practicado DATE,
    fecha_entrega1 DATE,
    fecha_entrega2 DATE,
    fecha_citatorio DATE,
    hora TIMESTAMP,
    ejecutor SMALLINT,
    clave_secuestro SMALLINT,
    clave_remate TEXT,
    fecha_remate DATE,
    porcentaje_multa SMALLINT,
    observaciones TEXT,
    fecha_pago DATE,
    recaudadora SMALLINT,
    caja TEXT,
    operacion INTEGER,
    importe_pago NUMERIC,
    vigencia TEXT,
    fecha_actualiz DATE,
    usuario INTEGER,
    clave_mov TEXT,
    hora_practicado TIMESTAMP,
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    ini_rfc TEXT,
    fec_rfc DATE,
    hom_rfc TEXT,
    nombre_1 TEXT,
    id_rec SMALLINT,
    categoria TEXT,
    observacion TEXT,
    oficio TEXT,
    fecinic DATE,
    fecterm DATE,
    vigencia_1 TEXT,
    vigreg TEXT
) AS $$
DECLARE
    sql TEXT;
BEGIN
    sql := 'SELECT a.*, b.*, c.*, ' ||
           'CASE WHEN b.folio_baja IS NULL THEN ''VIGENTE'' ELSE ''BAJA'' END AS vigreg '
           || 'FROM dbestacion.pubmain a '
           || 'JOIN ta_15_apremios b ON b.control_otr = a.id AND b.modulo = 24 '
           || 'JOIN ta_15_ejecutores c ON b.ejecutor = c.cve_eje AND b.zona = c.id_rec ';
    sql := sql || 'WHERE 1=1 ';
    IF p_numesta IS NOT NULL AND p_numesta <> 'todas' THEN
        sql := sql || 'AND a.numesta = ' || quote_literal(p_numesta) || ' ';
    END IF;
    IF p_clave_practicado IS NOT NULL AND p_clave_practicado <> 'todas' THEN
        sql := sql || 'AND b.clave_practicado = ' || quote_literal(p_clave_practicado) || ' ';
    END IF;
    IF p_vigencia IS NOT NULL AND p_vigencia <> 'todas' THEN
        IF p_vigencia = '2' THEN
            sql := sql || 'AND (b.vigencia = ' || quote_literal(p_vigencia) || ' OR b.vigencia = ''P'') ';
        ELSE
            sql := sql || 'AND b.vigencia = ' || quote_literal(p_vigencia) || ' ';
        END IF;
    END IF;
    RETURN QUERY EXECUTE sql;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: rpt_listaxregpub_get_recaudadora_info
-- Tipo: Catalog
-- Descripción: Obtiene información de la recaudadora y zona para el usuario actual.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_listaxregpub_get_recaudadora_info(
    p_usuario_id_rec SMALLINT
)
RETURNS TABLE (
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora TEXT,
    domicilio TEXT,
    tel TEXT,
    recaudador TEXT,
    sector TEXT,
    zona TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_rec, a.id_zona, a.recaudadora, a.domicilio, a.tel, a.recaudador, a.sector, b.zona
    FROM padron_licencias.comun.ta_12_recaudadoras a
    JOIN padron_licencias.comun.ta_12_zonas b ON a.id_zona = b.id_zona
    WHERE a.id_rec = p_usuario_id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

