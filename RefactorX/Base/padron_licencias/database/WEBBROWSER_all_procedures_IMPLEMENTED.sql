-- =====================================================================================
-- WEBBROWSER - Stored Procedures para Sistema de Navegacion Web Integrado
-- Modulo: padron_licencias
-- Schema: comun
-- Fecha: 2025-11-21
-- Descripcion: Procedimientos para historial de navegacion, bookmarks y auditoria
-- =====================================================================================

-- =====================================================================================
-- CREACION DE TABLAS
-- =====================================================================================

-- Tabla para registrar eventos de navegacion
CREATE TABLE IF NOT EXISTS comun.navigation_events (
    id BIGSERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    url TEXT NOT NULL,
    titulo VARCHAR(500),
    ip_address VARCHAR(45),
    event_time TIMESTAMP DEFAULT NOW()
);

-- Tabla para almacenar bookmarks/favoritos
CREATE TABLE IF NOT EXISTS comun.bookmarks (
    id BIGSERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    url TEXT NOT NULL,
    titulo VARCHAR(500),
    categoria VARCHAR(100) DEFAULT 'General',
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, url)
);

-- =====================================================================================
-- INDICES PARA OPTIMIZACION
-- =====================================================================================

-- Indices para navigation_events
CREATE INDEX IF NOT EXISTS idx_navigation_events_user_id
    ON comun.navigation_events(user_id);

CREATE INDEX IF NOT EXISTS idx_navigation_events_event_time
    ON comun.navigation_events(event_time DESC);

CREATE INDEX IF NOT EXISTS idx_navigation_events_user_time
    ON comun.navigation_events(user_id, event_time DESC);

-- Indices para bookmarks
CREATE INDEX IF NOT EXISTS idx_bookmarks_user_id
    ON comun.bookmarks(user_id);

CREATE INDEX IF NOT EXISTS idx_bookmarks_categoria
    ON comun.bookmarks(categoria);

CREATE INDEX IF NOT EXISTS idx_bookmarks_user_categoria
    ON comun.bookmarks(user_id, categoria);

