-- Stored Procedure: sp_cambiar_estatus_revision
-- Tipo: CRUD
-- Descripción: Cambia el estatus de una revisión, actualiza seg_revision, revisiones y tramites según reglas de negocio.
-- Generado para formulario: estatusfrm
-- Fecha: 2025-08-26 16:17:11

-- Cambia el estatus de una revisión y actualiza tablas relacionadas
CREATE OR REPLACE FUNCTION sp_cambiar_estatus_revision(
    p_revision_id INTEGER,
    p_nuevo_estatus VARCHAR,
    p_usuario VARCHAR,
    p_fecha_revision DATE DEFAULT NULL,
    p_oficio VARCHAR DEFAULT NULL,
    p_calificacion NUMERIC DEFAULT NULL,
    p_costo NUMERIC DEFAULT NULL,
    p_fecha_consejo DATE DEFAULT NULL,
    p_observacion TEXT DEFAULT NULL,
    p_fecha_actual TIMESTAMP DEFAULT now()
) RETURNS TABLE(result TEXT) AS $$
DECLARE
    v_id_tramite INTEGER;
    v_id_dependencia INTEGER;
    v_id_seg_revision INTEGER;
    v_tramite_estatus VARCHAR;
    v_tramite_dictamen INTEGER;
    v_giro_clasificacion VARCHAR;
    v_tipo_tramite INTEGER;
    v_aprobado BOOLEAN := FALSE;
    v_no_aprobado BOOLEAN := FALSE;
    v_oficio VARCHAR;
BEGIN
    -- Buscar datos de la revisión
    SELECT id_tramite, id_dependencia, oficio INTO v_id_tramite, v_id_dependencia, v_oficio
    FROM revisiones WHERE id_revision = p_revision_id;

    -- Actualizar seg_revision (último registro)
    SELECT id INTO v_id_seg_revision FROM seg_revision WHERE id_revision = p_revision_id ORDER BY id DESC LIMIT 1;
    IF v_id_seg_revision IS NULL THEN
        RAISE EXCEPTION 'No existe seg_revision para la revisión %', p_revision_id;
    END IF;

    -- Si el estatus es aprobado, cancelado o no aprobado, no se puede cambiar
    IF EXISTS (SELECT 1 FROM seg_revision WHERE id = v_id_seg_revision AND estatus IN ('A','C','N')) THEN
        RETURN QUERY SELECT 'El estatus ya no se puede cambiar.';
        RETURN;
    END IF;

    -- Actualizar seg_revision
    UPDATE seg_revision SET
        estatus = p_nuevo_estatus,
        fecha_revision = COALESCE(p_fecha_revision, fecha_revision),
        oficio = COALESCE(p_oficio, oficio),
        usr_revisa = p_usuario,
        feccap = p_fecha_actual,
        observacion = COALESCE(observacion, '') || '\n' || COALESCE(p_observacion, '')
    WHERE id = v_id_seg_revision;

    -- Si es prórroga, insertar nuevo seg_revision
    IF p_nuevo_estatus IN ('P','O') THEN
        INSERT INTO seg_revision (id_revision, oficio, fecha_revision, usr_revisa, estatus, feccap, observacion)
        VALUES (p_revision_id, v_oficio, p_fecha_revision, p_usuario, p_nuevo_estatus, p_fecha_actual, p_observacion);
    END IF;

    -- Si es no aprobado, actualizar tramite a rechazado
    IF p_nuevo_estatus = 'N' THEN
        UPDATE tramites SET estatus = 'R' WHERE id_tramite = v_id_tramite;
        v_no_aprobado := TRUE;
    END IF;

    -- Actualizar revisiones
    UPDATE revisiones SET
        estatus = p_nuevo_estatus,
        fecha_termino = CASE WHEN p_nuevo_estatus IN ('A','N') THEN p_fecha_actual ELSE fecha_termino END
    WHERE id_revision = p_revision_id;

    -- Si es aprobado y dependencia es obras públicas, poner dictamen=1
    IF p_nuevo_estatus = 'A' AND v_id_dependencia = 26 THEN
        UPDATE tramites SET dictamen = 1 WHERE id_tramite = v_id_tramite;
    END IF;

    -- Si es aprobado y dependencia es comite de giros restringidos, guardar calificación, costo y fecha consejo
    IF p_nuevo_estatus = 'A' AND v_id_dependencia IN (25,38) THEN
        SELECT clasificacion INTO v_giro_clasificacion FROM c_giros WHERE id_giro = (SELECT id_giro FROM tramites WHERE id_tramite = v_id_tramite);
        SELECT tipo_tramite INTO v_tipo_tramite FROM tramites WHERE id_tramite = v_id_tramite;
        IF v_giro_clasificacion = 'D' AND v_tipo_tramite IN (1,13) THEN
            UPDATE tramites SET
                calificacion = p_calificacion,
                costo = p_costo,
                fecha_consejo = p_fecha_consejo
            WHERE id_tramite = v_id_tramite;
        END IF;
    END IF;

    -- Si es aprobado y dictamen=1, verificar si todas las revisiones están aprobadas
    IF p_nuevo_estatus = 'A' AND (SELECT dictamen FROM tramites WHERE id_tramite = v_id_tramite) = 1 THEN
        IF NOT EXISTS (
            SELECT 1 FROM revisiones r
            JOIN seg_revision s ON s.id_revision = r.id_revision
            WHERE r.id_tramite = v_id_tramite AND s.estatus <> 'A'
        ) THEN
            v_aprobado := TRUE;
        END IF;
    END IF;

    -- Si aprobado, cambiar estatus del tramite (opcional, según reglas)
    -- IF v_aprobado THEN
    --     UPDATE tramites SET estatus = 'A' WHERE id_tramite = v_id_tramite;
    -- END IF;

    -- Si cancelado, cambiar estatus del tramite
    IF p_nuevo_estatus = 'C' THEN
        UPDATE tramites SET estatus = 'C' WHERE id_tramite = v_id_tramite;
    END IF;

    RETURN QUERY SELECT 'Estatus actualizado correctamente.';
END;
$$ LANGUAGE plpgsql;