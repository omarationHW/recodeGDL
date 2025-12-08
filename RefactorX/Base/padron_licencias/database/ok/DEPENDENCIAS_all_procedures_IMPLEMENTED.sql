-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Componente: DEPENDENCIAS
-- Formulario: dependenciasFrm
-- Archivo: DEPENDENCIAS_all_procedures_IMPLEMENTED.sql
-- Generado: 2025-11-20
-- Total SPs: 8
-- ============================================
-- Descripción: Gestión de dependencias gubernamentales para
--              inspecciones y revisiones de trámites de licencias
-- Tablas principales: c_dependencias, revisiones, seg_revision,
--                     dependencias_inspeccion, tramites
-- ============================================

-- ============================================
-- SP 1/8: sp_get_dependencias
-- Tipo: Catálogo
-- Descripción: Obtiene el catálogo de dependencias activas para licencias
-- Parámetros: Ninguno
-- Retorna: TABLE(id_dependencia INT, descripcion TEXT)
-- Uso: Lista de dependencias gubernamentales disponibles para asignar inspecciones
-- --------------------------------------------
CREATE OR REPLACE FUNCTION public.sp_get_dependencias()
RETURNS TABLE(
    id_dependencia INT,
    descripcion TEXT
) AS $$
BEGIN
    -- Retorna solo dependencias activas y habilitadas para licencias
    RETURN QUERY
    SELECT
        c.id_dependencia,
        c.descripcion
    FROM public.c_dependencias c
    WHERE c.licencias = 1
      AND c.vigente = 'V'
    ORDER BY c.descripcion;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_get_dependencias() IS
'Catálogo de dependencias gubernamentales activas para licencias';

-- ============================================
-- SP 2/8: sp_get_tramite_inspecciones
-- Tipo: Consulta/Reporte
-- Descripción: Obtiene las inspecciones/revisiones vigentes de un trámite
-- Parámetros: p_id_tramite INT - ID del trámite
-- Retorna: TABLE(id_revision INT, id_dependencia INT, descripcion TEXT)
-- Uso: Lista de todas las inspecciones asignadas a un trámite específico
-- --------------------------------------------
CREATE OR REPLACE FUNCTION public.sp_get_tramite_inspecciones(
    p_id_tramite INT
)
RETURNS TABLE(
    id_revision INT,
    id_dependencia INT,
    descripcion TEXT
) AS $$
BEGIN
    -- Validar parámetro requerido
    IF p_id_tramite IS NULL OR p_id_tramite <= 0 THEN
        RAISE EXCEPTION 'El ID del trámite es requerido y debe ser mayor a cero';
    END IF;

    -- Retornar inspecciones vigentes del trámite
    RETURN QUERY
    SELECT
        r.id_revision,
        r.id_dependencia,
        d.descripcion
    FROM public.revisiones r
    INNER JOIN public.c_dependencias d ON r.id_dependencia = d.id_dependencia
    WHERE r.id_tramite = p_id_tramite
      AND r.estatus = 'V'
    ORDER BY d.descripcion;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_get_tramite_inspecciones(INT) IS
'Obtiene las inspecciones/revisiones vigentes asignadas a un trámite';

-- ============================================
-- SP 3/8: sp_add_inspeccion
-- Tipo: CRUD - Create
-- Descripción: Agrega una nueva inspección/revisión a un trámite
-- Parámetros:
--   p_id_tramite INT - ID del trámite
--   p_id_dependencia INT - ID de la dependencia
--   p_usuario TEXT - Usuario que realiza la operación
-- Retorna: TABLE(success BOOLEAN, message TEXT, id_revision INT)
-- Uso: Asigna una dependencia gubernamental para inspección del trámite
-- --------------------------------------------
CREATE OR REPLACE FUNCTION public.sp_add_inspeccion(
    p_id_tramite INT,
    p_id_dependencia INT,
    p_usuario TEXT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id_revision INT
) AS $$
DECLARE
    v_exists INT;
    v_new_id_revision INT;
    v_descripcion TEXT;
    v_tramite_existe BOOLEAN;
    v_dependencia_existe BOOLEAN;
