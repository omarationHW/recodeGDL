-- ================================================================
-- SP: recaudadora_listdesctomultafrm
-- Módulo: multas_reglamentos
-- Descripción: Listado de descuentos aplicados a multas
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-03
-- Tabla: comun.h_descmultampal (101,794 registros)
-- ================================================================

DROP FUNCTION IF EXISTS multas_reglamentos.recaudadora_listdesctomultafrm(VARCHAR);

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_listdesctomultafrm(
    p_clave_cuenta VARCHAR DEFAULT ''
)
RETURNS TABLE (
    id_multa INTEGER,
    num_acta INTEGER,
    axo_acta INTEGER,
    contribuyente VARCHAR,
    tipo_descto VARCHAR,
    valor_descto NUMERIC(10,2),
    porcentaje VARCHAR,
    folio VARCHAR,
    cvepago VARCHAR,
    fecha_movto DATE,
    estado VARCHAR,
    autoriza VARCHAR,
    observacion VARCHAR,
    total_original NUMERIC(10,2),
    total_con_descto NUMERIC(10,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_filtro VARCHAR;
BEGIN
    -- Convertir filtro a mayúsculas
    v_filtro := UPPER(COALESCE(p_clave_cuenta, ''));

    -- Consultar descuentos de multas
    RETURN QUERY
    SELECT
        d.id_multa::INTEGER,
        COALESCE(m.num_acta, 0)::INTEGER AS num_acta,
        COALESCE(m.axo_acta, 0)::INTEGER AS axo_acta,
        COALESCE(TRIM(m.contribuyente), 'NO ESPECIFICADO')::VARCHAR AS contribuyente,
        COALESCE(
            CASE TRIM(d.tipo_descto)
                WHEN 'P' THEN 'Porcentaje'
                WHEN 'M' THEN 'Monto Fijo'
                WHEN 'A' THEN 'Autorizado'
                ELSE 'Tipo ' || COALESCE(TRIM(d.tipo_descto), 'N/A')
            END, 'NO ESPECIFICADO'
        )::VARCHAR AS tipo_descto,
        COALESCE(d.valor, 0)::NUMERIC(10,2) AS valor_descto,
        (
            CASE
                WHEN d.tipo_descto = 'P' THEN d.valor::TEXT || '%'
                ELSE 'N/A'
            END
        )::VARCHAR AS porcentaje,
        COALESCE(d.folio::TEXT, 'N/A')::VARCHAR AS folio,
        COALESCE(d.cvepago::TEXT, 'N/A')::VARCHAR AS cvepago,
        d.fecha_movto::DATE,
        COALESCE(
            CASE TRIM(d.estado)
                WHEN 'A' THEN 'Activo'
                WHEN 'C' THEN 'Cancelado'
                WHEN 'P' THEN 'Pagado'
                ELSE 'Estado ' || COALESCE(TRIM(d.estado), 'N/A')
            END, 'NO ESPECIFICADO'
        )::VARCHAR AS estado,
        COALESCE(d.autoriza::TEXT, 'N/A')::VARCHAR AS autoriza,
        COALESCE(TRIM(d.observacion), 'N/A')::VARCHAR AS observacion,
        COALESCE(m.total + d.valor, m.total, 0)::NUMERIC(10,2) AS total_original,
        COALESCE(m.total, 0)::NUMERIC(10,2) AS total_con_descto
    FROM comun.h_descmultampal d
    LEFT JOIN comun.multas m ON m.id_multa = d.id_multa
    WHERE
        d.valor > 0
        AND (
            v_filtro = ''
            OR d.id_multa::TEXT LIKE '%' || v_filtro || '%'
            OR UPPER(COALESCE(d.folio::TEXT, '')) LIKE '%' || v_filtro || '%'
            OR UPPER(COALESCE(m.contribuyente, '')) LIKE '%' || v_filtro || '%'
            OR COALESCE(m.num_acta::TEXT, '') LIKE '%' || v_filtro || '%'
        )
    ORDER BY
        d.fecha_movto DESC,
        d.id_multa DESC
    LIMIT 100;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_listdesctomultafrm(VARCHAR) IS
'Listado de descuentos aplicados a multas del municipio.
Tabla origen: comun.h_descmultampal (101,794 registros).
JOIN con: comun.multas para obtener datos del contribuyente.
Parámetro:
  - p_clave_cuenta: Filtro de búsqueda (id_multa, folio, contribuyente, num_acta) - opcional
Retorna: Máximo 100 descuentos ordenados por fecha descendente.
Búsqueda en: ID multa, folio, contribuyente, número de acta.';
