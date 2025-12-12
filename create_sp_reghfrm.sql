CREATE OR REPLACE FUNCTION publico.recaudadora_reghfrm(
    p_filtros VARCHAR
)
RETURNS TABLE (
    id_multa INTEGER,
    id_dependencia INTEGER,
    num_acta VARCHAR,
    axo_acta INTEGER,
    fecha_acta DATE,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    num_licencia VARCHAR,
    giro VARCHAR,
    calificacion NUMERIC
)
LANGUAGE plpgsql AS $$
DECLARE
    v_filtros JSON;
    v_tipo VARCHAR;
    v_id_multa INTEGER;
    v_id_dependencia INTEGER;
    v_axo_acta INTEGER;
    v_fecha_inicio DATE;
    v_fecha_fin DATE;
    v_limite INTEGER;
BEGIN
    -- Parsear JSON
    v_filtros := p_filtros::JSON;

    -- Extraer valores
    v_tipo := COALESCE(v_filtros->>'tipo', 'rango');
    v_id_multa := (v_filtros->>'id_multa')::INTEGER;
    v_id_dependencia := (v_filtros->>'id_dependencia')::INTEGER;
    v_axo_acta := (v_filtros->>'axo_acta')::INTEGER;
    v_fecha_inicio := (v_filtros->>'fecha_inicio')::DATE;
    v_fecha_fin := (v_filtros->>'fecha_fin')::DATE;
    v_limite := COALESCE((v_filtros->>'limite')::INTEGER, 20);

    RETURN QUERY
    SELECT
        r.id_multa,
        r.id_dependencia,
        r.num_acta::VARCHAR,
        r.axo_acta,
        r.fecha_acta,
        r.contribuyente::VARCHAR,
        r.domicilio::VARCHAR,
        r.num_licencia::VARCHAR,
        r.giro::VARCHAR,
        r.calificacion
    FROM publico.registro_historico r
    WHERE
        CASE
            WHEN v_tipo = 'id' AND v_id_multa IS NOT NULL THEN
                r.id_multa = v_id_multa
            WHEN v_tipo = 'dependencia' AND v_id_dependencia IS NOT NULL THEN
                r.id_dependencia = v_id_dependencia
                AND (v_fecha_inicio IS NULL OR r.fecha_acta >= v_fecha_inicio)
                AND (v_fecha_fin IS NULL OR r.fecha_acta <= v_fecha_fin)
            ELSE
                (v_fecha_inicio IS NULL OR r.fecha_acta >= v_fecha_inicio)
                AND (v_fecha_fin IS NULL OR r.fecha_acta <= v_fecha_fin)
        END
        AND (v_axo_acta IS NULL OR r.axo_acta = v_axo_acta)
    ORDER BY r.fecha_acta DESC, r.id_multa DESC
    LIMIT v_limite;
END; $$;
