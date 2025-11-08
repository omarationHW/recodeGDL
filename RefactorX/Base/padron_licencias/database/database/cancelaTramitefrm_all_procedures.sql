-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: cancelaTramitefrm
-- Generado: 2025-08-27 16:33:29
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_get_tramite_by_id
-- Tipo: Catalog
-- Descripción: Obtiene todos los datos de un trámite por su id_tramite.
-- --------------------------------------------

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

-- ============================================

-- SP 2/3: sp_get_giro_by_id
-- Tipo: Catalog
-- Descripción: Obtiene la descripción del giro por id_giro.
-- --------------------------------------------

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

-- ============================================

-- SP 3/3: sp_cancel_tramite
-- Tipo: CRUD
-- Descripción: Cancela un trámite si su estatus lo permite y almacena el motivo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cancel_tramite(p_id_tramite INTEGER, p_motivo TEXT)
RETURNS TABLE (
    result TEXT,
    new_status VARCHAR(1)
) AS $$
DECLARE
    v_estatus VARCHAR(1);
    v_motivo TEXT;
BEGIN
    SELECT estatus INTO v_estatus FROM tramites WHERE id_tramite = p_id_tramite;
    IF v_estatus IS NULL THEN
        RETURN QUERY SELECT 'Trámite no encontrado'::TEXT, NULL::VARCHAR;
        RETURN;
    END IF;
    IF v_estatus = 'C' THEN
        RETURN QUERY SELECT 'El trámite ya se encuentra cancelado'::TEXT, v_estatus;
        RETURN;
    END IF;
    IF v_estatus = 'A' THEN
        RETURN QUERY SELECT 'El trámite ya se encuentra aprobado. No se puede cancelar.'::TEXT, v_estatus;
        RETURN;
    END IF;
    v_motivo := 'CANCELADO POR PADRON Y LICENCIAS.' || chr(13) || chr(10) || p_motivo;
    UPDATE tramites SET estatus = 'C', espubic = v_motivo WHERE id_tramite = p_id_tramite;
    RETURN QUERY SELECT 'Trámite cancelado exitosamente'::TEXT, 'C'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- ============================================

