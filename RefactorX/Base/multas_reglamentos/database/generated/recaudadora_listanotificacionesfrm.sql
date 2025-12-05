-- ================================================================
-- SP: recaudadora_listanotificacionesfrm
-- Módulo: multas_reglamentos
-- Descripción: Lista de actas notificadas por recaudadora, año y rango de folios
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-03
-- ================================================================

DROP FUNCTION IF EXISTS multas_reglamentos.recaudadora_listanotificacionesfrm(INTEGER, INTEGER, INTEGER, INTEGER, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_listanotificacionesfrm(
    p_reca INTEGER,
    p_axo INTEGER,
    p_inicio INTEGER,
    p_final INTEGER,
    p_tipo VARCHAR DEFAULT 'N',
    p_orden VARCHAR DEFAULT 'lote'
)
RETURNS TABLE (
    abrevia VARCHAR,
    axo_acta INTEGER,
    num_acta INTEGER,
    num_lote INTEGER,
    folioreq INTEGER,
    dependencia VARCHAR,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    total NUMERIC(10,2),
    fecha_notif DATE,
    tipo_doc VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_orden_clause VARCHAR;
BEGIN
    -- Determinar el orden basándose en el parámetro
    CASE p_orden
        WHEN 'lote' THEN
            v_orden_clause := 'num_lote, axo_acta, num_acta';
        WHEN 'vigentes' THEN
            v_orden_clause := 'folioreq';
        WHEN 'dependencia' THEN
            v_orden_clause := 'id_dependencia, num_acta';
        ELSE
            v_orden_clause := 'num_lote, axo_acta, num_acta';
    END CASE;

    -- Consultar actas notificadas
    RETURN QUERY EXECUTE format('
        SELECT
            COALESCE(
                CASE m.id_dependencia
                    WHEN 1 THEN ''PC''
                    WHEN 2 THEN ''PL''
                    WHEN 3 THEN ''IV''
                    WHEN 4 THEN ''REG''
                    WHEN 5 THEN ''MER''
                    ELSE ''DEP'' || COALESCE(m.id_dependencia::TEXT, ''0'')
                END, ''N/A''
            )::VARCHAR AS abrevia,
            COALESCE(m.axo_acta, 0)::INTEGER AS axo_acta,
            COALESCE(m.num_acta, 0)::INTEGER AS num_acta,
            COALESCE(
                CASE
                    WHEN m.num_acta IS NOT NULL THEN (m.num_acta / 100)
                    ELSE 0
                END, 0
            )::INTEGER AS num_lote,
            COALESCE(m.id_multa, 0)::INTEGER AS folioreq,
            COALESCE(
                CASE m.id_dependencia
                    WHEN 1 THEN ''Protección Civil''
                    WHEN 2 THEN ''Padrón y Licencias''
                    WHEN 3 THEN ''Inspección y Vigilancia''
                    WHEN 4 THEN ''Reglamentos''
                    WHEN 5 THEN ''Mercados''
                    ELSE ''Dependencia '' || COALESCE(m.id_dependencia::TEXT, ''N/A'')
                END, ''N/A''
            )::VARCHAR AS dependencia,
            COALESCE(TRIM(m.contribuyente), ''NO ESPECIFICADO'')::VARCHAR AS contribuyente,
            COALESCE(TRIM(m.domicilio), ''NO ESPECIFICADO'')::VARCHAR AS domicilio,
            COALESCE(m.total, 0)::NUMERIC(10,2) AS total,
            m.fecha_acta::DATE AS fecha_notif,
            $1::VARCHAR AS tipo_doc
        FROM comun.multas m
        WHERE
            m.axo_acta = $2
            AND m.num_acta >= $3
            AND m.num_acta <= $4
            AND m.contribuyente IS NOT NULL
            AND m.total > 0
            AND m.fecha_cancelacion IS NULL
        ORDER BY %s', v_orden_clause)
    USING p_tipo, p_axo, p_inicio, p_final;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_listanotificacionesfrm(INTEGER, INTEGER, INTEGER, INTEGER, VARCHAR, VARCHAR) IS
'Lista de actas notificadas por recaudadora, año y rango de folios.
Parámetros:
  - p_reca: Recaudadora (1-5)
  - p_axo: Año del acta
  - p_inicio: Folio inicial
  - p_final: Folio final
  - p_tipo: Tipo de documento (N=Notificación, R=Requerimiento, S=Secuestro) - default ''N''
  - p_orden: Orden del listado (lote, vigentes, dependencia) - default ''lote''
Retorna: Lista de actas notificadas con información detallada.';
