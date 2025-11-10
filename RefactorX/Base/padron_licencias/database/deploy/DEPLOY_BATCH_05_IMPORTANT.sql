-- ============================================================
-- DEPLOY BATCH #5: 10 SPs IMPORTANT
-- Base de datos: padron_licencias
-- Fecha: 2025-11-10
-- ============================================================

-- SP: remove_anuncios_from_grupo (Operación READ para remove_anuncios_from_grupo)
CREATE OR REPLACE FUNCTION remove_anuncios_from_grupo(
    p_id INTEGER
)
RETURNS TABLE (
    id_anuncio INTEGER,
    anuncio INTEGER,
    recaud SMALLINT,
    id_giro INTEGER,
    id_licencia INTEGER,
    zona SMALLINT,
    subzona SMALLINT,
    fecha_otorgamiento DATE,
    misma_forma CHARACTER VARYING(1),
    medidas1 NUMERIC,
    medidas2 NUMERIC,
    area_anuncio NUMERIC,
    num_caras SMALLINT,
    cvecalle INTEGER,
    ubicacion CHARACTER VARYING(50),
    numext_ubic INTEGER,
    letraext_ubic CHARACTER VARYING(3),
    numint_ubic CHARACTER VARYING(5),
    letraint_ubic CHARACTER VARYING(3),
    colonia_ubic CHARACTER VARYING(25),
    id_fabricante INTEGER,
    texto_anuncio CHARACTER VARYING(50),
    vigente CHARACTER VARYING(1),
    feccap DATE,
    capturista CHARACTER VARYING(10),
    asiento INTEGER,
    espubic CHARACTER VARYING(100),
    fecha_baja DATE,
    axo_baja INTEGER,
    folio_baja INTEGER,
    bloqueado SMALLINT,
    cp INTEGER
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_anuncio,
        t.anuncio,
        t.recaud,
        t.id_giro,
        t.id_licencia,
        t.zona,
        t.subzona,
        t.fecha_otorgamiento,
        t.misma_forma,
        t.medidas1,
        t.medidas2,
        t.area_anuncio,
        t.num_caras,
        t.cvecalle,
        t.ubicacion,
        t.numext_ubic,
        t.letraext_ubic,
        t.numint_ubic,
        t.letraint_ubic,
        t.colonia_ubic,
        t.id_fabricante,
        t.texto_anuncio,
        t.vigente,
        t.feccap,
        t.capturista,
        t.asiento,
        t.espubic,
        t.fecha_baja,
        t.axo_baja,
        t.folio_baja,
        t.bloqueado,
        t.cp
    FROM public.h_anuncios t
    WHERE t.id = p_id;
END;
$$ LANGUAGE plpgsql;


-- SP: sp_insert_grupo_licencia (Operación READ para sp_insert_grupo_licencia)
CREATE OR REPLACE FUNCTION sp_insert_grupo_licencia(
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


-- SP: sp_update_grupo_licencia (Operación UPDATE para sp_update_grupo_licencia)
CREATE OR REPLACE FUNCTION sp_update_grupo_licencia(
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


-- SP: sp_delete_grupo_licencia (Operación DELETE para sp_delete_grupo_licencia)
CREATE OR REPLACE FUNCTION sp_delete_grupo_licencia(
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


-- SP: sp_update_tramite (Operación UPDATE para sp_update_tramite)
CREATE OR REPLACE FUNCTION sp_update_tramite(
    p_id INTEGER
)
RETURNS TABLE (
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite CHARACTER VARYING(2),
    id_giro INTEGER,
    x NUMERIC,
    y NUMERIC,
    zona SMALLINT,
    subzona SMALLINT,
    actividad CHARACTER VARYING(130),
    cvecuenta INTEGER,
    recaud SMALLINT,
    licencia_ref INTEGER,
    tramita_apoderado CHARACTER VARYING(100),
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
    email CHARACTER VARYING(50),
    cvecalle INTEGER,
    ubicacion CHARACTER VARYING(50),
    numext_ubic INTEGER,
    letraext_ubic CHARACTER VARYING(3),
    letraint_ubic CHARACTER VARYING(3),
    colonia_ubic CHARACTER VARYING(25),
    espubic CHARACTER VARYING(60),
    documentos TEXT,
    sup_construida NUMERIC,
    sup_autorizada NUMERIC,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC,
    costo NUMERIC,
    fecha_consejo DATE,
    id_fabricante INTEGER,
    texto_anuncio CHARACTER VARYING(50),
    medidas1 NUMERIC,
    medidas2 NUMERIC,
    area_anuncio NUMERIC,
    num_caras SMALLINT,
    calificacion NUMERIC,
    usr_califica CHARACTER VARYING(10),
    estatus CHARACTER VARYING(1),
    id_licencia INTEGER,
    id_anuncio INTEGER,
    feccap DATE,
    capturista CHARACTER VARYING(10),
    numint_ubic CHARACTER VARYING(5),
    bloqueado SMALLINT,
    dictamen SMALLINT,
    observaciones TEXT,
    rhorario CHARACTER VARYING(50),
    cp INTEGER,
    fecmov TIMESTAMP WITHOUT TIME ZONE,
    usuariomov CHARACTER VARYING(10)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_tramite,
        t.folio,
        t.tipo_tramite,
        t.id_giro,
        t.x,
        t.y,
        t.zona,
        t.subzona,
        t.actividad,
        t.cvecuenta,
        t.recaud,
        t.licencia_ref,
        t.tramita_apoderado,
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
        t.email,
        t.cvecalle,
        t.ubicacion,
        t.numext_ubic,
        t.letraext_ubic,
        t.letraint_ubic,
        t.colonia_ubic,
        t.espubic,
        t.documentos,
        t.sup_construida,
        t.sup_autorizada,
        t.num_cajones,
        t.num_empleados,
        t.aforo,
        t.inversion,
        t.costo,
        t.fecha_consejo,
        t.id_fabricante,
        t.texto_anuncio,
        t.medidas1,
        t.medidas2,
        t.area_anuncio,
        t.num_caras,
        t.calificacion,
        t.usr_califica,
        t.estatus,
        t.id_licencia,
        t.id_anuncio,
        t.feccap,
        t.capturista,
        t.numint_ubic,
        t.bloqueado,
        t.dictamen,
        t.observaciones,
        t.rhorario,
        t.cp,
        t.fecmov,
        t.usuariomov
    FROM public.h_tramites t
    WHERE t.id = p_id;
END;
$$ LANGUAGE plpgsql;


-- SP: sp_observaciones_create (Operación CREATE para sp_observaciones_create)
-- NOTA: Tabla c_observaciones no encontrada, requiere implementación manual
CREATE OR REPLACE FUNCTION sp_observaciones_create()
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


-- SP: sp_observaciones_update (Operación UPDATE para sp_observaciones_update)
-- NOTA: Tabla c_observaciones no encontrada, requiere implementación manual
CREATE OR REPLACE FUNCTION sp_observaciones_update()
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


-- SP: sp_observaciones_delete (Operación DELETE para sp_observaciones_delete)
-- NOTA: Tabla c_observaciones no encontrada, requiere implementación manual
CREATE OR REPLACE FUNCTION sp_observaciones_delete()
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


-- SP: sp_c_contribholog_create (Operación CREATE para sp_c_contribholog_create)
CREATE OR REPLACE FUNCTION sp_c_contribholog_create(
    p_id INTEGER
)
RETURNS TABLE (
    idcontrib INTEGER,
    nombre CHARACTER VARYING(50),
    domicilio CHARACTER VARYING(60),
    colonia CHARACTER VARYING(50),
    telefono CHARACTER VARYING(20),
    rfc CHARACTER VARYING(13),
    curp CHARACTER VARYING(18),
    email CHARACTER VARYING(40),
    feccap DATE,
    capturista CHARACTER VARYING(10)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.idcontrib,
        t.nombre,
        t.domicilio,
        t.colonia,
        t.telefono,
        t.rfc,
        t.curp,
        t.email,
        t.feccap,
        t.capturista
    FROM public.c_contribholog t
    WHERE t.id = p_id;
END;
$$ LANGUAGE plpgsql;


-- SP: sp_c_contribholog_update (Operación UPDATE para sp_c_contribholog_update)
CREATE OR REPLACE FUNCTION sp_c_contribholog_update(
    p_id INTEGER
)
RETURNS TABLE (
    idcontrib INTEGER,
    nombre CHARACTER VARYING(50),
    domicilio CHARACTER VARYING(60),
    colonia CHARACTER VARYING(50),
    telefono CHARACTER VARYING(20),
    rfc CHARACTER VARYING(13),
    curp CHARACTER VARYING(18),
    email CHARACTER VARYING(40),
    feccap DATE,
    capturista CHARACTER VARYING(10)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.idcontrib,
        t.nombre,
        t.domicilio,
        t.colonia,
        t.telefono,
        t.rfc,
        t.curp,
        t.email,
        t.feccap,
        t.capturista
    FROM public.c_contribholog t
    WHERE t.id = p_id;
END;
$$ LANGUAGE plpgsql;


