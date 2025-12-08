-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public y comun
-- ============================================
\c padron_licencias;
SET search_path TO public, comun;

-- ============================================
-- STORED PROCEDURES PARA MODIFICACIÓN DE TRÁMITES
-- Convención: modtramitefrm_XXX
-- Implementado: 2025-11-20
-- Tablas: comun.tramites, comun.c_giros, public.c_calles
-- Módulo: MODTRAMITEFRM (Prioridad Alta)
-- ============================================

-- ============================================
-- SP 1/5: modtramitefrm_get_tramite_by_id
-- Tipo: Query
-- Descripción: Obtiene un trámite por ID con toda su información
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.modtramitefrm_get_tramite_by_id(p_tramite_id INTEGER)
RETURNS TABLE(
    id_tramite INTEGER,
    folio VARCHAR,
    numero_tramite VARCHAR,
    id_giro INTEGER,
    nombre_giro VARCHAR,
    descripcion_tramite TEXT,
    id_calle INTEGER,
    nombre_calle VARCHAR,
    numero_exterior VARCHAR,
    numero_interior VARCHAR,
    id_colonia INTEGER,
    nombre_colonia VARCHAR,
    codigo_postal VARCHAR,
    referencia_ubicacion TEXT,
    nombre_solicitante VARCHAR,
    rfc VARCHAR,
    telefono VARCHAR,
    email VARCHAR,
    estado VARCHAR,
    fecha_solicitud DATE,
    fecha_registro TIMESTAMP,
    usuario_registro VARCHAR,
    observaciones TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_tramite,
        t.folio,
        t.numero_tramite,
        t.id_giro,
        g.nombre AS nombre_giro,
        t.descripcion AS descripcion_tramite,
        t.id_calle,
        c.nombre AS nombre_calle,
        t.numero_exterior,
        t.numero_interior,
        t.id_colonia,
        col.nombre AS nombre_colonia,
        t.codigo_postal,
        t.referencia_ubicacion,
        t.nombre_solicitante,
        t.rfc,
        t.telefono,
        t.email,
        t.estado,
        t.fecha_solicitud,
        t.fecha_registro,
        t.usuario_registro,
        t.observaciones
    FROM comun.tramites t
    LEFT JOIN comun.c_giros g ON g.id_giro = t.id_giro
    LEFT JOIN public.c_calles c ON c.id_calle = t.id_calle
    LEFT JOIN public.c_colonias col ON col.id_colonia = t.id_colonia
    WHERE t.id_tramite = p_tramite_id
      AND t.estado != 'ELIMINADO'
    LIMIT 1;
END;
$$;

COMMENT ON FUNCTION public.modtramitefrm_get_tramite_by_id(INTEGER) IS 'Obtiene información completa de un trámite por ID';

-- ============================================
-- SP 2/5: modtramitefrm_get_giro_by_id
-- Tipo: Query
-- Descripción: Obtiene información de un giro por ID
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.modtramitefrm_get_giro_by_id(p_giro_id INTEGER)
RETURNS TABLE(
    id_giro INTEGER,
    clave VARCHAR,
    nombre VARCHAR,
    descripcion TEXT,
    tipo_giro VARCHAR,
    requiere_licencia BOOLEAN,
    requiere_dictamen BOOLEAN,
    vigencia_dias INTEGER,
    costo NUMERIC,
    estado VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        g.id_giro,
        g.clave,
        g.nombre,
        g.descripcion,
        g.tipo_giro,
        g.requiere_licencia,
        g.requiere_dictamen,
        g.vigencia_dias,
        g.costo,
        g.estado
    FROM comun.c_giros g
    WHERE g.id_giro = p_giro_id
      AND g.estado = 'ACTIVO'
    LIMIT 1;
END;
$$;

COMMENT ON FUNCTION public.modtramitefrm_get_giro_by_id(INTEGER) IS 'Obtiene información de un giro específico';

-- ============================================
-- SP 3/5: modtramitefrm_get_giros_search
-- Tipo: Search
-- Descripción: Busca giros por nombre o clave
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.modtramitefrm_get_giros_search(p_termino VARCHAR)
RETURNS TABLE(
    id_giro INTEGER,
    clave VARCHAR,
    nombre VARCHAR,
    descripcion TEXT,
    tipo_giro VARCHAR,
    requiere_licencia BOOLEAN,
    costo NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        g.id_giro,
        g.clave,
        g.nombre,
        g.descripcion,
        g.tipo_giro,
        g.requiere_licencia,
        g.costo
    FROM comun.c_giros g
    WHERE g.estado = 'ACTIVO'
      AND (
          g.nombre ILIKE '%' || p_termino || '%'
          OR g.clave ILIKE '%' || p_termino || '%'
          OR g.descripcion ILIKE '%' || p_termino || '%'
      )
    ORDER BY g.nombre
    LIMIT 100;
END;
$$;

COMMENT ON FUNCTION public.modtramitefrm_get_giros_search(VARCHAR) IS 'Busca giros por término de búsqueda';

-- ============================================
-- SP 4/5: modtramitefrm_get_calles_search
-- Tipo: Search
-- Descripción: Busca calles por nombre
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.modtramitefrm_get_calles_search(p_termino VARCHAR)
RETURNS TABLE(
    id_calle INTEGER,
    cvecalle INTEGER,
    nombre VARCHAR,
    tipo_vialidad VARCHAR,
    codigo_postal VARCHAR,
    colonia VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id_calle,
        c.cvecalle,
        c.nombre,
        c.tipo_vialidad,
        c.codigo_postal,
        c.colonia
    FROM public.c_calles c
    WHERE c.nombre ILIKE '%' || p_termino || '%'
      AND c.estado = 'ACTIVO'
    ORDER BY c.nombre
    LIMIT 100;
END;
$$;

COMMENT ON FUNCTION public.modtramitefrm_get_calles_search(VARCHAR) IS 'Busca calles por nombre';

-- ============================================
-- SP 5/5: modtramitefrm_update_tramite
-- Tipo: Update
-- Descripción: Actualiza información de un trámite
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.modtramitefrm_update_tramite(
    p_tramite_id INTEGER,
    p_id_giro INTEGER DEFAULT NULL,
    p_id_calle INTEGER DEFAULT NULL,
    p_numero_exterior VARCHAR DEFAULT NULL,
    p_numero_interior VARCHAR DEFAULT NULL,
    p_id_colonia INTEGER DEFAULT NULL,
    p_codigo_postal VARCHAR DEFAULT NULL,
    p_referencia_ubicacion TEXT DEFAULT NULL,
    p_nombre_solicitante VARCHAR DEFAULT NULL,
    p_rfc VARCHAR DEFAULT NULL,
    p_telefono VARCHAR DEFAULT NULL,
    p_email VARCHAR DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL,
    p_usuario_modificacion VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    tramite_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_rows_affected INTEGER;
BEGIN
    -- Verificar que el trámite existe
    SELECT COUNT(*) INTO v_exists
    FROM comun.tramites
    WHERE id_tramite = p_tramite_id
      AND estado != 'ELIMINADO';

    IF v_exists = 0 THEN
        RETURN QUERY
        SELECT
            FALSE AS success,
            'Trámite no encontrado o eliminado.'::TEXT AS message,
            NULL::INTEGER AS tramite_id;
        RETURN;
    END IF;

    -- Actualizar solo los campos que no son NULL
    UPDATE comun.tramites
    SET
        id_giro = COALESCE(p_id_giro, id_giro),
        id_calle = COALESCE(p_id_calle, id_calle),
        numero_exterior = COALESCE(p_numero_exterior, numero_exterior),
        numero_interior = COALESCE(p_numero_interior, numero_interior),
        id_colonia = COALESCE(p_id_colonia, id_colonia),
        codigo_postal = COALESCE(p_codigo_postal, codigo_postal),
        referencia_ubicacion = COALESCE(p_referencia_ubicacion, referencia_ubicacion),
        nombre_solicitante = COALESCE(p_nombre_solicitante, nombre_solicitante),
        rfc = COALESCE(p_rfc, rfc),
        telefono = COALESCE(p_telefono, telefono),
        email = COALESCE(p_email, email),
        observaciones = COALESCE(p_observaciones, observaciones),
        usuario_modificacion = COALESCE(p_usuario_modificacion, usuario_modificacion),
        fecha_modificacion = CURRENT_TIMESTAMP
    WHERE id_tramite = p_tramite_id;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    IF v_rows_affected > 0 THEN
        RETURN QUERY
        SELECT
            TRUE AS success,
            'Trámite actualizado correctamente.'::TEXT AS message,
            p_tramite_id AS tramite_id;
    ELSE
        RETURN QUERY
        SELECT
            FALSE AS success,
            'Error al actualizar el trámite.'::TEXT AS message,
            NULL::INTEGER AS tramite_id;
    END IF;
END;
$$;

COMMENT ON FUNCTION public.modtramitefrm_update_tramite IS 'Actualiza información de un trámite existente';

-- ============================================
-- FUNCIONES ADICIONALES PARA COMPATIBILIDAD
-- ============================================

-- Alias: get_tramite_by_id (sin prefijo)
CREATE OR REPLACE FUNCTION public.get_tramite_by_id(p_tramite_id INTEGER)
RETURNS TABLE(
    id_tramite INTEGER,
    folio VARCHAR,
    numero_tramite VARCHAR,
    id_giro INTEGER,
    nombre_giro VARCHAR,
    descripcion_tramite TEXT,
    id_calle INTEGER,
    nombre_calle VARCHAR,
    numero_exterior VARCHAR,
    numero_interior VARCHAR,
    id_colonia INTEGER,
    nombre_colonia VARCHAR,
    codigo_postal VARCHAR,
    referencia_ubicacion TEXT,
    nombre_solicitante VARCHAR,
    rfc VARCHAR,
    telefono VARCHAR,
    email VARCHAR,
    estado VARCHAR,
    fecha_solicitud DATE,
    fecha_registro TIMESTAMP,
    usuario_registro VARCHAR,
    observaciones TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public.modtramitefrm_get_tramite_by_id(p_tramite_id);
END;
$$;

COMMENT ON FUNCTION public.get_tramite_by_id(INTEGER) IS 'Alias de modtramitefrm_get_tramite_by_id';

-- Alias: get_giro_by_id
CREATE OR REPLACE FUNCTION public.get_giro_by_id(p_giro_id INTEGER)
RETURNS TABLE(
    id_giro INTEGER,
    clave VARCHAR,
    nombre VARCHAR,
    descripcion TEXT,
    tipo_giro VARCHAR,
    requiere_licencia BOOLEAN,
    requiere_dictamen BOOLEAN,
    vigencia_dias INTEGER,
    costo NUMERIC,
    estado VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public.modtramitefrm_get_giro_by_id(p_giro_id);
END;
$$;

COMMENT ON FUNCTION public.get_giro_by_id(INTEGER) IS 'Alias de modtramitefrm_get_giro_by_id';

-- Alias: get_giros_search
CREATE OR REPLACE FUNCTION public.get_giros_search(p_termino VARCHAR)
RETURNS TABLE(
    id_giro INTEGER,
    clave VARCHAR,
    nombre VARCHAR,
    descripcion TEXT,
    tipo_giro VARCHAR,
    requiere_licencia BOOLEAN,
    costo NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public.modtramitefrm_get_giros_search(p_termino);
END;
$$;

COMMENT ON FUNCTION public.get_giros_search(VARCHAR) IS 'Alias de modtramitefrm_get_giros_search';

-- Alias: get_calles_search
CREATE OR REPLACE FUNCTION public.get_calles_search(p_termino VARCHAR)
RETURNS TABLE(
    id_calle INTEGER,
    cvecalle INTEGER,
    nombre VARCHAR,
    tipo_vialidad VARCHAR,
    codigo_postal VARCHAR,
    colonia VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public.modtramitefrm_get_calles_search(p_termino);
END;
$$;

COMMENT ON FUNCTION public.get_calles_search(VARCHAR) IS 'Alias de modtramitefrm_get_calles_search';

-- Alias: update_tramite
CREATE OR REPLACE FUNCTION public.update_tramite(
    p_tramite_id INTEGER,
    p_id_giro INTEGER DEFAULT NULL,
    p_id_calle INTEGER DEFAULT NULL,
    p_numero_exterior VARCHAR DEFAULT NULL,
    p_numero_interior VARCHAR DEFAULT NULL,
    p_id_colonia INTEGER DEFAULT NULL,
    p_codigo_postal VARCHAR DEFAULT NULL,
    p_referencia_ubicacion TEXT DEFAULT NULL,
    p_nombre_solicitante VARCHAR DEFAULT NULL,
    p_rfc VARCHAR DEFAULT NULL,
    p_telefono VARCHAR DEFAULT NULL,
    p_email VARCHAR DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL,
    p_usuario_modificacion VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    tramite_id INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public.modtramitefrm_update_tramite(
        p_tramite_id, p_id_giro, p_id_calle, p_numero_exterior,
        p_numero_interior, p_id_colonia, p_codigo_postal,
        p_referencia_ubicacion, p_nombre_solicitante, p_rfc,
        p_telefono, p_email, p_observaciones, p_usuario_modificacion
    );
END;
$$;

COMMENT ON FUNCTION public.update_tramite IS 'Alias de modtramitefrm_update_tramite';

-- ============================================
-- COMENTARIOS DE IMPLEMENTACIÓN
-- ============================================

/*
IMPLEMENTACIÓN COMPLETADA - 2025-11-20

Stored Procedures implementados: 10 SPs
- 5 SPs principales para modificación de trámites
- 5 SPs alias para compatibilidad

Tablas utilizadas:
- comun.tramites: Tabla de trámites del sistema
- comun.c_giros: Catálogo de giros
- public.c_calles: Catálogo de calles
- public.c_colonias: Catálogo de colonias

Funcionalidades implementadas:
1. Obtención de trámite por ID con datos completos
2. Obtención de giro por ID
3. Búsqueda de giros por término
4. Búsqueda de calles por nombre
5. Actualización de trámites con auditoría

Características:
- LEFT JOIN para datos opcionales
- LIMIT para búsquedas (100 registros)
- Actualización selectiva (solo campos no NULL)
- Auditoría con usuario y fecha de modificación
- Validación de existencia antes de actualizar
- ILIKE para búsquedas case-insensitive
- Filtrado por estado ACTIVO/ELIMINADO

Uso desde API genérico:
POST /api/generic
{
  "eRequest": {
    "Operacion": "modtramitefrm_get_tramite_by_id",
    "Base": "padron_licencias",
    "Esquema": "public",
    "Parametros": [
      {"nombre": "p_tramite_id", "valor": 123, "tipo": "integer"}
    ]
  }
}

POST /api/generic
{
  "eRequest": {
    "Operacion": "modtramitefrm_update_tramite",
    "Base": "padron_licencias",
    "Esquema": "public",
    "Parametros": [
      {"nombre": "p_tramite_id", "valor": 123, "tipo": "integer"},
      {"nombre": "p_id_giro", "valor": 45, "tipo": "integer"},
      {"nombre": "p_nombre_solicitante", "valor": "JUAN PEREZ", "tipo": "text"},
      {"nombre": "p_usuario_modificacion", "valor": "admin", "tipo": "text"}
    ]
  }
}
*/
