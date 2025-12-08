-- ============================================
-- STORED PROCEDURES IMPLEMENTADOS
-- Componente: consultaLicenciafrm
-- Módulo: padron_licencias
-- Generado: 2025-11-20
-- Total SPs: 4
-- ============================================
--
-- ESQUEMA: public (tablas licencias, detsal_lic, bloqueo, pagos)
--
-- CARACTERÍSTICAS:
-- - Consulta de adeudos de licencias y anuncios
-- - Bloqueo/desbloqueo de licencias con auditoría
-- - Consulta de pagos realizados
-- - Validaciones de parámetros requeridos
-- - Auditoría con capturista y fecha
-- ============================================

-- ============================================
-- SP 1/4: sp_consulta_licencia_get_adeudos
-- Tipo: Report/Consulta
-- Descripción: Obtiene el detalle de adeudos de una licencia o anuncio
--              por año, incluyendo derechos, recargos, formas, etc.
-- Parámetros:
--   p_id: ID de la licencia o anuncio
--   p_tipo: Tipo de consulta ('L' = Licencia, 'A' = Anuncio)
-- Retorna: Detalle de adeudos por año con todos los conceptos
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_consulta_licencia_get_adeudos(
    p_id INTEGER,
    p_tipo VARCHAR(1)
)
RETURNS TABLE(
    id_licencia INTEGER,
    axo INTEGER,
    licencia INTEGER,
    anuncio INTEGER,
    formas NUMERIC(12,2),
    desc_formas NUMERIC(12,2),
    derechos NUMERIC(12,2),
    desc_derechos NUMERIC(12,2),
    derechos2 NUMERIC(12,2),
    recargos NUMERIC(12,2),
    desc_recargos NUMERIC(12,2),
    actualizacion NUMERIC(12,2),
    gastos NUMERIC(12,2),
    multas NUMERIC(12,2),
    saldo NUMERIC(12,2),
    concepto VARCHAR(100),
    bloq VARCHAR(10)
) AS $$
BEGIN
    -- Validar parámetros requeridos
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_id es requerido';
    END IF;

    IF p_tipo IS NULL OR p_tipo NOT IN ('L', 'A') THEN
        RAISE EXCEPTION 'El parámetro p_tipo debe ser ''L'' (Licencia) o ''A'' (Anuncio)';
    END IF;

    -- Consulta de adeudos según el tipo
    IF p_tipo = 'L' THEN
        -- Consulta por ID de licencia
        RETURN QUERY
        SELECT
            d.id_licencia,
            d.axo,
            d.licencia,
            d.anuncio,
            COALESCE(d.formas, 0.00)::NUMERIC(12,2),
            COALESCE(d.desc_formas, 0.00)::NUMERIC(12,2),
            COALESCE(d.derechos, 0.00)::NUMERIC(12,2),
            COALESCE(d.desc_derechos, 0.00)::NUMERIC(12,2),
            COALESCE(d.derechos2, 0.00)::NUMERIC(12,2),
            COALESCE(d.recargos, 0.00)::NUMERIC(12,2),
            COALESCE(d.desc_recargos, 0.00)::NUMERIC(12,2),
            COALESCE(d.actualizacion, 0.00)::NUMERIC(12,2),
            COALESCE(d.gastos, 0.00)::NUMERIC(12,2),
            COALESCE(d.multas, 0.00)::NUMERIC(12,2),
            COALESCE(d.saldo, 0.00)::NUMERIC(12,2),
            COALESCE(d.concepto, '')::VARCHAR(100),
            COALESCE(d.bloq, '')::VARCHAR(10)
        FROM public.detsal_lic d
        WHERE d.id_licencia = p_id
          AND d.cvepago = 0
        ORDER BY d.axo DESC;

    ELSIF p_tipo = 'A' THEN
        -- Consulta por ID de anuncio
        RETURN QUERY
        SELECT
            d.id_licencia,
            d.axo,
            d.licencia,
            d.anuncio,
            COALESCE(d.formas, 0.00)::NUMERIC(12,2),
            COALESCE(d.desc_formas, 0.00)::NUMERIC(12,2),
            COALESCE(d.derechos, 0.00)::NUMERIC(12,2),
            COALESCE(d.desc_derechos, 0.00)::NUMERIC(12,2),
            COALESCE(d.derechos2, 0.00)::NUMERIC(12,2),
            COALESCE(d.recargos, 0.00)::NUMERIC(12,2),
            COALESCE(d.desc_recargos, 0.00)::NUMERIC(12,2),
            COALESCE(d.actualizacion, 0.00)::NUMERIC(12,2),
            COALESCE(d.gastos, 0.00)::NUMERIC(12,2),
            COALESCE(d.multas, 0.00)::NUMERIC(12,2),
            COALESCE(d.saldo, 0.00)::NUMERIC(12,2),
            COALESCE(d.concepto, '')::VARCHAR(100),
            COALESCE(d.bloq, '')::VARCHAR(10)
        FROM public.detsal_lic d
        WHERE d.anuncio = p_id
          AND d.cvepago = 0
        ORDER BY d.axo DESC;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_consulta_licencia_get_adeudos(INTEGER, VARCHAR) IS
