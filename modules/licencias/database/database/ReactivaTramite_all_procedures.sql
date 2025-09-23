-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ReactivaTramite
-- Generado: 2025-08-27 19:03:47
-- Total SPs: 2
-- ============================================

-- SP 1/2: get_tramite
-- Tipo: Catalog
-- Descripción: Obtiene los datos completos de un trámite, incluyendo giro y campos calculados.
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
    letrain_ubic varchar,
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
    cp integer,
    descripcion_giro varchar,
    propietarionvo varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.*, g.descripcion as descripcion_giro,
           trim(t.primer_ap) || ' ' || trim(t.segundo_ap) || ' ' || trim(t.propietario) as propietarionvo
    FROM tramites t
    LEFT JOIN c_giros g ON t.id_giro = g.id_giro
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: reactivar_tramite
-- Tipo: CRUD
-- Descripción: Reactivar un trámite cancelado o rechazado, actualizando estatus y revisiones.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION reactivar_tramite(p_id_tramite integer, p_motivo text)
RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_estatus varchar;
    v_motivo text;
    v_count integer;
BEGIN
    SELECT estatus INTO v_estatus FROM tramites WHERE id_tramite = p_id_tramite;
    IF v_estatus IS NULL THEN
        RETURN QUERY SELECT false, 'Trámite no encontrado.';
        RETURN;
    END IF;
    IF v_estatus NOT IN ('C', 'R') THEN
        RETURN QUERY SELECT false, 'El trámite no se encuentra cancelado o rechazado.';
        RETURN;
    END IF;
    IF v_estatus = 'A' THEN
        RETURN QUERY SELECT false, 'El trámite ya se encuentra aprobado. No se puede reactivar.';
        RETURN;
    END IF;
    v_motivo := 'REACTIVADO POR PADRON Y LICENCIAS.\n' || p_motivo;
    -- Actualizar tramite
    UPDATE tramites SET estatus = 'T', espubic = v_motivo WHERE id_tramite = p_id_tramite;
    -- Reactivar revisiones
    UPDATE revisiones SET estatus = 'V'
    WHERE id_tramite = p_id_tramite AND estatus IN ('C', 'N');
    -- Reactivar seg_revision
    UPDATE seg_revision SET estatus = 'V', observacion = v_motivo
    WHERE id_revision IN (
        SELECT id_revision FROM revisiones WHERE id_tramite = p_id_tramite AND estatus = 'V'
    );
    RETURN QUERY SELECT true, 'Trámite reactivado correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

