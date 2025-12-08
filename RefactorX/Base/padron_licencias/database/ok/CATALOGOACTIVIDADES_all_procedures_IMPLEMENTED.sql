-- ============================================
-- STORED PROCEDURES IMPLEMENTADOS
-- Componente: CatalogoActividades
-- Módulo: padron_licencias
-- Generado: 2025-11-20
-- Total SPs: 6
-- ============================================

-- ============================================
-- CONFIGURACIÓN DE ESQUEMA
-- ============================================
-- Schema: public
-- Tabla principal: c_actividades_lic
-- Tabla relacionada: c_giros

-- ============================================
-- SP 1/6: catalogo_actividades_list
-- Tipo: CONSULTA
-- Descripción: Lista actividades económicas con filtro opcional por descripción
-- Parámetros:
--   p_descripcion: Filtro de búsqueda por descripción (opcional, case-insensitive)
-- Retorna: Lista completa de actividades con campos de auditoría
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_catalogo_actividades_list(
    p_descripcion TEXT DEFAULT NULL
)
RETURNS TABLE(
    id_actividad INTEGER,
    id_giro INTEGER,
    descripcion TEXT,
    observaciones TEXT,
    vigente CHAR(1),
    fecha_alta TIMESTAMP,
    usuario_alta VARCHAR(50),
    fecha_baja TIMESTAMP,
    usuario_baja VARCHAR(50),
    motivo_baja TEXT
) AS $$
BEGIN
    -- Validación: Si el parámetro está vacío, tratarlo como NULL
    IF p_descripcion IS NOT NULL AND TRIM(p_descripcion) = '' THEN
        p_descripcion := NULL;
    END IF;

    RETURN QUERY
    SELECT
        c.id_actividad,
        c.id_giro,
        c.descripcion,
        c.observaciones,
        c.vigente,
        c.fecha_alta,
        c.usuario_alta,
        c.fecha_baja,
        c.usuario_baja,
        c.motivo_baja
    FROM c_actividades_lic c
    WHERE (
        p_descripcion IS NULL
        OR unaccent(LOWER(c.descripcion)) ILIKE '%' || unaccent(LOWER(p_descripcion)) || '%'
    )
    ORDER BY c.id_actividad DESC;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al listar actividades: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_catalogo_actividades_list(TEXT) IS
'Lista actividades económicas con filtro opcional por descripción - Módulo: padron_licencias';

-- ============================================
-- SP 2/6: catalogo_actividades_get
-- Tipo: CONSULTA
-- Descripción: Obtiene una actividad específica por ID
-- Parámetros:
--   p_id_actividad: ID de la actividad a consultar
-- Retorna: Registro completo de la actividad
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_catalogo_actividades_get(
    p_id_actividad INTEGER
)
RETURNS TABLE(
    id_actividad INTEGER,
    id_giro INTEGER,
    descripcion TEXT,
    observaciones TEXT,
    vigente CHAR(1),
    fecha_alta TIMESTAMP,
    usuario_alta VARCHAR(50),
    fecha_baja TIMESTAMP,
    usuario_baja VARCHAR(50),
    motivo_baja TEXT
) AS $$
BEGIN
    -- Validación: ID requerido
    IF p_id_actividad IS NULL OR p_id_actividad <= 0 THEN
        RAISE EXCEPTION 'El ID de actividad es requerido y debe ser mayor a cero';
    END IF;

    RETURN QUERY
    SELECT
        c.id_actividad,
        c.id_giro,
        c.descripcion,
        c.observaciones,
        c.vigente,
        c.fecha_alta,
        c.usuario_alta,
        c.fecha_baja,
        c.usuario_baja,
        c.motivo_baja
    FROM c_actividades_lic c
    WHERE c.id_actividad = p_id_actividad;

    -- Validación: Verificar si existe
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró la actividad con ID: %', p_id_actividad;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al obtener actividad: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_catalogo_actividades_get(INTEGER) IS
'Obtiene una actividad específica por ID - Módulo: padron_licencias';