BEGIN
    -- Validar parámetros requeridos
    IF p_id_tramite IS NULL OR p_id_tramite <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El ID del trámite es requerido y debe ser mayor a cero'::TEXT, NULL::INT;
        RETURN;
    END IF;

    IF p_id_dependencia IS NULL OR p_id_dependencia <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El ID de la dependencia es requerido y debe ser mayor a cero'::TEXT, NULL::INT;
        RETURN;
    END IF;

    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RETURN QUERY SELECT FALSE, 'El usuario es requerido'::TEXT, NULL::INT;
        RETURN;
    END IF;

    -- Verificar que el trámite existe
    SELECT EXISTS(SELECT 1 FROM public.tramites WHERE id_tramite = p_id_tramite) INTO v_tramite_existe;
    IF NOT v_tramite_existe THEN
        RETURN QUERY SELECT FALSE, 'El trámite especificado no existe'::TEXT, NULL::INT;
        RETURN;
    END IF;

    -- Verificar que la dependencia existe y está activa
    SELECT EXISTS(
        SELECT 1 FROM public.c_dependencias
        WHERE id_dependencia = p_id_dependencia
          AND vigente = 'V'
          AND licencias = 1
    ) INTO v_dependencia_existe;

    IF NOT v_dependencia_existe THEN
        RETURN QUERY SELECT FALSE, 'La dependencia especificada no existe o no está activa para licencias'::TEXT, NULL::INT;
        RETURN;
    END IF;

    -- Verificar que no existe ya esta inspección vigente
    SELECT COUNT(*) INTO v_exists
    FROM public.revisiones
    WHERE id_tramite = p_id_tramite
      AND id_dependencia = p_id_dependencia
      AND estatus = 'V';

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una inspección vigente de esta dependencia para el trámite'::TEXT, NULL::INT;
        RETURN;
    END IF;

    -- Obtener descripción de la dependencia
    SELECT descripcion INTO v_descripcion
    FROM public.c_dependencias
    WHERE id_dependencia = p_id_dependencia;

    -- Insertar la revisión/inspección
    INSERT INTO public.revisiones (
        id_tramite,
        id_dependencia,
        fecha_inicio,
        estatus,
        descripcion
    )
    VALUES (
        p_id_tramite,
        p_id_dependencia,
        NOW(),
        'V',
        v_descripcion
    )
    RETURNING revisiones.id_revision INTO v_new_id_revision;

    -- Registrar en el seguimiento de revisión
    INSERT INTO public.seg_revision (
        id_revision,
        estatus,
        feccap,
        usr_revisa
    )
    VALUES (
        v_new_id_revision,
        'V',
        NOW(),
        p_usuario
    );

    -- Retornar éxito
    RETURN QUERY SELECT TRUE, 'Inspección agregada exitosamente'::TEXT, v_new_id_revision;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_add_inspeccion(INT, INT, TEXT) IS
'Agrega una nueva inspección/revisión de una dependencia a un trámite';

