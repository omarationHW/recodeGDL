-- =====================================================
-- STORED PROCEDURES - ReactivaTramite.vue
-- Módulo: Padrón de Licencias
-- Funcionalidad: Reactivar Trámites Cancelados
-- Base de Datos: padron_licencias (192.168.6.146)
-- Usuario: refact
-- Fecha: 2025-11-07
-- =====================================================

-- NOTA: Este componente reutiliza los SPs de cancelaTramitefrm:
-- - sp_get_tramite_by_id (ya existe)
-- - sp_get_giro_by_id (ya existe)
-- Solo necesitamos crear el SP de reactivación

-- =====================================================
-- SP 1: sp_reactivar_tramite
-- Descripción: Reactiva un trámite cancelado
-- Autor: Sistema RefactorX
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_reactivar_tramite(INTEGER, TEXT, TEXT);

CREATE OR REPLACE FUNCTION comun.sp_reactivar_tramite(
    p_id_tramite INTEGER,
    p_motivo TEXT,
    p_usuario TEXT
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id_tramite INTEGER,
    estatus_anterior CHAR(1),
    estatus_nuevo CHAR(1)
) AS $$
DECLARE
    v_estatus_actual CHAR(1);
    v_motivo_reactivacion TEXT;
BEGIN
    -- Verificar que el trámite existe
    SELECT estatus INTO v_estatus_actual
    FROM comun.tramites
    WHERE id_tramite = p_id_tramite;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            FALSE,
            'El trámite no existe en el sistema'::TEXT,
            p_id_tramite,
            NULL::CHAR(1),
            NULL::CHAR(1);
        RETURN;
    END IF;

    -- Verificar que el trámite esté cancelado
    IF v_estatus_actual != 'C' THEN
        RETURN QUERY SELECT
            FALSE,
            'Solo se pueden reactivar trámites cancelados. Estado actual: ' || v_estatus_actual::TEXT,
            p_id_tramite,
            v_estatus_actual,
            v_estatus_actual;
        RETURN;
    END IF;

    -- Construir el motivo de reactivación
    v_motivo_reactivacion := 'REACTIVADO POR ' || UPPER(p_usuario) || '.' || chr(13) || chr(10) ||
                             'FECHA: ' || TO_CHAR(NOW(), 'DD/MM/YYYY HH24:MI:SS') || chr(13) || chr(10) ||
                             'MOTIVO: ' || p_motivo;

    -- Actualizar el trámite: cambiar estatus a 'T' (Trámite en proceso)
    -- y guardar el motivo en el campo observaciones
    UPDATE comun.tramites
    SET
        estatus = 'T',
        observaciones = COALESCE(observaciones || chr(13) || chr(10), '') || v_motivo_reactivacion,
        feccap = NOW()  -- Actualizar fecha de última modificación
    WHERE id_tramite = p_id_tramite;

    -- Retornar resultado exitoso
    RETURN QUERY SELECT
        TRUE,
        'Trámite reactivado exitosamente. Ahora puede continuar con el proceso normal.'::TEXT,
        p_id_tramite,
        'C'::CHAR(1),
        'T'::CHAR(1);
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTARIOS Y PERMISOS
-- =====================================================

COMMENT ON FUNCTION comun.sp_reactivar_tramite(INTEGER, TEXT, TEXT) IS
'Reactiva un trámite que fue cancelado previamente. Cambia el estatus de C (Cancelado) a T (Trámite en proceso) y registra el motivo de la reactivación.';

-- Otorgar permisos de ejecución
GRANT EXECUTE ON FUNCTION comun.sp_reactivar_tramite(INTEGER, TEXT, TEXT) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_reactivar_tramite(INTEGER, TEXT, TEXT) TO PUBLIC;

-- =====================================================
-- NOTAS DE IMPLEMENTACIÓN
-- =====================================================

/*
ESTADOS DE TRÁMITES:
- 'T' = Trámite en proceso (activo)
- 'A' = Autorizado
- 'C' = Cancelado
- 'R' = Rechazado

FLUJO DE REACTIVACIÓN:
1. Verificar que el trámite existe
2. Validar que esté en estado 'C' (Cancelado)
3. Cambiar estado a 'T' (Trámite en proceso)
4. Registrar motivo de reactivación en observaciones
5. Actualizar fecha de captura

TABLAS INVOLUCRADAS:
- comun.tramites (tabla principal de trámites)

CAMPOS ACTUALIZADOS:
- estatus: 'C' → 'T'
- observaciones: Se concatena el motivo de reactivación
- feccap: Se actualiza a la fecha/hora actual

VALIDACIONES:
- El trámite debe existir
- El trámite debe estar en estado 'C' (Cancelado)
- Se requiere motivo de reactivación
- Se registra usuario que reactiva

CASOS DE USO:
- Trámite cancelado por error
- Documentación faltante fue presentada
- Resolución favorable de revisión
- Corrección de datos que impedían continuar
*/

-- =====================================================
-- EJEMPLO DE USO
-- =====================================================

/*
-- Reactivar un trámite cancelado
SELECT * FROM comun.sp_reactivar_tramite(
    349786,  -- ID del trámite
    'Se presentó la documentación faltante y se validó correctamente',  -- Motivo
    'admin'  -- Usuario que reactiva
);

-- Verificar el cambio de estado
SELECT id_tramite, estatus, observaciones, feccap
FROM comun.tramites
WHERE id_tramite = 349786;
*/