-- ============================================
-- SP 3/6: catalogo_actividades_create
-- Tipo: INSERCIÓN
-- Descripción: Crea una nueva actividad económica
-- Parámetros:
--   p_id_giro: ID del giro al que pertenece
--   p_descripcion: Descripción de la actividad
--   p_observaciones: Observaciones adicionales (opcional)
--   p_vigente: Estado de vigencia (V=Vigente, C=Cancelado)
--   p_usuario_alta: Usuario que registra
-- Retorna: success (BOOLEAN), message (TEXT), id_actividad (INTEGER)
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_catalogo_actividades_create(
    p_id_giro INTEGER,
    p_descripcion TEXT,
    p_observaciones TEXT DEFAULT NULL,
    p_vigente CHAR(1) DEFAULT 'V',
    p_usuario_alta VARCHAR(50)
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id_actividad INTEGER
) AS $$
DECLARE
    v_new_id INTEGER;
    v_giro_existe BOOLEAN;
BEGIN
    -- Validación: Parámetros requeridos
    IF p_id_giro IS NULL OR p_id_giro <= 0 THEN
        RAISE EXCEPTION 'El ID de giro es requerido y debe ser mayor a cero';
    END IF;

    IF p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN
        RAISE EXCEPTION 'La descripción de la actividad es requerida';
    END IF;

    IF p_usuario_alta IS NULL OR TRIM(p_usuario_alta) = '' THEN
        RAISE EXCEPTION 'El usuario que registra es requerido';
    END IF;

    -- Validación: Estado vigente válido
    IF p_vigente NOT IN ('V', 'C') THEN
        RAISE EXCEPTION 'El estado vigente debe ser V (Vigente) o C (Cancelado)';
    END IF;

    -- Validación: Verificar que el giro existe
    SELECT EXISTS(SELECT 1 FROM c_giros WHERE id_giro = p_id_giro) INTO v_giro_existe;

    IF NOT v_giro_existe THEN
        RAISE EXCEPTION 'El giro con ID % no existe', p_id_giro;
    END IF;

    -- Inserción de la actividad
    INSERT INTO c_actividades_lic (
        id_giro,
        descripcion,
        observaciones,
        vigente,
        fecha_alta,
        usuario_alta
    )
    VALUES (
        p_id_giro,
        TRIM(p_descripcion),
        CASE WHEN p_observaciones IS NOT NULL THEN TRIM(p_observaciones) ELSE NULL END,
        p_vigente,
        NOW(),
        p_usuario_alta
    )
    RETURNING c_actividades_lic.id_actividad INTO v_new_id;

    -- Retorno exitoso
    RETURN QUERY
    SELECT
        TRUE,
        'Actividad creada exitosamente'::TEXT,
        v_new_id;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            FALSE,
            ('Error al crear actividad: ' || SQLERRM)::TEXT,
            NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_catalogo_actividades_create(INTEGER, TEXT, TEXT, CHAR, VARCHAR) IS
'Crea una nueva actividad económica - Módulo: padron_licencias';

-- ============================================
-- SP 4/6: catalogo_actividades_update
-- Tipo: ACTUALIZACIÓN
-- Descripción: Actualiza una actividad existente
-- Parámetros:
--   p_id_actividad: ID de la actividad a actualizar
--   p_id_giro: ID del giro al que pertenece
--   p_descripcion: Descripción de la actividad
--   p_observaciones: Observaciones adicionales (opcional)
--   p_vigente: Estado de vigencia (V=Vigente, C=Cancelado)
--   p_usuario_mod: Usuario que modifica
-- Retorna: success (BOOLEAN), message (TEXT), rows_affected (INTEGER)
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_catalogo_actividades_update(
    p_id_actividad INTEGER,
    p_id_giro INTEGER,
    p_descripcion TEXT,
    p_observaciones TEXT DEFAULT NULL,
    p_vigente CHAR(1),
    p_usuario_mod VARCHAR(50)
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    rows_affected INTEGER
) AS $$
DECLARE
    v_rows_affected INTEGER;
    v_giro_existe BOOLEAN;
    v_actividad_existe BOOLEAN;
