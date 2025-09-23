CREATE OR REPLACE FUNCTION sp_get_dependencias()
RETURNS TABLE (
    id_dependencia INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.id_dependencia, d.descripcion
    FROM c_dep_horario c
    INNER JOIN c_dependencias d ON c.id_dependencia = d.id_dependencia
    GROUP BY d.id_dependencia, d.descripcion
    ORDER BY d.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_dialetra(p_dia INTEGER)
RETURNS VARCHAR AS $$
DECLARE
    dias TEXT[] := ARRAY['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
BEGIN
    IF p_dia IS NULL OR p_dia < 0 OR p_dia > 6 THEN
        RETURN '';
    END IF;
    RETURN dias[p_dia+1];
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION buscar_anuncio(numero_anuncio TEXT)
RETURNS TABLE (
    id_anuncio INTEGER,
    id_licencia INTEGER,
    fecha_otorgamiento DATE,
    medidas1 TEXT,
    medidas2 TEXT,
    area_anuncio NUMERIC,
    ubicacion TEXT,
    numext_ubic TEXT,
    letraext_ubic TEXT,
    numint_ubic TEXT,
    letraint_ubic TEXT,
    bloqueado INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        id_anuncio,
        id_licencia,
        fecha_otorgamiento,
        medidas1,
        medidas2,
        area_anuncio,
        ubicacion,
        numext_ubic,
        letraext_ubic,
        numint_ubic,
        letraint_ubic,
        bloqueado
    FROM anuncios
    WHERE anuncio = numero_anuncio::INTEGER;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION consultar_bloqueos(id_anuncio INTEGER)
RETURNS TABLE (
    id_tramite INTEGER,
    id_licencia INTEGER,
    bloqueado SMALLINT,
    capturista TEXT,
    fecha_mov DATE,
    observa TEXT,
    estado TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        id_tramite,
        id_licencia,
        bloqueado,
        capturista,
        fecha_mov,
        observa,
        CASE WHEN bloqueado = 1 THEN 'BLOQUEADO' ELSE 'NO BLOQUEADO' END AS estado
    FROM bloqueo
    WHERE id_anuncio = consultar_bloqueos.id_anuncio
    ORDER BY fecha_mov DESC, id_tramite DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_tramite(p_id_tramite integer)
RETURNS TABLE (
    id_tramite integer,
    folio integer,
    tipo_tramite varchar,
    id_giro integer,
    x float,
    y float,
    zona smallint,
    subzona smallint,
    actividad varchar,
    cvecuenta integer,
    recaud smallint,
    licencia_ref integer,
    tramita_apoderado varchar,
    propietario varchar,
    primer_ap varchar,
    segundo_ap varchar,
    rfc varchar,
    curp varchar,
    domicilio varchar,
    numext_prop integer,
    numint_prop varchar,
    colonia_prop varchar,
    telefono_prop varchar,
    email varchar,
    cvecalle integer,
    ubicacion varchar,
    numext_ubic integer,
    letraext_ubic varchar,
    letraint_ubic varchar,
    colonia_ubic varchar,
    espubic varchar,
    documentos text,
    sup_construida float,
    sup_autorizada float,
    num_cajones smallint,
    num_empleados smallint,
    aforo smallint,
    inversion numeric,
    costo numeric,
    fecha_consejo date,
    id_fabricante integer,
    texto_anuncio varchar,
    medidas1 float,
    medidas2 float,
    area_anuncio float,
    num_caras smallint,
    calificacion numeric,
    usr_califica varchar,
    estatus varchar,
    id_licencia integer,
    id_anuncio integer,
    feccap date,
    capturista varchar,
    numint_ubic varchar,
    bloqueado smallint,
    dictamen smallint,
    observaciones text,
    rhorario varchar,
    cp integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM tramites WHERE id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_bloqueos(p_id_tramite integer)
RETURNS TABLE (
    id_tramite integer,
    id_licencia integer,
    bloqueado smallint,
    capturista varchar,
    fecha_mov date,
    observa varchar,
    estado varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.id_tramite,
        b.id_licencia,
        b.bloqueado,
        b.capturista,
        b.fecha_mov,
        b.observa,
        CASE WHEN b.bloqueado = 1 THEN 'BLOQUEADO' ELSE 'NO BLOQUEADO' END AS estado
    FROM bloqueo b
    WHERE b.id_tramite = p_id_tramite
    ORDER BY b.fecha_mov DESC, b.id_licencia DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_giro_descripcion(p_id_giro integer)
RETURNS TABLE (
    id_giro integer,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_giro, descripcion FROM c_giros WHERE id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_bloqueos_rfc()
RETURNS TABLE(
    rfc VARCHAR(13),
    id_tramite INTEGER,
    licencia INTEGER,
    hora TIMESTAMP,
    vig CHAR(1),
    observacion VARCHAR(255),
    capturista VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY SELECT rfc, id_tramite, licencia, hora, vig, observacion, capturista FROM bloqueo_rfc_lic ORDER BY rfc;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_search_bloqueos_rfc(p_rfc VARCHAR)
RETURNS TABLE(
    rfc VARCHAR(13),
    id_tramite INTEGER,
    licencia INTEGER,
    hora TIMESTAMP,
    vig CHAR(1),
    observacion VARCHAR(255),
    capturista VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY SELECT rfc, id_tramite, licencia, hora, vig, observacion, capturista FROM bloqueo_rfc_lic WHERE rfc ILIKE '%' || p_rfc || '%' ORDER BY rfc;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_tramite_info(p_id_tramite INTEGER)
RETURNS TABLE(
    id_tramite INTEGER,
    id_licencia INTEGER,
    rfc VARCHAR(13),
    actividad VARCHAR(130),
    propietarionvo VARCHAR(242)
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id_tramite, t.id_licencia, t.rfc, t.actividad,
      trim(trim(coalesce(t.primer_ap, '')) || ' ' || trim(coalesce(t.segundo_ap, '')) || ' ' || trim(t.propietario)) as propietarionvo
    FROM lic_autoev a
    JOIN tramites t ON t.id_tramite = a.id_tramite
    WHERE a.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_buscagiro_list(
    p_descripcion TEXT,
    p_tipo CHAR(1),
    p_autoev CHAR(1),
    p_pacto CHAR(1),
    p_usuario TEXT,
    p_year INT
)
RETURNS TABLE (
    id_giro INT,
    descripcion TEXT,
    costo NUMERIC,
    caracteristicas TEXT,
    clasificacion TEXT,
    vigente CHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_giro, a.descripcion, b.costo, a.caracteristicas, a.clasificacion, a.vigente
    FROM c_giros a
    LEFT JOIN c_valoreslic b ON a.id_giro = b.id_giro AND b.axo = p_year
    WHERE a.tipo = p_tipo
      AND a.id_giro > 500
      AND a.vigente = 'V'
      AND (
        p_descripcion IS NULL OR p_descripcion = '' OR
        UPPER(a.descripcion) LIKE '%' || UPPER(p_descripcion) || '%'
      )
      AND (
        (p_autoev = 'S' AND a.id_giro IN (SELECT id_giro FROM c_girosautoev)) OR
        (p_autoev = 'N')
      )
      AND (
        (p_pacto = 'S' AND a.clasificacion IN ('B')) OR
        (p_pacto = 'N')
      )
      AND (
        a.id_giro NOT BETWEEN 5000 AND 99999
      )
      AND (
        (
          SELECT giro_a FROM lic_permisos WHERE usuario = p_usuario AND id_permiso_catalogo = 2
        ) = 'S' OR (a.clasificacion <> 'A' OR a.clasificacion IS NULL)
      )
    ORDER BY a.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_buscagiro_permisos(
    p_usuario TEXT,
    p_id_permiso_catalogo INT
)
RETURNS TABLE (
    id INT,
    usuario TEXT,
    giro_a CHAR(1),
    giro_b CHAR(1),
    giro_c CHAR(1),
    giro_d CHAR(1),
    id_permiso_catalogo INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, usuario, giro_a, giro_b, giro_c, giro_d, id_permiso_catalogo
    FROM lic_permisos
    WHERE usuario = p_usuario AND id_permiso_catalogo = p_id_permiso_catalogo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION buscar_actividades(
    p_scian INTEGER,
    p_descripcion TEXT DEFAULT ''
)
RETURNS TABLE (
    id_giro INTEGER,
    cod_giro INTEGER,
    descripcion TEXT,
    vigente CHAR(1),
    axo INTEGER,
    costo NUMERIC,
    refrendo NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT cg.id_giro, cg.cod_giro, cg.descripcion, cg.vigente,
           cvl.axo, cvl.costo, cvl.refrendo
    FROM c_giros cg
    LEFT JOIN c_valoreslic cvl ON cvl.id_giro = cg.id_giro AND cvl.axo = EXTRACT(YEAR FROM CURRENT_DATE)
    WHERE cg.id_giro >= 5000
      AND cg.vigente = 'V'
      AND cg.id_giro <> cg.cod_giro
      AND cg.cod_giro = p_scian
      AND (
        p_descripcion IS NULL OR p_descripcion = '' OR
        cg.descripcion ILIKE '%' || p_descripcion || '%'
      )
    ORDER BY cg.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION buscar_actividad_por_id(
    p_id_giro INTEGER
)
RETURNS TABLE (
    id_giro INTEGER,
    cod_giro INTEGER,
    descripcion TEXT,
    vigente CHAR(1),
    axo INTEGER,
    costo NUMERIC,
    refrendo NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT cg.id_giro, cg.cod_giro, cg.descripcion, cg.vigente,
           cvl.axo, cvl.costo, cvl.refrendo
    FROM c_giros cg
    LEFT JOIN c_valoreslic cvl ON cvl.id_giro = cg.id_giro AND cvl.axo = EXTRACT(YEAR FROM CURRENT_DATE)
    WHERE cg.id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION catalogo_scian_busqueda(p_descripcion TEXT)
RETURNS TABLE (
    codigo_scian INTEGER,
    descripcion VARCHAR(200),
    vigente CHAR(1),
    es_microgenerador CHAR(1),
    microgenerador_a CHAR(1),
    microgenerador_b CHAR(1),
    microgenerador_c CHAR(1),
    microgenerador_d CHAR(1),
    fecha_alta TIMESTAMP,
    usuario_alta VARCHAR,
    fecha_baja TIMESTAMP,
    usuario_baja VARCHAR,
    tipo CHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        codigo_scian,
        descripcion,
        vigente,
        es_microgenerador,
        microgenerador_a,
        microgenerador_b,
        microgenerador_c,
        microgenerador_d,
        fecha_alta,
        usuario_alta,
        fecha_baja,
        usuario_baja,
        tipo
    FROM c_scian
    WHERE vigente = 'V'
      AND (
        p_descripcion IS NULL OR p_descripcion = ''
        OR (
          UPPER(descripcion) LIKE '%' || UPPER(p_descripcion) || '%'
          OR CAST(codigo_scian AS VARCHAR) LIKE '%' || p_descripcion || '%'
        )
      )
    ORDER BY descripcion ASC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_tramite_by_id(p_id_tramite INTEGER)
RETURNS TABLE (
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR(2),
    x FLOAT,
    y FLOAT,
    zona SMALLINT,
    subzona SMALLINT,
    actividad VARCHAR(130),
    cvecuenta INTEGER,
    recaud SMALLINT,
    licencia_ref INTEGER,
    tramita_apoderado VARCHAR(100),
    rfc VARCHAR(13),
    curp VARCHAR(18),
    domicilio VARCHAR(50),
    numext_prop INTEGER,
    numint_prop VARCHAR(5),
    colonia_prop VARCHAR(25),
    telefono_prop VARCHAR(30),
    email VARCHAR(50),
    cvecalle INTEGER,
    ubicacion VARCHAR(50),
    numext_ubic INTEGER,
    letraext_ubic VARCHAR(3),
    letraint_ubic VARCHAR(3),
    colonia_ubic VARCHAR(25),
    espubic VARCHAR(60),
    documentos TEXT,
    sup_construida FLOAT,
    sup_autorizada FLOAT,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC,
    costo NUMERIC,
    fecha_consejo DATE,
    id_fabricante INTEGER,
    texto_anuncio VARCHAR(50),
    medidas1 FLOAT,
    medidas2 FLOAT,
    area_anuncio FLOAT,
    num_caras SMALLINT,
    calificacion NUMERIC,
    usr_califica VARCHAR(10),
    estatus VARCHAR(1),
    id_licencia INTEGER,
    id_anuncio INTEGER,
    feccap DATE,
    capturista VARCHAR(10),
    numint_ubic VARCHAR(5),
    bloqueado SMALLINT,
    dictamen SMALLINT,
    observaciones TEXT,
    rhorario VARCHAR(50),
    cp INTEGER,
    id_giro INTEGER,
    propietario VARCHAR(80),
    primer_ap VARCHAR(80),
    segundo_ap VARCHAR(80)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id_tramite, t.folio, t.tipo_tramite, t.x, t.y, t.zona, t.subzona, t.actividad, t.cvecuenta, t.recaud, t.licencia_ref,
        t.tramita_apoderado, t.rfc, t.curp, t.domicilio, t.numext_prop, t.numint_prop, t.colonia_prop, t.telefono_prop, t.email,
        t.cvecalle, t.ubicacion, t.numext_ubic, t.letraext_ubic, t.letraint_ubic, t.colonia_ubic, t.espubic, t.documentos,
        t.sup_construida, t.sup_autorizada, t.num_cajones, t.num_empleados, t.aforo, t.inversion, t.costo, t.fecha_consejo,
        t.id_fabricante, t.texto_anuncio, t.medidas1, t.medidas2, t.area_anuncio, t.num_caras, t.calificacion, t.usr_califica,
        t.estatus, t.id_licencia, t.id_anuncio, t.feccap, t.capturista, t.numint_ubic, t.bloqueado, t.dictamen, t.observaciones,
        t.rhorario, t.cp, t.id_giro, t.propietario, t.primer_ap, t.segundo_ap
    FROM tramites t
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_giro_by_id(p_id_giro INTEGER)
RETURNS TABLE (
    id_giro INTEGER,
    descripcion VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_giro, descripcion FROM c_giros WHERE id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_condominio(p_cvecatnva VARCHAR)
RETURNS TABLE(
    cvecond INTEGER,
    nombre VARCHAR,
    tipocond VARCHAR,
    numpred INTEGER,
    escritura INTEGER,
    idnotaria INTEGER,
    fecescrit DATE,
    cvecatnva VARCHAR,
    areacomun NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecond, nombre, tipocond, numpred, escritura, idnotaria, fecescrit, cvecatnva, areacomun
    FROM condominio
    WHERE cvecatnva = p_cvecatnva;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_cargadatos(p_cvecatnva TEXT)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT row_to_json(t)
  INTO result
  FROM (
    SELECT
      u.calle,
      u.noexterior,
      u.interior,
      u.colonia,
      c.nombre_completo,
      c.rfc,
      c.domicilio,
      r.poblacion,
      c.codpos,
      a.observacion,
      -- Otros campos relevantes
      ARRAY(
        SELECT json_build_object('uso', us.uso, 'descripcion', us.descripcion)
        FROM usos_suelo us WHERE us.cvecatnva = p_cvecatnva
      ) AS usos
    FROM ubicacion u
    JOIN contribuyente c ON c.cvecatnva = u.cvecatnva
    JOIN regprop r ON r.cvecatnva = u.cvecatnva
    LEFT JOIN avaluos a ON a.cvecatnva = u.cvecatnva
    WHERE u.cvecatnva = p_cvecatnva
    LIMIT 1
  ) t;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_avaluos(p_cvecatnva TEXT, p_subpredio INT)
RETURNS TABLE(
  cveavaluo INT,
  supterr NUMERIC,
  supconst NUMERIC,
  valorterr NUMERIC,
  valorconst NUMERIC,
  valfiscal NUMERIC,
  feccap DATE
) AS $$
BEGIN
  RETURN QUERY
  SELECT cveavaluo, supterr, supconst, valorterr, valorconst, valfiscal, feccap
  FROM avaluos
  WHERE cvecatnva = p_cvecatnva AND (subpredio = p_subpredio OR p_subpredio = 0)
  ORDER BY feccap DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_construcciones(p_cveavaluo INT)
RETURNS TABLE(
  cvebloque INT,
  cveclasif INT,
  descripcion TEXT,
  areaconst NUMERIC,
  importe NUMERIC,
  numpisos INT,
  estructura TEXT,
  factorajus NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.cvebloque, a.cveclasif, b.descripcion, a.areaconst, a.importe, a.numpisos, a.estructura, a.factorajus
  FROM construc a
  LEFT JOIN c_bloqcon b ON b.axovig = a.axovig AND b.cveclasif = a.cveclasif
  WHERE a.cveavaluo = p_cveavaluo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_area_carto(p_cvecatnva TEXT)
RETURNS TABLE(supconst NUMERIC) AS $$
BEGIN
  RETURN QUERY
  SELECT SUM(areaconst) AS supconst
  FROM construc_carto
  WHERE cvecatnva = p_cvecatnva AND vigente = 'V';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_document_types()
RETURNS TABLE(id integer, documento varchar) AS $$
BEGIN
  RETURN QUERY SELECT id, documento FROM c_doctos ORDER BY documento;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_cuenta_by_cvecuenta(p_cvecuenta INTEGER)
RETURNS TABLE (
    cvecuenta INTEGER,
    cvemunicipio SMALLINT,
    recaud SMALLINT,
    urbrus VARCHAR(1),
    cuenta INTEGER,
    digver SMALLINT,
    zonaanter SMALLINT,
    manzanter SMALLINT,
    loteanter SMALLINT,
    cvecatnva VARCHAR(11),
    subpredio SMALLINT,
    crec SMALLINT,
    cur VARCHAR(1),
    ccta INTEGER,
    cip VARCHAR(9),
    vigente VARCHAR(1),
    cvelocalidad SMALLINT,
    coordenada_x DOUBLE PRECISION,
    coordenada_y DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY SELECT cvecuenta, cvemunicipio, recaud, urbrus, cuenta, digver, zonaanter, manzanter, loteanter, cvecatnva, subpredio, crec, cur, ccta, cip, vigente, cvelocalidad, coordenada_x, coordenada_y
    FROM convcta WHERE cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION catalogo_actividades_list(descripcion TEXT DEFAULT NULL)
RETURNS TABLE (
  id_actividad INTEGER,
  id_giro INTEGER,
  descripcion TEXT,
  observaciones TEXT,
  vigente CHAR(1),
  fecha_alta TIMESTAMP,
  usuario_alta VARCHAR(50),
  fecha_baja TIMESTAMP,
  usuario_baja VARCHAR(50),
  motivo_baja TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT id_actividad, id_giro, descripcion, observaciones, vigente, fecha_alta, usuario_alta, fecha_baja, usuario_baja, motivo_baja
    FROM c_actividades_lic
    WHERE (descripcion IS NULL OR unaccent(lower(descripcion)) ILIKE '%' || unaccent(lower($1)) || '%')
    ORDER BY id_actividad DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION catalogo_actividades_get(id INTEGER)
RETURNS TABLE (
  id_actividad INTEGER,
  id_giro INTEGER,
  descripcion TEXT,
  observaciones TEXT,
  vigente CHAR(1),
  fecha_alta TIMESTAMP,
  usuario_alta VARCHAR(50),
  fecha_baja TIMESTAMP,
  usuario_baja VARCHAR(50),
  motivo_baja TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT id_actividad, id_giro, descripcion, observaciones, vigente, fecha_alta, usuario_alta, fecha_baja, usuario_baja, motivo_baja
    FROM c_actividades_lic
    WHERE id_actividad = $1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION catalogo_giros_list()
RETURNS TABLE (
  id_giro INTEGER,
  descripcion TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT id_giro, descripcion FROM c_giros WHERE vigente = 'V' AND id_giro > 500 ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cat_requisitos_list()
RETURNS TABLE(req integer, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT req, descripcion FROM c_girosreq ORDER BY req;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cat_requisitos_search(p_descripcion varchar)
RETURNS TABLE(req integer, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT req, descripcion FROM c_girosreq WHERE descripcion ILIKE '%' || p_descripcion || '%' ORDER BY req;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_lic_400(p_licencia INTEGER)
RETURNS TABLE (
    ofna TEXT,
    numlic INTEGER,
    inirfc TEXT,
    fnarfc TEXT,
    homono TEXT,
    dighom TEXT,
    codgir TEXT,
    ilgir1 TEXT,
    ilgir2 TEXT,
    ilgir3 TEXT,
    nocars TEXT,
    nugrub TEXT,
    nuext TEXT,
    letext TEXT,
    numint TEXT,
    letint TEXT,
    piso TEXT,
    letsec TEXT,
    numzon TEXT,
    zonpos TEXT,
    fecalt DATE,
    fecbaj DATE,
    nomcal TEXT,
    tomesu TEXT,
    numanu TEXT,
    nuayt TEXT,
    reint TEXT,
    reclt TEXT,
    imlit NUMERIC,
    liimt NUMERIC,
    vigenc TEXT,
    actgrl TEXT,
    grabo TEXT,
    resta TEXT,
    fut1 TEXT,
    fut2 TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ofna, numlic, inirfc, fnarfc, homono, dighom, codgir, ilgir1, ilgir2, ilgir3, nocars, nugrub, nuext, letext, numint, letint, piso, letsec, numzon, zonpos, fecalt, fecbaj, nomcal, tomesu, numanu, nuayt, reint, reclt, imlit, liimt, vigenc, actgrl, grabo, resta, fut1, fut2
    FROM lic_400
    WHERE numlic = p_licencia;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_pago_lic_400(p_numlic INTEGER)
RETURNS SETOF pago_lic_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM pago_lic_400 WHERE numlic = p_numlic;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_dependencias()
RETURNS TABLE (
    id_dependencia integer,
    descripcion varchar,
    clave varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_dependencia, descripcion, clave
    FROM c_dependencias
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_deptos_by_dependencia(p_id_dependencia integer)
RETURNS TABLE (
    cvedepto integer,
    nombredepto varchar,
    telefono varchar,
    cvedependencia integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvedepto, nombredepto, telefono, cvedependencia
    FROM deptos
    WHERE cvedependencia = p_id_dependencia
    ORDER BY nombredepto;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cruces_search_calle1(search_text TEXT)
RETURNS TABLE (
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
    RETURN QUERY
    SELECT cvecalle, cvepoblacion, desvial, calle, cvevig, anterior, feccap, capturista
    FROM c_calles
    WHERE UPPER(calle) LIKE '%' || UPPER(search_text) || '%'
      AND cvecalle NOT IN (
        SELECT cvecalle FROM c_calles_escondidas WHERE vigente = 'V' AND num_tag = 8000
      );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cruces_search_calle2(search_text TEXT)
RETURNS TABLE (
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
    RETURN QUERY
    SELECT cvecalle, cvepoblacion, desvial, calle, cvevig, anterior, feccap, capturista
    FROM c_calles
    WHERE UPPER(calle) LIKE '%' || UPPER(search_text) || '%'
      AND cvecalle NOT IN (
        SELECT cvecalle FROM c_calles_escondidas WHERE vigente = 'V' AND num_tag = 8000
      );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_dependencias()
RETURNS TABLE(id_dependencia INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_dependencia, descripcion
    FROM c_dependencias
    WHERE licencias = 1 AND vigente = 'V'
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dictamenusodesuelo_list()
RETURNS TABLE(
  axo INTEGER,
  folio INTEGER,
  id_licencia INTEGER,
  solicita VARCHAR,
  partidapago VARCHAR,
  observacion VARCHAR,
  domicilio VARCHAR,
  vigente VARCHAR,
  feccap DATE,
  capturista VARCHAR,
  licencia INTEGER,
  tipo INTEGER
) AS $$
BEGIN
  RETURN QUERY
    SELECT axo, folio, id_licencia, solicita, partidapago, observacion, domicilio, vigente, feccap, capturista, licencia, tipo
    FROM constancias
    ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dictamenusodesuelo_search(
  p_axo INTEGER DEFAULT NULL,
  p_folio INTEGER DEFAULT NULL,
  p_licencia INTEGER DEFAULT NULL,
  p_fecha_ini DATE DEFAULT NULL,
  p_fecha_fin DATE DEFAULT NULL
)
RETURNS TABLE(
  axo INTEGER,
  folio INTEGER,
  id_licencia INTEGER,
  solicita VARCHAR,
  partidapago VARCHAR,
  observacion VARCHAR,
  domicilio VARCHAR,
  vigente VARCHAR,
  feccap DATE,
  capturista VARCHAR,
  licencia INTEGER,
  tipo INTEGER
) AS $$
BEGIN
  RETURN QUERY
    SELECT axo, folio, id_licencia, solicita, partidapago, observacion, domicilio, vigente, feccap, capturista, licencia, tipo
    FROM constancias
    WHERE (p_axo IS NULL OR axo = p_axo)
      AND (p_folio IS NULL OR folio = p_folio)
      AND (p_licencia IS NULL OR id_licencia = p_licencia)
      AND (p_fecha_ini IS NULL OR feccap >= p_fecha_ini)
      AND (p_fecha_fin IS NULL OR feccap <= p_fecha_fin)
    ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_doctosfrm_catalog()
RETURNS TABLE(codigo text, descripcion text) AS $$
BEGIN
  RETURN QUERY VALUES
    ('fotofachada', 'Fotografías de la fachada'),
    ('recibopredial', 'Recibo de predial'),
    ('ident_titular', 'Identificación titular'),
    ('ident_dueno_finca', 'Identificación del dueño de la finca'),
    ('ident_r1', 'Identificación R1 (alta de Hacienda)'),
    ('contrato_arrend', 'Contrato de arrendamiento'),
    ('solic_lic_usosuelo', 'Solicitud de licencia y uso de suelo'),
    ('solic_mod_padron', 'Solicitud de modificación al padrón y uso de suelo'),
    ('licencia_vigente', 'Licencia original vigente'),
    ('carta_policia', 'Carta de policía'),
    ('carta_poder', 'Carta de poder simple'),
    ('memoria_calculo', 'Memoria de cálculo'),
    ('poliza_responsabilidad', 'Póliza vigente de responsabilidad civil del anuncio'),
    ('acta_constitutiva', 'Acta constitutiva'),
    ('poder_notarial', 'Poder notarial'),
    ('asignacion_numeros', 'Asignación de números'),
    ('copia_licencia', 'Copia de licencia'),
    ('solic_lic_anuncio', 'Solicitud de licencia y anuncio'),
    ('solic_dictamen_anuncio', 'Solicitud de dictamen de anuncio');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fechasegfrm_list()
RETURNS TABLE(id INTEGER, fecha DATE, oficio VARCHAR, created_at TIMESTAMP) AS $$
BEGIN
    RETURN QUERY
    SELECT id, fecha, oficio, created_at
    FROM fechasegfrm
    ORDER BY created_at DESC
    LIMIT 20;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_buscar_calles(filtro TEXT)
RETURNS TABLE (
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig VARCHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecalle, cvepoblacion, desvial, calle, cvevig, anterior, feccap, capturista
    FROM c_calles
    WHERE calle ILIKE '%' || filtro || '%'
      AND cvecalle NOT IN (
        SELECT cvecalle FROM c_calles_escondidas WHERE vigente = 'V' AND num_tag = 8000
      );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listar_calles()
RETURNS TABLE (
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig VARCHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecalle, cvepoblacion, desvial, calle, cvevig, anterior, feccap, capturista
    FROM c_calles
    WHERE cvecalle NOT IN (
        SELECT cvecalle FROM c_calles_escondidas WHERE vigente = 'V' AND num_tag = 8000
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_buscar_colonias(p_c_mnpio integer, p_filtro text)
RETURNS TABLE (
    colonia text,
    d_codigopostal integer,
    d_tipo_asenta text
) AS $$
BEGIN
    RETURN QUERY
    SELECT colonia, d_codigopostal, d_tipo_asenta
    FROM cp_correos
    WHERE c_mnpio = p_c_mnpio
      AND (
        p_filtro IS NULL OR trim(p_filtro) = '' OR
        UPPER(colonia) LIKE '%' || UPPER(p_filtro) || '%'
      )
    ORDER BY colonia;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_obtener_colonia_seleccionada(p_c_mnpio integer, p_colonia text)
RETURNS TABLE (
    colonia text,
    d_codigopostal integer,
    d_tipo_asenta text
) AS $$
BEGIN
    RETURN QUERY
    SELECT colonia, d_codigopostal, d_tipo_asenta
    FROM cp_correos
    WHERE c_mnpio = p_c_mnpio
      AND colonia = p_colonia
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_licencias_reglamentadas()
RETURNS TABLE(
    id INTEGER,
    nombre VARCHAR,
    descripcion TEXT,
    usuario_id INTEGER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY SELECT id, nombre, descripcion, usuario_id, created_at, updated_at FROM licencias_reglamentadas ORDER BY id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_calles(filter TEXT DEFAULT '')
RETURNS TABLE (cvecalle INTEGER, calle TEXT) AS $$
BEGIN
    IF filter IS NULL OR trim(filter) = '' THEN
        RETURN QUERY SELECT cvecalle, calle FROM c_calles ORDER BY calle;
    ELSE
        RETURN QUERY SELECT cvecalle, calle FROM c_calles WHERE calle ILIKE filter || '%' ORDER BY calle;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_calle_by_ids(ids_csv TEXT)
RETURNS TABLE (cvecalle INTEGER, calle TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecalle, calle
    FROM c_calles
    WHERE cvecalle = ANY (string_to_array(ids_csv, ',')::int[]);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_grs_dlg_search(
    p_table text,
    p_field text,
    p_value text,
    p_case_insensitive boolean DEFAULT true,
    p_partial boolean DEFAULT true
)
RETURNS SETOF RECORD AS $$
DECLARE
    sql text;
    ref refcursor;
    q_value text;
BEGIN
    IF p_partial THEN
        q_value := '%' || p_value || '%';
    ELSE
        q_value := p_value;
    END IF;

    IF p_case_insensitive THEN
        sql := format('SELECT * FROM %I WHERE %I ILIKE $1', p_table, p_field);
    ELSE
        sql := format('SELECT * FROM %I WHERE %I LIKE $1', p_table, p_field);
    END IF;

    OPEN ref FOR EXECUTE sql USING q_value;
    RETURN QUERY FETCH ALL FROM ref;
    CLOSE ref;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION anuncios_grupos_list(p_descripcion TEXT DEFAULT NULL)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
    SELECT id, descripcion
    FROM anuncios_grupos
    WHERE (p_descripcion IS NULL OR descripcion ILIKE '%' || p_descripcion || '%')
    ORDER BY descripcion;
END;
$$;

CREATE OR REPLACE FUNCTION anuncios_grupos_get(p_id INTEGER)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
    SELECT id, descripcion
    FROM anuncios_grupos
    WHERE id = p_id;
END;
$$;

CREATE OR REPLACE FUNCTION sp_list_grupos_licencias(p_descripcion TEXT DEFAULT '')
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT id, descripcion
    FROM lic_grupos
    WHERE (p_descripcion IS NULL OR p_descripcion = '' OR descripcion ILIKE '%' || p_descripcion || '%')
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_grupo_licencia(p_id INTEGER)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT id, descripcion
    FROM lic_grupos
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_grupos_licencias(p_descripcion TEXT DEFAULT NULL)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT id, descripcion
    FROM lic_grupos
    WHERE p_descripcion IS NULL OR descripcion ILIKE '%' || p_descripcion || '%'
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_licencias_disponibles(p_grupo_id INTEGER, p_actividad TEXT DEFAULT NULL, p_id_giro INTEGER DEFAULT NULL)
RETURNS TABLE(
  licencia INTEGER,
  propietario TEXT,
  actividad TEXT,
  fecha_otorgamiento DATE,
  ubicacion TEXT,
  numext_ubic INTEGER,
  letraext_ubic TEXT,
  numint_ubic TEXT,
  letraint_ubic TEXT,
  colonia_ubic TEXT,
  bloqueado SMALLINT,
  vigente TEXT,
  id_licencia INTEGER,
  propietarionvo TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT l.licencia, l.propietario, l.actividad, l.fecha_otorgamiento, l.ubicacion, l.numext_ubic, l.letraext_ubic, l.numint_ubic, l.letraint_ubic, l.colonia_ubic, l.bloqueado, l.vigente, l.id_licencia,
      TRIM(COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, '')) AS propietarionvo
    FROM licencias l
    WHERE l.licencia NOT IN (SELECT licencia FROM lic_detgrupo WHERE lic_grupos_id = p_grupo_id)
      AND l.vigente = 'V'
      AND (p_actividad IS NULL OR l.actividad ILIKE '%' || p_actividad || '%' OR TRIM(COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, '')) ILIKE '%' || p_actividad || '%')
      AND (p_id_giro IS NULL OR l.id_giro = p_id_giro)
    ORDER BY l.actividad;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_licencias_grupo(p_grupo_id INTEGER, p_actividad TEXT DEFAULT NULL)
RETURNS TABLE(
  licencia INTEGER,
  propietario TEXT,
  actividad TEXT,
  fecha_otorgamiento DATE,
  ubicacion TEXT,
  numext_ubic INTEGER,
  letraext_ubic TEXT,
  numint_ubic TEXT,
  letraint_ubic TEXT,
  colonia_ubic TEXT,
  bloqueado SMALLINT,
  vigente TEXT,
  id_licencia INTEGER,
  propietarionvo TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT l.licencia, l.propietario, l.actividad, l.fecha_otorgamiento, l.ubicacion, l.numext_ubic, l.letraext_ubic, l.numint_ubic, l.letraint_ubic, l.colonia_ubic, l.bloqueado, l.vigente, l.id_licencia,
      TRIM(COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, '')) AS propietarionvo
    FROM licencias l
    WHERE l.licencia IN (SELECT licencia FROM lic_detgrupo WHERE lic_grupos_id = p_grupo_id)
      AND l.vigente = 'V'
      AND (p_actividad IS NULL OR l.actividad ILIKE '%' || p_actividad || '%' OR TRIM(COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, '')) ILIKE '%' || p_actividad || '%')
    ORDER BY l.actividad;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_giros()
RETURNS TABLE(id_giro INTEGER, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_giro, descripcion FROM c_giros WHERE tipo = 'L' ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_h_bloqueo_dom_detalle(p_id INTEGER)
RETURNS TABLE (
    cvecuenta INTEGER,
    cvecalle INTEGER,
    calle VARCHAR,
    num_ext INTEGER,
    let_ext VARCHAR,
    num_int INTEGER,
    let_int VARCHAR,
    folio INTEGER,
    fecha DATE,
    hora TIMESTAMP,
    vig VARCHAR,
    observacion VARCHAR,
    capturista VARCHAR,
    fecha_mov TIMESTAMP,
    motivo_mov VARCHAR,
    tipo_mov VARCHAR,
    modifico VARCHAR
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM h_bloqueo_dom WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_tramite_info(p_tramite_id INTEGER)
RETURNS TABLE(
    id_tramite INTEGER,
    propietario TEXT,
    ubicacion TEXT,
    estatus TEXT,
    tipo_tramite TEXT,
    fecha TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id_tramite, t.propietario, t.ubicacion, t.estatus, t.tipo_tramite, t.feccap
    FROM tramites t
    WHERE t.id_tramite = p_tramite_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_licencia_recibo(p_licencia INTEGER)
RETURNS TABLE(
    licencia INTEGER,
    nombre TEXT,
    domicilio TEXT,
    id_licencia INTEGER,
    dom_completo TEXT,
    propietarionvo TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.licencia,
           (COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, '')) AS nombre,
           (l.ubicacion || ' ' || l.numext_ubic || '-' || COALESCE(l.letraext_ubic, '') || '-' || COALESCE(l.numint_ubic, '') || '-' || COALESCE(l.letraint_ubic, '')) AS domicilio,
           l.id_licencia,
           (l.ubicacion || ' ' || l.numext_ubic || '-' || COALESCE(l.letraext_ubic, '') || '-' || COALESCE(l.numint_ubic, '') || '-' || COALESCE(l.letraint_ubic, '')) AS dom_completo,
           (COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, '')) AS propietarionvo
    FROM licencias l
    WHERE l.licencia = p_licencia AND l.vigente = 'V';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_parametros_recibo()
RETURNS TABLE(
    costo_certific NUMERIC,
    costo_constancia NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT costo_certific, costo_constancia FROM parametros_lic LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_observaciones()
RETURNS TABLE(id BIGINT, observacion TEXT, created_at TIMESTAMP) AS $$
BEGIN
    RETURN QUERY
        SELECT id, observacion, created_at
        FROM observaciones
        ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_prepago_get_data(p_cvecuenta INTEGER)
RETURNS TABLE(
    ncompleto TEXT,
    calle TEXT,
    noexterior TEXT,
    interior TEXT,
    ultcomp INTEGER,
    axoultcomp SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.nombre_completo, c.calle, c.noexterior, c.interior, ca.ultcomp, ca.axoultcomp
    FROM catastro ca
    JOIN regprop rp ON rp.cvecuenta = ca.cvecuenta AND rp.cveregprop = ca.cveregprop AND rp.encabeza = 'S'
    JOIN contrib c ON c.cvecont = rp.cvecont
    WHERE ca.cvecuenta = p_cvecuenta
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_prepago_get_descuentos(
    p_cvecuenta INTEGER,
    p_asal INTEGER,
    p_bsal INTEGER,
    p_asalf INTEGER,
    p_bsalf INTEGER
) RETURNS TABLE(
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

CREATE OR REPLACE FUNCTION sp_prepago_get_ultimo_requerimiento(p_cvecuenta INTEGER)
RETURNS TABLE(
    cvereq INTEGER,
    cveejecut SMALLINT,
    folioreq INTEGER,
    axoreq SMALLINT,
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
    axoini SMALLINT,
    bimini SMALLINT,
    axofin SMALLINT,
    bimfin SMALLINT,
    secuencia SMALLINT,
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
    WHERE cvecuenta = p_cvecuenta AND vigencia = 'V' AND fecent IS NOT NULL
    ORDER BY axoreq DESC, folioreq DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_usuarios_privilegios(
    campo TEXT,
    filtro TEXT,
    offset_val INTEGER DEFAULT 0,
    limit_val INTEGER DEFAULT 20
)
RETURNS TABLE (
    usuario VARCHAR,
    nombres VARCHAR,
    baja DATE,
    nombredepto VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT usuario, nombres, baja, nombredepto FROM (
        SELECT a.usuario, u.nombres, u.fecbaj AS baja, d.nombredepto
        FROM c_programas p
        INNER JOIN aud_auto a ON a.num_tag = p.num_tag
        INNER JOIN usuarios u ON u.usuario = a.usuario
        LEFT JOIN deptos d ON d.cvedepto = u.cvedepto
        WHERE p.num_tag BETWEEN 8000 AND 8999
        GROUP BY 1,2,3,4
        UNION ALL
        SELECT a.usuario, u.nombres, u.fecbaj AS baja, d.nombredepto
        FROM c_programas p
        INNER JOIN autoriza a ON a.num_tag = p.num_tag
        INNER JOIN usuarios u ON u.usuario = a.usuario
        LEFT JOIN deptos d ON d.cvedepto = u.cvedepto
        WHERE p.num_tag BETWEEN 8000 AND 8999
        GROUP BY 1,2,3,4
    ) AS usuarios
    WHERE LOWER(usuario) LIKE '%' || LOWER(filtro) || '%' OR LOWER(nombres) LIKE '%' || LOWER(filtro) || '%'
    ORDER BY CASE WHEN campo = 'usuario' THEN usuario
                  WHEN campo = 'nombres' THEN nombres
                  WHEN campo = 'baja' THEN baja::text
                  WHEN campo = 'nombredepto' THEN nombredepto
                  ELSE usuario END
    OFFSET offset_val LIMIT limit_val;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_permisos_usuario(
    p_usuario VARCHAR
)
RETURNS TABLE (
    num_tag INTEGER,
    descripcion VARCHAR,
    seleccionado VARCHAR,
    grupo SMALLINT,
    feccap DATE,
    capturista VARCHAR,
    usuario VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.num_tag, p.descripcion, p.seleccionado, p.grupo, p.feccap, p.capturista, a.usuario
    FROM c_programas p
    INNER JOIN autoriza a ON a.num_tag = p.num_tag AND a.usuario = p_usuario
    WHERE p.num_tag BETWEEN 8000 AND 8999;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_deptos()
RETURNS TABLE (
    cvedepto INTEGER,
    nombredepto VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.cvedepto, d.nombredepto
    FROM c_programas p
    INNER JOIN autoriza a ON a.num_tag = p.num_tag
    INNER JOIN usuarios u ON u.usuario = a.usuario
    LEFT JOIN deptos d ON d.cvedepto = u.cvedepto
    WHERE p.num_tag BETWEEN 8000 AND 8999
    GROUP BY 1,2
    ORDER BY 2;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_contribholog_list()
RETURNS TABLE (
    idcontrib integer,
    nombre varchar,
    domicilio varchar,
    colonia varchar,
    telefono varchar,
    rfc varchar,
    curp varchar,
    email varchar,
    feccap timestamp,
    capturista varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT idcontrib, nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista
    FROM c_contribholog
    ORDER BY nombre;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_contribholog_by_id(p_idcontrib integer)
RETURNS TABLE (
    idcontrib integer,
    nombre varchar,
    domicilio varchar,
    colonia varchar,
    telefono varchar,
    rfc varchar,
    curp varchar,
    email varchar,
    feccap timestamp,
    capturista varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT idcontrib, nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista
    FROM c_contribholog
    WHERE idcontrib = p_idcontrib;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION propuestatab_regimen(p_cvecuenta INTEGER)
RETURNS TABLE(
  cvereg INTEGER,
  encabeza VARCHAR,
  porcentaje NUMERIC,
  descripcion VARCHAR,
  exento VARCHAR,
  ncompleto VARCHAR,
  rfc VARCHAR,
  calle VARCHAR,
  noexterior VARCHAR,
  interior VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT r.cvereg, r.encabeza, r.porcentaje, r.descripcion, r.exento,
         r.ncompleto, r.rfc, r.calle, r.noexterior, r.interior
  FROM regimen_propiedad r
  WHERE r.cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION propuestatab_obs400(p_recaud INTEGER, p_urbrus VARCHAR, p_cuenta INTEGER)
RETURNS TABLE(
  acomp INTEGER,
  observa VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT o.acomp, o.observa
  FROM observ_400 o
  WHERE o.recaud = p_recaud AND o.urbrus = p_urbrus AND o.cuenta = p_cuenta;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION propuestatab_condominio(p_cvecatnva VARCHAR)
RETURNS TABLE(
  nombre VARCHAR,
  tipocond VARCHAR,
  numpred INTEGER,
  escritura INTEGER,
  fecescrit DATE,
  areacomun NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT c.nombre, c.tipocond, c.numpred, c.escritura, c.fecescrit, c.areacomun
  FROM condominio c
  WHERE c.cvecatnva = p_cvecatnva;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION psplash_get_version()
RETURNS TABLE(version TEXT, app_name TEXT, copyright TEXT, company TEXT) AS $$
BEGIN
  -- Estos valores pueden ser parametrizables o leídos de una tabla de configuración
  version := '1.0.0.0';
  app_name := 'LICENCIAS';
  copyright := '© 2024 Municipio';
  company := 'Ayuntamiento de Ejemplo';
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION psplash_get_splash_data()
RETURNS TABLE(message TEXT, label_effect TEXT, image_base64 TEXT) AS $$
BEGIN
  message := 'Cargando Aplicación';
  label_effect := 'Padrón y Licencias';
  -- Imagen base64: aquí se puede almacenar en una tabla o archivo, para ejemplo se deja NULL
  image_base64 := NULL; -- O cargar desde tabla/configuración
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_tramite(p_id_tramite integer)
RETURNS TABLE (
    id_tramite integer,
    folio integer,
    tipo_tramite varchar,
    id_giro integer,
    x float,
    y float,
    zona smallint,
    subzona smallint,
    actividad varchar,
    cvecuenta integer,
    recaud smallint,
    licencia_ref integer,
    tramita_apoderado varchar,
    propietario varchar,
    primer_ap varchar,
    segundo_ap varchar,
    rfc varchar,
    curp varchar,
    domicilio varchar,
    numext_prop integer,
    numint_prop varchar,
    colonia_prop varchar,
    telefono_prop varchar,
    email varchar,
    cvecalle integer,
    ubicacion varchar,
    numext_ubic integer,
    letraext_ubic varchar,
    letrain_ubic varchar,
    colonia_ubic varchar,
    espubic varchar,
    documentos text,
    sup_construida float,
    sup_autorizada float,
    num_cajones smallint,
    num_empleados smallint,
    aforo smallint,
    inversion numeric,
    costo numeric,
    fecha_consejo date,
    id_fabricante integer,
    texto_anuncio varchar,
    medidas1 float,
    medidas2 float,
    area_anuncio float,
    num_caras smallint,
    calificacion numeric,
    usr_califica varchar,
    estatus varchar,
    id_licencia integer,
    id_anuncio integer,
    feccap date,
    capturista varchar,
    numint_ubic varchar,
    bloqueado smallint,
    dictamen smallint,
    observaciones text,
    rhorario varchar,
    cp integer,
    descripcion_giro varchar,
    propietarionvo varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.*, g.descripcion as descripcion_giro,
           trim(t.primer_ap) || ' ' || trim(t.segundo_ap) || ' ' || trim(t.propietario) as propietarionvo
    FROM tramites t
    LEFT JOIN c_giros g ON t.id_giro = g.id_giro
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_repdoc_get_giros(p_tipo TEXT)
RETURNS TABLE(id_giro INTEGER, descripcion TEXT, clasificacion TEXT, tipo TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT id_giro, descripcion, clasificacion, tipo
    FROM c_giros
    WHERE tipo = p_tipo AND vigente = 'V'
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_repdoc_get_giro_by_id(p_id_giro INTEGER)
RETURNS TABLE(id_giro INTEGER, descripcion TEXT, clasificacion TEXT, tipo TEXT, caracteristicas TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT id_giro, descripcion, clasificacion, tipo, caracteristicas
    FROM c_giros
    WHERE id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION buscar_licencia_responsiva(p_licencia INTEGER)
RETURNS TABLE (
    id_licencia INTEGER,
    licencia INTEGER,
    recaud INTEGER,
    descripcion TEXT,
    actividad TEXT,
    propietarionvo TEXT,
    ubicacion TEXT,
    numext_ubic TEXT,
    letraext_ubic TEXT,
    numint_ubic TEXT,
    letraint_ubic TEXT,
    colonia_ubic TEXT,
    cp TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia, l.recaud, g.descripcion, l.actividad,
           trim(coalesce(l.primer_ap,'') || ' ' || coalesce(l.segundo_ap,'') || ' ' || coalesce(l.propietario,'')) as propietarionvo,
           l.ubicacion, l.numext_ubic, l.letraext_ubic, l.numint_ubic, l.letraint_ubic, l.colonia_ubic, l.cp
    FROM licencias l
    LEFT JOIN c_giros g ON g.id_giro = l.id_giro
    WHERE l.licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION listar_responsivas(p_tipo TEXT)
RETURNS TABLE (
    axo INTEGER,
    folio INTEGER,
    id_licencia INTEGER,
    tipo TEXT,
    observacion TEXT,
    vigente TEXT,
    feccap DATE,
    capturista TEXT,
    licencia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.axo, r.folio, r.id_licencia, r.tipo, r.observacion, r.vigente, r.feccap, r.capturista, l.licencia
    FROM responsivas r
    JOIN licencias l ON l.id_licencia = r.id_licencia
    WHERE r.tipo = p_tipo
    ORDER BY r.axo DESC, r.folio DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION buscar_responsiva_folio(
    p_axo INTEGER,
    p_folio INTEGER,
    p_tipo TEXT
) RETURNS TABLE (
    axo INTEGER,
    folio INTEGER,
    id_licencia INTEGER,
    tipo TEXT,
    observacion TEXT,
    vigente TEXT,
    feccap DATE,
    capturista TEXT,
    licencia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.axo, r.folio, r.id_licencia, r.tipo, r.observacion, r.vigente, r.feccap, r.capturista, l.licencia
    FROM responsivas r
    JOIN licencias l ON l.id_licencia = r.id_licencia
    WHERE r.axo = p_axo AND r.folio = p_folio AND r.tipo = p_tipo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION buscar_responsiva_licencia(
    p_licencia INTEGER,
    p_tipo TEXT
) RETURNS TABLE (
    axo INTEGER,
    folio INTEGER,
    id_licencia INTEGER,
    tipo TEXT,
    observacion TEXT,
    vigente TEXT,
    feccap DATE,
    capturista TEXT,
    licencia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.axo, r.folio, r.id_licencia, r.tipo, r.observacion, r.vigente, r.feccap, r.capturista, l.licencia
    FROM responsivas r
    JOIN licencias l ON l.id_licencia = r.id_licencia
    WHERE l.licencia = p_licencia AND r.tipo = p_tipo
    ORDER BY r.axo DESC, r.folio DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_buscar_cuenta_catastral(p_recaud INTEGER, p_urbrus VARCHAR, p_cuenta INTEGER)
RETURNS TABLE(
    cvecuenta INTEGER,
    recaud INTEGER,
    urbrus VARCHAR,
    cuenta INTEGER,
    cvecatnva VARCHAR,
    subpredio INTEGER,
    claveutm VARCHAR,
    manzana VARCHAR,
    ctacat VARCHAR,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecuenta, recaud, urbrus, cuenta, cvecatnva, subpredio,
           (recaud || '-' || urbrus || '-' || cuenta) AS claveutm,
           (cip || subpredio) AS manzana,
           (cvecatnva || subpredio) AS ctacat,
           vigente
    FROM convcta
    WHERE recaud = p_recaud AND urbrus = p_urbrus AND cuenta = p_cuenta;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_consulta_licencia(p_licencia INTEGER)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT row_to_json(t) INTO v_result
    FROM (
        SELECT * FROM licencias WHERE licencia = p_licencia
    ) t;
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_consulta_anuncio(p_anuncio INTEGER)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT row_to_json(t) INTO v_result
    FROM (
        SELECT * FROM anuncios WHERE anuncio = p_anuncio
    ) t;
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_consulta_tramite(p_tramite INTEGER)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT row_to_json(t) INTO v_result
    FROM (
        SELECT * FROM tramites WHERE id_tramite = p_tramite
    ) t;
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_tipo_bloqueo_catalog()
RETURNS TABLE(id integer, descripcion varchar, sel_cons char(1))
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT id, descripcion, sel_cons
    FROM c_tipobloqueo
    WHERE sel_cons = 'S';
END;
$$;

CREATE OR REPLACE FUNCTION get_unidad_img()
RETURNS TABLE(unidad_img VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT valor FROM configuracion WHERE clave = 'UnidadImg' LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_zonaanuncio_catalogs()
RETURNS TABLE(tipo TEXT, id INTEGER, nombre TEXT, descripcion TEXT, cvezona INTEGER)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT 'zona', cvezona, zona, cvezona || ' - ' || zona, cvezona FROM c_zonas;
  RETURN QUERY SELECT 'subzona', cvesubzona, descsubzon, cvesubzona || ' - ' || descsubzon, cvezona FROM c_subzonas;
  RETURN QUERY SELECT 'recaudadora', recaud, descripcion, recaud || ' - ' || descripcion, NULL FROM c_recaud WHERE recaud <= 5;
END; $$;

CREATE OR REPLACE FUNCTION sp_get_zonas(p_recaud INTEGER)
RETURNS TABLE(cvezona SMALLINT, cvepoblacion INTEGER, zona VARCHAR, feccap DATE, capturista VARCHAR, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT z.cvezona, z.cvepoblacion, z.zona, z.feccap, z.capturista, z.cvezona || ' - ' || z.zona AS descripcion
  FROM c_zonas z
  WHERE z.cvezona IN (SELECT zona FROM c_zonayrec WHERE rec = p_recaud)
  ORDER BY z.cvezona;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_subzonas(p_cvezona INTEGER, p_recaud INTEGER)
RETURNS TABLE(cvezona INTEGER, cvesubzona INTEGER, descsubzon VARCHAR, feccap DATE, capturista VARCHAR, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT s.cvezona, s.cvesubzona, s.descsubzon, s.feccap, s.capturista, s.cvesubzona || ' - ' || s.descsubzon AS descripcion
  FROM c_subzonas s
  WHERE s.cvezona = p_cvezona
    AND s.cvesubzona IN (SELECT subzona FROM c_zonayrec WHERE rec = p_recaud AND zona = s.cvezona)
  ORDER BY s.cvesubzona;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(recaud SMALLINT, descripcion VARCHAR, mpio SMALLINT, recaudador VARCHAR, domicilio VARCHAR, feccap DATE, capturista VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT recaud, descripcion, mpio, recaudador, domicilio, feccap, capturista
  FROM c_recaud
  WHERE recaud <= 5;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_licencia(p_licencia INTEGER)
RETURNS TABLE(id_licencia INTEGER, licencia INTEGER, empresa INTEGER, recaud SMALLINT, id_giro INTEGER, x FLOAT, y FLOAT, zona SMALLINT, subzona SMALLINT, tipo_registro VARCHAR, actividad VARCHAR, cvecuenta INTEGER, fecha_otorgamiento DATE, propietario VARCHAR, rfc VARCHAR, curp VARCHAR, domicilio VARCHAR, numext_prop INTEGER, numint_prop VARCHAR, colonia_prop VARCHAR, telefono_prop VARCHAR, email VARCHAR, cvecalle INTEGER, ubicacion VARCHAR, numext_ubic INTEGER, letraext_ubic VARCHAR, numint_ubic VARCHAR, letrain_ubic VARCHAR, colonia_ubic VARCHAR, sup_construida FLOAT, sup_autorizada FLOAT, num_cajones SMALLINT, num_empleados SMALLINT, aforo SMALLINT, inversion NUMERIC, rhorario VARCHAR, fecha_consejo DATE, bloqueado SMALLINT, asiento SMALLINT, vigente VARCHAR, fecha_baja DATE, axo_baja INTEGER, folio_baja INTEGER, espubic VARCHAR, base_impuesto NUMERIC) AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM licencias WHERE licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_licencias_zona(p_licencia INTEGER)
RETURNS TABLE(licencia INTEGER, zona SMALLINT, subzona SMALLINT, recaud SMALLINT, feccap TIMESTAMP, capturista VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM licencias_zona WHERE licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;