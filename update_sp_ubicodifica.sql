-- =====================================================
-- Stored Procedure: recaudadora_ubicodifica
-- Base de Datos: multas_reglamentos
-- Esquema: publico
-- Descripción: Ubicación y codificación de direcciones
--              Consulta ubicaciones y codificaciones basadas en cartas de invitación predial
-- =====================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS publico.recaudadora_ubicodifica(VARCHAR);

-- Crear función
CREATE OR REPLACE FUNCTION publico.recaudadora_ubicodifica(
    p_filtro VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    cvecuenta INTEGER,
    domicilio TEXT,
    noexterior TEXT,
    interior TEXT,
    colonia TEXT,
    observaciones TEXT,
    fec_alta DATE,
    usuario_alta TEXT,
    vigencia TEXT,
    fec_baja DATE,
    fec_mov DATE,
    usuario_mov TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_filtro_trimmed VARCHAR;
BEGIN
    -- Trim espacios del filtro
    v_filtro_trimmed := TRIM(p_filtro);

    -- Buscar en tabla cartainvpredial (cartas de invitación predial con ubicación)
    RETURN QUERY
    SELECT
        c.cvecuenta,
        COALESCE(c.calle, '')::TEXT as domicilio,
        COALESCE(c.exterior, '')::TEXT as noexterior,
        COALESCE(c.interior, '')::TEXT as interior,
        COALESCE(c.colonia, '')::TEXT as colonia,
        COALESCE(c.obs, '')::TEXT as observaciones,
        c.feccap as fec_alta,
        COALESCE(c.capturista, '')::TEXT as usuario_alta,
        COALESCE(c.vigencia, '')::TEXT as vigencia,
        NULL::DATE as fec_baja,
        NULL::DATE as fec_mov,
        ''::TEXT as usuario_mov
    FROM public.cartainvpredial c
    WHERE (
        -- Si no hay filtro, mostrar todos (vigentes primero)
        v_filtro_trimmed IS NULL OR v_filtro_trimmed = ''
        -- Buscar por cuenta
        OR c.cvecuenta::TEXT ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por calle (domicilio)
        OR c.calle ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por número exterior
        OR c.exterior ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por colonia
        OR c.colonia ILIKE '%' || v_filtro_trimmed || '%'
        -- Buscar por observaciones
        OR c.obs ILIKE '%' || v_filtro_trimmed || '%'
    )
    ORDER BY
        CASE WHEN c.vigencia = 'V' THEN 0 ELSE 1 END, -- Vigentes primero
        c.feccap DESC
    LIMIT 100;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al consultar ubicaciones/codificación: %', SQLERRM;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION publico.recaudadora_ubicodifica(VARCHAR) IS
'Consulta de ubicaciones y codificación de direcciones.
Basado en la tabla public.cartainvpredial (cartas de invitación predial).
Parámetros:
  - p_filtro: VARCHAR (opcional) - Busca por:
    * Número de cuenta (cvecuenta)
    * Calle/Domicilio
    * Número exterior
    * Colonia
    * Observaciones
Retorna tabla con información de ubicación incluyendo:
  - Identificación (cuenta)
  - Domicilio completo (calle, exterior, interior, colonia)
  - Observaciones
  - Vigencia (V=Vigente, P=Pagado, etc.)
  - Fechas (alta)
  - Usuario (capturista)
Nota: Los campos fec_baja, fec_mov y usuario_mov no están disponibles en la tabla fuente.
Límite: 100 registros';

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION publico.recaudadora_ubicodifica(VARCHAR) TO refact;
GRANT EXECUTE ON FUNCTION publico.recaudadora_ubicodifica(VARCHAR) TO PUBLIC;
