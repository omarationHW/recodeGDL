-- ============================================================
-- DEPLOY BATCH #7: 10 SPs IMPORTANT
-- Base de datos: padron_licencias
-- Fecha: 2025-11-10
-- ============================================================

-- SP: sp_zonaanuncio_delete (Operación DELETE para sp_zonaanuncio_delete)
CREATE OR REPLACE FUNCTION sp_zonaanuncio_delete(
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


-- SP: sp_save_licencias_zona (Operación READ para sp_save_licencias_zona)
CREATE OR REPLACE FUNCTION sp_save_licencias_zona(
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


-- SP: consulta_licencias_estadisticas (Operación READ para consulta_licencias_estadisticas)
CREATE OR REPLACE FUNCTION consulta_licencias_estadisticas(
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


-- SP: sp_get_saldo_licencia (Operación READ para sp_get_saldo_licencia)
CREATE OR REPLACE FUNCTION sp_get_saldo_licencia(
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


-- SP: get_deptos_by_dependencia (Operación READ para get_deptos_by_dependencia)
CREATE OR REPLACE FUNCTION get_deptos_by_dependencia(
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


-- SP: unidadimg_rutadir (Operación READ para unidadimg_rutadir)
-- NOTA: Tabla c_unidadimg_rutadir no encontrada, requiere implementación manual
CREATE OR REPLACE FUNCTION unidadimg_rutadir()
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


-- SP: carga_imagen_sp_get_document_image (Operación READ para carga_imagen_sp_get_document_image)
-- NOTA: Tabla c_carga_imagen_sp_get_document_image no encontrada, requiere implementación manual
CREATE OR REPLACE FUNCTION carga_imagen_sp_get_document_image()
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


-- SP: sp_catalogogiros_get (Operación READ para sp_catalogogiros_get)
CREATE OR REPLACE FUNCTION sp_catalogogiros_get(
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


-- SP: frmimplicenciareglamentada_sp_get_licencia_reglamentada_by_id (Operación READ para frmimplicenciareglamentada_sp_get_licencia_reglamentada_by_id)
CREATE OR REPLACE FUNCTION frmimplicenciareglamentada_sp_get_licencia_reglamentada_by_id(
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


-- SP: sp_frmselcalle_get_calles (Operación READ para sp_frmselcalle_get_calles)
-- NOTA: Tabla c_frmselcalle_get_calles no encontrada, requiere implementación manual
CREATE OR REPLACE FUNCTION sp_frmselcalle_get_calles()
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


