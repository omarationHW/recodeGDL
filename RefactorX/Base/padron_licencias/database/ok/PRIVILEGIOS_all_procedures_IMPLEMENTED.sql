-- ============================================
-- STORED PROCEDURES - COMPONENTE: PRIVILEGIOS
-- Módulo: padron_licencias
-- Archivo: PRIVILEGIOS_all_procedures_IMPLEMENTED.sql
-- Fecha de implementación: 2025-11-20
-- Total SPs: 7
-- Schema: public
-- ============================================
-- Descripción del Componente:
-- Gestión completa de privilegios de usuarios del sistema
-- Incluye: listado de usuarios, permisos, auditoría, movimientos y reportes
-- ============================================

-- ============================================
-- CONFIGURACIÓN DE SCHEMA
-- ============================================
-- SET search_path TO public;

-- ============================================
-- SP 1/7: sp_get_usuarios_privilegios
-- Tipo: Catalog
-- Descripción: Obtiene la lista de usuarios con privilegios del sistema
--              Filtra por campo específico y texto de búsqueda
--              Incluye paginación con offset y limit
-- Parámetros:
--   p_campo: Campo por el cual ordenar (usuario, nombres, baja, nombredepto)
--   p_filtro: Texto para filtrar por usuario o nombres
--   p_offset: Número de registros a saltar (paginación)
--   p_limit: Número máximo de registros a retornar
-- Retorna: Lista de usuarios con privilegios y su información básica
-- Tablas: c_programas, aud_auto, autoriza, usuarios, deptos
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_get_usuarios_privilegios(
    p_campo TEXT DEFAULT 'usuario',
    p_filtro TEXT DEFAULT '',
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
    usuario VARCHAR,
    nombres VARCHAR,
    baja DATE,
    nombredepto VARCHAR,
    total_registros BIGINT
) AS $$
BEGIN
    -- Validación de parámetros
    IF p_offset < 0 THEN
        RAISE EXCEPTION 'El offset debe ser mayor o igual a 0';
    END IF;

    IF p_limit < 1 OR p_limit > 1000 THEN
        RAISE EXCEPTION 'El limit debe estar entre 1 y 1000';
    END IF;

    -- Query principal con UNION de tablas aud_auto y autoriza
    RETURN QUERY
    WITH usuarios_privilegios AS (
        -- Usuarios con privilegios desde aud_auto
        SELECT a.usuario, u.nombres, u.fecbaj AS baja, d.nombredepto
        FROM c_programas p
        INNER JOIN aud_auto a ON a.num_tag = p.num_tag
        INNER JOIN usuarios u ON u.usuario = a.usuario
        LEFT JOIN deptos d ON d.cvedepto = u.cvedepto
        WHERE p.num_tag BETWEEN 8000 AND 8999
        GROUP BY a.usuario, u.nombres, u.fecbaj, d.nombredepto

        UNION

        -- Usuarios con privilegios desde autoriza
        SELECT a.usuario, u.nombres, u.fecbaj AS baja, d.nombredepto
        FROM c_programas p
        INNER JOIN autoriza a ON a.num_tag = p.num_tag
        INNER JOIN usuarios u ON u.usuario = a.usuario
        LEFT JOIN deptos d ON d.cvedepto = u.cvedepto
        WHERE p.num_tag BETWEEN 8000 AND 8999
        GROUP BY a.usuario, u.nombres, u.fecbaj, d.nombredepto
    )
    SELECT
        up.usuario,
        up.nombres,
        up.baja,
        up.nombredepto,
        COUNT(*) OVER() AS total_registros
    FROM usuarios_privilegios up
    WHERE
        (p_filtro = '' OR
         LOWER(up.usuario) LIKE '%' || LOWER(p_filtro) || '%' OR
         LOWER(up.nombres) LIKE '%' || LOWER(p_filtro) || '%')
    ORDER BY
        CASE
            WHEN p_campo = 'usuario' THEN up.usuario
            WHEN p_campo = 'nombres' THEN up.nombres
            WHEN p_campo = 'baja' THEN up.baja::TEXT
            WHEN p_campo = 'nombredepto' THEN up.nombredepto
            ELSE up.usuario
        END
    OFFSET p_offset
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 2/7: sp_get_permisos_usuario
-- Tipo: Catalog
-- Descripción: Obtiene todos los permisos asignados a un usuario específico
--              Lista los programas/módulos a los que tiene acceso
-- Parámetros:
--   p_usuario: Usuario del cual se consultarán los permisos
-- Retorna: Lista de permisos con información del programa y auditoría
-- Tablas: c_programas, autoriza
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_get_permisos_usuario(
    p_usuario VARCHAR
)
RETURNS TABLE (
    num_tag INTEGER,
    descripcion VARCHAR,
    seleccionado VARCHAR,
    grupo SMALLINT,
    feccap DATE,
    capturista VARCHAR,
    usuario VARCHAR
) AS $$
BEGIN
    -- Validación de parámetros requeridos
    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RAISE EXCEPTION 'El parámetro p_usuario es requerido';
    END IF;

    -- Query principal
    RETURN QUERY
    SELECT
        p.num_tag,
        p.descripcion,
        p.seleccionado,
        p.grupo,
        p.feccap,
        p.capturista,
        a.usuario
    FROM c_programas p
    INNER JOIN autoriza a ON a.num_tag = p.num_tag AND a.usuario = p_usuario
    WHERE p.num_tag BETWEEN 8000 AND 8999
    ORDER BY p.grupo, p.num_tag;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 3/7: sp_get_auditoria_usuario
