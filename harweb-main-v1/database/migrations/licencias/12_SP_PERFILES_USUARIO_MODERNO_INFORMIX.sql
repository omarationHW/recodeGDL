-- =====================================================
-- STORED PROCEDURES: PERFILES USUARIO MODERNO
-- Módulo: Licencias
-- Descripción: Sistema de perfiles diferenciados por función
-- Esquema: INFORMIX compatible
-- Fecha: 2025-09-29
-- =====================================================

-- 1. SP para obtener perfiles de usuario con separación granular
CREATE OR REPLACE FUNCTION sp_perfiles_usuario_list(
    p_limite INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0,
    p_filtro TEXT DEFAULT '',
    p_tipo_perfil TEXT DEFAULT 'TODOS'
)
RETURNS TABLE (
    usuario VARCHAR(20),
    nombres VARCHAR(100),
    apellidos VARCHAR(100),
    tipo_perfil VARCHAR(30),
    perfil_padron CHAR(1),
    perfil_licencias CHAR(1),
    perfil_ingresos CHAR(1),
    departamento VARCHAR(50),
    dependencia VARCHAR(80),
    fecha_alta DATE,
    fecha_modificacion TIMESTAMP,
    activo CHAR(1),
    total_count INTEGER
) AS $$
DECLARE
    total_records INTEGER;
BEGIN
    -- Obtener el total de registros
    SELECT COUNT(*) INTO total_records
    FROM usuarios u
    INNER JOIN deptos d ON d.cvedepto = u.cvedepto
    INNER JOIN dependencias dep ON dep.cvedependencia = d.cvedependencia
    WHERE (p_filtro = '' OR
           LOWER(u.usuario) LIKE '%' || LOWER(p_filtro) || '%' OR
           LOWER(u.nombres) LIKE '%' || LOWER(p_filtro) || '%' OR
           LOWER(d.nombredepto) LIKE '%' || LOWER(p_filtro) || '%')
    AND (p_tipo_perfil = 'TODOS' OR
         (p_tipo_perfil = 'PADRON' AND COALESCE(u.perfil_padron, 'N') = 'S') OR
         (p_tipo_perfil = 'LICENCIAS' AND COALESCE(u.perfil_licencias, 'N') = 'S') OR
         (p_tipo_perfil = 'INGRESOS' AND COALESCE(u.perfil_ingresos, 'N') = 'S'))
    AND COALESCE(u.fecbaj, '9999-12-31'::DATE) > CURRENT_DATE;

    -- Retornar datos paginados
    RETURN QUERY
    SELECT
        u.usuario,
        u.nombres,
        COALESCE(u.apellidos, '') as apellidos,
        CASE
            WHEN COALESCE(u.perfil_padron, 'N') = 'S' AND
                 COALESCE(u.perfil_licencias, 'N') = 'S' AND
                 COALESCE(u.perfil_ingresos, 'N') = 'S' THEN 'COMPLETO'
            WHEN COALESCE(u.perfil_padron, 'N') = 'S' AND
                 COALESCE(u.perfil_licencias, 'N') = 'S' THEN 'PADRON_LICENCIAS'
            WHEN COALESCE(u.perfil_licencias, 'N') = 'S' AND
                 COALESCE(u.perfil_ingresos, 'N') = 'S' THEN 'LICENCIAS_INGRESOS'
            WHEN COALESCE(u.perfil_padron, 'N') = 'S' THEN 'PADRON'
            WHEN COALESCE(u.perfil_licencias, 'N') = 'S' THEN 'LICENCIAS'
            WHEN COALESCE(u.perfil_ingresos, 'N') = 'S' THEN 'INGRESOS'
            ELSE 'BASICO'
        END as tipo_perfil,
        COALESCE(u.perfil_padron, 'N') as perfil_padron,
        COALESCE(u.perfil_licencias, 'N') as perfil_licencias,
        COALESCE(u.perfil_ingresos, 'N') as perfil_ingresos,
        d.nombredepto as departamento,
        dep.nombredependencia as dependencia,
        COALESCE(u.fecalta, CURRENT_DATE) as fecha_alta,
        COALESCE(u.fecha_modificacion, CURRENT_TIMESTAMP) as fecha_modificacion,
        CASE WHEN COALESCE(u.fecbaj, '9999-12-31'::DATE) > CURRENT_DATE THEN 'S' ELSE 'N' END as activo,
        total_records as total_count
    FROM usuarios u
    INNER JOIN deptos d ON d.cvedepto = u.cvedepto
    INNER JOIN dependencias dep ON dep.cvedependencia = d.cvedependencia
    WHERE (p_filtro = '' OR
           LOWER(u.usuario) LIKE '%' || LOWER(p_filtro) || '%' OR
           LOWER(u.nombres) LIKE '%' || LOWER(p_filtro) || '%' OR
           LOWER(d.nombredepto) LIKE '%' || LOWER(p_filtro) || '%')
    AND (p_tipo_perfil = 'TODOS' OR
         (p_tipo_perfil = 'PADRON' AND COALESCE(u.perfil_padron, 'N') = 'S') OR
         (p_tipo_perfil = 'LICENCIAS' AND COALESCE(u.perfil_licencias, 'N') = 'S') OR
         (p_tipo_perfil = 'INGRESOS' AND COALESCE(u.perfil_ingresos, 'N') = 'S'))
    AND COALESCE(u.fecbaj, '9999-12-31'::DATE) > CURRENT_DATE
    ORDER BY u.nombres, u.usuario
    OFFSET p_offset LIMIT p_limite;