BEGIN
    -- Validación: Parámetros requeridos
    IF p_id_actividad IS NULL OR p_id_actividad <= 0 THEN
        RAISE EXCEPTION 'El ID de actividad es requerido y debe ser mayor a cero';
    END IF;

    IF p_id_giro IS NULL OR p_id_giro <= 0 THEN
        RAISE EXCEPTION 'El ID de giro es requerido y debe ser mayor a cero';
    END IF;

    IF p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN
        RAISE EXCEPTION 'La descripción de la actividad es requerida';
    END IF;

    IF p_usuario_mod IS NULL OR TRIM(p_usuario_mod) = '' THEN
        RAISE EXCEPTION 'El usuario que modifica es requerido';
    END IF;

    -- Validación: Estado vigente válido
    IF p_vigente NOT IN ('V', 'C') THEN
        RAISE EXCEPTION 'El estado vigente debe ser V (Vigente) o C (Cancelado)';
    END IF;

    -- Validación: Verificar que la actividad existe
    SELECT EXISTS(SELECT 1 FROM c_actividades_lic WHERE id_actividad = p_id_actividad)
    INTO v_actividad_existe;

    IF NOT v_actividad_existe THEN
        RAISE EXCEPTION 'La actividad con ID % no existe', p_id_actividad;
    END IF;

    -- Validación: Verificar que el giro existe
    SELECT EXISTS(SELECT 1 FROM c_giros WHERE id_giro = p_id_giro) INTO v_giro_existe;

    IF NOT v_giro_existe THEN
        RAISE EXCEPTION 'El giro con ID % no existe', p_id_giro;
    END IF;

    -- Actualización de la actividad
    UPDATE c_actividades_lic
    SET
        id_giro = p_id_giro,
        descripcion = TRIM(p_descripcion),
        observaciones = CASE WHEN p_observaciones IS NOT NULL THEN TRIM(p_observaciones) ELSE NULL END,
        vigente = p_vigente,
        -- Si se reactiva (V), actualizar fecha y usuario de alta
        fecha_alta = CASE WHEN p_vigente = 'V' THEN NOW() ELSE fecha_alta END,
        usuario_alta = CASE WHEN p_vigente = 'V' THEN p_usuario_mod ELSE usuario_alta END,
        -- Si se cancela (C), actualizar fecha y usuario de baja
        fecha_baja = CASE WHEN p_vigente = 'C' THEN NOW() ELSE NULL END,
        usuario_baja = CASE WHEN p_vigente = 'C' THEN p_usuario_mod ELSE NULL END
    WHERE id_actividad = p_id_actividad;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    -- Retorno exitoso
    RETURN QUERY
    SELECT
        TRUE,
        'Actividad actualizada exitosamente'::TEXT,
        v_rows_affected;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            FALSE,
            ('Error al actualizar actividad: ' || SQLERRM)::TEXT,
            0;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_catalogo_actividades_update(INTEGER, INTEGER, TEXT, TEXT, CHAR, VARCHAR) IS
'Actualiza una actividad existente - Módulo: padron_licencias';

-- ============================================
-- SP 5/6: catalogo_actividades_delete
-- Tipo: ELIMINACIÓN (SOFT DELETE)
-- Descripción: Marca una actividad como cancelada (baja lógica)
-- Parámetros:
--   p_id_actividad: ID de la actividad a cancelar
--   p_usuario_baja: Usuario que cancela
--   p_motivo_baja: Motivo de la cancelación
-- Retorna: success (BOOLEAN), message (TEXT), rows_affected (INTEGER)
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_catalogo_actividades_delete(
    p_id_actividad INTEGER,
    p_usuario_baja VARCHAR(50),
    p_motivo_baja TEXT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    rows_affected INTEGER
) AS $$
DECLARE
    v_rows_affected INTEGER;
    v_actividad_existe BOOLEAN;
    v_ya_cancelada BOOLEAN;
