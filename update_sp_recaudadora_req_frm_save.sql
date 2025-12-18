-- Actualización del Stored Procedure para ReqFrm
-- Usa la tabla reqmultas del esquema publico

DROP FUNCTION IF EXISTS publico.recaudadora_req_frm_save(TEXT) CASCADE;

CREATE OR REPLACE FUNCTION publico.recaudadora_req_frm_save(p_registro TEXT)
RETURNS TABLE(
    success BOOLEAN,
    mensaje TEXT,
    req_id INTEGER
)
LANGUAGE plpgsql AS $$
DECLARE
    v_datos JSON;
    v_clave_cuenta VARCHAR;
    v_folio INTEGER;
    v_ejercicio INTEGER;
    v_id_multa INTEGER;
    v_monto NUMERIC;
    v_cvereq_generado INTEGER;
BEGIN
    -- Parsear el JSON
    BEGIN
        v_datos := p_registro::JSON;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT FALSE, 'Error: JSON inválido'::TEXT, NULL::INTEGER;
            RETURN;
    END;

    -- Extraer campos del JSON (solo los que vienen del formulario)
    v_clave_cuenta := v_datos->>'clave_cuenta';
    v_folio := NULLIF(v_datos->>'folio', '')::INTEGER;
    v_ejercicio := NULLIF(v_datos->>'ejercicio', '')::INTEGER;

    -- Validaciones básicas
    IF v_clave_cuenta IS NULL OR v_clave_cuenta = '' THEN
        RETURN QUERY SELECT FALSE, 'Error: La cuenta es obligatoria'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    IF v_folio IS NULL OR v_folio = 0 THEN
        RETURN QUERY SELECT FALSE, 'Error: El folio es obligatorio'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    IF v_ejercicio IS NULL OR v_ejercicio = 0 THEN
        v_ejercicio := EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;
    END IF;

    -- Buscar la multa por num_acta para obtener el id_multa y el monto
    BEGIN
        SELECT m.id_multa, COALESCE(m.multa, 0)
        INTO v_id_multa, v_monto
        FROM publico.multas m
        WHERE m.num_acta::TEXT = v_clave_cuenta
          AND m.axo_acta = v_ejercicio
        LIMIT 1;
    EXCEPTION
        WHEN OTHERS THEN
            v_id_multa := NULL;
            v_monto := 0;
    END;

    -- Si no se encontró la multa, retornar error
    IF v_id_multa IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Error: No se encontró la multa con el número de acta especificado'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Verificar si el folio ya existe para este ejercicio
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM publico.reqmultas r
            WHERE r.folioreq = v_folio
              AND r.axoreq = v_ejercicio
        ) THEN
            RETURN QUERY SELECT FALSE, 'Error: Ya existe un requerimiento con este folio en el ejercicio especificado'::TEXT, NULL::INTEGER;
            RETURN;
        END IF;

        -- Insertar el requerimiento en reqmultas y obtener el ID generado
        WITH new_req AS (
            INSERT INTO publico.reqmultas (
                folioreq,
                axoreq,
                tipo,
                fecemi,
                id_multa,
                vigencia,
                recaud,
                multas,
                gasto_req,
                gastos,
                total,
                cveejecut,
                nodiligenciado,
                feccap,
                capturista,
                obs
            ) VALUES (
                v_folio,                            -- Folio especificado en el formulario
                v_ejercicio::SMALLINT,
                'R',                                -- Tipo: R=Requerimiento
                CURRENT_DATE,                       -- Fecha de emisión
                v_id_multa,                         -- ID de la multa encontrada
                'V',                                -- Vigencia: V=Vigente
                3,                                  -- Recaudadora: 3=Multas
                v_monto,                            -- Monto de la multa
                500.00,                             -- Gastos de requerimiento (valor fijo)
                500.00,                             -- Gastos totales (valor fijo)
                v_monto + 500.00,                   -- Total
                0,                                  -- Ejecutor (0=Sin asignar)
                'N',                                -- No diligenciado
                CURRENT_DATE,                       -- Fecha de captura
                CURRENT_USER,                       -- Usuario capturista
                'Requerimiento capturado desde formulario'  -- Observaciones
            )
            RETURNING cvereq AS generated_id
        )
        SELECT generated_id INTO v_cvereq_generado FROM new_req;

        -- Retornar éxito
        RETURN QUERY SELECT
            TRUE,
            'Requerimiento guardado exitosamente. Folio: ' || v_folio::TEXT || '/' || v_ejercicio::TEXT,
            v_cvereq_generado;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT FALSE, ('Error al guardar: ' || SQLERRM)::TEXT, NULL::INTEGER;
            RETURN;
    END;
END;
$$;

-- Comentarios sobre el mapeo:
-- JSON clave_cuenta -> busca id_multa en publico.multas por num_acta
-- JSON folio -> reqmultas.folioreq (si no se proporciona, se auto-genera)
-- JSON ejercicio -> reqmultas.axoreq (año)
-- JSON id_multa -> reqmultas.id_multa (opcional, se busca si no se proporciona)
-- JSON monto -> reqmultas.multas
-- JSON gastos -> reqmultas.gasto_req y reqmultas.gastos
-- JSON observaciones -> reqmultas.obs
-- vigencia -> 'V' (Vigente por defecto)
-- tipo -> 'R' (Requerimiento)
-- recaud -> 3 (Multas)
-- nodiligenciado -> 'N' (No)
