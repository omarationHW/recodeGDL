-- ============================================================
-- DEPLOY BATCH #8: 10 SPs OPTIONAL
-- Base de datos: padron_licencias
-- Fecha: 2025-11-10
-- ============================================================

-- SP: sp_get_subzonas (Operación READ para sp_get_subzonas)
CREATE OR REPLACE FUNCTION sp_get_subzonas(
    p_id INTEGER
)
RETURNS TABLE (
    cvezona INTEGER,
    cvesubzona INTEGER,
    descsubzon CHARACTER VARYING(30),
    feccap DATE,
    capturista CHARACTER VARYING(10)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.cvezona,
        t.cvesubzona,
        t.descsubzon,
        t.feccap,
        t.capturista
    FROM public.c_subzonas t
    WHERE t.id = p_id;
END;
$$ LANGUAGE plpgsql;


-- SP: sp_get_dependencias (Operación READ para sp_get_dependencias)
CREATE OR REPLACE FUNCTION sp_get_dependencias(
    p_id INTEGER
)
RETURNS TABLE (
    id_dependencia INTEGER,
    descripcion CHARACTER VARYING(50),
    tipo CHARACTER VARYING(1),
    cvectaapl INTEGER,
    abrevia CHARACTER VARYING(20),
    licencias SMALLINT,
    vigencia CHARACTER VARYING(1),
    feccap DATE,
    capturista CHARACTER VARYING(10),
    cta_vencido INTEGER
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_dependencia,
        t.descripcion,
        t.tipo,
        t.cvectaapl,
        t.abrevia,
        t.licencias,
        t.vigencia,
        t.feccap,
        t.capturista,
        t.cta_vencido
    FROM comun.c_dependencias t
    WHERE t.id = p_id;
END;
$$ LANGUAGE plpgsql;


-- SP: sp_get_agenda_visitas (Operación READ para sp_get_agenda_visitas)
-- NOTA: Tabla c_agenda_visitas no encontrada, requiere implementación manual
CREATE OR REPLACE FUNCTION sp_get_agenda_visitas()
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
AS $$
BEGIN
    -- TODO: Implementar lógica del SP
    RETURN QUERY SELECT TRUE, 'SP stub - requiere implementación'::TEXT;
END;
$$ LANGUAGE plpgsql;


-- SP: sp_consulta_licencia (Operación READ para sp_consulta_licencia)
CREATE OR REPLACE FUNCTION sp_consulta_licencia(
    p_id INTEGER
)
RETURNS TABLE (
    id_licencia INTEGER,
    licencia INTEGER,
    empresa INTEGER,
    recaud SMALLINT,
    id_giro INTEGER,
    x NUMERIC,
    y NUMERIC,
    zona SMALLINT,
    subzona SMALLINT,
    tipo_registro CHARACTER VARYING(1),
    actividad CHARACTER VARYING(130),
    cvecuenta INTEGER,
    fecha_otorgamiento DATE,
    propietario CHARACTER VARYING(80),
    primer_ap CHARACTER VARYING(80),
    segundo_ap CHARACTER VARYING(80),
    rfc CHARACTER VARYING(13),
    curp CHARACTER VARYING(18),
    domicilio CHARACTER VARYING(50),
    numext_prop INTEGER,
    numint_prop CHARACTER VARYING(5),
    colonia_prop CHARACTER VARYING(25),
    telefono_prop CHARACTER VARYING(30),
    cvecalle INTEGER,
    ubicacion CHARACTER VARYING(50),
    numext_ubic INTEGER,
    letraext_ubic CHARACTER VARYING(3),
    numint_ubic CHARACTER VARYING(5),
    letraint_ubic CHARACTER VARYING(3),
    colonia_ubic CHARACTER VARYING(25),
    sup_construida NUMERIC,
    sup_autorizada NUMERIC,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC,
    rhorario CHARACTER VARYING(50),
    fecha_consejo DATE,
    bloqueado SMALLINT,
    asiento SMALLINT,
    vigente CHARACTER VARYING(1),
    espubic CHARACTER VARYING(100),
    feccap DATE,
    capturista CHARACTER VARYING(10),
    fecha_baja DATE,
    axo_baja INTEGER,
    folio_baja INTEGER,
    cp INTEGER
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_licencia,
        t.licencia,
        t.empresa,
        t.recaud,
        t.id_giro,
        t.x,
        t.y,
        t.zona,
        t.subzona,
        t.tipo_registro,
        t.actividad,
        t.cvecuenta,
        t.fecha_otorgamiento,
        t.propietario,
        t.primer_ap,
        t.segundo_ap,
        t.rfc,
        t.curp,
        t.domicilio,
        t.numext_prop,
        t.numint_prop,
        t.colonia_prop,
        t.telefono_prop,
        t.cvecalle,
        t.ubicacion,
        t.numext_ubic,
        t.letraext_ubic,
        t.numint_ubic,
        t.letraint_ubic,
        t.colonia_ubic,
        t.sup_construida,
        t.sup_autorizada,
        t.num_cajones,
        t.num_empleados,
        t.aforo,
        t.inversion,
        t.rhorario,
        t.fecha_consejo,
        t.bloqueado,
        t.asiento,
        t.vigente,
        t.espubic,
        t.feccap,
        t.capturista,
        t.fecha_baja,
        t.axo_baja,
        t.folio_baja,
        t.cp
    FROM public.h_licencias t
    WHERE t.id = p_id;
END;
$$ LANGUAGE plpgsql;


-- SP: sp_consulta_anuncios_licencia (Operación READ para sp_consulta_anuncios_licencia)
CREATE OR REPLACE FUNCTION sp_consulta_anuncios_licencia(
    p_id INTEGER
)
RETURNS TABLE (
    id_licencia INTEGER,
    licencia INTEGER,
    empresa INTEGER,
    recaud SMALLINT,
    id_giro INTEGER,
    x NUMERIC,
    y NUMERIC,
    zona SMALLINT,
    subzona SMALLINT,
    tipo_registro CHARACTER VARYING(1),
    actividad CHARACTER VARYING(130),
    cvecuenta INTEGER,
    fecha_otorgamiento DATE,
    propietario CHARACTER VARYING(80),
    primer_ap CHARACTER VARYING(80),
    segundo_ap CHARACTER VARYING(80),
    rfc CHARACTER VARYING(13),
    curp CHARACTER VARYING(18),
    domicilio CHARACTER VARYING(50),
    numext_prop INTEGER,
    numint_prop CHARACTER VARYING(5),
    colonia_prop CHARACTER VARYING(25),
    telefono_prop CHARACTER VARYING(30),
    cvecalle INTEGER,
    ubicacion CHARACTER VARYING(50),
    numext_ubic INTEGER,
    letraext_ubic CHARACTER VARYING(3),
    numint_ubic CHARACTER VARYING(5),
    letraint_ubic CHARACTER VARYING(3),
    colonia_ubic CHARACTER VARYING(25),
    sup_construida NUMERIC,
    sup_autorizada NUMERIC,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC,
    rhorario CHARACTER VARYING(50),
    fecha_consejo DATE,
    bloqueado SMALLINT,
    asiento SMALLINT,
    vigente CHARACTER VARYING(1),
    espubic CHARACTER VARYING(100),
    feccap DATE,
    capturista CHARACTER VARYING(10),
    fecha_baja DATE,
    axo_baja INTEGER,
    folio_baja INTEGER,
    cp INTEGER
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_licencia,
        t.licencia,
        t.empresa,
        t.recaud,
        t.id_giro,
        t.x,
        t.y,
        t.zona,
        t.subzona,
        t.tipo_registro,
        t.actividad,
        t.cvecuenta,
        t.fecha_otorgamiento,
        t.propietario,
        t.primer_ap,
        t.segundo_ap,
        t.rfc,
        t.curp,
        t.domicilio,
        t.numext_prop,
        t.numint_prop,
        t.colonia_prop,
        t.telefono_prop,
        t.cvecalle,
        t.ubicacion,
        t.numext_ubic,
        t.letraext_ubic,
        t.numint_ubic,
        t.letraint_ubic,
        t.colonia_ubic,
        t.sup_construida,
        t.sup_autorizada,
        t.num_cajones,
        t.num_empleados,
        t.aforo,
        t.inversion,
        t.rhorario,
        t.fecha_consejo,
        t.bloqueado,
        t.asiento,
        t.vigente,
        t.espubic,
        t.feccap,
        t.capturista,
        t.fecha_baja,
        t.axo_baja,
        t.folio_baja,
        t.cp
    FROM public.h_licencias t
    WHERE t.id = p_id;
END;
$$ LANGUAGE plpgsql;


-- SP: sp_baja_licencia (Operación READ para sp_baja_licencia)
CREATE OR REPLACE FUNCTION sp_baja_licencia(
    p_id INTEGER
)
RETURNS TABLE (
    id_licencia INTEGER,
    licencia INTEGER,
    empresa INTEGER,
    recaud SMALLINT,
    id_giro INTEGER,
    x NUMERIC,
    y NUMERIC,
    zona SMALLINT,
    subzona SMALLINT,
    tipo_registro CHARACTER VARYING(1),
    actividad CHARACTER VARYING(130),
    cvecuenta INTEGER,
    fecha_otorgamiento DATE,
    propietario CHARACTER VARYING(80),
    primer_ap CHARACTER VARYING(80),
    segundo_ap CHARACTER VARYING(80),
    rfc CHARACTER VARYING(13),
    curp CHARACTER VARYING(18),
    domicilio CHARACTER VARYING(50),
    numext_prop INTEGER,
    numint_prop CHARACTER VARYING(5),
    colonia_prop CHARACTER VARYING(25),
    telefono_prop CHARACTER VARYING(30),
    cvecalle INTEGER,
    ubicacion CHARACTER VARYING(50),
    numext_ubic INTEGER,
    letraext_ubic CHARACTER VARYING(3),
    numint_ubic CHARACTER VARYING(5),
    letraint_ubic CHARACTER VARYING(3),
    colonia_ubic CHARACTER VARYING(25),
    sup_construida NUMERIC,
    sup_autorizada NUMERIC,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC,
    rhorario CHARACTER VARYING(50),
    fecha_consejo DATE,
    bloqueado SMALLINT,
    asiento SMALLINT,
    vigente CHARACTER VARYING(1),
    espubic CHARACTER VARYING(100),
    feccap DATE,
    capturista CHARACTER VARYING(10),
    fecha_baja DATE,
    axo_baja INTEGER,
    folio_baja INTEGER,
    cp INTEGER
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_licencia,
        t.licencia,
        t.empresa,
        t.recaud,
        t.id_giro,
        t.x,
        t.y,
        t.zona,
        t.subzona,
        t.tipo_registro,
        t.actividad,
        t.cvecuenta,
        t.fecha_otorgamiento,
        t.propietario,
        t.primer_ap,
        t.segundo_ap,
        t.rfc,
        t.curp,
        t.domicilio,
        t.numext_prop,
        t.numint_prop,
        t.colonia_prop,
        t.telefono_prop,
        t.cvecalle,
        t.ubicacion,
        t.numext_ubic,
        t.letraext_ubic,
        t.numint_ubic,
        t.letraint_ubic,
        t.colonia_ubic,
        t.sup_construida,
        t.sup_autorizada,
        t.num_cajones,
        t.num_empleados,
        t.aforo,
        t.inversion,
        t.rhorario,
        t.fecha_consejo,
        t.bloqueado,
        t.asiento,
        t.vigente,
        t.espubic,
        t.feccap,
        t.capturista,
        t.fecha_baja,
        t.axo_baja,
        t.folio_baja,
        t.cp
    FROM public.h_licencias t
    WHERE t.id = p_id;
END;
$$ LANGUAGE plpgsql;


-- SP: consulta_giros_estadisticas (Operación READ para consulta_giros_estadisticas)
CREATE OR REPLACE FUNCTION consulta_giros_estadisticas(
    p_id INTEGER
)
RETURNS TABLE (
    id_giro INTEGER,
    id_mensaje INTEGER,
    cod_giro INTEGER,
    cod_anun CHARACTER VARYING(5),
    descripcion CHARACTER VARYING(96),
    caracteristicas CHARACTER VARYING(130),
    clasificacion CHARACTER VARYING(1),
    tipo CHARACTER VARYING(1),
    ctaaplic INTEGER,
    reglamentada CHARACTER VARYING(1),
    ctaaplic_rez INTEGER,
    vigente CHARACTER VARYING(1),
    ctaaplicref INTEGER,
    ctaaplicref_rez INTEGER
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_giro,
        t.id_mensaje,
        t.cod_giro,
        t.cod_anun,
        t.descripcion,
        t.caracteristicas,
        t.clasificacion,
        t.tipo,
        t.ctaaplic,
        t.reglamentada,
        t.ctaaplic_rez,
        t.vigente,
        t.ctaaplicref,
        t.ctaaplicref_rez
    FROM comun.c_giros t
    WHERE t.id = p_id;
END;
$$ LANGUAGE plpgsql;


-- SP: buscagiro_list (Operación READ para buscagiro_list)
CREATE OR REPLACE FUNCTION buscagiro_list(
    p_id INTEGER
)
RETURNS TABLE (
    id_giro INTEGER,
    id_mensaje INTEGER,
    cod_giro INTEGER,
    cod_anun CHARACTER VARYING(5),
    descripcion CHARACTER VARYING(96),
    caracteristicas CHARACTER VARYING(130),
    clasificacion CHARACTER VARYING(1),
    tipo CHARACTER VARYING(1),
    ctaaplic INTEGER,
    reglamentada CHARACTER VARYING(1),
    ctaaplic_rez INTEGER,
    vigente CHARACTER VARYING(1),
    ctaaplicref INTEGER,
    ctaaplicref_rez INTEGER
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_giro,
        t.id_mensaje,
        t.cod_giro,
        t.cod_anun,
        t.descripcion,
        t.caracteristicas,
        t.clasificacion,
        t.tipo,
        t.ctaaplic,
        t.reglamentada,
        t.ctaaplic_rez,
        t.vigente,
        t.ctaaplicref,
        t.ctaaplicref_rez
    FROM comun.c_giros t
    WHERE t.id = p_id;
END;
$$ LANGUAGE plpgsql;


-- SP: sp_busque_search_by_owner (Operación READ para sp_busque_search_by_owner)
-- NOTA: Tabla c_busque_search_by_owner no encontrada, requiere implementación manual
CREATE OR REPLACE FUNCTION sp_busque_search_by_owner()
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
AS $$
BEGIN
    -- TODO: Implementar lógica del SP
    RETURN QUERY SELECT TRUE, 'SP stub - requiere implementación'::TEXT;
END;
$$ LANGUAGE plpgsql;


-- SP: sp_busque_search_by_location (Operación READ para sp_busque_search_by_location)
-- NOTA: Tabla c_busque_search_by_location no encontrada, requiere implementación manual
CREATE OR REPLACE FUNCTION sp_busque_search_by_location()
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
AS $$
BEGIN
    -- TODO: Implementar lógica del SP
    RETURN QUERY SELECT TRUE, 'SP stub - requiere implementación'::TEXT;
END;
$$ LANGUAGE plpgsql;


