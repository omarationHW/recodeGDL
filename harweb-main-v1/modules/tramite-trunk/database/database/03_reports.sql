CREATE OR REPLACE FUNCTION get_comprobantes_report(
    p_fecha_desde date,
    p_fecha_hasta date,
    p_filtrar_movimiento boolean,
    p_cvemov integer,
    p_filtrar_capturista boolean,
    p_capturista varchar(50),
    p_cvedepto integer
)
RETURNS TABLE(
    axocomp varchar,
    nocomp varchar,
    capturista varchar,
    feccap date,
    recaud varchar,
    urbrus varchar,
    cuenta varchar,
    clavemovto varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.axocomp, a.nocomp, a.capturista, a.feccap, b.recaud, b.urbrus, b.cuenta, c.clavemovto
    FROM h_catastro a
    JOIN convcta b ON a.cvecuenta = b.cvecuenta
    LEFT JOIN c_movcta c ON a.cvemov = c.cvemov
    WHERE a.feccap BETWEEN p_fecha_desde AND p_fecha_hasta
      AND (
        (NOT p_filtrar_movimiento) OR (a.cvemov = p_cvemov)
      )
      AND (
        (NOT p_filtrar_capturista) OR (a.capturista = p_capturista)
      )
      AND (
        (p_cvedepto IS NULL) OR (a.capturista IN (SELECT usuario FROM usuarios WHERE cvedepto = p_cvedepto))
      )
    ORDER BY a.axocomp, a.nocomp;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_comprobantes_totales_dia(
    p_fecha_desde date,
    p_fecha_hasta date,
    p_filtrar_movimiento boolean,
    p_cvemov integer,
    p_filtrar_capturista boolean,
    p_capturista varchar(50),
    p_cvedepto integer
)
RETURNS TABLE(
    axocomp varchar,
    nocomp varchar,
    capturista varchar,
    feccap date,
    recaud varchar,
    urbrus varchar,
    cuenta_count bigint,
    clavemovto varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        '' as axocomp,
        '' as nocomp,
        CASE WHEN p_filtrar_capturista THEN a.capturista ELSE '' END as capturista,
        a.feccap,
        '' as recaud,
        '' as urbrus,
        COUNT(*) as cuenta_count,
        CASE WHEN p_filtrar_movimiento THEN c.clavemovto ELSE '' END as clavemovto
    FROM h_catastro a
    JOIN convcta b ON a.cvecuenta = b.cvecuenta
    LEFT JOIN c_movcta c ON a.cvemov = c.cvemov
    WHERE a.feccap BETWEEN p_fecha_desde AND p_fecha_hasta
      AND (
        (NOT p_filtrar_movimiento) OR (a.cvemov = p_cvemov)
      )
      AND (
        (NOT p_filtrar_capturista) OR (a.capturista = p_capturista)
      )
      AND (
        (p_cvedepto IS NULL) OR (a.capturista IN (SELECT usuario FROM usuarios WHERE cvedepto = p_cvedepto))
      )
    GROUP BY a.feccap, a.capturista, c.clavemovto
    ORDER BY a.feccap;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION condueños_porcentajes(p_cvecuenta integer)
RETURNS TABLE(
  cvecont integer,
  nombre_completo text,
  porcentaje numeric,
  encabeza char(1)
) AS $$
BEGIN
  RETURN QUERY
    SELECT r.cvecont, c.nombre_completo, r.porcentaje, r.encabeza
    FROM regprop r
    JOIN contrib c ON c.cvecont = r.cvecont
    WHERE r.cvecuenta = p_cvecuenta AND r.vigencia = 'V'
    ORDER BY r.encabeza DESC, r.porcentaje DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION condueños_history(p_cvecuenta integer)
RETURNS TABLE(
  cvecont integer,
  nombre_completo text,
  porcentaje numeric,
  encabeza char(1),
  vigencia char(1),
  feccap timestamp,
  capturista text
) AS $$
BEGIN
  RETURN QUERY
    SELECT r.cvecont, c.nombre_completo, r.porcentaje, r.encabeza, r.vigencia, r.feccap, r.capturista
    FROM regprop r
    JOIN contrib c ON c.cvecont = r.cvecont
    WHERE r.cvecuenta = p_cvecuenta
    ORDER BY r.feccap DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_consreq400_search(
    p_ofnar VARCHAR,
    p_tpr VARCHAR,
    p_ctarfc VARCHAR
)
RETURNS TABLE (
    folreq VARCHAR(7),
    fecent1 VARCHAR(6),
    fecent2 VARCHAR(6),
    prareq VARCHAR(1),
    fecpra VARCHAR(6),
    horapra VARCHAR(4),
    feccita VARCHAR(6),
    horacit VARCHAR(4),
    vigreq VARCHAR(1),
    ejereq VARCHAR(6),
    dilreq VARCHAR(1),
    fecreq VARCHAR(6),
    fecpagr VARCHAR(6),
    ofnpagr VARCHAR(3),
    cajpag VARCHAR(1),
    opepagr VARCHAR(4),
    actreq VARCHAR(6),
    observr VARCHAR(30),
    axodesr VARCHAR(2),
    mesdesr VARCHAR(2),
    axohasr VARCHAR(2),
    meshasr VARCHAR(2),
    cvelet VARCHAR(3),
    cvenum VARCHAR(4),
    mesgas VARCHAR(2),
    zonreq VARCHAR(3),
    impgas VARCHAR(9),
    impcuo VARCHAR(9),
    cvesecr VARCHAR(1),
    cveremr VARCHAR(1),
    fecremr VARCHAR(6),
    mulreq VARCHAR(1),
    grabo02 VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        folreq, fecent1, fecent2, prareq, fecpra, horapra, feccita, horacit, vigreq, ejereq, dilreq, fecreq, fecpagr, ofnpagr, cajpag, opepagr, actreq, observr, axodesr, mesdesr, axohasr, meshasr, cvelet, cvenum, mesgas, zonreq, impgas, impcuo, cvesecr, cveremr, fecremr, mulreq, grabo02
    FROM req_400
    WHERE ofnar = p_ofnar AND tpr = p_tpr AND ctarfc = p_ctarfc;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_constp_query(
    p_notaria INTEGER,
    p_municipio INTEGER,
    p_escritura INTEGER
)
RETURNS TABLE (
    notaria INTEGER,
    municipio INTEGER,
    escritura INTEGER,
    otros_datos TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.notaria,
        t.municipio,
        t.escritura,
        t.otros_datos
    FROM
        transmisiones_patrimoniales t
    WHERE
        (p_notaria IS NULL OR t.notaria = p_notaria)
        AND (p_municipio IS NULL OR t.municipio = p_municipio)
        AND (p_escritura IS NULL OR t.escritura = p_escritura);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION consultar_transmision_por_folio(p_folio INTEGER)
RETURNS TABLE (
    folio INTEGER,
    bimefec INTEGER,
    axoefec INTEGER,
    nocomp VARCHAR,
    axocomp INTEGER,
    nstatus VARCHAR,
    noescrituras VARCHAR,
    fechaotorg DATE,
    fechafirma DATE,
    fechaadjudicacion DATE,
    valortransm NUMERIC,
    exento VARCHAR,
    feccap DATE,
    fectram DATE,
    capturista VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        folio, bimefec, axoefec, nocomp, axocomp, nstatus, noescrituras, fechaotorg, fechafirma, fechaadjudicacion, valortransm, exento, feccap, fectram, capturista
    FROM actostransm
    WHERE folio = p_folio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION consultar_transmisiones_por_fechas(p_desde DATE, p_hasta DATE)
RETURNS TABLE (
    folio INTEGER,
    fecha DATE,
    noescrituras VARCHAR,
    notaria VARCHAR,
    nombres VARCHAR,
    paterno VARCHAR,
    materno VARCHAR,
    recaud VARCHAR,
    urbrus VARCHAR,
    cuenta VARCHAR,
    nocomp VARCHAR,
    axocomp VARCHAR,
    status VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.folio, p.fecha, a.noescrituras, n.notaria, n.nombres, n.paterno, n.materno, c.recaud, c.urbrus, c.cuenta, a.nocomp, a.axocomp, a.nstatus as status
    FROM actostransm a
    JOIN pagos p ON p.cvepago = a.cvepago
    JOIN notario n ON n.idnotaria = a.idnotaria
    JOIN convcta c ON c.cvecuenta = a.cvecuenta
    WHERE p.cveconcepto = 2
      AND p.fecha BETWEEN p_desde AND p_hasta
    ORDER BY p.fecha;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION contar_folios_por_fechas(p_desde DATE, p_hasta DATE)
RETURNS INTEGER AS $$
DECLARE
    total INTEGER;
BEGIN
    SELECT COUNT(*) INTO total
    FROM actostransm a
    JOIN pagos p ON p.cvepago = a.cvepago
    JOIN notario n ON n.idnotaria = a.idnotaria
    JOIN convcta c ON c.cvecuenta = a.cvecuenta
    WHERE p.cveconcepto = 2
      AND p.fecha BETWEEN p_desde AND p_hasta;
    RETURN total;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION consultar_transmisiones_totales_por_fecha(p_desde DATE, p_hasta DATE)
RETURNS TABLE (
    fecha DATE,
    total INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.fecha, COUNT(*) as total
    FROM actostransm a
    JOIN pagos p ON p.cvepago = a.cvepago
    JOIN notario n ON n.idnotaria = a.idnotaria
    JOIN convcta c ON c.cvecuenta = a.cvecuenta
    WHERE p.cveconcepto = 2
      AND p.fecha BETWEEN p_desde AND p_hasta
    GROUP BY p.fecha
    ORDER BY p.fecha;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION consultar_pagos_transmisiones_patrimoniales(
    p_fecha integer DEFAULT NULL,
    p_recaud smallint DEFAULT NULL,
    p_operacion smallint DEFAULT NULL,
    p_caja varchar DEFAULT NULL
)
RETURNS SETOF pagotransm_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM pagotransm_400
    WHERE (p_fecha IS NULL OR fec_pag = p_fecha)
      AND (p_recaud IS NULL OR rec_pag = p_recaud)
      AND (p_operacion IS NULL OR opc_pag = p_operacion)
      AND (p_caja IS NULL OR cajpag = p_caja);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION consultar_transmisiones_patrimoniales(
    p_fecha integer DEFAULT NULL,
    p_recaud smallint DEFAULT NULL,
    p_operacion integer DEFAULT NULL,
    p_caja varchar DEFAULT NULL
)
RETURNS SETOF transm_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM transm_400
    WHERE (p_fecha IS NULL OR fecha = p_fecha)
      AND (p_recaud IS NULL OR recaud = p_recaud)
      AND (p_operacion IS NULL OR folio = p_operacion)
      AND (p_caja IS NULL OR caja = p_caja);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_consume400_search(p_recaud integer, p_ur integer, p_cuenta integer)
RETURNS TABLE (
  recaud smallint,
  ur smallint,
  cuenta integer,
  mpio smallint,
  zona smallint,
  manz smallint,
  lote smallint,
  subp smallint,
  calleu varchar(25),
  extu varchar(6),
  intu varchar(5),
  colu varchar(10),
  crec smallint,
  cur smallint,
  ccta integer,
  cvecatnva varchar(10),
  activo smallint,
  acomp integer,
  cm varchar(2),
  otorg integer,
  areaterr float,
  areaconst float,
  indiviso integer,
  valterr float,
  valconst float,
  valfis float,
  tasauem smallint,
  efec smallint,
  homorfc varchar(2),
  letrasrfc varchar(4),
  numrfc integer,
  detrfc varchar(3),
  prop varchar(35),
  called varchar(25),
  extd varchar(6),
  intd varchar(4),
  cold varchar(10),
  secd varchar(1),
  pobld varchar(15),
  cpd integer,
  edod varchar(3),
  paisd varchar(2),
  axost smallint,
  asiento integer,
  fecha integer,
  capturo varchar(8),
  predial smallint,
  patrim varchar(5),
  ultacomp integer
) AS $$
BEGIN
  RETURN QUERY
    SELECT * FROM historico
    WHERE recaud = p_recaud AND ur = p_ur AND cuenta = p_cuenta;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION basephp.consulta_predial_get_saldos(
    p_cvecuenta INTEGER
) RETURNS TABLE (
    anio INTEGER,
    impuesto NUMERIC,
    recargos NUMERIC,
    saldototal NUMERIC,
    impfac NUMERIC,
    imprec NUMERIC,
    impvir NUMERIC,
    recfac NUMERIC,
    recrec NUMERIC,
    total NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.anio, s.impfac-s.impvir AS impuesto, s.recfac-s.recrec AS recargos, s.saldototal, s.impfac, s.imprec, s.impvir, s.recfac, s.recrec, (s.impfac-s.impvir)+(s.recfac-s.recrec) AS total
    FROM saldosanio s
    WHERE s.cvecuenta = p_cvecuenta
    ORDER BY s.anio DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION basephp.consulta_predial_get_recibos(
    p_cvecuenta INTEGER
) RETURNS TABLE (
    cvepago INTEGER,
    recaud INTEGER,
    caja VARCHAR,
    folio INTEGER,
    descripcion VARCHAR,
    fecha DATE,
    hora TIME,
    importe NUMERIC,
    cajero VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.cvepago, p.recaud, p.caja, p.folio, d.descripcion, p.fecha, p.hora::time, p.importe, p.cajero
    FROM pagos p
    JOIN c_conceptos d ON d.cveconcepto = p.cveconcepto AND d.cvegrupo = 1
    WHERE p.cvecuenta = p_cvecuenta
    ORDER BY p.fecha DESC, p.hora DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION basephp.consulta_predial_get_requerimientos(
    p_cvecuenta INTEGER
) RETURNS TABLE (
    axoreq INTEGER,
    folioreq INTEGER,
    impuesto NUMERIC,
    recargos NUMERIC,
    gastos NUMERIC,
    gasto_req NUMERIC,
    multas NUMERIC,
    total NUMERIC,
    recaud INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.axoreq, r.folioreq, r.impuesto, r.recargos, r.gastos, r.gasto_req, r.multas, r.total, r.recaud
    FROM reqpredial r
    WHERE r.cvecuenta = p_cvecuenta
    ORDER BY r.axoreq DESC, r.folioreq DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION basephp.consulta_predial_get_regimen_propiedad(
    p_cvecuenta INTEGER
) RETURNS TABLE (
    encabeza VARCHAR,
    porcentaje NUMERIC,
    descripcion VARCHAR,
    exento VARCHAR,
    ncompleto VARCHAR,
    rfc VARCHAR,
    cvecont INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.encabeza, r.porcentaje, c.descripcion, r.exento, co.nombre_completo, co.rfc, co.cvecont
    FROM regprop r
    JOIN c_calidpro c ON c.cvereg = r.cvereg
    JOIN contrib co ON co.cvecont = r.cvecont
    WHERE r.cvecuenta = p_cvecuenta AND r.vigencia = 'V'
    ORDER BY r.encabeza DESC, r.porcentaje DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION basephp.consulta_predial_get_valores(
    p_cvecuenta INTEGER
) RETURNS TABLE (
    axoefec INTEGER,
    bimefec INTEGER,
    tasa NUMERIC,
    valfiscal NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT v.axoefec, v.bimefec, v.tasa, v.valfiscal
    FROM valores v
    WHERE v.cvecuenta = p_cvecuenta
    ORDER BY v.axoefec DESC, v.bimefec DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_cvecatdup_list(p_cvecatnva VARCHAR DEFAULT NULL)
RETURNS TABLE(recaud INTEGER, urbrus VARCHAR, cuenta INTEGER) AS $$
BEGIN
  RETURN QUERY
    SELECT recaud, urbrus, cuenta
    FROM cvecatdup
    WHERE (p_cvecatnva IS NULL OR cvecatnva = p_cvecatnva);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_construc_list(p_cvecatnva VARCHAR)
RETURNS TABLE(
    id INT,
    cvecatnva VARCHAR,
    subpredio SMALLINT,
    cvebloque SMALLINT,
    axoconst SMALLINT,
    areaconst FLOAT,
    cveclasif INT,
    cvecuenta INT,
    estructura SMALLINT,
    factorajus FLOAT,
    numpisos SMALLINT,
    importe NUMERIC,
    cveavaluo INT,
    axovig SMALLINT,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, cvecatnva, subpredio, cvebloque, axoconst, areaconst, cveclasif, cvecuenta, estructura, factorajus, numpisos, importe, cveavaluo, axovig, vigente
    FROM construc
    WHERE cvecatnva = p_cvecatnva AND subpredio > 0 AND vigente = 'V'
    ORDER BY subpredio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_historico_comprobante(
    p_cvecuenta INTEGER,
    p_axocomp INTEGER,
    p_nocomp INTEGER,
    p_feccap DATE
) RETURNS TABLE(
    cvecuenta INTEGER,
    axocomp INTEGER,
    nocomp INTEGER,
    feccap DATE,
    observacion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecuenta, axocomp, nocomp, feccap, observacion
    FROM h_catastro
    WHERE cvecuenta = p_cvecuenta AND axocomp = p_axocomp AND nocomp = p_nocomp AND feccap = p_feccap;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_impno_get_notification_data(
    p_recaud VARCHAR,
    p_urbrus VARCHAR,
    p_cuenta VARCHAR
) RETURNS JSON AS $$
DECLARE
    v_convcta RECORD;
    v_catastro RECORD;
    v_regprop RECORD;
    v_contrib RECORD;
    v_ubicacion RECORD;
    v_avaluos RECORD;
    v_valores RECORD;
    v_valoradeudo RECORD;
    v_parametros RECORD;
    v_detsaldos RECORD;
    v_pob RECORD;
    v_mun RECORD;
    result JSON;
BEGIN
    -- Buscar convcta
    SELECT * INTO v_convcta FROM convcta WHERE recaud = p_recaud AND urbrus = p_urbrus AND cuenta = p_cuenta LIMIT 1;
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;
    -- Buscar catastro
    SELECT * INTO v_catastro FROM catastro WHERE cvecuenta = v_convcta.cvecuenta LIMIT 1;
    -- Buscar regprop
    SELECT * INTO v_regprop FROM regprop WHERE cvecuenta = v_convcta.cvecuenta AND cveregprop = v_catastro.cveregprop LIMIT 1;
    -- Buscar contrib
    SELECT * INTO v_contrib FROM contrib WHERE cvecont = v_regprop.cvecont LIMIT 1;
    -- Buscar ubicacion
    SELECT * INTO v_ubicacion FROM ubicacion WHERE cvecuenta = v_convcta.cvecuenta LIMIT 1;
    -- Buscar avaluos
    SELECT * INTO v_avaluos FROM avaluos WHERE cvecuenta = v_convcta.cvecuenta LIMIT 1;
    -- Buscar valores
    SELECT * INTO v_valores FROM valores WHERE cvevalor = v_catastro.cvevalor LIMIT 1;
    -- Buscar valoradeudo
    SELECT * INTO v_valoradeudo FROM valoradeudo WHERE cvecuenta = v_convcta.cvecuenta LIMIT 1;
    -- Buscar parametros
    SELECT * INTO v_parametros FROM parametros LIMIT 1;
    -- Buscar detsaldos
    SELECT * INTO v_detsaldos FROM detsaldos WHERE cvecuenta = v_convcta.cvecuenta LIMIT 1;
    -- Buscar pob
    SELECT * INTO v_pob FROM c_poblac WHERE cvepoblacion = v_contrib.cvepoblacion AND cvemunicipio = v_contrib.cvemunicipio LIMIT 1;
    -- Buscar mun
    SELECT * INTO v_mun FROM c_mpios WHERE cvemunicipio = v_contrib.cvemunicipio LIMIT 1;
    -- Armar resultado JSON
    result := json_build_object(
        'convcta', row_to_json(v_convcta),
        'catastro', row_to_json(v_catastro),
        'regprop', row_to_json(v_regprop),
        'contrib', row_to_json(v_contrib),
        'ubicacion', row_to_json(v_ubicacion),
        'avaluos', row_to_json(v_avaluos),
        'valores', row_to_json(v_valores),
        'valoradeudo', row_to_json(v_valoradeudo),
        'parametros', row_to_json(v_parametros),
        'detsaldos', row_to_json(v_detsaldos),
        'pob', row_to_json(v_pob),
        'mun', row_to_json(v_mun)
    );
    RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_loctp_detalle(p_cvecuenta integer)
RETURNS TABLE(
  recaud smallint,
  urbrus varchar,
  cuenta integer
) AS $$
BEGIN
  RETURN QUERY SELECT recaud, urbrus, cuenta FROM convcta WHERE cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_muestradup_list(p_cvecond INTEGER)
RETURNS TABLE(
    cvecond INTEGER,
    cvecuenta INTEGER,
    recaud INTEGER,
    urbrus VARCHAR,
    cuenta INTEGER,
    subpredio INTEGER,
    estado VARCHAR,
    fecha TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecond, cvecuenta, recaud, urbrus, cuenta, subpredio, estado, fecha
    FROM cuentas_duplicadas
    WHERE cvecond = p_cvecond AND estado <> 'D'
    ORDER BY subpredio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_muestradup_report(p_cvecond INTEGER)
RETURNS TABLE(
    cvecond INTEGER,
    cvecuenta INTEGER,
    recaud INTEGER,
    urbrus VARCHAR,
    cuenta INTEGER,
    subpredio INTEGER,
    estado VARCHAR,
    fecha TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecond, cvecuenta, recaud, urbrus, cuenta, subpredio, estado, fecha
    FROM cuentas_duplicadas
    WHERE cvecond = p_cvecond
    ORDER BY subpredio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_preferencial_list(p_folio INTEGER)
RETURNS TABLE(
    id INTEGER,
    folio INTEGER,
    bimefec INTEGER,
    axoefec INTEGER,
    nocomp INTEGER,
    axocomp INTEGER,
    nstatus TEXT,
    noescrituras INTEGER,
    fechaotorg DATE,
    fechafirma DATE,
    fechaadjudicacion DATE,
    valortransm NUMERIC,
    exento TEXT,
    feccap DATE,
    fectram DATE,
    capturista TEXT,
    tasa NUMERIC,
    tasa_nva NUMERIC,
    feccap_nva DATE,
    fecha_baja DATE,
    user_baja TEXT,
    observacion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.folio,
        a.bimefec,
        a.axoefec,
        a.nocomp,
        a.axocomp,
        a.nstatus,
        a.noescrituras,
        a.fechaotorg,
        a.fechafirma,
        a.fechaadjudicacion,
        a.valortransm,
        a.exento,
        a.feccap,
        a.fectram,
        a.capturista,
        p.tasa,
        p.tasa_nva,
        p.feccap AS feccap_nva,
        p.fecha_baja,
        p.user_baja,
        p.observacion
    FROM preferencial p
    JOIN actos a ON a.folio = p.folio
    WHERE p.folio = p_folio
    ORDER BY p.id DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_prepago_get_resumen(p_cvecuenta INTEGER)
RETURNS TABLE (
  ncompleto TEXT,
  calle TEXT,
  noexterior TEXT,
  interior TEXT,
  impppag NUMERIC,
  recppag NUMERIC,
  gasto NUMERIC,
  multa NUMERIC,
  total NUMERIC,
  ubicacion_calle TEXT,
  ubicacion_noexterior TEXT,
  ubicacion_interior TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT c.nombre_completo, c.calle, c.noexterior, c.interior,
         COALESCE(s.impppag,0), COALESCE(s.recppag,0), COALESCE(s.gasto,0), COALESCE(s.multa,0),
         COALESCE(s.impppag,0)+COALESCE(s.recppag,0)+COALESCE(s.gasto,0)+COALESCE(s.multa,0) AS total,
         u.calle, u.noexterior, u.interior
  FROM contrib c
  JOIN regprop r ON r.cvecont = c.cvecont AND r.cvecuenta = p_cvecuenta AND r.encabeza = 'S' AND r.vigencia <> 'E'
  JOIN catastro ct ON ct.cvecuenta = p_cvecuenta AND r.cveregprop = ct.cveregprop
  LEFT JOIN (
    SELECT SUM(d.recfac-d.recpag-d.recvir) AS recppag,
           SUM(d.impfac-d.imppag-d.impvir) AS impppag,
           (s.multa-s.multavir) AS multa,
           s.gasto
    FROM detsaldos d
    JOIN saldos s ON s.cvecuenta = d.cvecuenta
    WHERE d.cvecuenta = p_cvecuenta AND d.saldo > 0
    GROUP BY s.multa, s.multavir, s.gasto
  ) s ON TRUE
  LEFT JOIN ubicacion u ON u.cvecuenta = p_cvecuenta AND u.vigencia = 'V'
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_prepago_get_periodos(
  p_cvecuenta INTEGER,
  p_asal INTEGER,
  p_bsal INTEGER,
  p_asalf INTEGER,
  p_bsalf INTEGER
)
RETURNS TABLE (
  axoefec INTEGER,
  valfiscal NUMERIC,
  tasa NUMERIC,
  axosobre INTEGER,
  recvir NUMERIC,
  impfac NUMERIC,
  impvir NUMERIC,
  impade NUMERIC,
  total NUMERIC,
  bimini INTEGER,
  bimfin INTEGER,
  inicio TEXT,
  fin TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT v.axoefec, v.valfiscal, v.tasa, v.axosobre,
         SUM(d.recvir) AS recvir,
         SUM(d.impade+d.impvir) AS impfac,
         SUM(d.impvir) AS impvir,
         SUM(d.impade) AS impade,
         SUM(d.recfac-d.recpag-d.recvir) AS total,
         MIN(v.bimefec) AS bimini,
         MAX(v.bimefec) AS bimfin,
         MIN(v.bimefec)::TEXT||'/'||v.axoefec AS inicio,
         MAX(v.bimefec)::TEXT||'/'||v.axoefec AS fin
  FROM detsaldos d
  JOIN valoradeudo v ON v.cvecuenta = d.cvecuenta AND v.axoefec = d.axosal AND v.bimefec = d.bimsal
  WHERE d.cvecuenta = p_cvecuenta AND d.saldo > 0
    AND ((d.axosal > p_asal OR (d.bimsal >= p_bsal AND d.axosal = p_asal))
         AND (d.axosal < p_asalf OR (d.bimsal <= p_bsalf AND d.axosal = p_asalf)))
  GROUP BY v.axoefec, v.valfiscal, v.tasa, v.axosobre
  ORDER BY v.axoefec, bimini;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_prepago_get_ultimo_requerimiento(p_cvecuenta INTEGER)
RETURNS TABLE (
  cvereq INTEGER,
  cveejecut INTEGER,
  folioreq INTEGER,
  axoreq INTEGER,
  cvecuenta INTEGER,
  cvepago INTEGER,
  impuesto NUMERIC,
  recargos NUMERIC,
  gastos NUMERIC,
  multas NUMERIC,
  total NUMERIC,
  fecemi DATE,
  fecent DATE,
  cvecancr TEXT,
  axoini INTEGER,
  bimini INTEGER,
  axofin INTEGER,
  bimfin INTEGER,
  secuencia INTEGER,
  vigencia TEXT,
  feccap DATE,
  capturista TEXT,
  iniper TEXT,
  finper TEXT,
  diastrans INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT *, bimini::TEXT||'/'||axoini AS iniper, bimfin::TEXT||'/'||axofin AS finper, (CURRENT_DATE - fecent) AS diastrans
  FROM reqpredial
  WHERE cvecuenta = p_cvecuenta AND vigencia = 'V' AND fecent IS NOT NULL AND nodiligenciado <> 'S'
  ORDER BY axoreq DESC, folioreq DESC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_prepago_get_descuentos(
  p_cvecuenta INTEGER,
  p_asal INTEGER,
  p_bsal INTEGER,
  p_asalf INTEGER,
  p_bsalf INTEGER
)
RETURNS TABLE (
  cvedescuento INTEGER,
  descripcion TEXT,
  impdescto NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT d.cvedescuento, c.descripcion, SUM(d.impvir) AS impdescto
  FROM detsaldos d
  JOIN valoradeudo v ON v.cvecuenta = d.cvecuenta AND v.axoefec = d.axosal AND v.bimefec = d.bimsal
  LEFT JOIN c_descpred c ON d.cvedescuento = c.cvedescuento
  WHERE d.cvecuenta = p_cvecuenta AND d.saldo > 0
    AND ((d.axosal > p_asal OR (d.bimsal >= p_bsal AND d.axosal = p_asal))
         AND (d.axosal < p_asalf OR (d.bimsal <= p_bsalf AND d.axosal = p_asalf)))
    AND d.cvedescuento IS NOT NULL
  GROUP BY d.cvedescuento, c.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION propuestatab1_list()
RETURNS TABLE(cvecuenta integer, cuenta integer, cvecatnva varchar, subpredio integer, recaud integer, urbrus varchar, asiento integer, cmovto varchar, observacion text) AS $$
BEGIN
  RETURN QUERY SELECT cvecuenta, cuenta, cvecatnva, subpredio, recaud, urbrus, asiento, cmovto, observacion FROM historico_cuentas;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION propuestatab1_show(cvecuenta integer)
RETURNS TABLE(cvecuenta integer, cuenta integer, cvecatnva varchar, subpredio integer, recaud integer, urbrus varchar, asiento integer, cmovto varchar, observacion text) AS $$
BEGIN
  RETURN QUERY SELECT cvecuenta, cuenta, cvecatnva, subpredio, recaud, urbrus, asiento, cmovto, observacion FROM historico_cuentas WHERE cvecuenta = $1;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION propuestatab1_history(cvecuenta integer)
RETURNS TABLE(fecha date, movimiento varchar, observacion text) AS $$
BEGIN
  RETURN QUERY SELECT fecha, movimiento, observacion FROM historico_movimientos WHERE cvecuenta = $1 ORDER BY fecha DESC;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION propuestatab1_regimen(cvecuenta integer)
RETURNS TABLE(encabeza varchar, porcentaje numeric, descripcion varchar, exento varchar, ncompleto varchar, rfc varchar, calle varchar, interior varchar, noexterior varchar, poblacion varchar, municipio varchar, estado varchar, pais varchar) AS $$
BEGIN
  RETURN QUERY SELECT encabeza, porcentaje, descripcion, exento, ncompleto, rfc, calle, interior, noexterior, poblacion, municipio, estado, pais FROM regimen_propiedad WHERE cvecuenta = $1;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION propuestatab1_valores(cvecuenta integer)
RETURNS TABLE(valorterr numeric, valorconst numeric, valfiscal numeric, areaterr integer, areaconst integer, tasa numeric) AS $$
BEGIN
  RETURN QUERY SELECT valorterr, valorconst, valfiscal, areaterr, areaconst, tasa FROM valores_cuenta WHERE cvecuenta = $1;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION propuestatab1_pagos(cvecuenta integer)
RETURNS TABLE(fecha date, importe numeric, recaud integer, caja varchar, folio integer, cajero varchar) AS $$
BEGIN
  RETURN QUERY SELECT fecha, importe, recaud, caja, folio, cajero FROM pagos_transpat WHERE cvecuenta = $1;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION propuestatab1_diferencias(cvecuenta integer)
RETURNS TABLE(bimini smallint, axoini integer, bimfin smallint, axofin integer, tasaant numeric, stasaant smallint, valfisant numeric, tasa numeric, axosobretasa smallint, valfiscal numeric) AS $$
BEGIN
  RETURN QUERY SELECT bimini, axoini, bimfin, axofin, tasaant, stasaant, valfisant, tasa, axosobretasa, valfiscal FROM diferencias_valores WHERE cvecuenta = $1;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION propuestatab1_obs400(cvecuenta integer)
RETURNS TABLE(acomp integer, observa varchar) AS $$
BEGIN
  RETURN QUERY SELECT acomp, observa FROM obs400 WHERE cvecuenta = $1;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION propuestatab1_cfs400(cvecuenta integer)
RETURNS TABLE(mpio smallint, axocomp smallint, nocomp integer, escritura integer, notario smallint, mpio_notario smallint, estado varchar, fideicomisario varchar, fideicomitente varchar) AS $$
BEGIN
  RETURN QUERY SELECT mpio, axocomp, nocomp, escritura, notario, mpio_notario, estado, fideicomisario, fideicomitente FROM cfs400 WHERE cvecuenta = $1;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION propuestatab1_escrituras(cvecuenta integer)
RETURNS TABLE(escritura integer, notario smallint, mpio smallint, folio integer, axofolio smallint, nocomp integer, axocomp smallint, ccta integer, crec smallint, clave varchar, capturista varchar, enviado varchar, regresado varchar, fecha integer) AS $$
BEGIN
  RETURN QUERY SELECT escritura, notario, mpio, folio, axofolio, nocomp, axocomp, ccta, crec, clave, capturista, enviado, regresado, fecha FROM escrituras_400 WHERE cvecuenta = $1;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION propuestatab1_condominio(cvecatnva varchar)
RETURNS TABLE(cvecond integer, nombre varchar, tipocond varchar, numpred integer, escritura integer, idnotaria smallint, fecescrit date, cvecatnva varchar, cveubic integer, fecag date, cveavg integer, areacomun float, axoefec smallint, bimefec smallint, feccap date, capturista varchar, cvecolonia integer, noexp integer, cuenta_inicio integer, cuenta_final integer, cvecartografia integer, fecha_verificado date, usr_verificado varchar) AS $$
BEGIN
  RETURN QUERY SELECT cvecond, nombre, tipocond, numpred, escritura, idnotaria, fecescrit, cvecatnva, cveubic, fecag, cveavg, areacomun, axoefec, bimefec, feccap, capturista, cvecolonia, noexp, cuenta_inicio, cuenta_final, cvecartografia, fecha_verificado, usr_verificado FROM condominio WHERE cvecatnva = $1;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_extractos_rango_cuentas(
    p_recaud integer,
    p_inicial integer,
    p_final integer
)
RETURNS TABLE(
    recaud integer,
    urbrus varchar,
    cuenta integer,
    digver integer,
    cvecatnva varchar,
    subpredio integer,
    cip varchar,
    nocomp integer,
    axoultcomp integer,
    ultcomp integer,
    asiento integer,
    feccap date,
    capturista varchar,
    cvecuenta integer,
    axocomp integer,
    cvemov integer,
    axoefec integer,
    bimefec integer,
    cvecont integer,
    rfc varchar,
    noexterior varchar,
    interior varchar,
    codpos integer,
    callecont varchar,
    tasa numeric,
    valfiscal numeric,
    areaterr integer,
    areaconst integer,
    calleubic varchar,
    cvecolonia integer,
    noexterior_1 varchar,
    interior_1 varchar,
    ncompleto varchar,
    movimiento varchar,
    paiscont varchar,
    edocont varchar,
    mpiocont varchar,
    pobcont varchar,
    impfac numeric,
    areatitulo numeric,
    obsinter text,
    valterr numeric,
    valconst numeric,
    folio integer,
    indiviso numeric,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.recaud, c.urbrus, c.cuenta, c.digver, c.cvecatnva, c.subpredio, c.cip, 
        c.nocomp, c.axoultcomp, c.ultcomp, c.asiento, c.feccap, c.capturista, c.cvecuenta, 
        c.axocomp, c.cvemov, c.axoefec, c.bimefec, c.cvecont, c.rfc, c.noexterior, c.interior, 
        c.codpos, c.callecont, c.tasa, c.valfiscal, c.areaterr, c.areaconst, c.calleubic, 
        c.cvecolonia, c.noexterior_1, c.interior_1, c.ncompleto, c.movimiento, c.paiscont, 
        c.edocont, c.mpiocont, c.pobcont, c.impfac, c.areatitulo, c.obsinter, c.valterr, 
        c.valconst, c.folio, c.indiviso, c.descripcion
    FROM extractos_adq c
    WHERE c.recaud = p_recaud
      AND c.cuenta BETWEEN p_inicial AND p_final
    ORDER BY c.cuenta;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_extractos_rango_capturista(
    p_capturista varchar,
    p_fecha_ini date,
    p_fecha_fin date
)
RETURNS TABLE(
    recaud integer,
    urbrus varchar,
    cuenta integer,
    digver integer,
    cvecatnva varchar,
    subpredio integer,
    cip varchar,
    nocomp integer,
    axoultcomp integer,
    ultcomp integer,
    asiento integer,
    feccap date,
    capturista varchar,
    cvecuenta integer,
    axocomp integer,
    cvemov integer,
    axoefec integer,
    bimefec integer,
    cvecont integer,
    rfc varchar,
    noexterior varchar,
    interior varchar,
    codpos integer,
    callecont varchar,
    tasa numeric,
    valfiscal numeric,
    areaterr integer,
    areaconst integer,
    calleubic varchar,
    cvecolonia integer,
    noexterior_1 varchar,
    interior_1 varchar,
    ncompleto varchar,
    movimiento varchar,
    paiscont varchar,
    edocont varchar,
    mpiocont varchar,
    pobcont varchar,
    impfac numeric,
    areatitulo numeric,
    obsinter text,
    valterr numeric,
    valconst numeric,
    folio integer,
    indiviso numeric,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.recaud, c.urbrus, c.cuenta, c.digver, c.cvecatnva, c.subpredio, c.cip, 
        c.nocomp, c.axoultcomp, c.ultcomp, c.asiento, c.feccap, c.capturista, c.cvecuenta, 
        c.axocomp, c.cvemov, c.axoefec, c.bimefec, c.cvecont, c.rfc, c.noexterior, c.interior, 
        c.codpos, c.callecont, c.tasa, c.valfiscal, c.areaterr, c.areaconst, c.calleubic, 
        c.cvecolonia, c.noexterior_1, c.interior_1, c.ncompleto, c.movimiento, c.paiscont, 
        c.edocont, c.mpiocont, c.pobcont, c.impfac, c.areatitulo, c.obsinter, c.valterr, 
        c.valconst, c.folio, c.indiviso, c.descripcion
    FROM extractos_adq c
    WHERE c.capturista = p_capturista
      AND c.feccap BETWEEN p_fecha_ini AND p_fecha_fin
    ORDER BY c.feccap, c.cuenta;
END;
$$ LANGUAGE plpgsql;

-- sp_get_motivo_rechazo(folio integer)
CREATE OR REPLACE FUNCTION sp_get_motivo_rechazo(
    p_folio integer
) RETURNS TABLE(motivo text, fecha_rechazo timestamp, usuario text) AS $$
BEGIN
    RETURN QUERY
    SELECT documentosotros, fecha_rechazo, usuario_rechazo
    FROM actostransm
    WHERE folio = p_folio AND status = 'R' AND axocomp = 9999 AND nocomp = 999999;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reghfrm_list_history(p_cvecuenta INTEGER)
RETURNS TABLE(
    axocomp INTEGER,
    nocomp INTEGER,
    cvemov INTEGER,
    feccap DATE,
    capturista VARCHAR,
    observacion TEXT,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT axocomp, nocomp, cvemov, feccap, capturista, observacion, vigente
    FROM h_catastro
    WHERE cvecuenta = p_cvecuenta
    ORDER BY axocomp DESC, nocomp DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reghfrm_show_record(p_cvecuenta INTEGER, p_axocomp INTEGER, p_nocomp INTEGER)
RETURNS TABLE(
    axocomp INTEGER,
    nocomp INTEGER,
    cvemov INTEGER,
    feccap DATE,
    capturista VARCHAR,
    observacion TEXT,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT axocomp, nocomp, cvemov, feccap, capturista, observacion, vigente
    FROM h_catastro
    WHERE cvecuenta = p_cvecuenta AND axocomp = p_axocomp AND nocomp = p_nocomp
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reghfrm_search_history(p_criteria JSON)
RETURNS TABLE(
    axocomp INTEGER,
    nocomp INTEGER,
    cvemov INTEGER,
    feccap DATE,
    capturista VARCHAR,
    observacion TEXT,
    vigente VARCHAR
) AS $$
DECLARE
    _sql TEXT;
BEGIN
    _sql := 'SELECT axocomp, nocomp, cvemov, feccap, capturista, observacion, vigente FROM h_catastro WHERE 1=1';
    IF p_criteria ? 'cvecuenta' THEN
        _sql := _sql || ' AND cvecuenta = ' || (p_criteria->>'cvecuenta');
    END IF;
    IF p_criteria ? 'cvemov' THEN
        _sql := _sql || ' AND cvemov = ' || (p_criteria->>'cvemov');
    END IF;
    IF p_criteria ? 'feccap_from' THEN
        _sql := _sql || ' AND feccap >= ''' || (p_criteria->>'feccap_from') || '''';
    END IF;
    IF p_criteria ? 'feccap_to' THEN
        _sql := _sql || ' AND feccap <= ''' || (p_criteria->>'feccap_to') || '''';
    END IF;
    RETURN QUERY EXECUTE _sql;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reghfrm_filter_history(p_filters JSON)
RETURNS TABLE(
    axocomp INTEGER,
    nocomp INTEGER,
    cvemov INTEGER,
    feccap DATE,
    capturista VARCHAR,
    observacion TEXT,
    vigente VARCHAR
) AS $$
DECLARE
    _sql TEXT;
BEGIN
    _sql := 'SELECT axocomp, nocomp, cvemov, feccap, capturista, observacion, vigente FROM h_catastro WHERE 1=1';
    IF p_filters ? 'vigente' THEN
        _sql := _sql || ' AND vigente = ''' || (p_filters->>'vigente') || '''';
    END IF;
    IF p_filters ? 'capturista' THEN
        _sql := _sql || ' AND capturista ILIKE ''%' || (p_filters->>'capturista') || '%''';
    END IF;
    RETURN QUERY EXECUTE _sql;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reghfrm_account_history(p_cvecuenta INTEGER)
RETURNS TABLE(
    axocomp INTEGER,
    nocomp INTEGER,
    cvemov INTEGER,
    feccap DATE,
    capturista VARCHAR,
    observacion TEXT,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT axocomp, nocomp, cvemov, feccap, capturista, observacion, vigente
    FROM h_catastro
    WHERE cvecuenta = p_cvecuenta
    ORDER BY axocomp DESC, nocomp DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_buscar_cuenta(p_recaud INTEGER, p_urbrus TEXT, p_cuenta INTEGER)
RETURNS TABLE(
    cvecuenta INTEGER,
    recaud INTEGER,
    urbrus TEXT,
    cuenta INTEGER,
    claveutm TEXT,
    subpredio INTEGER,
    vigente TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecuenta, recaud, urbrus, cuenta, (recaud || '-' || urbrus || '-' || cuenta) as claveutm, subpredio, vigente
    FROM convcta
    WHERE recaud = p_recaud AND urbrus = p_urbrus AND cuenta = p_cuenta;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_consultar_propietarios(p_cvecuenta INTEGER)
RETURNS TABLE(
    id SERIAL,
    cvecuenta INTEGER,
    nombre TEXT,
    rfc TEXT,
    porcentaje NUMERIC,
    tipo TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, cvecuenta, nombre, rfc, porcentaje, tipo
    FROM propietarios
    WHERE cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_consultar_liquidacion(p_cvecuenta INTEGER)
RETURNS TABLE(
    id SERIAL,
    cvecuenta INTEGER,
    concepto TEXT,
    importe NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, cvecuenta, concepto, importe
    FROM liquidaciones
    WHERE cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_consultar_horario_usuario(p_usuario TEXT)
RETURNS TABLE(
    usuario TEXT,
    hora_inicio TEXT,
    hora_termino TEXT,
    tolerancia TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT usuario, hora_inicio, hora_termino, tolerancia
    FROM horario_usuario
    WHERE usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_consultar_version()
RETURNS TABLE(
    version TEXT,
    permite_acceso TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT version, permite_acceso FROM c_aplicaciones WHERE nombre = 'TRAMITE';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_porcentaje_total(p_folio integer)
RETURNS numeric AS $$
DECLARE
  v_total numeric := 0;
BEGIN
  SELECT SUM(porccoprop) INTO v_total FROM receptcontrib WHERE folio = p_folio;
  RETURN v_total;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_encabeza(p_folio integer)
RETURNS boolean AS $$
DECLARE
  v_exists boolean := false;
BEGIN
  SELECT TRUE INTO v_exists FROM receptcontrib WHERE folio = p_folio AND encabeza = 'S' LIMIT 1;
  RETURN v_exists;
END;
$$ LANGUAGE plpgsql;