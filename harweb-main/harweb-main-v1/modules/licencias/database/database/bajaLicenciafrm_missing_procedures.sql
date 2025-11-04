-- ============================================
-- STORED PROCEDURES FALTANTES
-- Formulario: bajaLicenciafrm
-- Generado: 2025-11-03
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_licencia_buscar
-- Descripción: Busca una licencia por su número
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_licencia_buscar(p_numero_licencia VARCHAR)
RETURNS TABLE(
    id INTEGER,
    licencia VARCHAR,
    propietario VARCHAR,
    domicilio VARCHAR,
    actividad VARCHAR,
    vigente VARCHAR,
    fecha_otorgamiento DATE,
    bloqueado SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_licencia as id,
        l.licencia::VARCHAR,
        l.propietario::VARCHAR,
        l.domicilio::VARCHAR,
        l.actividad::VARCHAR,
        l.vigente::VARCHAR,
        l.fecha_otorgamiento,
        l.bloqueado
    FROM comun.licencias l
    WHERE l.licencia::VARCHAR = p_numero_licencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_licencia_adeudos
-- Descripción: Lista los adeudos pendientes de una licencia
-- NOTA: La tabla detsal_lic NO tiene columna 'concepto', tiene columnas por tipo de cargo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_licencia_adeudos(p_id_licencia INTEGER)
RETURNS TABLE(
    concepto VARCHAR,
    importe NUMERIC,
    ejercicio SMALLINT,
    cvepago INTEGER
) AS $$
BEGIN
    -- Retornar adeudos desglosados por concepto
    RETURN QUERY
    SELECT
        'Derechos'::VARCHAR as concepto,
        d.derechos as importe,
        d.axo as ejercicio,
        d.cvepago
    FROM comun.detsal_lic d
    WHERE d.id_licencia = p_id_licencia
    AND (d.id_anuncio IS NULL OR d.id_anuncio = 0)
    AND d.cvepago = 0
    AND d.derechos > 0

    UNION ALL

    SELECT
        'Recargos'::VARCHAR as concepto,
        d.recargos as importe,
        d.axo as ejercicio,
        d.cvepago
    FROM comun.detsal_lic d
    WHERE d.id_licencia = p_id_licencia
    AND (d.id_anuncio IS NULL OR d.id_anuncio = 0)
    AND d.cvepago = 0
    AND d.recargos > 0

    UNION ALL

    SELECT
        'Formas'::VARCHAR as concepto,
        d.forma as importe,
        d.axo as ejercicio,
        d.cvepago
    FROM comun.detsal_lic d
    WHERE d.id_licencia = p_id_licencia
    AND (d.id_anuncio IS NULL OR d.id_anuncio = 0)
    AND d.cvepago = 0
    AND d.forma > 0

    UNION ALL

    SELECT
        'Actualización'::VARCHAR as concepto,
        d.actualizacion as importe,
        d.axo as ejercicio,
        d.cvepago
    FROM comun.detsal_lic d
    WHERE d.id_licencia = p_id_licencia
    AND (d.id_anuncio IS NULL OR d.id_anuncio = 0)
    AND d.cvepago = 0
    AND d.actualizacion > 0

    ORDER BY ejercicio, concepto;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_licencia_anuncios
-- Descripción: Lista los anuncios de una licencia con conteo de adeudos
-- NOTA: texto_anuncio es character(50), bloqueado es SMALLINT
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_licencia_anuncios(p_id_licencia INTEGER)
RETURNS TABLE(
    anuncio INTEGER,
    id_anuncio INTEGER,
    texto_anuncio VARCHAR,
    vigente VARCHAR,
    bloqueado SMALLINT,
    adeudos_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.anuncio,
        a.id_anuncio,
        a.texto_anuncio::VARCHAR,
        a.vigente::VARCHAR,
        a.bloqueado,
        (SELECT COUNT(*)
         FROM comun.detsal_lic d
         WHERE d.id_anuncio = a.id_anuncio
         AND d.cvepago = 0) as adeudos_count
    FROM comun.anuncios a
    WHERE a.id_licencia = p_id_licencia
    ORDER BY a.anuncio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_licencia_baja
-- Descripción: Procesa la baja de una licencia, sus anuncios y cancela adeudos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_licencia_baja(
    p_id_licencia INTEGER,
    p_motivo TEXT,
    p_anio INTEGER DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL,
    p_baja_error VARCHAR DEFAULT 'N'
) RETURNS JSONB AS $$
DECLARE
    v_licencia RECORD;
    v_anuncio RECORD;
    v_count INTEGER;
BEGIN
    -- Verificar que la licencia existe
    SELECT * INTO v_licencia FROM comun.licencias WHERE id_licencia = p_id_licencia;
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Licencia no encontrada'
        );
    END IF;

    -- Verificar que la licencia está vigente
    IF v_licencia.vigente <> 'V' THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'La licencia ya está dada de baja o cancelada'
        );
    END IF;

    -- Verificar que no está bloqueada
    IF v_licencia.bloqueado > 0 AND v_licencia.bloqueado < 5 THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'La licencia está bloqueada, no se puede dar de baja'
        );
    END IF;

    -- Verificar que no tenga anuncios bloqueados
    SELECT COUNT(*) INTO v_count
    FROM comun.anuncios
    WHERE id_licencia = p_id_licencia
    AND vigente = 'V'
    AND bloqueado > 0;

    IF v_count > 0 THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'La licencia tiene anuncios bloqueados, no se puede dar de baja'
        );
    END IF;

    -- Cancelar adeudos de la licencia (marcar como cancelados)
    UPDATE comun.detsal_lic
    SET cvepago = 999999
    WHERE id_licencia = p_id_licencia
    AND (id_anuncio IS NULL OR id_anuncio = 0)
    AND cvepago = 0;

    -- Dar de baja anuncios vigentes y sus adeudos
    FOR v_anuncio IN
        SELECT * FROM comun.anuncios
        WHERE id_licencia = p_id_licencia
        AND vigente = 'V'
    LOOP
        -- Cancelar adeudos del anuncio
        UPDATE comun.detsal_lic
        SET cvepago = 999999
        WHERE id_anuncio = v_anuncio.id_anuncio
        AND cvepago = 0;

        -- Dar de baja el anuncio
        UPDATE comun.anuncios
        SET
            vigente = 'C',
            fecha_baja = CURRENT_DATE,
            axo_baja = p_anio,
            folio_baja = p_folio,
            espubic = p_motivo
        WHERE id_anuncio = v_anuncio.id_anuncio;
    END LOOP;

    -- Dar de baja la licencia
    UPDATE comun.licencias
    SET
        vigente = 'C',
        fecha_baja = CURRENT_DATE,
        axo_baja = p_anio,
        folio_baja = p_folio,
        espubic = p_motivo
    WHERE id_licencia = p_id_licencia;

    -- Retornar éxito
    RETURN jsonb_build_object(
        'success', true,
        'message', 'Licencia dada de baja exitosamente'
    );

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'success', false,
        'message', 'Error al procesar la baja: ' || SQLERRM
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- NOTAS:
-- 1. Estos SPs usan el schema 'comun' para las tablas (comun.licencias, comun.anuncios, comun.detsal_lic)
-- 2. Se crean en el schema 'public' para que sean accesibles desde el backend
-- 3. El SP sp_licencia_baja retorna JSONB con success y message
-- 4. Los adeudos se cancelan marcando cvepago = 999999
-- 5. Las licencias y anuncios se marcan como vigente = 'C' (Cancelado)
-- 6. CORRECCIONES APLICADAS (tipos de datos):
--    TABLA comun.licencias:
--      - Columna 'giro' NO existe, se usa 'actividad' (character(130))
--      - Columna 'bloqueado' es SMALLINT, no INTEGER
--      - Columna 'licencia' es INTEGER, se convierte a VARCHAR para búsqueda
--
--    TABLA comun.detsal_lic:
--      - NO tiene columna 'concepto', tiene columnas por tipo:
--        * derechos, recargos, forma, actualizacion (todas NUMERIC)
--      - Columna 'axo' es SMALLINT (no INTEGER para ejercicio)
--      - Se usa UNION ALL para crear conceptos virtuales
--
--    TABLA comun.anuncios:
--      - 'texto_anuncio' es CHARACTER(50), se convierte a VARCHAR
--      - 'vigente' es CHARACTER(1), se convierte a VARCHAR
--      - 'bloqueado' es SMALLINT
