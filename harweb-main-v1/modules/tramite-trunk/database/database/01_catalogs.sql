CREATE OR REPLACE FUNCTION sp_get_propietarios(p_cvecuenta integer, p_cveregprop integer)
RETURNS TABLE(
    cvecont integer,
    nombre_completo text,
    encabeza text,
    porcentaje numeric,
    descripcion text
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.cvecont, c.nombre_completo, r.encabeza, r.porcentaje, cp.descripcion
    FROM contrib c
    JOIN regprop r ON c.cvecont = r.cvecont
    JOIN c_calidpro cp ON cp.cvereg = r.cvereg
    WHERE r.cvecuenta = p_cvecuenta AND r.cveregprop = p_cveregprop
    ORDER BY cp.cvereg;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_calidades()
RETURNS TABLE(
    cvereg integer,
    descripcion text
) AS $$
BEGIN
    RETURN QUERY SELECT cvereg, descripcion FROM c_calidpro ORDER BY cvereg;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_movimientos()
RETURNS TABLE(
    cvemov integer,
    abreviatura varchar(2),
    clavemovto varchar(30),
    feccap date,
    capturista varchar(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvemov, abreviatura, clavemovto, feccap, capturista
    FROM c_movcta
    ORDER BY clavemovto;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_departamentos()
RETURNS TABLE(
    cvedepto integer,
    cvedependencia integer,
    nombredepto varchar(30),
    telefono varchar(35),
    feccap date,
    capturista varchar(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvedepto, cvedependencia, nombredepto, telefono, feccap, capturista
    FROM deptos
    ORDER BY nombredepto;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION condueños_list(p_cvecuenta integer)
RETURNS TABLE(
  cvecont integer,
  nombre_completo text,
  rfc text,
  porcentaje numeric,
  encabeza char(1),
  vigencia char(1)
) AS $$
BEGIN
  RETURN QUERY
    SELECT r.cvecont, c.nombre_completo, c.rfc, r.porcentaje, r.encabeza, r.vigencia
    FROM regprop r
    JOIN contrib c ON c.cvecont = r.cvecont
    WHERE r.cvecuenta = p_cvecuenta AND r.vigencia <> 'E'
    ORDER BY r.encabeza DESC, r.porcentaje DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION condueños_show(p_cvecont integer)
RETURNS TABLE(
  cvecont integer,
  nombre_completo text,
  rfc text,
  porcentaje numeric,
  encabeza char(1),
  vigencia char(1),
  datos jsonb
) AS $$
BEGIN
  RETURN QUERY
    SELECT r.cvecont, c.nombre_completo, c.rfc, r.porcentaje, r.encabeza, r.vigencia,
           row_to_json(c.*)::jsonb
    FROM regprop r
    JOIN contrib c ON c.cvecont = r.cvecont
    WHERE r.cvecont = p_cvecont AND r.vigencia <> 'E';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION condueños_add_colonia(p_nombre text, p_cvepoblacion integer, p_codpos integer, p_usuario text)
RETURNS TABLE(cvecolonia integer) AS $$
DECLARE
  v_cvecolonia integer;
BEGIN
  INSERT INTO c_colonia (colonia, cvepoblacion, codpos, feccap, capturista)
    VALUES (p_nombre, p_cvepoblacion, p_codpos, now(), p_usuario)
    RETURNING cvecolonia INTO v_cvecolonia;
  RETURN QUERY SELECT v_cvecolonia;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION basephp.consulta_predial_get_cuenta(
    p_recaud INTEGER, p_urbrus VARCHAR, p_cuenta INTEGER
) RETURNS TABLE (
    cvecuenta INTEGER,
    cvecatnva VARCHAR,
    subpredio INTEGER,
    vigente VARCHAR,
    claveutm VARCHAR,
    cuenta INTEGER,
    recaud INTEGER,
    urbrus VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecuenta, c.cvecatnva, c.subpredio, c.vigente, c.claveutm, c.cuenta, c.recaud, c.urbrus
    FROM convcta c
    WHERE c.recaud = p_recaud AND c.urbrus = p_urbrus AND c.cuenta = p_cuenta AND c.vigente = 'V';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION basephp.consulta_predial_get_ubicacion(
    p_cvecuenta INTEGER
) RETURNS TABLE (
    calle VARCHAR,
    noexterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    vigencia VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT u.calle, u.noexterior, u.interior, u.colonia, u.vigencia
    FROM ubicacion u
    WHERE u.cvecuenta = p_cvecuenta AND u.vigencia = 'V'
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_cvecat_info(p_cvecuenta INTEGER)
RETURNS TABLE(
    convcta JSON,
    propietario JSON,
    ubicacion JSON
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        row_to_json(c1),
        row_to_json(p1),
        row_to_json(u1)
    FROM convcta c1
    LEFT JOIN uem2 p1 ON p1.cvectacat = c1.cvecuenta
    LEFT JOIN ubicacion u1 ON u1.cvecuenta = c1.cvecuenta
    WHERE c1.cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_ubicacion_by_cuenta(p_cvecuenta INTEGER)
RETURNS TABLE(
    cveubic INTEGER,
    cvecuenta INTEGER,
    cvecalle INTEGER,
    cvecolonia INTEGER,
    noexterior VARCHAR(6),
    interior VARCHAR(5),
    obsinter TEXT,
    vigente CHAR(1),
    feccap TIMESTAMP,
    capturista VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT cveubic, cvecuenta, cvecalle, cvecolonia, noexterior, interior, obsinter, vigente, feccap, capturista
    FROM ubicacion
    WHERE cvecuenta = p_cvecuenta AND vigente = 'V';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_calles()
RETURNS TABLE(
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig CHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY SELECT cvecalle, cvepoblacion, desvial, calle, cvevig, anterior, feccap, capturista FROM c_calles ORDER BY calle;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_colonias()
RETURNS TABLE(
    cvecolonia INTEGER,
    cvepoblacion INTEGER,
    colonia VARCHAR(40),
    codpos INTEGER,
    cvevig CHAR(1),
    feccap DATE,
    capturista VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY SELECT cvecolonia, cvepoblacion, colonia, codpos, cvevig, feccap, capturista FROM c_colonia ORDER BY colonia;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_construc_list(p_cvecatnva VARCHAR)
RETURNS TABLE (
  cvebloque SMALLINT,
  cveavaluo INTEGER,
  cveclasif INTEGER,
  estructura SMALLINT,
  axovig SMALLINT,
  axoconst SMALLINT,
  areaconst FLOAT,
  importe NUMERIC,
  factorajus FLOAT,
  vigente VARCHAR,
  cvecuenta INTEGER,
  numpisos SMALLINT,
  cvecatnva VARCHAR,
  subpredio SMALLINT
) AS $$
BEGIN
  RETURN QUERY
    SELECT cvebloque, cveavaluo, cveclasif, estructura, axovig, axoconst, areaconst, importe, factorajus, vigente, cvecuenta, numpisos, cvecatnva, subpredio
    FROM construc
    WHERE cvecatnva = p_cvecatnva AND subpredio = 0 AND vigente = 'V'
    ORDER BY cvebloque;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_construc_show(p_cvebloque INTEGER)
RETURNS TABLE (
  cvebloque SMALLINT,
  cveavaluo INTEGER,
  cveclasif INTEGER,
  estructura SMALLINT,
  axovig SMALLINT,
  axoconst SMALLINT,
  areaconst FLOAT,
  importe NUMERIC,
  factorajus FLOAT,
  vigente VARCHAR,
  cvecuenta INTEGER,
  numpisos SMALLINT,
  cvecatnva VARCHAR,
  subpredio SMALLINT
) AS $$
BEGIN
  RETURN QUERY
    SELECT cvebloque, cveavaluo, cveclasif, estructura, axovig, axoconst, areaconst, importe, factorajus, vigente, cvecuenta, numpisos, cvecatnva, subpredio
    FROM construc
    WHERE cvebloque = p_cvebloque;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_construc_get(p_id INT)
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
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION funcion_abstencion_get_abstenciones()
RETURNS TABLE(
    id serial,
    cvecuenta integer,
    anio integer,
    bimestre integer,
    observacion text,
    usuario varchar,
    fecha timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, cvecuenta, anio, bimestre, observacion, usuario, fecha
    FROM abstencion_movimientos
    ORDER BY fecha DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION funcion_abstencion_get_by_cuenta(p_cvecuenta integer)
RETURNS TABLE(
    id serial,
    cvecuenta integer,
    anio integer,
    bimestre integer,
    observacion text,
    usuario varchar,
    fecha timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, cvecuenta, anio, bimestre, observacion, usuario, fecha
    FROM abstencion_movimientos
    WHERE cvecuenta = p_cvecuenta
    ORDER BY fecha DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_loctp_municipios()
RETURNS TABLE(cvemunicipio integer, municipio varchar) AS $$
BEGIN
  RETURN QUERY SELECT cvemunicipio, municipio FROM c_mpios ORDER BY municipio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_muestradup_show(p_cvecuenta INTEGER)
RETURNS TABLE(
    cvecond INTEGER,
    cvecuenta INTEGER,
    recaud INTEGER,
    urbrus VARCHAR,
    cuenta INTEGER,
    subpredio INTEGER,
    estado VARCHAR,
    fecha TIMESTAMP,
    detalles JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecond, cvecuenta, recaud, urbrus, cuenta, subpredio, estado, fecha,
           to_jsonb(c) as detalles
    FROM cuentas_duplicadas c
    WHERE cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure to get user info
CREATE OR REPLACE FUNCTION sp_passwdfrm_get_user(p_usuario TEXT)
RETURNS TABLE(usuario TEXT, clave TEXT, nombres TEXT) AS $$
BEGIN
    RETURN QUERY SELECT usuario, clave, nombres FROM usuarios WHERE usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_tasas_validas(p_axoefec INTEGER)
RETURNS TABLE(
    tasaporcen NUMERIC,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT tasaporcen, descripcion
    FROM c_tasas
    WHERE axo = p_axoefec
    ORDER BY tasaporcen;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION psplash_get_splash_info()
RETURNS TABLE (
    image_url TEXT,
    version TEXT,
    copyright TEXT
) AS $$
BEGIN
    -- En un sistema real, estos valores podrían estar en una tabla de configuración
    RETURN QUERY SELECT
        '/assets/splash.jpg' AS image_url, -- Puede ser una ruta pública o base64
        '1.4.2.5' AS version,
        'TRAMITE © 2024' AS copyright;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_cuenta(p_cvecuenta INTEGER)
RETURNS TABLE(
    cvecuenta INTEGER,
    vigente VARCHAR,
    bimefec INTEGER,
    axoefec INTEGER,
    observacion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecuenta, c.vigente, ca.bimefec, ca.axoefec, ca.observacion
    FROM convcta c
    LEFT JOIN catastro ca ON ca.cvecuenta = c.cvecuenta
    WHERE c.cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_observacion(p_cvecuenta INTEGER)
RETURNS TEXT AS $$
DECLARE
    v_obs TEXT;
BEGIN
    SELECT observacion INTO v_obs FROM catastro WHERE cvecuenta = p_cvecuenta;
    RETURN v_obs;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_avaluos_externos(cvecuenta integer, axoefec integer)
RETURNS TABLE(cveavaext integer, supterr numeric, axofolio integer, folio integer, valava numeric, fecaprob date) AS $$
BEGIN
    RETURN QUERY
    SELECT cveavaext, supterr, axofolio, folio, valava, fecaprob
    FROM avaluos_externos
    WHERE cvecuenta = $1 AND axofolio >= $2;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_valoresref(cveavaext integer, axoefec integer, bimefec integer)
RETURNS TABLE(valor numeric) AS $$
BEGIN
    RETURN QUERY
    SELECT valor FROM valoresref WHERE cveavaext = $1 AND axoefec = $2 AND bimefec = $3;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_notarios()
RETURNS TABLE(idnotaria integer, nnotario text, nombre text, municipio text, cvemunicipio integer) AS $$
BEGIN
    RETURN QUERY SELECT idnotaria, nnotario, nombre, municipio, cvemunicipio FROM notarios;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_municipios()
RETURNS TABLE(cvemunicipio integer, municipio text) AS $$
BEGIN
    RETURN QUERY SELECT cvemunicipio, municipio FROM municipios;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_naturalezas_acto()
RETURNS TABLE(idacto integer, descripcion text) AS $$
BEGIN
    RETURN QUERY SELECT idacto, descripcion FROM c_natactos;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_tasas(p_axo integer)
RETURNS TABLE(tasaporcen numeric, axo integer) AS $$
BEGIN
  RETURN QUERY SELECT tasaporcen, axo FROM c_tasas WHERE axo = p_axo ORDER BY tasaporcen;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_valores_aux_list()
RETURNS TABLE (
    id SERIAL,
    axoefec INTEGER,
    bimefec INTEGER,
    valfiscal NUMERIC(18,2),
    tasa NUMERIC(10,4),
    axosobre INTEGER,
    ahasta INTEGER,
    bhasta INTEGER,
    observacion TEXT
) AS $$
BEGIN
    RETURN QUERY SELECT id, axoefec, bimefec, valfiscal, tasa, axosobre, ahasta, bhasta, observacion FROM valores_aux ORDER BY id DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_valores_aux_by_id(p_id INTEGER)
RETURNS TABLE (
    id INTEGER,
    axoefec INTEGER,
    bimefec INTEGER,
    valfiscal NUMERIC(18,2),
    tasa NUMERIC(10,4),
    axosobre INTEGER,
    ahasta INTEGER,
    bhasta INTEGER,
    observacion TEXT
) AS $$
BEGIN
    RETURN QUERY SELECT id, axoefec, bimefec, valfiscal, tasa, axosobre, ahasta, bhasta, observacion FROM valores_aux WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;