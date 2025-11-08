-- =====================================================
-- STORED PROCEDURES - cancelaTramitefrm.vue (TIPOS CORREGIDOS)
-- Módulo: Padrón de Licencias
-- Funcionalidad: Cancelación de Trámites
-- Base de Datos: padron_licencias (192.168.6.146)
-- Esquema: comun
-- Usuario: refact
-- Fecha: 2025-11-08
-- SPs: 3
-- =====================================================

-- SP 1/3: sp_get_tramite_by_id
-- Obtiene todos los datos de un trámite por su id_tramite
-- TIPOS CORREGIDOS para coincidir EXACTAMENTE con comun.tramites

DROP FUNCTION IF EXISTS comun.sp_get_tramite_by_id(INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_get_tramite_by_id(p_id_tramite INTEGER)
RETURNS TABLE (
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite CHAR(2),
    x NUMERIC,
    y NUMERIC,
    zona SMALLINT,
    subzona SMALLINT,
    actividad CHAR(130),
    cvecuenta INTEGER,
    recaud SMALLINT,
    licencia_ref INTEGER,
    tramita_apoderado VARCHAR(100),
    rfc CHAR(13),
    curp CHAR(18),
    domicilio CHAR(50),
    numext_prop INTEGER,
    numint_prop CHAR(5),
    colonia_prop CHAR(25),
    telefono_prop CHAR(30),
    email CHAR(50),
    cvecalle INTEGER,
    ubicacion CHAR(50),
    numext_ubic INTEGER,
    letraext_ubic CHAR(3),
    letraint_ubic CHAR(3),
    colonia_ubic CHAR(25),
    espubic CHAR(60),
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
    texto_anuncio CHAR(50),
    medidas1 NUMERIC,
    medidas2 NUMERIC,
    area_anuncio NUMERIC,
    num_caras SMALLINT,
    calificacion NUMERIC,
    usr_califica CHAR(10),
    estatus CHAR(1),
    id_licencia INTEGER,
    id_anuncio INTEGER,
    feccap DATE,
    capturista CHAR(10),
    numint_ubic CHAR(5),
    bloqueado SMALLINT,
    dictamen SMALLINT,
    observaciones TEXT,
    rhorario CHAR(50),
    cp INTEGER,
    id_giro INTEGER,
    propietario CHAR(80),
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
    FROM comun.tramites t
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

-- =====================================================

-- SP 2/3: sp_get_giro_by_id
-- Obtiene la descripción del giro por id_giro

DROP FUNCTION IF EXISTS comun.sp_get_giro_by_id(INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_get_giro_by_id(p_id_giro INTEGER)
RETURNS TABLE (
    id_giro INTEGER,
    descripcion VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        g.giro::INTEGER AS id_giro,
        g.descripcion::VARCHAR(255)
    FROM comun.liccat_giros g
    WHERE g.giro = p_id_giro
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- =====================================================

-- SP 3/3: sp_cancel_tramite
-- Cancela un trámite si su estatus lo permite y almacena el motivo

DROP FUNCTION IF EXISTS comun.sp_cancel_tramite(INTEGER, TEXT);

CREATE OR REPLACE FUNCTION comun.sp_cancel_tramite(p_id_tramite INTEGER, p_motivo TEXT)
RETURNS TABLE (
    result TEXT,
    new_status CHAR(1)
) AS $$
DECLARE
    v_estatus CHAR(1);
    v_motivo TEXT;
BEGIN
    -- Obtener el estatus actual del trámite
    SELECT estatus INTO v_estatus FROM comun.tramites WHERE id_tramite = p_id_tramite;

    -- Validar que el trámite existe
    IF v_estatus IS NULL THEN
        RETURN QUERY SELECT 'Trámite no encontrado'::TEXT, NULL::CHAR(1);
        RETURN;
    END IF;

    -- Validar que no esté ya cancelado
    IF v_estatus = 'C' THEN
        RETURN QUERY SELECT 'El trámite ya se encuentra cancelado'::TEXT, v_estatus;
        RETURN;
    END IF;

    -- Validar que no esté aprobado
    IF v_estatus = 'A' THEN
        RETURN QUERY SELECT 'El trámite ya se encuentra aprobado. No se puede cancelar.'::TEXT, v_estatus;
        RETURN;
    END IF;

    -- Construir el motivo completo
    v_motivo := 'CANCELADO POR PADRON Y LICENCIAS.' || chr(13) || chr(10) || p_motivo;

    -- Actualizar el trámite
    UPDATE comun.tramites
    SET estatus = 'C',
        espubic = v_motivo
    WHERE id_tramite = p_id_tramite;

    -- Retornar resultado exitoso
    RETURN QUERY SELECT 'Trámite cancelado exitosamente'::TEXT, 'C'::CHAR(1);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTARIOS
-- =====================================================

COMMENT ON FUNCTION comun.sp_get_tramite_by_id(INTEGER) IS
'Obtiene todos los datos de un trámite por su id_tramite';

COMMENT ON FUNCTION comun.sp_get_giro_by_id(INTEGER) IS
'Obtiene la descripción del giro por id_giro';

COMMENT ON FUNCTION comun.sp_cancel_tramite(INTEGER, TEXT) IS
'Cancela un trámite si su estatus lo permite y almacena el motivo';

-- =====================================================
-- PERMISOS
-- =====================================================

GRANT EXECUTE ON FUNCTION comun.sp_get_tramite_by_id(INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_get_tramite_by_id(INTEGER) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_get_giro_by_id(INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_get_giro_by_id(INTEGER) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_cancel_tramite(INTEGER, TEXT) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_cancel_tramite(INTEGER, TEXT) TO PUBLIC;
