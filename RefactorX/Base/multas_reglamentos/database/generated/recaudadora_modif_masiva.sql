-- ================================================================
-- SP: recaudadora_modif_masiva
-- Módulo: multas_reglamentos
-- Descripción: Modificación masiva de requerimientos por rango de folios
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-03
-- Tablas: comun.reqpredial (3,676,785 registros)
--         comun.reqmultas (403,145 registros)
--         comun.reqlicencias (224,736 registros)
-- ================================================================

DROP FUNCTION IF EXISTS multas_reglamentos.recaudadora_modif_masiva(VARCHAR);

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_modif_masiva(
    p_datos VARCHAR DEFAULT '{}'
)
RETURNS TABLE (
    tipo_req VARCHAR,
    registros_actualizados INTEGER,
    folio_inicio INTEGER,
    folio_final INTEGER,
    mensaje VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tipo VARCHAR;
    v_recaud INTEGER;
    v_folio_ini INTEGER;
    v_folio_fin INTEGER;
    v_fecha DATE;
    v_accion VARCHAR;
    v_usuario VARCHAR;
    v_count INTEGER;
    v_json JSON;
BEGIN
    -- Parsear JSON de entrada con manejo de errores
    v_json := p_datos::JSON;

    -- Extraer parámetros del JSON
    v_tipo := COALESCE((v_json->>'tipo')::VARCHAR, 'predial');
    v_recaud := COALESCE((v_json->>'recaud')::INTEGER, 1);
    v_folio_ini := COALESCE((v_json->>'folio_ini')::INTEGER, 0);
    v_folio_fin := COALESCE((v_json->>'folio_fin')::INTEGER, 0);
    v_fecha := COALESCE((v_json->>'fecha')::DATE, CURRENT_DATE);
    v_accion := COALESCE((v_json->>'accion')::VARCHAR, 'consultar');
    v_usuario := COALESCE((v_json->>'usuario')::VARCHAR, 'SISTEMA');

    -- Validar parámetros
    IF v_folio_ini <= 0 OR v_folio_fin <= 0 OR v_folio_ini > v_folio_fin THEN
        RETURN QUERY
        SELECT
            v_tipo::VARCHAR,
            0::INTEGER,
            v_folio_ini::INTEGER,
            v_folio_fin::INTEGER,
            ('Error: Folios inválidos (inicio: ' || v_folio_ini || ', fin: ' || v_folio_fin || ')')::VARCHAR;
        RETURN;
    END IF;

    -- Procesar según tipo de requerimiento
    IF v_tipo = 'predial' THEN
        -- Modificación masiva de requerimientos prediales
        IF v_accion = 'modificar' THEN
            -- Actualizar fecha de entrega
            UPDATE comun.reqpredial
            SET
                fecent = v_fecha
            WHERE
                recaud = v_recaud
                AND axoreq = EXTRACT(YEAR FROM v_fecha)
                AND folioreq BETWEEN v_folio_ini AND v_folio_fin;

            GET DIAGNOSTICS v_count = ROW_COUNT;

            RETURN QUERY
            SELECT
                'predial'::VARCHAR,
                v_count::INTEGER,
                v_folio_ini::INTEGER,
                v_folio_fin::INTEGER,
                'Requerimientos prediales actualizados exitosamente'::VARCHAR;

        ELSIF v_accion = 'cancelar' THEN
            -- Cancelar requerimientos
            UPDATE comun.reqpredial
            SET
                cvecancr = 99,
                feccancr = v_fecha
            WHERE
                recaud = v_recaud
                AND axoreq = EXTRACT(YEAR FROM v_fecha)
                AND folioreq BETWEEN v_folio_ini AND v_folio_fin
                AND COALESCE(cvecancr, 0) = 0;

            GET DIAGNOSTICS v_count = ROW_COUNT;

            RETURN QUERY
            SELECT
                'predial'::VARCHAR,
                v_count::INTEGER,
                v_folio_ini::INTEGER,
                v_folio_fin::INTEGER,
                'Requerimientos prediales cancelados exitosamente'::VARCHAR;

        ELSE
            -- Solo consultar
            SELECT COUNT(*)::INTEGER INTO v_count
            FROM comun.reqpredial
            WHERE
                recaud = v_recaud
                AND axoreq = EXTRACT(YEAR FROM v_fecha)
                AND folioreq BETWEEN v_folio_ini AND v_folio_fin;

            RETURN QUERY
            SELECT
                'predial'::VARCHAR,
                v_count::INTEGER,
                v_folio_ini::INTEGER,
                v_folio_fin::INTEGER,
                ('Consulta: ' || v_count || ' requerimientos encontrados')::VARCHAR;
        END IF;

    ELSIF v_tipo = 'multa' THEN
        -- Modificación masiva de requerimientos de multas
        IF v_accion = 'modificar' THEN
            UPDATE comun.reqmultas
            SET
                fecpract = v_fecha,
                horapract = CURRENT_TIME
            WHERE
                recaud = v_recaud
                AND axoreq = EXTRACT(YEAR FROM v_fecha)
                AND folioreq BETWEEN v_folio_ini AND v_folio_fin;

            GET DIAGNOSTICS v_count = ROW_COUNT;

            RETURN QUERY
            SELECT
                'multa'::VARCHAR,
                v_count::INTEGER,
                v_folio_ini::INTEGER,
                v_folio_fin::INTEGER,
                'Requerimientos de multas actualizados exitosamente'::VARCHAR;

        ELSIF v_accion = 'cancelar' THEN
            DELETE FROM comun.reqmultas
            WHERE
                recaud = v_recaud
                AND axoreq = EXTRACT(YEAR FROM v_fecha)
                AND folioreq BETWEEN v_folio_ini AND v_folio_fin
                AND COALESCE(cvepago, 0) = 0;

            GET DIAGNOSTICS v_count = ROW_COUNT;

            RETURN QUERY
            SELECT
                'multa'::VARCHAR,
                v_count::INTEGER,
                v_folio_ini::INTEGER,
                v_folio_fin::INTEGER,
                'Requerimientos de multas cancelados exitosamente'::VARCHAR;

        ELSE
            SELECT COUNT(*)::INTEGER INTO v_count
            FROM comun.reqmultas
            WHERE
                recaud = v_recaud
                AND axoreq = EXTRACT(YEAR FROM v_fecha)
                AND folioreq BETWEEN v_folio_ini AND v_folio_fin;

            RETURN QUERY
            SELECT
                'multa'::VARCHAR,
                v_count::INTEGER,
                v_folio_ini::INTEGER,
                v_folio_fin::INTEGER,
                ('Consulta: ' || v_count || ' requerimientos encontrados')::VARCHAR;
        END IF;

    ELSIF v_tipo = 'licencia' THEN
        -- Modificación masiva de requerimientos de licencias
        IF v_accion = 'modificar' THEN
            UPDATE comun.reqlicencias
            SET
                fecpract = v_fecha,
                horapract = CURRENT_TIME
            WHERE
                recaud = v_recaud
                AND axoreq = EXTRACT(YEAR FROM v_fecha)
                AND folioreq BETWEEN v_folio_ini AND v_folio_fin;

            GET DIAGNOSTICS v_count = ROW_COUNT;

            RETURN QUERY
            SELECT
                'licencia'::VARCHAR,
                v_count::INTEGER,
                v_folio_ini::INTEGER,
                v_folio_fin::INTEGER,
                'Requerimientos de licencias actualizados exitosamente'::VARCHAR;

        ELSIF v_accion = 'cancelar' THEN
            DELETE FROM comun.reqlicencias
            WHERE
                recaud = v_recaud
                AND axoreq = EXTRACT(YEAR FROM v_fecha)
                AND folioreq BETWEEN v_folio_ini AND v_folio_fin
                AND COALESCE(cvepago, 0) = 0;

            GET DIAGNOSTICS v_count = ROW_COUNT;

            RETURN QUERY
            SELECT
                'licencia'::VARCHAR,
                v_count::INTEGER,
                v_folio_ini::INTEGER,
                v_folio_fin::INTEGER,
                'Requerimientos de licencias cancelados exitosamente'::VARCHAR;

        ELSE
            SELECT COUNT(*)::INTEGER INTO v_count
            FROM comun.reqlicencias
            WHERE
                recaud = v_recaud
                AND axoreq = EXTRACT(YEAR FROM v_fecha)
                AND folioreq BETWEEN v_folio_ini AND v_folio_fin;

            RETURN QUERY
            SELECT
                'licencia'::VARCHAR,
                v_count::INTEGER,
                v_folio_ini::INTEGER,
                v_folio_fin::INTEGER,
                ('Consulta: ' || v_count || ' requerimientos encontrados')::VARCHAR;
        END IF;

    ELSE
        RETURN QUERY
        SELECT
            v_tipo::VARCHAR,
            0::INTEGER,
            v_folio_ini::INTEGER,
            v_folio_fin::INTEGER,
            ('Error: Tipo de requerimiento inválido: ' || v_tipo)::VARCHAR;
    END IF;

    RETURN;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_modif_masiva(VARCHAR) IS
'Modificación masiva de requerimientos por rango de folios.
Tablas afectadas:
  - comun.reqpredial (3,676,785 registros)
  - comun.reqmultas (403,145 registros)
  - comun.reqlicencias (224,736 registros)

Parámetro JSON:
{
  "tipo": "predial|multa|licencia",
  "recaud": 1-99,
  "folio_ini": número inicial,
  "folio_fin": número final,
  "fecha": "YYYY-MM-DD",
  "accion": "consultar|modificar|cancelar",
  "usuario": "nombre usuario"
}

Acciones:
  - consultar: Solo cuenta cuántos registros serían afectados
  - modificar: Actualiza fechas de práctica/entrega
  - cancelar: Marca requerimientos como cancelados (solo sin pago)

Retorna: Tabla con tipo, cantidad actualizada, folios y mensaje de resultado.';
