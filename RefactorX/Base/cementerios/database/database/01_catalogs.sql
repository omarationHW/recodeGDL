CREATE OR REPLACE FUNCTION sp_consultar_sanandres()
RETURNS TABLE (
    id integer,
    clase text,
    seccion text,
    linea text,
    fosa text,
    ppago text,
    nombre text,
    fcompra timestamp,
    otros text,
    clave smallint,
    medida float,
    calle text,
    colonia text
) AS $$
BEGIN
    RETURN QUERY SELECT id, clase, seccion, linea, fosa, ppago, nombre, fcompra, otros, clave, medida, calle, colonia FROM datos;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_consultar_sanandres_paginated(p_page integer, p_per_page integer)
RETURNS TABLE (
    id integer,
    clase text,
    seccion text,
    linea text,
    fosa text,
    ppago text,
    nombre text,
    fcompra timestamp,
    otros text,
    clave smallint,
    medida float,
    calle text,
    colonia text
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, clase, seccion, linea, fosa, ppago, nombre, fcompra, otros, clave, medida, calle, colonia
    FROM datos
    ORDER BY id
    OFFSET ((p_page - 1) * p_per_page)
    LIMIT p_per_page;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_usuario_detalle(p_usuario VARCHAR)
RETURNS TABLE(
    id_usuario INTEGER,
    usuario VARCHAR,
    nombre VARCHAR,
    estado VARCHAR,
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora VARCHAR,
    domicilio VARCHAR,
    tel VARCHAR,
    recaudador VARCHAR,
    nivel SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_usuario,
        a.usuario,
        a.nombre,
        a.estado,
        a.id_rec,
        b.id_zona,
        b.recaudadora,
        b.domicilio,
        b.tel,
        b.recaudador,
        a.nivel
    FROM ta_12_passwords a
    JOIN ta_12_recaudadoras b ON a.id_rec = b.id_rec
    WHERE a.usuario = p_usuario
      AND a.estado = 'A';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_version_detalle(p_proyecto VARCHAR, p_version VARCHAR)
RETURNS TABLE(
    proyecto VARCHAR,
    version VARCHAR,
    fecha DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT proyecto, version, fecha
    FROM ta_versiones
    WHERE proyecto = p_proyecto AND version = p_version;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_cementerios_list()
RETURNS TABLE (
    cementerio VARCHAR,
    nombre VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT cementerio, nombre FROM tc_13_cementerios ORDER BY cementerio;
END;
$$ LANGUAGE plpgsql;

-- PostgreSQL stored procedure for recaudadora info
CREATE OR REPLACE FUNCTION sp_get_recaudadora(par_id_rec integer)
RETURNS TABLE(
    id_rec integer,
    nomre text,
    titulo text,
    d_zona text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_rec, a.nomre, a.titulo, upper(c.zona) as d_zona
    FROM ta_12_nombrerec a
    JOIN ta_12_recaudadoras b ON a.recing = b.id_rec
    JOIN ta_12_zonas c ON b.id_zona = c.id_zona
    WHERE a.recing = par_id_rec;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION rpt_titulos_get_recaudadora(rec smallint)
RETURNS TABLE (
    recing smallint,
    nomre varchar,
    titulo varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT recing, nomre, titulo
    FROM ta_12_nombrerec
    WHERE recing = rec;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_titulos_view(p_fecha DATE, p_folio INTEGER, p_operacion INTEGER)
RETURNS TABLE(
    nombre_beneficiario TEXT,
    domicilio_beneficiario TEXT,
    colonia_beneficiario TEXT,
    telefono_beneficiario TEXT,
    libro INTEGER,
    axo INTEGER,
    folio_libro INTEGER,
    partida TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.nombre_beneficiario, t.domicilio_beneficiario, t.colonia_beneficiario, t.telefono_beneficiario, t.libro, t.axo, t.folio, t.partida
    FROM ta_13_titulos t
    WHERE t.fecha = p_fecha AND t.control_rcm = p_folio AND t.operacion = p_operacion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_titulos_extra(p_fecha DATE, p_folio INTEGER, p_operacion INTEGER)
RETURNS TABLE(
    scontrol_rcm INTEGER,
    snombre TEXT,
    sdomicilio TEXT,
    scolonia TEXT,
    stelefono TEXT,
    slibro INTEGER,
    saxo INTEGER,
    sfoliot INTEGER,
    snombreben TEXT,
    sdomben TEXT,
    scolben TEXT,
    stelben TEXT,
    spartida TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT scontrol_rcm, snombre, sdomicilio, scolonia, stelefono, slibro, saxo, sfoliot, snombreben, sdomben, scolben, stelben, spartida
    FROM v_titulos_cem
    WHERE sfecha = p_fecha AND scontrol_rcm = p_folio AND soperacion = p_operacion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_titulosin_get_rec(
    p_rec SMALLINT
) RETURNS TABLE(
    recing SMALLINT,
    nomre VARCHAR,
    titulo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT recing, UPPER(nomre), titulo
    FROM ta_12_nombrerec
    WHERE recing = p_rec;
END;
$$ LANGUAGE plpgsql;