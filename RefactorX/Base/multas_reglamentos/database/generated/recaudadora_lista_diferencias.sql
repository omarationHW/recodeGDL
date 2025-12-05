-- ================================================================
-- SP: recaudadora_lista_diferencias
-- Módulo: multas_reglamentos
-- Descripción: Lista diferencias detectadas usando tabla real comun.predial_diferencias
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-02
-- Actualizado: 2025-12-03 - Usando tabla real comun.predial_diferencias
-- ================================================================

DROP FUNCTION IF EXISTS db_ingresos.recaudadora_lista_diferencias(VARCHAR);

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_lista_diferencias(
    p_filtro VARCHAR
)
RETURNS TABLE (
    id_diferencia INTEGER,
    folio VARCHAR,
    tipo_diferencia VARCHAR,
    cuenta VARCHAR,
    ejercicio SMALLINT,
    monto_diferencia NUMERIC(10,2),
    estado VARCHAR,
    prioridad VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_filtro VARCHAR;
BEGIN
    -- Convertir filtro a mayúsculas para búsqueda case-insensitive
    v_filtro := UPPER(COALESCE(p_filtro, ''));

    -- Consultar tabla real de diferencias prediales
    RETURN QUERY
    SELECT
        pd.id AS id_diferencia,
        ('DIF-PRED-' || TO_CHAR(pd.axo, 'FM0000') || '-' || LPAD(pd.id::TEXT, 5, '0'))::VARCHAR AS folio,
        'Diferencia Predial'::VARCHAR AS tipo_diferencia,
        ('CTA-' || LPAD(pd.cvecuenta::TEXT, 8, '0'))::VARCHAR AS cuenta,
        pd.axo AS ejercicio,
        pd.monto AS monto_diferencia,
        (CASE
            WHEN pd.status = 'V' THEN 'Vigente'
            WHEN pd.status = 'P' THEN 'Pendiente'
            WHEN pd.status = 'C' THEN 'Corregido'
            ELSE 'Desconocido'
        END)::VARCHAR AS estado,
        (CASE
            WHEN ABS(pd.monto) > 100 THEN 'Alta'
            WHEN ABS(pd.monto) > 40 THEN 'Media'
            ELSE 'Baja'
        END)::VARCHAR AS prioridad
    FROM comun.predial_diferencias pd
    WHERE
        -- Si hay filtro, aplicar búsqueda
        (v_filtro = '' OR
         pd.cvecuenta::TEXT LIKE '%' || v_filtro || '%' OR
         pd.axo::TEXT LIKE '%' || v_filtro || '%' OR
         UPPER(
            CASE
                WHEN pd.status = 'V' THEN 'VIGENTE'
                WHEN pd.status = 'P' THEN 'PENDIENTE'
                WHEN pd.status = 'C' THEN 'CORREGIDO'
                ELSE 'DESCONOCIDO'
            END
         ) LIKE '%' || v_filtro || '%' OR
         UPPER(
            CASE
                WHEN ABS(pd.monto) > 100 THEN 'ALTA'
                WHEN ABS(pd.monto) > 40 THEN 'MEDIA'
                ELSE 'BAJA'
            END
         ) LIKE '%' || v_filtro || '%')
    ORDER BY
        -- Ordenar por prioridad (Alta primero) y luego por monto descendente
        CASE
            WHEN ABS(pd.monto) > 100 THEN 1
            WHEN ABS(pd.monto) > 40 THEN 2
            ELSE 3
        END,
        ABS(pd.monto) DESC,
        pd.axo DESC,
        pd.id;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_lista_diferencias(VARCHAR) IS
'Lista diferencias detectadas en procesos de recaudación usando la tabla real comun.predial_diferencias.
Parámetros:
  - p_filtro: Término de búsqueda (cuenta, año, estado o prioridad)
Retorna: Diferencias reales del sistema predial con folio, cuenta, monto y prioridad.
Tabla utilizada: comun.predial_diferencias (29 registros)';