-- =====================================================================================
-- SP 1: sp_webbrowser_log_navigation
-- Descripcion: Registra un evento de navegacion del usuario
-- Parametros:
--   p_user_id    - ID del usuario que navega
--   p_url        - URL visitada
--   p_ip_address - Direccion IP del cliente
--   p_titulo     - Titulo de la pagina (opcional)
-- Retorna: success, message, event_id
-- =====================================================================================
CREATE OR REPLACE FUNCTION comun.sp_webbrowser_log_navigation(
    p_user_id INTEGER,
    p_url TEXT,
    p_ip_address VARCHAR(45),
    p_titulo VARCHAR(500) DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    event_id BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_event_id BIGINT;
    v_url_clean TEXT;
BEGIN
    -- Validar parametros obligatorios
    IF p_user_id IS NULL THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            'Error: El ID de usuario es obligatorio'::TEXT,
            NULL::BIGINT;
        RETURN;
    END IF;

    IF p_url IS NULL OR TRIM(p_url) = '' THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            'Error: La URL es obligatoria'::TEXT,
            NULL::BIGINT;
        RETURN;
    END IF;

    -- Limpiar y normalizar URL
    v_url_clean := TRIM(p_url);

    -- Insertar evento de navegacion
    INSERT INTO comun.navigation_events (
        user_id,
        url,
        titulo,
        ip_address,
        event_time
    ) VALUES (
        p_user_id,
        v_url_clean,
        NULLIF(TRIM(COALESCE(p_titulo, '')), ''),
        p_ip_address,
        NOW()
    )
    RETURNING id INTO v_event_id;

    -- Retornar resultado exitoso
    RETURN QUERY SELECT
        TRUE::BOOLEAN,
        'Navegacion registrada correctamente'::TEXT,
        v_event_id;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            ('Error al registrar navegacion: ' || SQLERRM)::TEXT,
            NULL::BIGINT;
END;
$$;

-- Comentario del procedimiento
COMMENT ON FUNCTION comun.sp_webbrowser_log_navigation(INTEGER, TEXT, VARCHAR, VARCHAR) IS
'Registra un evento de navegacion web del usuario para auditoria y seguimiento';

-- =====================================================================================
-- SP 2: sp_webbrowser_get_history
-- Descripcion: Obtiene el historial de navegacion de un usuario
-- Parametros:
--   p_user_id     - ID del usuario
--   p_fecha_desde - Fecha desde la cual obtener historial (opcional)
--   p_limit       - Cantidad maxima de registros (default 50)
-- Retorna: id, url, titulo, ip_address, event_time
-- =====================================================================================
CREATE OR REPLACE FUNCTION comun.sp_webbrowser_get_history(
    p_user_id INTEGER,
    p_fecha_desde DATE DEFAULT NULL,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE(
    id BIGINT,
    url TEXT,
    titulo VARCHAR(500),
    ip_address VARCHAR(45),
    event_time TIMESTAMP
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_limit INTEGER;
BEGIN
    -- Validar usuario
    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'El ID de usuario es obligatorio';
    END IF;

    -- Establecer limite con valor por defecto y maximo
    v_limit := COALESCE(p_limit, 50);
    IF v_limit <= 0 THEN
        v_limit := 50;
    END IF;
    IF v_limit > 1000 THEN
        v_limit := 1000; -- Limite maximo de seguridad
    END IF;

    -- Retornar historial filtrado
    RETURN QUERY
    SELECT
        ne.id,
        ne.url,
        ne.titulo,
        ne.ip_address,
        ne.event_time
    FROM comun.navigation_events ne
    WHERE ne.user_id = p_user_id
      AND (p_fecha_desde IS NULL OR ne.event_time >= p_fecha_desde::TIMESTAMP)
    ORDER BY ne.event_time DESC
    LIMIT v_limit;

END;
$$;

-- Comentario del procedimiento
COMMENT ON FUNCTION comun.sp_webbrowser_get_history(INTEGER, DATE, INTEGER) IS
'Obtiene el historial de navegacion de un usuario con filtros opcionales de fecha y limite';

-- =====================================================================================
-- SP 3: sp_webbrowser_save_bookmark
-- Descripcion: Guarda un nuevo bookmark/favorito para el usuario
-- Parametros:
--   p_user_id   - ID del usuario
--   p_url       - URL del bookmark
--   p_titulo    - Titulo del bookmark
--   p_categoria - Categoria del bookmark (default 'General')
-- Retorna: success, message, bookmark_id
-- =====================================================================================
CREATE OR REPLACE FUNCTION comun.sp_webbrowser_save_bookmark(
    p_user_id INTEGER,
    p_url TEXT,
    p_titulo VARCHAR(500),
    p_categoria VARCHAR(100) DEFAULT 'General'
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    bookmark_id BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_bookmark_id BIGINT;
    v_url_clean TEXT;
    v_titulo_clean VARCHAR(500);
    v_categoria_clean VARCHAR(100);
    v_existing_id BIGINT;
BEGIN
    -- Validar parametros obligatorios
    IF p_user_id IS NULL THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            'Error: El ID de usuario es obligatorio'::TEXT,
            NULL::BIGINT;
        RETURN;
    END IF;

    -- Validar URL no vacia
    IF p_url IS NULL OR TRIM(p_url) = '' THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            'Error: La URL es obligatoria y no puede estar vacia'::TEXT,
            NULL::BIGINT;
        RETURN;
    END IF;

    -- Validar titulo
    IF p_titulo IS NULL OR TRIM(p_titulo) = '' THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            'Error: El titulo es obligatorio'::TEXT,
            NULL::BIGINT;
        RETURN;
    END IF;

    -- Limpiar valores
    v_url_clean := TRIM(p_url);
    v_titulo_clean := TRIM(p_titulo);
    v_categoria_clean := COALESCE(NULLIF(TRIM(p_categoria), ''), 'General');

    -- Verificar si ya existe el bookmark para este usuario y URL
    SELECT b.id INTO v_existing_id
    FROM comun.bookmarks b
    WHERE b.user_id = p_user_id
      AND b.url = v_url_clean;

    IF v_existing_id IS NOT NULL THEN
        -- Actualizar bookmark existente
        UPDATE comun.bookmarks
        SET titulo = v_titulo_clean,
            categoria = v_categoria_clean
        WHERE id = v_existing_id;

        RETURN QUERY SELECT
            TRUE::BOOLEAN,
            'Bookmark actualizado correctamente'::TEXT,
            v_existing_id;
        RETURN;
    END IF;

    -- Insertar nuevo bookmark
    INSERT INTO comun.bookmarks (
        user_id,
        url,
        titulo,
        categoria,
        created_at
    ) VALUES (
        p_user_id,
        v_url_clean,
        v_titulo_clean,
        v_categoria_clean,
        NOW()
    )
    RETURNING id INTO v_bookmark_id;

    -- Retornar resultado exitoso
    RETURN QUERY SELECT
        TRUE::BOOLEAN,
        'Bookmark guardado correctamente'::TEXT,
        v_bookmark_id;

EXCEPTION
    WHEN unique_violation THEN
        -- En caso de violacion de unicidad (race condition), intentar actualizar
        UPDATE comun.bookmarks
        SET titulo = v_titulo_clean,
            categoria = v_categoria_clean
        WHERE user_id = p_user_id
          AND url = v_url_clean
        RETURNING id INTO v_bookmark_id;

        RETURN QUERY SELECT
            TRUE::BOOLEAN,
            'Bookmark actualizado correctamente'::TEXT,
            v_bookmark_id;
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            ('Error al guardar bookmark: ' || SQLERRM)::TEXT,
            NULL::BIGINT;
END;
$$;

-- Comentario del procedimiento
COMMENT ON FUNCTION comun.sp_webbrowser_save_bookmark(INTEGER, TEXT, VARCHAR, VARCHAR) IS
'Guarda o actualiza un bookmark/favorito para el usuario en la categoria especificada';

-- =====================================================================================
-- SP 4: sp_webbrowser_get_bookmarks
-- Descripcion: Lista los bookmarks de un usuario, opcionalmente filtrados por categoria
-- Parametros:
--   p_user_id   - ID del usuario
--   p_categoria - Categoria a filtrar (opcional, NULL = todas)
-- Retorna: id, url, titulo, categoria, created_at
-- =====================================================================================
CREATE OR REPLACE FUNCTION comun.sp_webbrowser_get_bookmarks(
    p_user_id INTEGER,
    p_categoria VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE(
    id BIGINT,
    url TEXT,
    titulo VARCHAR(500),
    categoria VARCHAR(100),
    created_at TIMESTAMP
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Validar usuario
    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'El ID de usuario es obligatorio';
    END IF;

    -- Retornar bookmarks filtrados
    RETURN QUERY
    SELECT
        b.id,
        b.url,
        b.titulo,
        b.categoria,
        b.created_at
    FROM comun.bookmarks b
    WHERE b.user_id = p_user_id
      AND (p_categoria IS NULL OR b.categoria = p_categoria)
    ORDER BY b.categoria ASC, b.titulo ASC;

END;
$$;

-- Comentario del procedimiento
COMMENT ON FUNCTION comun.sp_webbrowser_get_bookmarks(INTEGER, VARCHAR) IS
'Lista los bookmarks/favoritos de un usuario ordenados por categoria y titulo';

-- =====================================================================================
-- SP ADICIONAL: sp_webbrowser_delete_bookmark
-- Descripcion: Elimina un bookmark del usuario
-- Parametros:
--   p_user_id     - ID del usuario
--   p_bookmark_id - ID del bookmark a eliminar
-- Retorna: success, message
-- =====================================================================================
CREATE OR REPLACE FUNCTION comun.sp_webbrowser_delete_bookmark(
    p_user_id INTEGER,
    p_bookmark_id BIGINT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_deleted INTEGER;
BEGIN
    -- Validar parametros
    IF p_user_id IS NULL THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            'Error: El ID de usuario es obligatorio'::TEXT;
        RETURN;
    END IF;

    IF p_bookmark_id IS NULL THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            'Error: El ID del bookmark es obligatorio'::TEXT;
        RETURN;
    END IF;

    -- Eliminar bookmark (solo si pertenece al usuario)
    DELETE FROM comun.bookmarks
    WHERE id = p_bookmark_id
      AND user_id = p_user_id;

    GET DIAGNOSTICS v_deleted = ROW_COUNT;

    IF v_deleted > 0 THEN
        RETURN QUERY SELECT
            TRUE::BOOLEAN,
            'Bookmark eliminado correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            'Bookmark no encontrado o no pertenece al usuario'::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            ('Error al eliminar bookmark: ' || SQLERRM)::TEXT;
END;
$$;

-- Comentario del procedimiento
COMMENT ON FUNCTION comun.sp_webbrowser_delete_bookmark(INTEGER, BIGINT) IS
'Elimina un bookmark del usuario verificando propiedad';

-- =====================================================================================
-- SP ADICIONAL: sp_webbrowser_get_categories
-- Descripcion: Obtiene las categorias de bookmarks del usuario
-- Parametros:
--   p_user_id - ID del usuario
-- Retorna: categoria, total_bookmarks
-- =====================================================================================
CREATE OR REPLACE FUNCTION comun.sp_webbrowser_get_categories(
    p_user_id INTEGER
)
RETURNS TABLE(
    categoria VARCHAR(100),
    total_bookmarks BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Validar usuario
    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'El ID de usuario es obligatorio';
    END IF;

    -- Retornar categorias con conteo
    RETURN QUERY
    SELECT
        b.categoria,
        COUNT(*)::BIGINT AS total_bookmarks
    FROM comun.bookmarks b
    WHERE b.user_id = p_user_id
    GROUP BY b.categoria
    ORDER BY b.categoria ASC;

END;
$$;

-- Comentario del procedimiento
COMMENT ON FUNCTION comun.sp_webbrowser_get_categories(INTEGER) IS
'Obtiene las categorias de bookmarks del usuario con conteo de items';

-- =====================================================================================
-- SP ADICIONAL: sp_webbrowser_clear_history
-- Descripcion: Limpia el historial de navegacion del usuario
-- Parametros:
--   p_user_id     - ID del usuario
--   p_fecha_hasta - Eliminar registros hasta esta fecha (opcional, NULL = todo)
-- Retorna: success, message, deleted_count
-- =====================================================================================
CREATE OR REPLACE FUNCTION comun.sp_webbrowser_clear_history(
    p_user_id INTEGER,
    p_fecha_hasta DATE DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    deleted_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_deleted BIGINT;
BEGIN
    -- Validar usuario
    IF p_user_id IS NULL THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            'Error: El ID de usuario es obligatorio'::TEXT,
            0::BIGINT;
        RETURN;
    END IF;

    -- Eliminar historial
    IF p_fecha_hasta IS NULL THEN
        -- Eliminar todo el historial del usuario
        DELETE FROM comun.navigation_events
        WHERE user_id = p_user_id;
    ELSE
        -- Eliminar historial hasta la fecha especificada
        DELETE FROM comun.navigation_events
        WHERE user_id = p_user_id
          AND event_time <= (p_fecha_hasta + INTERVAL '1 day' - INTERVAL '1 second');
    END IF;

    GET DIAGNOSTICS v_deleted = ROW_COUNT;

    RETURN QUERY SELECT
        TRUE::BOOLEAN,
        ('Historial limpiado correctamente. Registros eliminados: ' || v_deleted::TEXT)::TEXT,
        v_deleted;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            ('Error al limpiar historial: ' || SQLERRM)::TEXT,
            0::BIGINT;
END;
$$;

-- Comentario del procedimiento
COMMENT ON FUNCTION comun.sp_webbrowser_clear_history(INTEGER, DATE) IS
'Limpia el historial de navegacion del usuario, opcionalmente hasta una fecha especifica';

-- =====================================================================================
-- GRANTS - Permisos de ejecucion
-- =====================================================================================

-- Otorgar permisos de ejecucion al rol de aplicacion (ajustar segun necesidad)
-- GRANT EXECUTE ON FUNCTION comun.sp_webbrowser_log_navigation(INTEGER, TEXT, VARCHAR, VARCHAR) TO app_user;
-- GRANT EXECUTE ON FUNCTION comun.sp_webbrowser_get_history(INTEGER, DATE, INTEGER) TO app_user;
-- GRANT EXECUTE ON FUNCTION comun.sp_webbrowser_save_bookmark(INTEGER, TEXT, VARCHAR, VARCHAR) TO app_user;
-- GRANT EXECUTE ON FUNCTION comun.sp_webbrowser_get_bookmarks(INTEGER, VARCHAR) TO app_user;
-- GRANT EXECUTE ON FUNCTION comun.sp_webbrowser_delete_bookmark(INTEGER, BIGINT) TO app_user;
-- GRANT EXECUTE ON FUNCTION comun.sp_webbrowser_get_categories(INTEGER) TO app_user;
-- GRANT EXECUTE ON FUNCTION comun.sp_webbrowser_clear_history(INTEGER, DATE) TO app_user;

-- =====================================================================================
-- FIN DEL SCRIPT
-- =====================================================================================