-- Tipo: Report
-- Descripción: Obtiene la bitácora de auditoría de permisos de un usuario
--              Muestra historial de asignación, eliminación y actualización
-- Parámetros:
--   p_usuario: Usuario del cual se consultará la auditoría
-- Retorna: Historial de cambios en permisos con detalle de operación
-- Tablas: c_programas, aud_auto
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_get_auditoria_usuario(
    p_usuario VARCHAR
)
RETURNS TABLE (
    num_tag INTEGER,
    descripcion VARCHAR,
    id INTEGER,
    fechahora TIMESTAMP,
    equipo VARCHAR,
    proc VARCHAR,
    usuario VARCHAR
) AS $$
BEGIN
    -- Validación de parámetros requeridos
    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RAISE EXCEPTION 'El parámetro p_usuario es requerido';
    END IF;

    -- Query principal con interpretación del tipo de proceso
    RETURN QUERY
    SELECT
        p.num_tag,
        p.descripcion,
        a.id,
        a.fechahora,
        a.equipo,
        CASE a.proc
            WHEN 'I' THEN 'Asignado'
            WHEN 'D' THEN 'Eliminado'
            WHEN 'U' THEN 'Actualizado'
            ELSE a.proc
        END AS proc,
        a.usuario
    FROM c_programas p
    INNER JOIN aud_auto a ON a.num_tag = p.num_tag AND a.usuario = p_usuario
    WHERE p.num_tag BETWEEN 8000 AND 8999
    ORDER BY a.fechahora DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 4/7: sp_get_mov_tramites
-- Tipo: Report
-- Descripción: Obtiene todos los movimientos de trámites realizados por un usuario
--              en un rango de fechas específico
-- Parámetros:
--   p_usuario: Usuario del cual se consultarán los movimientos
--   p_fechaini: Fecha inicial del rango de búsqueda
--   p_fechafin: Fecha final del rango de búsqueda
-- Retorna: Historial completo de movimientos en trámites
-- Tablas: sysbacktram
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_get_mov_tramites(
    p_usuario VARCHAR,
    p_fechaini DATE,
    p_fechafin DATE
)
RETURNS TABLE (
    id INTEGER,
    uid SMALLINT,
    username VARCHAR,
    ttyin VARCHAR,
    ttyout VARCHAR,
    ttyerr VARCHAR,
    cwd TEXT,
    hostname TEXT,
    time TIMESTAMP,
    event VARCHAR,
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
    rhorario VARCHAR
) AS $$
BEGIN
    -- Validación de parámetros requeridos
    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RAISE EXCEPTION 'El parámetro p_usuario es requerido';
    END IF;

    IF p_fechaini IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_fechaini es requerido';
    END IF;

    IF p_fechafin IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_fechafin es requerido';
    END IF;

    IF p_fechaini > p_fechafin THEN
        RAISE EXCEPTION 'La fecha inicial no puede ser mayor que la fecha final';
    END IF;

    -- Query principal
    RETURN QUERY
    SELECT *
    FROM sysbacktram
    WHERE username = p_usuario
      AND DATE(time) BETWEEN p_fechaini AND p_fechafin
    ORDER BY time DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 5/7: sp_get_mov_licencias