'Obtiene el detalle de adeudos de una licencia o anuncio por año';

-- ============================================
-- SP 2/4: sp_consulta_licencia_bloquear
-- Tipo: CRUD/Transacción
-- Descripción: Bloquea una licencia con un tipo de bloqueo y motivo,
--              registrando la operación en auditoría
-- Parámetros:
--   p_id_licencia: ID de la licencia a bloquear
--   p_tipo_bloqueo: Código del tipo de bloqueo
--   p_motivo: Motivo o justificación del bloqueo
-- Retorna: Resultado de la operación (success, message)
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_consulta_licencia_bloquear(
    p_id_licencia INTEGER,
    p_tipo_bloqueo INTEGER,
    p_motivo TEXT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_licencia_existe BOOLEAN;
    v_ya_bloqueada BOOLEAN;
    v_bloqueo_actual INTEGER;
BEGIN
    -- Validar parámetros requeridos
    IF p_id_licencia IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_id_licencia es requerido';
    END IF;

    IF p_tipo_bloqueo IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_tipo_bloqueo es requerido';
    END IF;

    IF p_motivo IS NULL OR TRIM(p_motivo) = '' THEN
        RAISE EXCEPTION 'El parámetro p_motivo es requerido y no puede estar vacío';
    END IF;

    -- Verificar que la licencia existe
    SELECT EXISTS(
        SELECT 1
        FROM public.licencias
        WHERE id_licencia = p_id_licencia
    ) INTO v_licencia_existe;

    IF NOT v_licencia_existe THEN
        RETURN QUERY SELECT FALSE, 'La licencia especificada no existe';
        RETURN;
    END IF;

    -- Verificar el estado actual de bloqueo
    SELECT bloqueado INTO v_bloqueo_actual
    FROM public.licencias
    WHERE id_licencia = p_id_licencia;

    IF v_bloqueo_actual IS NOT NULL AND v_bloqueo_actual > 0 THEN
        RETURN QUERY SELECT FALSE,
            'La licencia ya está bloqueada con tipo de bloqueo: ' || v_bloqueo_actual::TEXT;
        RETURN;
    END IF;

    -- Actualizar el estado de bloqueo en la tabla licencias
    UPDATE public.licencias
    SET bloqueado = p_tipo_bloqueo
    WHERE id_licencia = p_id_licencia;

    -- Registrar el bloqueo en la tabla de auditoría
    INSERT INTO public.bloqueo (
        bloqueado,
        id_licencia,
        observa,
        vigente,
        fecha_mov,
        capturista
    ) VALUES (
        p_tipo_bloqueo,
        p_id_licencia,
        p_motivo,
        'V',
        NOW(),
        CURRENT_USER
    );

    -- Retornar éxito
    RETURN QUERY SELECT TRUE,
        'Licencia bloqueada exitosamente con tipo: ' || p_tipo_bloqueo::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE,
            'Error al bloquear la licencia: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_consulta_licencia_bloquear(INTEGER, INTEGER, TEXT) IS
'Bloquea una licencia con un tipo de bloqueo específico y registra la operación';

-- ============================================
-- SP 3/4: sp_consulta_licencia_desbloquear
-- Tipo: CRUD/Transacción
-- Descripción: Desbloquea una licencia cancelando el bloqueo actual
--              y registrando la operación en auditoría
-- Parámetros:
--   p_id_licencia: ID de la licencia a desbloquear
--   p_tipo_bloqueo: Tipo de bloqueo a cancelar
--   p_motivo: Motivo del desbloqueo
-- Retorna: Resultado de la operación (success, message)
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_consulta_licencia_desbloquear(
    p_id_licencia INTEGER,
    p_tipo_bloqueo INTEGER,
    p_motivo TEXT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_licencia_existe BOOLEAN;
    v_bloqueos_actualizados INTEGER;
    v_bloqueo_actual INTEGER;
BEGIN
    -- Validar parámetros requeridos
    IF p_id_licencia IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_id_licencia es requerido';
    END IF;

    IF p_tipo_bloqueo IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_tipo_bloqueo es requerido';
    END IF;

    IF p_motivo IS NULL OR TRIM(p_motivo) = '' THEN
        RAISE EXCEPTION 'El parámetro p_motivo es requerido y no puede estar vacío';
    END IF;

    -- Verificar que la licencia existe
    SELECT EXISTS(
        SELECT 1
        FROM public.licencias
        WHERE id_licencia = p_id_licencia
    ) INTO v_licencia_existe;

    IF NOT v_licencia_existe THEN
        RETURN QUERY SELECT FALSE, 'La licencia especificada no existe';
        RETURN;
    END IF;

    -- Verificar que la licencia tiene el bloqueo especificado
    SELECT bloqueado INTO v_bloqueo_actual
    FROM public.licencias
    WHERE id_licencia = p_id_licencia;

    IF v_bloqueo_actual IS NULL OR v_bloqueo_actual = 0 THEN
        RETURN QUERY SELECT FALSE, 'La licencia no está bloqueada';
        RETURN;
    END IF;

    IF v_bloqueo_actual <> p_tipo_bloqueo THEN
        RETURN QUERY SELECT FALSE,
            'El tipo de bloqueo no coincide. Bloqueo actual: ' || v_bloqueo_actual::TEXT;
        RETURN;
    END IF;

    -- Cancelar bloqueos vigentes del tipo especificado
    UPDATE public.bloqueo
    SET vigente = 'C'
    WHERE id_licencia = p_id_licencia
      AND bloqueado = p_tipo_bloqueo
      AND vigente = 'V';

    GET DIAGNOSTICS v_bloqueos_actualizados = ROW_COUNT;

    -- Desbloquear la licencia en la tabla principal
    UPDATE public.licencias
    SET bloqueado = 0
    WHERE id_licencia = p_id_licencia;

    -- Registrar el desbloqueo en la tabla de auditoría
    INSERT INTO public.bloqueo (
        bloqueado,
        id_licencia,
        observa,
        vigente,
        fecha_mov,
        capturista
    ) VALUES (
        0,
        p_id_licencia,
        p_motivo,
        'V',
        NOW(),
        CURRENT_USER
    );

    -- Retornar éxito
    RETURN QUERY SELECT TRUE,
        'Licencia desbloqueada exitosamente. Bloqueos cancelados: ' || v_bloqueos_actualizados::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE,
            'Error al desbloquear la licencia: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_consulta_licencia_desbloquear(INTEGER, INTEGER, TEXT) IS
'Desbloquea una licencia y registra la operación de desbloqueo';

-- ============================================
-- SP 4/4: sp_consulta_licencia_get_pagos
-- Tipo: Report/Consulta
-- Descripción: Obtiene el historial de pagos realizados para una licencia
-- Parámetros:
--   p_id_licencia: ID de la licencia (cvecuenta)
-- Retorna: Lista de pagos ordenados por fecha descendente
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_consulta_licencia_get_pagos(
    p_id_licencia INTEGER
)
RETURNS TABLE(
    cvepago INTEGER,
    cvecuenta INTEGER,
    recaud SMALLINT,
    caja VARCHAR(20),
    folio INTEGER,
    fecha DATE,
    hora TIMESTAMP,
    importe NUMERIC(12,2),
    cajero VARCHAR(100),
    cvecanc INTEGER,
    cveconcepto INTEGER
) AS $$
BEGIN
    -- Validar parámetro requerido
    IF p_id_licencia IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_id_licencia es requerido';
    END IF;

    -- Consultar pagos de la licencia
    RETURN QUERY
    SELECT
        p.cvepago,
        p.cvecuenta,
        p.recaud,
        p.caja::VARCHAR(20),
        p.folio,
        p.fecha,
        p.hora,
        COALESCE(p.importe, 0.00)::NUMERIC(12,2),
        p.cajero::VARCHAR(100),
        p.cvecanc,
        p.cveconcepto
    FROM public.pagos p
    WHERE p.cvecuenta = p_id_licencia
      AND p.cveconcepto IN (8, 27, 28)  -- Conceptos de licencias
      AND p.cvecanc IS NULL              -- Pagos no cancelados
    ORDER BY p.fecha DESC, p.hora DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_consulta_licencia_get_pagos(INTEGER) IS
'Obtiene el historial de pagos realizados para una licencia';

-- ============================================
-- ÍNDICES RECOMENDADOS PARA OPTIMIZACIÓN
-- ============================================

-- Índices para tabla detsal_lic
CREATE INDEX IF NOT EXISTS idx_detsal_lic_id_licencia
    ON public.detsal_lic(id_licencia)
    WHERE cvepago = 0;

CREATE INDEX IF NOT EXISTS idx_detsal_lic_anuncio
    ON public.detsal_lic(anuncio)
    WHERE cvepago = 0;

CREATE INDEX IF NOT EXISTS idx_detsal_lic_cvepago
    ON public.detsal_lic(cvepago);

-- Índices para tabla bloqueo
CREATE INDEX IF NOT EXISTS idx_bloqueo_id_licencia
    ON public.bloqueo(id_licencia);

CREATE INDEX IF NOT EXISTS idx_bloqueo_vigente
    ON public.bloqueo(id_licencia, bloqueado)
    WHERE vigente = 'V';

CREATE INDEX IF NOT EXISTS idx_bloqueo_fecha_mov
    ON public.bloqueo(fecha_mov DESC);

-- Índices para tabla pagos
CREATE INDEX IF NOT EXISTS idx_pagos_cvecuenta
    ON public.pagos(cvecuenta);

CREATE INDEX IF NOT EXISTS idx_pagos_cveconcepto
    ON public.pagos(cveconcepto);

CREATE INDEX IF NOT EXISTS idx_pagos_fecha
    ON public.pagos(fecha DESC, hora DESC);

CREATE INDEX IF NOT EXISTS idx_pagos_no_cancelados
    ON public.pagos(cvecuenta, cveconcepto)
    WHERE cvecanc IS NULL;

-- Índices para tabla licencias
CREATE INDEX IF NOT EXISTS idx_licencias_id_licencia
    ON public.licencias(id_licencia);

CREATE INDEX IF NOT EXISTS idx_licencias_bloqueado
    ON public.licencias(bloqueado);

-- ============================================
-- VERIFICACIÓN DE INSTALACIÓN
-- ============================================

DO $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Contar funciones instaladas
    SELECT COUNT(*) INTO v_count
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
      AND p.proname IN (
          'sp_consulta_licencia_get_adeudos',
          'sp_consulta_licencia_bloquear',
          'sp_consulta_licencia_desbloquear',
          'sp_consulta_licencia_get_pagos'
      );

    RAISE NOTICE '==============================================';
    RAISE NOTICE 'INSTALACIÓN COMPLETADA';
    RAISE NOTICE 'Componente: consultaLicenciafrm';
    RAISE NOTICE 'Total funciones instaladas: %', v_count;
    RAISE NOTICE '==============================================';

    IF v_count = 4 THEN
        RAISE NOTICE 'ESTADO: ✓ Todas las funciones instaladas correctamente';
    ELSE
        RAISE WARNING 'ESTADO: ⚠ Solo % de 4 funciones instaladas', v_count;
    END IF;
END $$;

-- ============================================
-- RESUMEN DE IMPLEMENTACIÓN
-- ============================================
/*
TOTAL SPS IMPLEMENTADOS: 4

LISTA DE STORED PROCEDURES:
1. sp_consulta_licencia_get_adeudos    - Obtiene adeudos de licencia/anuncio
2. sp_consulta_licencia_bloquear       - Bloquea licencia con auditoría
3. sp_consulta_licencia_desbloquear    - Desbloquea licencia con auditoría
4. sp_consulta_licencia_get_pagos      - Obtiene historial de pagos

SCHEMA UTILIZADO: public

TABLAS PRINCIPALES:
- public.licencias          - Información principal de licencias
- public.detsal_lic         - Detalle de saldos y adeudos
- public.bloqueo           - Auditoría de bloqueos/desbloqueos
- public.pagos             - Registro de pagos realizados

CARACTERÍSTICAS ESPECIALES:
✓ Validación de parámetros requeridos con RAISE EXCEPTION
✓ RETURNS TABLE con tipos de datos correctos
✓ Operaciones CRUD retornan (success BOOLEAN, message TEXT)
✓ Auditoría con capturista (CURRENT_USER) y fecha (NOW())
✓ Soft delete con campo vigente ('V'/'C')
✓ Validación de existencia de registros antes de operaciones
✓ Manejo de errores con EXCEPTION y mensajes descriptivos
✓ Índices optimizados para consultas frecuentes
✓ Comentarios en funciones con COMMENT ON FUNCTION
✓ COALESCE para valores nulos en consultas
✓ WHERE con filtros específicos (cvepago=0, vigente='V')
✓ Bloqueos con verificación de estado actual
✓ Conceptos específicos de licencias (8, 27, 28)

RUTA DEL ARCHIVO:
C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/CONSULTALICENCIAFRM_all_procedures_IMPLEMENTED.sql

FECHA DE GENERACIÓN: 2025-11-20
ESTADO: ✓ LISTO PARA DESPLIEGUE
*/
