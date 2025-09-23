CREATE OR REPLACE FUNCTION sp_get_apremios(par_modulo integer, par_control integer)
RETURNS TABLE (
    id_control integer,
    zona smallint,
    folio integer,
    diligencia char(1),
    importe_global numeric(15,2),
    importe_multa numeric(15,2),
    importe_recargo numeric(15,2),
    importe_gastos numeric(15,2),
    zona_apremio smallint,
    fecha_emision date,
    clave_practicado char(1),
    fecha_practicado date,
    hora_practicado time,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora time,
    ejecutor varchar(50),
    clave_secuestro smallint,
    clave_remate char(1),
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.zona, a.folio, a.diligencia,
           a.importe_global, a.importe_multa, a.importe_recargo, a.importe_gastos,
           a.zona_apremio, a.fecha_emision, a.clave_practicado, a.fecha_practicado, a.hora_practicado::time,
           a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora::time, b.usuario AS ejecutor,
           a.clave_secuestro, a.clave_remate, a.fecha_remate, a.porcentaje_multa, a.observaciones
    FROM ta_15_apremios a
    JOIN ta_12_passwords b ON b.id_usuario = a.ejecutor
    WHERE a.modulo = par_modulo
      AND a.control_otr = par_control
      AND a.vigencia = '1'
      AND a.clave_practicado = 'P';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_periodos_by_control(id_control integer)
RETURNS TABLE (
    ayo integer,
    periodo integer,
    importe numeric(15,2),
    recargos numeric(15,2),
    cantidad integer,
    tipo varchar(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT ayo, periodo, importe, recargos, cantidad, tipo
    FROM ta_15_periodos
    WHERE control_otr = id_control;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp34_tablas(par_tab integer)
RETURNS TABLE(
    cve_tab varchar,
    nombre varchar,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cve_tab, a.nombre, b.descripcion
    FROM t34_tablas a
    JOIN t34_unidades b ON a.cve_tab = b.cve_tab
    WHERE a.cve_tab = par_tab
    GROUP BY a.cve_tab, a.nombre, b.descripcion
    ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp34_etiq(par_tab integer)
RETURNS TABLE(
    cve_tab varchar,
    abreviatura varchar,
    etiq_control varchar,
    concesionario varchar,
    ubicacion varchar,
    superficie varchar,
    fecha_inicio varchar,
    fecha_fin varchar,
    recaudadora varchar,
    sector varchar,
    zona varchar,
    licencia varchar,
    fecha_cancelacion varchar,
    unidad varchar,
    categoria varchar,
    seccion varchar,
    bloque varchar,
    nombre_comercial varchar,
    lugar varchar,
    obs varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM t34_etiq WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp34_vigencias(par_tab integer)
RETURNS TABLE(
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT b.descripcion
    FROM t34_datos a, t34_status b
    WHERE a.cve_tab = par_tab
      AND b.id_34_stat = a.id_stat
    GROUP BY b.descripcion
    ORDER BY b.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gadeudos_tablas(par_tab TEXT)
RETURNS TABLE(
    cve_tab TEXT,
    nombre TEXT,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cve_tab, a.nombre, b.descripcion
    FROM t34_tablas a
    LEFT JOIN t34_unidades b ON b.cve_tab = a.cve_tab
    WHERE a.cve_tab = par_tab
    GROUP BY a.cve_tab, a.nombre, b.descripcion
    ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gadeudos_etiquetas(par_tab TEXT)
RETURNS TABLE(
    cve_tab TEXT,
    abreviatura TEXT,
    etiq_control TEXT,
    concesionario TEXT,
    ubicacion TEXT,
    superficie TEXT,
    fecha_inicio TEXT,
    fecha_fin TEXT,
    recaudadora TEXT,
    sector TEXT,
    zona TEXT,
    licencia TEXT,
    fecha_cancelacion TEXT,
    unidad TEXT,
    categoria TEXT,
    seccion TEXT,
    bloque TEXT,
    nombre_comercial TEXT,
    lugar TEXT,
    obs TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM t34_etiq WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS t34_tablas (
  cve_tab integer PRIMARY KEY,
  nombre varchar(100),
  descripcion varchar(100)
);

CREATE TABLE IF NOT EXISTS t34_etiq (
  cve_tab integer,
  abreviatura varchar(4),
  etiq_control varchar(50),
  concesionario varchar(100),
  ubicacion varchar(100),
  superficie varchar(50),
  fecha_inicio varchar(20),
  fecha_fin varchar(20),
  recaudadora varchar(50),
  sector varchar(20),
  zona varchar(20),
  licencia varchar(20),
  fecha_cancelacion varchar(20),
  unidad varchar(20),
  categoria varchar(20),
  seccion varchar(20),
  bloque varchar(20),
  nombre_comercial varchar(100),
  lugar varchar(100),
  obs varchar(100)
);

CREATE OR REPLACE FUNCTION sp_get_tabla_info(par_tab integer)
RETURNS TABLE(cve_tab integer, nombre text, descripcion text) AS $$
BEGIN
  RETURN QUERY
  SELECT a.cve_tab, a.nombre, b.descripcion
  FROM t34_tablas a
  JOIN t34_unidades b ON b.cve_tab = a.cve_tab
  WHERE a.cve_tab = par_tab
  GROUP BY a.cve_tab, a.nombre, b.descripcion
  ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_etiq(par_tab integer)
RETURNS TABLE(
  cve_tab integer,
  abreviatura text,
  etiq_control text,
  concesionario text,
  ubicacion text,
  superficie text,
  fecha_inicio text,
  fecha_fin text,
  recaudadora text,
  sector text,
  zona text,
  licencia text,
  fecha_cancelacion text,
  unidad text,
  categoria text,
  seccion text,
  bloque text,
  nombre_comercial text,
  lugar text,
  obs text
) AS $$
BEGIN
  RETURN QUERY
  SELECT cve_tab, abreviatura, etiq_control, concesionario, ubicacion, superficie, fecha_inicio, fecha_fin, recaudadora, sector, zona, licencia, fecha_cancelacion, unidad, categoria, seccion, bloque, nombre_comercial, lugar, obs
  FROM t34_etiq
  WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(
  id_rec smallint,
  id_zona integer,
  recaudadora text,
  domicilio text,
  tel text,
  recaudador text,
  sector text
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_rec, id_zona, recaudadora, domicilio, tel, recaudador, sector
  FROM ta_12_recaudadoras
  ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_operaciones()
RETURNS TABLE(
  id_rec smallint,
  caja text,
  operacion integer,
  id_usuario integer,
  tip_impresora text
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_rec, caja, operacion, id_usuario, tip_impresora
  FROM ta_12_operaciones
  ORDER BY id_rec, caja;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gconsulta2_get_etiquetas(par_tab integer)
RETURNS TABLE (
  cve_tab varchar,
  abreviatura varchar,
  etiq_control varchar,
  concesionario varchar,
  ubicacion varchar,
  superficie varchar,
  fecha_inicio varchar,
  fecha_fin varchar,
  recaudadora varchar,
  sector varchar,
  zona varchar,
  licencia varchar,
  fecha_cancelacion varchar,
  unidad varchar,
  categoria varchar,
  seccion varchar,
  bloque varchar,
  nombre_comercial varchar,
  lugar varchar,
  obs varchar
) AS $$
BEGIN
  RETURN QUERY SELECT * FROM t34_etiq WHERE cve_tab = par_tab::text;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_gconsulta2_get_tablas(par_tab integer)
RETURNS TABLE (
  cve_tab varchar,
  nombre varchar,
  descripcion varchar
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.cve_tab, a.nombre, b.descripcion
    FROM t34_tablas a
    JOIN t34_unidades b ON b.cve_tab = a.cve_tab
    WHERE a.cve_tab = par_tab::text
    GROUP BY a.cve_tab, a.nombre, b.descripcion
    ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_tablas(par_tab VARCHAR)
RETURNS TABLE(
    cve_tab VARCHAR,
    nombre VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cve_tab, a.nombre, b.descripcion
    FROM t34_tablas a
    JOIN t34_unidades b ON a.cve_tab = b.cve_tab
    WHERE a.cve_tab = par_tab
    GROUP BY a.cve_tab, a.nombre, b.descripcion
    ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_etiquetas(par_tab VARCHAR)
RETURNS TABLE(
    cve_tab VARCHAR,
    abreviatura VARCHAR,
    etiq_control VARCHAR,
    concesionario VARCHAR,
    ubicacion VARCHAR,
    superficie VARCHAR,
    fecha_inicio VARCHAR,
    fecha_fin VARCHAR,
    recaudadora VARCHAR,
    sector VARCHAR,
    zona VARCHAR,
    licencia VARCHAR,
    fecha_cancelacion VARCHAR,
    unidad VARCHAR,
    categoria VARCHAR,
    seccion VARCHAR,
    bloque VARCHAR,
    nombre_comercial VARCHAR,
    lugar VARCHAR,
    obs VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM t34_etiq WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp34_vigencias_concesion(par_tab integer)
RETURNS TABLE(descripcion text) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT b.descripcion
    FROM t34_datos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.cve_tab = par_tab
    ORDER BY b.descripcion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp34_etiq_tabla(par_tab integer)
RETURNS TABLE(
    cve_tab text,
    abreviatura text,
    etiq_control text,
    concesionario text,
    ubicacion text,
    superficie text,
    fecha_inicio text,
    fecha_fin text,
    recaudadora text,
    sector text,
    zona text,
    licencia text,
    fecha_cancelacion text,
    unidad text,
    categoria text,
    seccion text,
    bloque text,
    nombre_comercial text,
    lugar text,
    obs text
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM t34_etiq WHERE cve_tab = par_tab::text;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp34_nombre_tabla(par_tab integer)
RETURNS TABLE(nombre text) AS $$
BEGIN
    RETURN QUERY
    SELECT nombre FROM t34_tablas WHERE cve_tab = par_tab::text;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_menu_get_menu(p_usuario TEXT)
RETURNS JSON AS $$
DECLARE
  v_nivel SMALLINT;
  v_menu JSON;
BEGIN
  SELECT nivel INTO v_nivel FROM ta_12_passwords WHERE usuario = p_usuario;
  -- Ejemplo de menú, debe adaptarse a la lógica real de permisos
  v_menu := json_build_array(
    json_build_object('nombre', 'Controles', 'opciones', json_build_array(
      json_build_object('id', 101, 'titulo', 'Alta de Fuente de Sodas', 'enabled', v_nivel >= 1),
      json_build_object('id', 102, 'titulo', 'Alta de Juegos Mecánicos', 'enabled', v_nivel >= 1)
    )),
    json_build_object('nombre', 'Reportes', 'opciones', json_build_array(
      json_build_object('id', 301, 'titulo', 'Edo. Cuenta', 'enabled', v_nivel >= 1)
    ))
  );
  RETURN v_menu;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_menu_get_ejercicios()
RETURNS TABLE(ejercicio INT) AS $$
BEGIN
  RETURN QUERY
    SELECT DISTINCT ejercicio_recolec AS ejercicio
    FROM ta_16_unidades
    ORDER BY ejercicio_recolec;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_menu_get_user_info(p_usuario TEXT)
RETURNS TABLE(id_usuario INT, usuario TEXT, nombre TEXT, estado TEXT, id_rec SMALLINT, nivel SMALLINT) AS $$
BEGIN
  RETURN QUERY
    SELECT id_usuario, usuario, nombre, estado, id_rec, nivel
    FROM ta_12_passwords
    WHERE usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION buscar_concesion(control TEXT)
RETURNS TABLE (
    id_34_datos INTEGER,
    control TEXT,
    concesionario TEXT,
    ubicacion TEXT,
    superficie NUMERIC,
    fecha_inicio DATE,
    fecha_fin DATE,
    id_recaudadora INTEGER,
    sector TEXT,
    id_zona INTEGER,
    licencia INTEGER,
    status TEXT,
    unidades TEXT,
    categoria TEXT,
    seccion TEXT,
    bloque TEXT,
    nom_comercial TEXT,
    lugar TEXT,
    obs TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT A.id_34_datos, A.control, A.concesionario, A.ubicacion, A.superficie, A.fecha_inicio, A.fecha_fin, A.id_recaudadora,
           A.sector, A.id_zona, A.licencia, Z.descripcion AS status, F.descripcion AS unidades,
           B.categoria, B.seccion, B.bloque, C.concepto AS nom_comercial, D.concepto AS lugar, E.concepto AS obs
    FROM t34_datos A
    LEFT JOIN t34_adicionales B ON B.id_datos = A.id_34_datos
    LEFT JOIN t34_conceptos C ON C.id_datos = A.id_34_datos AND C.tipo = 'N'
    LEFT JOIN t34_conceptos D ON D.id_datos = A.id_34_datos AND D.tipo = 'L'
    LEFT JOIN t34_conceptos E ON E.id_datos = A.id_34_datos AND E.tipo = 'O'
    JOIN t34_status Z ON Z.id_34_stat = A.id_stat
    JOIN t34_unidades F ON F.id_34_unidad = A.id_unidad
    WHERE A.control = control;
END;
$$ LANGUAGE plpgsql;

-- Tabla: ta_12_recaudadoras
-- id_rec, recaudadora, domicilio, tel, recaudador, sector
-- SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;

-- Tabla: ta_12_operaciones
-- id_rec, caja, operacion, id_usuario, tip_impresora
-- SELECT id_rec, caja FROM ta_12_operaciones ORDER BY id_rec, caja;

CREATE OR REPLACE FUNCTION sp_rbaja_buscar_local(p_numero VARCHAR, p_letra VARCHAR)
RETURNS TABLE (
    id_34_datos INTEGER,
    control VARCHAR,
    concesionario VARCHAR,
    ubicacion VARCHAR,
    superficie NUMERIC,
    fecha_inicio DATE,
    id_recaudadora INTEGER,
    sector VARCHAR,
    id_zona INTEGER,
    licencia INTEGER,
    descrip_unidad VARCHAR,
    cve_stat VARCHAR,
    descrip_stat VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_datos, a.control, a.concesionario, a.ubicacion, a.superficie, a.fecha_inicio,
           a.id_recaudadora, a.sector, a.id_zona, a.licencia, b.descripcion AS descrip_unidad, c.cve_stat, c.descripcion AS descrip_stat
    FROM t34_datos a
    JOIN t34_unidades b ON b.id_34_unidad = a.id_unidad
    JOIN t34_status c ON c.id_34_stat = a.id_stat
    WHERE a.cve_tab = 3
      AND a.control = CONCAT(TRIM(p_numero), '-', TRIM(p_letra));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_concesion_by_control(p_control TEXT)
RETURNS TABLE(
    id_34_datos INTEGER,
    control TEXT,
    concesionario TEXT,
    ubicacion TEXT,
    superficie NUMERIC,
    fecha_inicio DATE,
    id_recaudadora INTEGER,
    sector TEXT,
    id_zona INTEGER,
    licencia INTEGER,
    descrip_unidad TEXT,
    cve_stat TEXT,
    descrip_stat TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_datos, a.control, a.concesionario, a.ubicacion, a.superficie, a.fecha_inicio,
           a.id_recaudadora, a.sector, a.id_zona, a.licencia, b.descripcion AS descrip_unidad,
           c.cve_stat, c.descripcion AS descrip_stat
    FROM t34_datos a
    JOIN t34_unidades b ON b.id_34_unidad = a.id_unidad
    JOIN t34_status c ON c.id_34_stat = a.id_stat
    WHERE a.cve_tab = 3 AND a.control = p_control;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_fecha_limite()
RETURNS TABLE(fechalimite DATE) AS $$
BEGIN
    RETURN QUERY
    SELECT fechalimite
    FROM t34_fechalimite
    WHERE EXTRACT(YEAR FROM fechalimite) = EXTRACT(YEAR FROM CURRENT_DATE)
      AND EXTRACT(MONTH FROM fechalimite) = EXTRACT(MONTH FROM CURRENT_DATE)
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ins34_rubro_01(par_nombre VARCHAR)
RETURNS TABLE(status INTEGER, concepto_status VARCHAR) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    IF par_nombre IS NULL OR trim(par_nombre) = '' THEN
        status := -1;
        concepto_status := 'El nombre del rubro es obligatorio.';
        RETURN NEXT;
        RETURN;
    END IF;
    -- Verificar si ya existe un rubro con ese nombre
    IF EXISTS (SELECT 1 FROM t34_tablas WHERE UPPER(nombre) = UPPER(par_nombre)) THEN
        status := -2;
        concepto_status := 'Ya existe un rubro con ese nombre.';
        RETURN NEXT;
        RETURN;
    END IF;
    -- Insertar el nuevo rubro
    INSERT INTO t34_tablas (cve_tab, nombre, cajero, auto_tab)
    VALUES (
        (SELECT COALESCE(MAX(CAST(cve_tab AS INTEGER)),0)+1 FROM t34_tablas),
        par_nombre,
        'N',
        (SELECT COALESCE(MAX(auto_tab),0)+1 FROM t34_tablas)
    ) RETURNING id_34_tab INTO new_id;
    status := new_id;
    concepto_status := 'Rubro creado correctamente';
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE ins34_status(
    par_cve_tab INTEGER,
    par_cve_stat VARCHAR,
    par_descripcion VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO t34_status (id_34_stat, cve_tab, cve_stat, descripcion, usuario)
    VALUES (
        DEFAULT,
        par_cve_tab,
        par_cve_stat,
        par_descripcion,
        current_user
    );
END;
$$;