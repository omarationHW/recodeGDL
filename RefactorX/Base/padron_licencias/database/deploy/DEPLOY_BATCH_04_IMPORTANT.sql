-- ============================================================
-- DEPLOY BATCH #4: 10 SPs IMPORTANT
-- Base de datos: padron_licencias
-- Fecha: 2025-11-10
-- ============================================================

-- SP: sp_firma_save (Operación READ para sp_firma_save)
-- NOTA: Tabla c_firma_save no encontrada, requiere implementación manual
CREATE OR REPLACE FUNCTION sp_firma_save()
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


-- SP: frmimplicenciareglamentada_sp_create_licencia_reglamentada (Operación CREATE para frmimplicenciareglamentada_sp_create_licencia_reglamentada)
CREATE OR REPLACE FUNCTION frmimplicenciareglamentada_sp_create_licencia_reglamentada(
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


-- SP: frmimplicenciareglamentada_sp_update_licencia_reglamentada (Operación UPDATE para frmimplicenciareglamentada_sp_update_licencia_reglamentada)
CREATE OR REPLACE FUNCTION frmimplicenciareglamentada_sp_update_licencia_reglamentada(
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


-- SP: frmimplicenciareglamentada_sp_delete_licencia_reglamentada (Operación DELETE para frmimplicenciareglamentada_sp_delete_licencia_reglamentada)
CREATE OR REPLACE FUNCTION frmimplicenciareglamentada_sp_delete_licencia_reglamentada(
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


-- SP: gruposanunciosabcfrm_sp_anuncios_grupos_insert (Operación READ para gruposanunciosabcfrm_sp_anuncios_grupos_insert)
CREATE OR REPLACE FUNCTION gruposanunciosabcfrm_sp_anuncios_grupos_insert(
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


-- SP: gruposanunciosabcfrm_sp_anuncios_grupos_update (Operación UPDATE para gruposanunciosabcfrm_sp_anuncios_grupos_update)
CREATE OR REPLACE FUNCTION gruposanunciosabcfrm_sp_anuncios_grupos_update(
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


-- SP: gruposanunciosabcfrm_sp_anuncios_grupos_delete (Operación DELETE para gruposanunciosabcfrm_sp_anuncios_grupos_delete)
CREATE OR REPLACE FUNCTION gruposanunciosabcfrm_sp_anuncios_grupos_delete(
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


-- SP: insert_grupo_anuncio (Operación READ para insert_grupo_anuncio)
CREATE OR REPLACE FUNCTION insert_grupo_anuncio(
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


-- SP: update_grupo_anuncio (Operación READ para update_grupo_anuncio)
CREATE OR REPLACE FUNCTION update_grupo_anuncio(
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


-- SP: delete_grupo_anuncio (Operación READ para delete_grupo_anuncio)
CREATE OR REPLACE FUNCTION delete_grupo_anuncio(
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


