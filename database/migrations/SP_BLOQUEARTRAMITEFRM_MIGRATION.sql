-- ============================================
-- MIGRACIÓN DE STORED PROCEDURES - BLOQUEARTRAMITEFRM
-- Base de datos: padron_licencias
-- Esquema: informix
-- Generado: 2025-09-22
-- ============================================

\c padron_licencias;
SET search_path TO informix;

-- ============================================
-- SP 1/3: get_tramite
-- Descripción: Obtiene los datos completos de un trámite por su id_tramite
-- ============================================

CREATE OR REPLACE FUNCTION informix.get_tramite(p_id_tramite INTEGER)
RETURNS TABLE (
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR,
    id_giro INTEGER,
    x FLOAT,
    y FLOAT,
    zona SMALLINT,
    subzona SMALLINT,
    actividad VARCHAR,
    cvecuenta INTEGER,
    recaud SMALLINT,
    licencia_ref INTEGER,
    tramita_apoderado VARCHAR,
    propietario VARCHAR,
    primer_ap VARCHAR,
    segundo_ap VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    domicilio VARCHAR,
    numext_prop INTEGER,
    numint_prop VARCHAR,
    colonia_prop VARCHAR,
    telefono_prop VARCHAR,
    email VARCHAR,
    cvecalle INTEGER,
    ubicacion VARCHAR,
    numext_ubic INTEGER,
    letraext_ubic VARCHAR,
    letraint_ubic VARCHAR,
    colonia_ubic VARCHAR,
    espubic VARCHAR,
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
    texto_anuncio VARCHAR,
    medidas1 FLOAT,
    medidas2 FLOAT,
    area_anuncio FLOAT,
    num_caras SMALLINT,
    calificacion NUMERIC,
    usr_califica VARCHAR,
    estatus VARCHAR,
    id_licencia INTEGER,
    id_anuncio INTEGER,
    feccap DATE,
    capturista VARCHAR,
    numint_ubic VARCHAR,
    bloqueado SMALLINT,
    dictamen SMALLINT,
    observaciones TEXT,
    rhorario VARCHAR,
    cp INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM informix.tramites WHERE tramites.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 2/3: get_giro_descripcion
-- Descripción: Obtiene la descripción del giro por id_giro
-- ============================================

CREATE OR REPLACE FUNCTION informix.get_giro_descripcion(p_id_giro INTEGER)
RETURNS TABLE (
    id_giro INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id_giro, c.descripcion
    FROM informix.c_giros c
    WHERE c.id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 3/3: desbloquear_tramite
-- Descripción: Desbloquea un trámite, cancela el último bloqueo vigente y registra el desbloqueo
-- ============================================

CREATE OR REPLACE FUNCTION informix.desbloquear_tramite(
    p_id_tramite INTEGER,
    p_observa VARCHAR,
    p_capturista VARCHAR
)
RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Verificar que el trámite existe
    SELECT COUNT(*) INTO v_count FROM informix.tramites WHERE id_tramite = p_id_tramite;

    IF v_count = 0 THEN
        RETURN QUERY SELECT FALSE, 'No existe el trámite especificado';
        RETURN;
    END IF;

    -- Actualizar campo bloqueado en tramites
    UPDATE informix.tramites SET bloqueado = 0 WHERE id_tramite = p_id_tramite;

    -- Cancelar último bloqueo vigente
    UPDATE informix.bloqueo SET vigente = 'C'
    WHERE id_tramite = p_id_tramite AND vigente = 'V';

    -- Insertar nuevo desbloqueo
    INSERT INTO informix.bloqueo (bloqueado, id_tramite, observa, capturista, fecha_mov, vigente)
    VALUES (0, p_id_tramite, p_observa, p_capturista, CURRENT_DATE, 'V');

    RETURN QUERY SELECT TRUE, 'Trámite desbloqueado correctamente';

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error al desbloquear trámite: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMENTARIOS DE USO
-- ============================================
-- 1. Obtener datos de trámite: SELECT * FROM informix.get_tramite(12345);
-- 2. Obtener descripción de giro: SELECT * FROM informix.get_giro_descripcion(100);
-- 3. Desbloquear trámite: SELECT * FROM informix.desbloquear_tramite(12345, 'Motivo del desbloqueo', 'usuario_sistema');