-- ============================================
-- SP 4/8: sp_delete_inspeccion
-- Tipo: CRUD - Delete
-- Descripción: Elimina una inspección/revisión de un trámite
-- Parámetros:
--   p_id_tramite INT - ID del trámite
--   p_id_dependencia INT - ID de la dependencia
-- Retorna: TABLE(success BOOLEAN, message TEXT)
-- Uso: Remueve una dependencia asignada para inspección del trámite
-- --------------------------------------------
CREATE OR REPLACE FUNCTION public.sp_delete_inspeccion(
    p_id_tramite INT,
    p_id_dependencia INT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_id_revision INT;
    v_deleted_count INT;
BEGIN
    -- Validar parámetros requeridos
    IF p_id_tramite IS NULL OR p_id_tramite <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El ID del trámite es requerido y debe ser mayor a cero'::TEXT;
        RETURN;
    END IF;

    IF p_id_dependencia IS NULL OR p_id_dependencia <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El ID de la dependencia es requerido y debe ser mayor a cero'::TEXT;
        RETURN;
    END IF;

    -- Buscar la revisión vigente
    SELECT id_revision INTO v_id_revision
    FROM public.revisiones
    WHERE id_tramite = p_id_tramite
      AND id_dependencia = p_id_dependencia
      AND estatus = 'V'
    LIMIT 1;

    IF v_id_revision IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No existe una inspección vigente de esta dependencia para el trámite'::TEXT;
        RETURN;
    END IF;

    -- Eliminar registros de seguimiento
    DELETE FROM public.seg_revision
    WHERE id_revision = v_id_revision;

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    -- Eliminar la revisión
    DELETE FROM public.revisiones
    WHERE id_revision = v_id_revision;

    -- Retornar éxito
    RETURN QUERY SELECT TRUE, 'Inspección eliminada exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_delete_inspeccion(INT, INT) IS
'Elimina una inspección/revisión de una dependencia de un trámite';

-- ============================================
-- SP 5/8: sp_get_tramite_info
-- Tipo: Consulta/Reporte
-- Descripción: Obtiene información básica de un trámite
-- Parámetros: p_id_tramite INT - ID del trámite
-- Retorna: TABLE(id_tramite INT, propietario TEXT, ubicacion TEXT, estatus TEXT)
-- Uso: Información de cabecera del trámite para contexto de inspecciones
-- --------------------------------------------
CREATE OR REPLACE FUNCTION public.sp_get_tramite_info(
    p_id_tramite INT
)
RETURNS TABLE(
    id_tramite INT,
    propietario TEXT,
    ubicacion TEXT,
    estatus TEXT
) AS $$
BEGIN
    -- Validar parámetro requerido
    IF p_id_tramite IS NULL OR p_id_tramite <= 0 THEN
        RAISE EXCEPTION 'El ID del trámite es requerido y debe ser mayor a cero';
    END IF;

    -- Retornar información del trámite
    RETURN QUERY
    SELECT
        t.id_tramite,
        t.propietario,
        t.ubicacion,
        t.estatus
    FROM public.tramites t
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_get_tramite_info(INT) IS
'Obtiene información básica de un trámite para contexto de inspecciones';

-- ============================================
-- SP 6/8: sp_get_inspecciones_memoria
-- Tipo: Consulta/Reporte
-- Descripción: Obtiene inspecciones de trámite desde tabla temporal/memoria
-- Parámetros: p_tramite_id INT - ID del trámite
-- Retorna: TABLE(id_dependencia INT, descripcion TEXT)
-- Uso: Consulta de inspecciones en proceso (tabla temporal dependencias_inspeccion)
-- --------------------------------------------
CREATE OR REPLACE FUNCTION public.sp_get_inspecciones_memoria(
    p_tramite_id INT
)
RETURNS TABLE(
    id_dependencia INT,
    descripcion TEXT
) AS $$
BEGIN
    -- Validar parámetro requerido
    IF p_tramite_id IS NULL OR p_tramite_id <= 0 THEN
        RAISE EXCEPTION 'El ID del trámite es requerido y debe ser mayor a cero';
    END IF;

    -- Retornar inspecciones desde tabla temporal
    RETURN QUERY
    SELECT
        di.id_dependencia,
        d.descripcion
    FROM public.dependencias_inspeccion di
    INNER JOIN public.c_dependencias d ON d.id_dependencia = di.id_dependencia
    WHERE di.id_tramite = p_tramite_id
    ORDER BY d.descripcion;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_get_inspecciones_memoria(INT) IS
'Obtiene inspecciones de un trámite desde tabla temporal/memoria';

-- ============================================
-- SP 7/8: sp_add_dependencia_inspeccion
-- Tipo: CRUD - Create (Tabla temporal)
-- Descripción: Agrega una dependencia a inspecciones en memoria/temporal
-- Parámetros:
--   p_tramite_id INT - ID del trámite
--   p_id_dependencia INT - ID de la dependencia
--   p_usuario TEXT - Usuario que realiza la operación
-- Retorna: TABLE(success BOOLEAN, message TEXT)
-- Uso: Registra inspección en proceso (tabla temporal antes de confirmar)
-- --------------------------------------------
CREATE OR REPLACE FUNCTION public.sp_add_dependencia_inspeccion(
    p_tramite_id INT,
    p_id_dependencia INT,
    p_usuario TEXT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_existe BOOLEAN;
    v_dependencia_existe BOOLEAN;
BEGIN
    -- Validar parámetros requeridos
    IF p_tramite_id IS NULL OR p_tramite_id <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El ID del trámite es requerido y debe ser mayor a cero'::TEXT;
        RETURN;
    END IF;

    IF p_id_dependencia IS NULL OR p_id_dependencia <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El ID de la dependencia es requerido y debe ser mayor a cero'::TEXT;
        RETURN;
    END IF;

    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RETURN QUERY SELECT FALSE, 'El usuario es requerido'::TEXT;
        RETURN;
    END IF;

    -- Verificar que la dependencia existe y está activa
    SELECT EXISTS(
        SELECT 1 FROM public.c_dependencias
        WHERE id_dependencia = p_id_dependencia
          AND vigente = 'V'
          AND licencias = 1
    ) INTO v_dependencia_existe;

    IF NOT v_dependencia_existe THEN
        RETURN QUERY SELECT FALSE, 'La dependencia especificada no existe o no está activa para licencias'::TEXT;
        RETURN;
    END IF;

    -- Verificar si ya existe la inspección en memoria
    SELECT EXISTS(
        SELECT 1 FROM public.dependencias_inspeccion
        WHERE id_tramite = p_tramite_id
          AND id_dependencia = p_id_dependencia
    ) INTO v_existe;

    IF v_existe THEN
        RETURN QUERY SELECT FALSE, 'Ya existe la inspección para esta dependencia en memoria'::TEXT;
        RETURN;
    END IF;

    -- Insertar en tabla temporal
    INSERT INTO public.dependencias_inspeccion (
        id_tramite,
        id_dependencia,
        usuario_alta,
        fecha_alta
    )
    VALUES (
        p_tramite_id,
        p_id_dependencia,
        p_usuario,
        NOW()
    );

    -- Retornar éxito
    RETURN QUERY SELECT TRUE, 'Inspección agregada a memoria exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_add_dependencia_inspeccion(INT, INT, TEXT) IS
'Agrega una dependencia a inspecciones en tabla temporal/memoria';

-- ============================================
-- SP 8/8: sp_remove_dependencia_inspeccion
-- Tipo: CRUD - Delete (Tabla temporal)
-- Descripción: Elimina una dependencia de inspecciones en memoria/temporal
-- Parámetros:
--   p_tramite_id INT - ID del trámite
--   p_id_dependencia INT - ID de la dependencia
-- Retorna: TABLE(success BOOLEAN, message TEXT)
-- Uso: Remueve inspección en proceso (tabla temporal)
-- --------------------------------------------
CREATE OR REPLACE FUNCTION public.sp_remove_dependencia_inspeccion(
    p_tramite_id INT,
    p_id_dependencia INT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_deleted_count INT;
BEGIN
    -- Validar parámetros requeridos
    IF p_tramite_id IS NULL OR p_tramite_id <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El ID del trámite es requerido y debe ser mayor a cero'::TEXT;
        RETURN;
    END IF;

    IF p_id_dependencia IS NULL OR p_id_dependencia <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El ID de la dependencia es requerido y debe ser mayor a cero'::TEXT;
        RETURN;
    END IF;

    -- Eliminar de tabla temporal
    DELETE FROM public.dependencias_inspeccion
    WHERE id_tramite = p_tramite_id
      AND id_dependencia = p_id_dependencia;

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    IF v_deleted_count = 0 THEN
        RETURN QUERY SELECT FALSE, 'No se encontró la inspección en memoria para eliminar'::TEXT;
        RETURN;
    END IF;

    -- Retornar éxito
    RETURN QUERY SELECT TRUE, 'Inspección removida de memoria exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_remove_dependencia_inspeccion(INT, INT) IS
'Elimina una dependencia de inspecciones en tabla temporal/memoria';

-- ============================================
-- FIN DE STORED PROCEDURES - DEPENDENCIAS
-- Total: 8 procedures
-- Fecha: 2025-11-20
-- ============================================
