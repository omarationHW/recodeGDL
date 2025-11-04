-- ============================================
-- STORED PROCEDURES PARA bloqueoDomiciliosfrm
-- Generado: 2025-11-04
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_domicilios_buscar
-- Descripción: Busca licencias por domicilio y muestra su estado de bloqueo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_domicilios_buscar(
    p_calle VARCHAR DEFAULT NULL,
    p_numero_exterior VARCHAR DEFAULT NULL,
    p_colonia VARCHAR DEFAULT NULL,
    p_codigo_postal VARCHAR DEFAULT NULL,
    p_estado_bloqueo CHAR DEFAULT NULL
)
RETURNS TABLE(
    id INTEGER,
    licencia INTEGER,
    propietario VARCHAR,
    direccion_completa VARCHAR,
    colonia VARCHAR,
    codigo_postal VARCHAR,
    bloqueado VARCHAR,
    licencias_afectadas INTEGER,
    fecha_bloqueo DATE,
    usuario_bloqueo VARCHAR,
    motivo_bloqueo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (l.id_licencia)
        l.id_licencia as id,
        l.licencia::INTEGER,
        l.propietario::VARCHAR,
        COALESCE(l.domicilio::VARCHAR, 'Sin domicilio') as direccion_completa,
        COALESCE(l.colonia_prop::VARCHAR, l.colonia_ubic::VARCHAR, 'N/A') as colonia,
        COALESCE(l.cp::VARCHAR, 'N/A') as codigo_postal,
        CASE
            WHEN b.id_local IS NOT NULL AND (b.fecha_final IS NULL OR b.fecha_final >= CURRENT_DATE)
            THEN 'S'::VARCHAR
            ELSE 'N'::VARCHAR
        END as bloqueado,
        1 as licencias_afectadas,
        b.fecha_inicio as fecha_bloqueo,
        b.id_usuario::VARCHAR as usuario_bloqueo,
        b.observacion::VARCHAR as motivo_bloqueo
    FROM comun.licencias l
    LEFT JOIN comun.ta_11_bloqueo b ON l.id_licencia = b.id_local
        AND (b.fecha_final IS NULL OR b.fecha_final >= CURRENT_DATE)
    WHERE l.vigente = 'V'
        AND (p_calle IS NULL OR l.domicilio::VARCHAR ILIKE '%' || p_calle || '%')
        AND (p_colonia IS NULL OR l.colonia_prop::VARCHAR ILIKE '%' || p_colonia || '%' OR l.colonia_ubic::VARCHAR ILIKE '%' || p_colonia || '%')
        AND (p_codigo_postal IS NULL OR l.cp::VARCHAR = p_codigo_postal)
        AND (p_estado_bloqueo IS NULL OR
            (p_estado_bloqueo = 'S' AND b.id_local IS NOT NULL AND (b.fecha_final IS NULL OR b.fecha_final >= CURRENT_DATE)) OR
            (p_estado_bloqueo = 'N' AND (b.id_local IS NULL OR b.fecha_final < CURRENT_DATE)))
    ORDER BY l.id_licencia, b.fecha_inicio DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_domicilios_bloquear_masivo
-- Descripción: Bloquea múltiples licencias basándose en sus domicilios
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_domicilios_bloquear_masivo(
    p_ids_domicilios VARCHAR,
    p_motivo VARCHAR,
    p_fecha_vigencia DATE DEFAULT NULL,
    p_usuario VARCHAR DEFAULT 'admin'
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR
) AS $$
DECLARE
    v_id_array INTEGER[];
    v_id INTEGER;
    v_count INTEGER := 0;
    v_id_usuario SMALLINT := 1; -- Usuario por defecto
BEGIN
    -- Convertir string de IDs a array
    v_id_array := string_to_array(p_ids_domicilios, ',')::INTEGER[];

    -- Insertar bloqueos para cada licencia
    FOREACH v_id IN ARRAY v_id_array
    LOOP
        -- Verificar que la licencia existe y está vigente
        IF EXISTS (SELECT 1 FROM comun.licencias WHERE id_licencia = v_id AND vigente = 'V') THEN
            -- Verificar que no esté ya bloqueada
            IF NOT EXISTS (
                SELECT 1 FROM comun.ta_11_bloqueo
                WHERE id_local = v_id
                AND (fecha_final IS NULL OR fecha_final >= CURRENT_DATE)
            ) THEN
                -- Insertar bloqueo
                INSERT INTO comun.ta_11_bloqueo (
                    id_local,
                    cve_bloqueo,
                    fecha_inicio,
                    fecha_final,
                    observacion,
                    id_usuario,
                    fecha_actual
                ) VALUES (
                    v_id,
                    1, -- Tipo de bloqueo por domicilio
                    CURRENT_DATE,
                    p_fecha_vigencia,
                    p_motivo,
                    v_id_usuario,
                    CURRENT_TIMESTAMP
                );

                v_count := v_count + 1;
            END IF;
        END IF;
    END LOOP;

    -- Retornar resultado
    RETURN QUERY SELECT
        true,
        ('Se bloquearon ' || v_count || ' licencia(s) exitosamente')::VARCHAR;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT
        false,
        ('Error al bloquear licencias: ' || SQLERRM)::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_domicilios_desbloquear_masivo
-- Descripción: Desbloquea múltiples licencias actualizando fecha_final
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_domicilios_desbloquear_masivo(
    p_ids_domicilios VARCHAR,
    p_motivo VARCHAR,
    p_usuario VARCHAR DEFAULT 'admin'
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR
) AS $$
DECLARE
    v_id_array INTEGER[];
    v_id INTEGER;
    v_count INTEGER := 0;
BEGIN
    -- Convertir string de IDs a array
    v_id_array := string_to_array(p_ids_domicilios, ',')::INTEGER[];

    -- Actualizar bloqueos activos para cada licencia
    FOREACH v_id IN ARRAY v_id_array
    LOOP
        -- Actualizar fecha_final de bloqueos activos
        UPDATE comun.ta_11_bloqueo
        SET
            fecha_final = CURRENT_DATE - INTERVAL '1 day',
            observacion = observacion || ' | DESBLOQUEADO: ' || p_motivo
        WHERE id_local = v_id
        AND (fecha_final IS NULL OR fecha_final >= CURRENT_DATE);

        IF FOUND THEN
            v_count := v_count + 1;
        END IF;
    END LOOP;

    -- Retornar resultado
    RETURN QUERY SELECT
        true,
        ('Se desbloquearon ' || v_count || ' licencia(s) exitosamente')::VARCHAR;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT
        false,
        ('Error al desbloquear licencias: ' || SQLERRM)::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- NOTAS:
-- 1. sp_domicilios_buscar busca licencias por domicilio y muestra estado de bloqueo
-- 2. sp_domicilios_bloquear_masivo crea registros en ta_11_bloqueo
-- 3. sp_domicilios_desbloquear_masivo actualiza fecha_final para desbloquear
-- 4. id_local en ta_11_bloqueo = id_licencia en licencias
-- 5. Un bloqueo está activo si fecha_final IS NULL O fecha_final >= CURRENT_DATE
-- 6. cve_bloqueo = 1 se usa para bloqueos por domicilio