-- Tipo: Report
-- Descripción: Obtiene todos los movimientos de licencias realizados por un usuario
--              en un rango de fechas específico
--              Utiliza función auxiliar get_sysbacklcs
-- Parámetros:
--   p_usuario: Usuario del cual se consultarán los movimientos
--   p_fechaini: Fecha inicial del rango de búsqueda
--   p_fechafin: Fecha final del rango de búsqueda
-- Retorna: Historial completo de movimientos en licencias
-- Tablas: get_sysbacklcs (función auxiliar)
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_get_mov_licencias(
    p_usuario VARCHAR,
    p_fechaini DATE,
    p_fechafin DATE
)
RETURNS TABLE (
    id INTEGER,
    uid INTEGER,
    username VARCHAR,
    ttyin VARCHAR,
    ttyout VARCHAR,
    ttyerr VARCHAR,
    cwd TEXT,
    hostname TEXT,
    time TIMESTAMP,
    event VARCHAR,
    id_licencia INTEGER,
    licencia INTEGER,
    empresa INTEGER,
    recaud SMALLINT,
    id_giro INTEGER,
    x FLOAT,
    y FLOAT,
    zona SMALLINT,
    subzona SMALLINT,
    tipo_registro VARCHAR,
    actividad VARCHAR,
    cvecuenta INTEGER,
    fecha_otorgamiento DATE,
    propietario VARCHAR,
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
    numint_ubic VARCHAR,
    letraint_ubic VARCHAR,
    colonia_ubic VARCHAR,
    sup_construida FLOAT,
    sup_autorizada FLOAT,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC,
    rhorario VARCHAR,
    fecha_consejo DATE,
    bloqueado SMALLINT,
    asiento SMALLINT,
    vigente VARCHAR,
    fecha_baja DATE,
    axo_baja INTEGER,
    folio_baja INTEGER,
    espubic VARCHAR,
    base_impuesto NUMERIC
) AS $$
BEGIN
    -- Validación de parámetros requeridos
    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RAISE EXCEPTION 'El parámetro p_usuario es requerido';
    END IF;

    IF p_fechaini IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_fechaini es requerido';
    END IF;

    IF p_fechafin IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_fechafin es requerido';
    END IF;

    IF p_fechaini > p_fechafin THEN
        RAISE EXCEPTION 'La fecha inicial no puede ser mayor que la fecha final';
    END IF;

    -- Query principal usando función auxiliar
    -- Nota: Si get_sysbacklcs no existe, se debe implementar o usar directamente la tabla
    RETURN QUERY
    SELECT * FROM get_sysbacklcs(p_usuario, p_fechaini, p_fechafin)
    ORDER BY time DESC;

EXCEPTION
    WHEN undefined_function THEN
        -- Si la función get_sysbacklcs no existe, intentar acceso directo a tabla
        RAISE NOTICE 'Función get_sysbacklcs no encontrada, intentando acceso directo a sysbacklcs';
        RETURN QUERY
        SELECT *
        FROM sysbacklcs
        WHERE username = p_usuario
          AND DATE(time) BETWEEN p_fechaini AND p_fechafin
        ORDER BY time DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 6/7: sp_get_deptos
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de departamentos que tienen usuarios con privilegios
--              Lista única de departamentos sin duplicados
-- Parámetros: Ninguno
-- Retorna: Lista de departamentos con su clave y nombre
-- Tablas: c_programas, autoriza, usuarios, deptos
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_get_deptos()
RETURNS TABLE (
    cvedepto INTEGER,
    nombredepto VARCHAR
) AS $$
BEGIN
    -- Query principal con agrupación para evitar duplicados
    RETURN QUERY
    SELECT
        d.cvedepto,
        d.nombredepto
    FROM c_programas p
    INNER JOIN autoriza a ON a.num_tag = p.num_tag
    INNER JOIN usuarios u ON u.usuario = a.usuario
    LEFT JOIN deptos d ON d.cvedepto = u.cvedepto
    WHERE p.num_tag BETWEEN 8000 AND 8999
      AND d.cvedepto IS NOT NULL
    GROUP BY d.cvedepto, d.nombredepto
    ORDER BY d.nombredepto;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 7/7: sp_get_revisiones