BEGIN
    -- Validación: Parámetros requeridos
    IF p_id_actividad IS NULL OR p_id_actividad <= 0 THEN
        RAISE EXCEPTION 'El ID de actividad es requerido y debe ser mayor a cero';
    END IF;

    IF p_usuario_baja IS NULL OR TRIM(p_usuario_baja) = '' THEN
        RAISE EXCEPTION 'El usuario que cancela es requerido';
    END IF;

    IF p_motivo_baja IS NULL OR TRIM(p_motivo_baja) = '' THEN
        RAISE EXCEPTION 'El motivo de cancelación es requerido';
    END IF;

    -- Validación: Verificar que la actividad existe
    SELECT EXISTS(SELECT 1 FROM c_actividades_lic WHERE id_actividad = p_id_actividad)
    INTO v_actividad_existe;

    IF NOT v_actividad_existe THEN
        RAISE EXCEPTION 'La actividad con ID % no existe', p_id_actividad;
    END IF;

    -- Validación: Verificar si ya está cancelada
    SELECT vigente = 'C' INTO v_ya_cancelada
    FROM c_actividades_lic
    WHERE id_actividad = p_id_actividad;

    IF v_ya_cancelada THEN
        RAISE EXCEPTION 'La actividad con ID % ya está cancelada', p_id_actividad;
    END IF;

    -- Cancelación de la actividad (soft delete)
    UPDATE c_actividades_lic
    SET
        vigente = 'C',
        fecha_baja = NOW(),
        usuario_baja = p_usuario_baja,
        motivo_baja = TRIM(p_motivo_baja)
    WHERE id_actividad = p_id_actividad;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    -- Retorno exitoso
    RETURN QUERY
    SELECT
        TRUE,
        'Actividad cancelada exitosamente'::TEXT,
        v_rows_affected;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            FALSE,
            ('Error al cancelar actividad: ' || SQLERRM)::TEXT,
            0;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_catalogo_actividades_delete(INTEGER, VARCHAR, TEXT) IS
'Cancela una actividad (baja lógica) - Módulo: padron_licencias';

-- ============================================
-- SP 6/6: catalogo_giros_list
-- Tipo: CATÁLOGO
-- Descripción: Lista todos los giros vigentes para selección en combo
-- Parámetros: Ninguno
-- Retorna: Lista de giros vigentes con ID > 500
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_catalogo_giros_list()
RETURNS TABLE(
    id_giro INTEGER,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        g.id_giro,
        g.descripcion
    FROM c_giros g
    WHERE g.vigente = 'V'
      AND g.id_giro > 500
    ORDER BY g.descripcion;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al listar giros: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_catalogo_giros_list() IS
'Lista todos los giros vigentes para selección - Módulo: padron_licencias';

-- ============================================
-- FIN DE STORED PROCEDURES
-- ============================================

-- ============================================
-- RESUMEN DE IMPLEMENTACIÓN
-- ============================================
-- Total SPs implementados: 6
--
-- Lista de SPs:
-- 1. sp_catalogo_actividades_list    - CONSULTA   - Lista actividades con filtro
-- 2. sp_catalogo_actividades_get     - CONSULTA   - Obtiene actividad por ID
-- 3. sp_catalogo_actividades_create  - INSERCIÓN  - Crea nueva actividad
-- 4. sp_catalogo_actividades_update  - ACTUALIZACIÓN - Actualiza actividad
-- 5. sp_catalogo_actividades_delete  - ELIMINACIÓN - Cancela actividad (soft delete)
-- 6. sp_catalogo_giros_list          - CATÁLOGO   - Lista giros vigentes
--
-- Schema: public
--
-- Tablas utilizadas:
-- - c_actividades_lic (principal)
-- - c_giros (relacionada)
--
-- Características implementadas:
-- ✓ Nomenclatura estándar (p_ para parámetros, v_ para variables)
-- ✓ Validaciones completas de parámetros requeridos
-- ✓ RAISE EXCEPTION descriptivos
-- ✓ Retorno estructurado (success, message, data)
-- ✓ Soft delete implementado
-- ✓ Campos de auditoría (fecha_alta, usuario_alta, fecha_baja, usuario_baja)
-- ✓ Búsqueda case-insensitive con unaccent
-- ✓ Manejo robusto de errores
-- ✓ Comentarios descriptivos en cada función
-- ============================================