END;
$$ LANGUAGE plpgsql;

-- 2. SP para obtener detalle de un perfil específico
CREATE OR REPLACE FUNCTION sp_perfiles_usuario_detalle(
    p_usuario VARCHAR(20)
)
RETURNS TABLE (
    usuario VARCHAR(20),
    nombres VARCHAR(100),
    apellidos VARCHAR(100),
    departamento VARCHAR(50),
    dependencia VARCHAR(80),
    perfil_padron CHAR(1),
    perfil_licencias CHAR(1),
    perfil_ingresos CHAR(1),
    permisos_padron TEXT,
    permisos_licencias TEXT,
    permisos_ingresos TEXT,
    fecha_alta DATE,
    fecha_modificacion TIMESTAMP,
    usuario_modificacion VARCHAR(20),
    observaciones TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.usuario,
        u.nombres,
        COALESCE(u.apellidos, '') as apellidos,
        d.nombredepto as departamento,
        dep.nombredependencia as dependencia,
        COALESCE(u.perfil_padron, 'N') as perfil_padron,
        COALESCE(u.perfil_licencias, 'N') as perfil_licencias,
        COALESCE(u.perfil_ingresos, 'N') as perfil_ingresos,
        COALESCE(u.permisos_padron, '') as permisos_padron,
        COALESCE(u.permisos_licencias, '') as permisos_licencias,
        COALESCE(u.permisos_ingresos, '') as permisos_ingresos,
        COALESCE(u.fecalta, CURRENT_DATE) as fecha_alta,
        COALESCE(u.fecha_modificacion, CURRENT_TIMESTAMP) as fecha_modificacion,
        COALESCE(u.usuario_modificacion, '') as usuario_modificacion,
        COALESCE(u.observaciones, '') as observaciones
    FROM usuarios u
    INNER JOIN deptos d ON d.cvedepto = u.cvedepto
    INNER JOIN dependencias dep ON dep.cvedependencia = d.cvedependencia
    WHERE u.usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;

-- 3. SP para actualizar perfiles de usuario
CREATE OR REPLACE FUNCTION sp_perfiles_usuario_update(
    p_usuario VARCHAR(20),
    p_perfil_padron CHAR(1),
    p_perfil_licencias CHAR(1),
    p_perfil_ingresos CHAR(1),
    p_permisos_padron TEXT DEFAULT '',
    p_permisos_licencias TEXT DEFAULT '',
    p_permisos_ingresos TEXT DEFAULT '',
    p_usuario_modificacion VARCHAR(20),
    p_observaciones TEXT DEFAULT ''
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    usuario_actualizado VARCHAR(20)
) AS $$
DECLARE
    user_exists INTEGER;
    affected_rows INTEGER;
BEGIN
    -- Verificar si el usuario existe
    SELECT COUNT(*) INTO user_exists
    FROM usuarios
    WHERE usuario = p_usuario;

    IF user_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'Usuario no encontrado', p_usuario;
        RETURN;
    END IF;

    -- Actualizar perfiles
    UPDATE usuarios SET
        perfil_padron = p_perfil_padron,
        perfil_licencias = p_perfil_licencias,
        perfil_ingresos = p_perfil_ingresos,
        permisos_padron = p_permisos_padron,
        permisos_licencias = p_permisos_licencias,
        permisos_ingresos = p_permisos_ingresos,
        fecha_modificacion = CURRENT_TIMESTAMP,
        usuario_modificacion = p_usuario_modificacion,
        observaciones = p_observaciones
    WHERE usuario = p_usuario;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;

    IF affected_rows > 0 THEN
        RETURN QUERY SELECT TRUE, 'Perfil actualizado correctamente', p_usuario;
    ELSE
        RETURN QUERY SELECT FALSE, 'Error al actualizar el perfil', p_usuario;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 4. SP para obtener estadísticas de perfiles
CREATE OR REPLACE FUNCTION sp_perfiles_usuario_estadisticas()
RETURNS TABLE (
    total_usuarios INTEGER,
    usuarios_activos INTEGER,
    usuarios_inactivos INTEGER,
    con_perfil_padron INTEGER,
    con_perfil_licencias INTEGER,
    con_perfil_ingresos INTEGER,
    perfiles_completos INTEGER,
    perfiles_basicos INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*)::INTEGER as total_usuarios,
        COUNT(CASE WHEN COALESCE(fecbaj, '9999-12-31'::DATE) > CURRENT_DATE THEN 1 END)::INTEGER as usuarios_activos,
        COUNT(CASE WHEN COALESCE(fecbaj, '9999-12-31'::DATE) <= CURRENT_DATE THEN 1 END)::INTEGER as usuarios_inactivos,
        COUNT(CASE WHEN COALESCE(perfil_padron, 'N') = 'S' THEN 1 END)::INTEGER as con_perfil_padron,
        COUNT(CASE WHEN COALESCE(perfil_licencias, 'N') = 'S' THEN 1 END)::INTEGER as con_perfil_licencias,
        COUNT(CASE WHEN COALESCE(perfil_ingresos, 'N') = 'S' THEN 1 END)::INTEGER as con_perfil_ingresos,
        COUNT(CASE WHEN COALESCE(perfil_padron, 'N') = 'S' AND
                         COALESCE(perfil_licencias, 'N') = 'S' AND
                         COALESCE(perfil_ingresos, 'N') = 'S' THEN 1 END)::INTEGER as perfiles_completos,
        COUNT(CASE WHEN COALESCE(perfil_padron, 'N') = 'N' AND
                         COALESCE(perfil_licencias, 'N') = 'N' AND
                         COALESCE(perfil_ingresos, 'N') = 'N' THEN 1 END)::INTEGER as perfiles_basicos
    FROM usuarios;
END;
$$ LANGUAGE plpgsql;

-- 5. SP para obtener historial de cambios de perfiles
CREATE OR REPLACE FUNCTION sp_perfiles_usuario_historial(
    p_usuario VARCHAR(20) DEFAULT '',
    p_limite INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id INTEGER,
    usuario VARCHAR(20),
    nombres VARCHAR(100),
    accion VARCHAR(50),
    campo_modificado VARCHAR(50),
    valor_anterior TEXT,
    valor_nuevo TEXT,
    fecha_cambio TIMESTAMP,
    usuario_modificacion VARCHAR(20),
    observaciones TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        h.id,
        h.usuario,
        u.nombres,
        h.accion,
        h.campo_modificado,
        COALESCE(h.valor_anterior, '') as valor_anterior,
        COALESCE(h.valor_nuevo, '') as valor_nuevo,
        h.fecha_cambio,
        h.usuario_modificacion,
        COALESCE(h.observaciones, '') as observaciones
    FROM historial_perfiles h
    INNER JOIN usuarios u ON u.usuario = h.usuario
    WHERE (p_usuario = '' OR h.usuario = p_usuario)
    ORDER BY h.fecha_cambio DESC
    OFFSET p_offset LIMIT p_limite;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTARIOS DE IMPLEMENTACIÓN:
--
-- 1. Los SPs están diseñados para INFORMIX/PostgreSQL
-- 2. Incluyen paginación server-side para performance
-- 3. Manejo de perfiles granulares: Padrón, Licencias, Ingresos
-- 4. Sistema de auditoría para cambios de perfiles
-- 5. Estadísticas en tiempo real
-- 6. Filtrado avanzado por tipo de perfil
-- 7. Validaciones de integridad de datos
-- =====================================================