-- Tipo: Report
-- Descripción: Obtiene las revisiones realizadas por un usuario en un rango de fechas
--              Incluye información de la dependencia y estado de seguimiento
-- Parámetros:
--   p_fechaini: Fecha inicial del rango de búsqueda
--   p_fechafin: Fecha final del rango de búsqueda
--   p_usuario: Usuario del cual se consultarán las revisiones
-- Retorna: Lista de revisiones con seguimiento y observaciones
-- Tablas: revisiones, seg_revision, c_dependencias
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_get_revisiones(
    p_fechaini DATE,
    p_fechafin DATE,
    p_usuario VARCHAR
)
RETURNS TABLE (
    id_revision INTEGER,
    id_tramite INTEGER,
    dependencia VARCHAR,
    fecha_inicio DATE,
    fecha_termino DATE,
    estatus_revision VARCHAR,
    fecha_revision DATE,
    usr_revisa VARCHAR,
    estatus_seguimiento VARCHAR,
    observacion TEXT,
    fecha_seguimiento DATE
) AS $$
BEGIN
    -- Validación de parámetros requeridos
    IF p_fechaini IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_fechaini es requerido';
    END IF;

    IF p_fechafin IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_fechafin es requerido';
    END IF;

    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RAISE EXCEPTION 'El parámetro p_usuario es requerido';
    END IF;

    IF p_fechaini > p_fechafin THEN
        RAISE EXCEPTION 'La fecha inicial no puede ser mayor que la fecha final';
    END IF;

    -- Query principal con JOINs a dependencias
    RETURN QUERY
    SELECT
        r.id_revision,
        r.id_tramite,
        d.descripcion AS dependencia,
        r.fecha_inicio,
        r.fecha_termino,
        r.estatus AS estatus_revision,
        s.fecha_revision,
        s.usr_revisa,
        s.estatus AS estatus_seguimiento,
        s.observacion,
        s.feccap AS fecha_seguimiento
    FROM revisiones r
    LEFT JOIN seg_revision s ON s.id_revision = r.id_revision
    LEFT JOIN c_dependencias d ON d.id_dependencia = r.id_dependencia
    WHERE s.feccap BETWEEN p_fechaini AND p_fechafin
      AND s.usr_revisa = p_usuario
    ORDER BY s.feccap DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DE STORED PROCEDURES - PRIVILEGIOS
-- ============================================

-- ============================================
-- COMENTARIOS DE IMPLEMENTACIÓN
-- ============================================
-- 1. Todas las funciones usan el patrón RETURNS TABLE con tipos específicos
-- 2. Se incluyen validaciones de parámetros requeridos al inicio
-- 3. Se usa nomenclatura estándar: p_ para parámetros, v_ para variables
-- 4. Se incluyen mensajes de excepción descriptivos
-- 5. El rango de num_tag 8000-8999 identifica programas del sistema de privilegios
-- 6. Se implementa paginación con COUNT(*) OVER() en sp_get_usuarios_privilegios
-- 7. Manejo de errores con EXCEPTION en sp_get_mov_licencias
-- 8. Ordenamiento dinámico por campo en sp_get_usuarios_privilegios
-- 9. Todas las queries incluyen ORDER BY para resultados consistentes
-- 10. Se usa LEFT JOIN para deptos permitiendo valores NULL
-- ============================================

-- ============================================
-- TABLAS PRINCIPALES REFERENCIADAS
-- ============================================
-- public.c_programas - Catálogo de programas/módulos del sistema
-- public.autoriza - Tabla de autorizaciones de usuarios
-- public.aud_auto - Auditoría de autorizaciones
-- public.usuarios - Catálogo de usuarios del sistema
-- public.deptos - Catálogo de departamentos
-- public.sysbacktram - Bitácora de movimientos en trámites
-- public.sysbacklcs - Bitácora de movimientos en licencias
-- public.revisiones - Registro de revisiones
-- public.seg_revision - Seguimiento de revisiones
-- public.c_dependencias - Catálogo de dependencias
-- ============================================
