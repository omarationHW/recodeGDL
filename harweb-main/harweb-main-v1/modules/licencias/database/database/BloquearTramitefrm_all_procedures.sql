-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: BloquearTramitefrm
-- Generado: 2025-08-27 16:06:44
-- Total SPs: 5
-- ============================================

-- SP 1/5: get_tramite
-- Tipo: Catalog
-- Descripción: Obtiene los datos completos de un trámite por su id_tramite.
-- --------------------------------------------

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

-- ============================================

-- SP 2/5: get_bloqueos
-- Tipo: Catalog
-- Descripción: Obtiene el historial de bloqueos/desbloqueos de un trámite.
-- --------------------------------------------

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

-- ============================================

-- SP 3/5: get_giro_descripcion
-- Tipo: Catalog
-- Descripción: Obtiene la descripción del giro por id_giro.
-- --------------------------------------------

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

-- ============================================

-- SP 4/5: bloquear_tramite
-- Tipo: CRUD
-- Descripción: Bloquea un trámite, cancela el último bloqueo vigente y registra el nuevo bloqueo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION bloquear_tramite(p_id_tramite integer, p_observa varchar, p_capturista varchar)
RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_count integer;
BEGIN
    -- Actualizar campo bloqueado en tramites
    UPDATE tramites SET bloqueado = 1 WHERE id_tramite = p_id_tramite;
    -- Cancelar último bloqueo vigente
    UPDATE bloqueo SET vigente = 'C' WHERE id_tramite = p_id_tramite AND vigente = 'V';
    -- Insertar nuevo bloqueo
    INSERT INTO bloqueo (bloqueado, id_tramite, observa, capturista, fecha_mov, vigente)
    VALUES (1, p_id_tramite, p_observa, p_capturista, CURRENT_DATE, 'V');
    RETURN QUERY SELECT true, 'Trámite bloqueado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, 'Error al bloquear trámite: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: desbloquear_tramite
-- Tipo: CRUD
-- Descripción: Desbloquea un trámite, cancela el último bloqueo vigente y registra el desbloqueo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION desbloquear_tramite(p_id_tramite integer, p_observa varchar, p_capturista varchar)
RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_count integer;
BEGIN
    -- Actualizar campo bloqueado en tramites
    UPDATE tramites SET bloqueado = 0 WHERE id_tramite = p_id_tramite;
    -- Cancelar último bloqueo vigente
    UPDATE bloqueo SET vigente = 'C' WHERE id_tramite = p_id_tramite AND vigente = 'V';
    -- Insertar nuevo desbloqueo
    INSERT INTO bloqueo (bloqueado, id_tramite, observa, capturista, fecha_mov, vigente)
    VALUES (0, p_id_tramite, p_observa, p_capturista, CURRENT_DATE, 'V');
    RETURN QUERY SELECT true, 'Trámite desbloqueado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, 'Error al desbloquear trámite: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================

