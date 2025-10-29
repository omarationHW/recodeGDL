-- ============================================
-- STORED PROCEDURES MIGRADOS - INFORMIX
-- Formulario: BUSQUEDAACTIVIDADFRM
-- Archivo: 09_SP_LICENCIAS_BUSQUEDAACTIVIDADFRM_INFORMIX.sql
-- Migración desde PostgreSQL a INFORMIX
-- Fecha: 2025-09-23
-- Total SPs: 3
-- ============================================

-- SP 1/1: buscar_actividades
-- Tipo: Catalog
-- Descripción: Busca actividades en c_giros filtrando por cod_giro (SCIAN) y descripción, mostrando solo vigentes y excluyendo id_giro = cod_giro. Incluye costo y refrendo del año actual.
-- Parámetros entrada: p_scian (INTEGER), p_descripcion (LVARCHAR) - opcional
-- Parámetros salida: id_giro, cod_giro, descripcion, vigente, axo, costo, refrendo
-- --------------------------------------------

CREATE PROCEDURE buscar_actividades(
    p_scian INTEGER,
    p_descripcion LVARCHAR(255) DEFAULT ''
)
RETURNING INTEGER AS id_giro,
          INTEGER AS cod_giro,
          LVARCHAR(255) AS descripcion,
          CHAR(1) AS vigente,
          INTEGER AS axo,
          DECIMAL(10,2) AS costo,
          DECIMAL(10,2) AS refrendo;

DEFINE v_current_year INTEGER;

    -- Obtener el año actual
    LET v_current_year = YEAR(TODAY);

    RETURN
        cg.id_giro,
        cg.cod_giro,
        cg.descripcion,
        cg.vigente,
        cvl.axo,
        cvl.costo,
        cvl.refrendo
    FROM c_giros cg
    LEFT JOIN c_valoreslic cvl ON cvl.id_giro = cg.id_giro AND cvl.axo = v_current_year
    WHERE cg.id_giro >= 5000
      AND cg.vigente = 'V'
      AND cg.id_giro <> cg.cod_giro
      AND cg.cod_giro = p_scian
      AND (
        p_descripcion IS NULL OR
        p_descripcion = '' OR
        UPPER(cg.descripcion) LIKE '%' || UPPER(p_descripcion) || '%'
      )
    ORDER BY cg.descripcion;

END PROCEDURE;

-- SP 2/3: sp_obtener_giros_disponibles
-- Tipo: Catalog
-- Descripción: Obtiene la lista de giros disponibles con conteos de licencias y trámites.
-- Parámetros entrada: Ninguno
-- Parámetros salida: id_giro, descripcion_giro, total_en_licencias, total_en_tramites
-- --------------------------------------------

CREATE PROCEDURE sp_obtener_giros_disponibles()
RETURNING INTEGER AS id_giro,
          LVARCHAR(255) AS descripcion_giro,
          INTEGER AS total_en_licencias,
          INTEGER AS total_en_tramites;

    RETURN
        g.id_giro,
        g.descripcion AS descripcion_giro,
        COALESCE(l.total_licencias, 0) AS total_en_licencias,
        COALESCE(t.total_tramites, 0) AS total_en_tramites
    FROM c_giros g
    LEFT JOIN (
        SELECT id_giro, COUNT(*) AS total_licencias
        FROM licencias
        GROUP BY id_giro
    ) l ON g.id_giro = l.id_giro
    LEFT JOIN (
        SELECT id_giro, COUNT(*) AS total_tramites
        FROM tramites
        WHERE id_giro IS NOT NULL
        GROUP BY id_giro
    ) t ON g.id_giro = t.id_giro
    WHERE g.vigente = 'V'
      AND (l.total_licencias > 0 OR t.total_tramites > 0)
    ORDER BY g.descripcion;

END PROCEDURE;

-- SP 3/3: sp_buscar_actividades_combinado
-- Tipo: Catalog
-- Descripción: Busca actividades combinando licencias y trámites con filtros opcionales.
-- Parámetros entrada: p_id_giro (INTEGER opcional), p_descripcion (LVARCHAR opcional), p_fuente (LVARCHAR opcional)
-- Parámetros salida: id_giro, actividad, fuente, total_registros, registros_activos, registros_bloqueados
-- --------------------------------------------

CREATE PROCEDURE sp_buscar_actividades_combinado(
    p_id_giro INTEGER DEFAULT NULL,
    p_descripcion LVARCHAR(255) DEFAULT NULL,
    p_fuente LVARCHAR(20) DEFAULT 'AMBOS'
)
RETURNING INTEGER AS id_giro,
          LVARCHAR(255) AS actividad,
          LVARCHAR(20) AS fuente,
          INTEGER AS total_registros,
          INTEGER AS registros_activos,
          INTEGER AS registros_bloqueados;

    -- Buscar en licencias si fuente es AMBOS o LICENCIAS
    IF p_fuente = 'AMBOS' OR p_fuente = 'LICENCIAS' THEN
        RETURN
            l.id_giro,
            l.actividad,
            'LICENCIAS' AS fuente,
            COUNT(*) AS total_registros,
            SUM(CASE WHEN l.bloqueado = 0 THEN 1 ELSE 0 END) AS registros_activos,
            SUM(CASE WHEN l.bloqueado > 0 THEN 1 ELSE 0 END) AS registros_bloqueados
        FROM licencias l
        WHERE l.actividad IS NOT NULL
          AND l.actividad != ''
          AND (p_id_giro IS NULL OR l.id_giro = p_id_giro)
          AND (
            p_descripcion IS NULL OR
            p_descripcion = '' OR
            UPPER(l.actividad) LIKE '%' || UPPER(p_descripcion) || '%'
          )
        GROUP BY l.id_giro, l.actividad
        HAVING COUNT(*) > 0;
    END IF;

    -- Buscar en trámites si fuente es AMBOS o TRAMITES
    IF p_fuente = 'AMBOS' OR p_fuente = 'TRAMITES' THEN
        RETURN
            t.id_giro,
            t.actividad,
            'TRAMITES' AS fuente,
            COUNT(*) AS total_registros,
            SUM(CASE WHEN t.bloqueado = 0 THEN 1 ELSE 0 END) AS registros_activos,
            SUM(CASE WHEN t.bloqueado > 0 THEN 1 ELSE 0 END) AS registros_bloqueados
        FROM tramites t
        WHERE t.actividad IS NOT NULL
          AND t.actividad != ''
          AND (p_id_giro IS NULL OR t.id_giro = p_id_giro)
          AND (
            p_descripcion IS NULL OR
            p_descripcion = '' OR
            UPPER(t.actividad) LIKE '%' || UPPER(p_descripcion) || '%'
          )
        GROUP BY t.id_giro, t.actividad
        HAVING COUNT(*) > 0;
    END IF;

END PROCEDURE;