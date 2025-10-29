-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES PARA BLOQUEO DE LICENCIAS
-- Convención: SP_BLOQUEARLIC_XXX
-- Generado: 2025-09-09
-- Módulo: 09 - BLOQUEARLICENCIAFRM (Prioridad Media)
-- ============================================

-- SP 1/7: SP_BLOQUEARLIC_LIST
-- Tipo: List/Read
-- Descripción: Lista bloqueos de licencias
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_BLOQUEARLIC_LIST(
    p_numero_licencia VARCHAR(100) DEFAULT NULL,
    p_propietario VARCHAR(255) DEFAULT NULL,
    p_tipo_bloqueo VARCHAR(50) DEFAULT NULL,
    p_estado_bloqueo VARCHAR(30) DEFAULT NULL,
    p_activos_solo BOOLEAN DEFAULT FALSE,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    folio_bloqueo VARCHAR(100),
    numero_licencia VARCHAR(100),
    propietario VARCHAR(255),
    tipo_bloqueo VARCHAR(50),
    motivo_bloqueo TEXT,
    fecha_inicio_bloqueo DATE,
    fecha_fin_bloqueo DATE,
    estado_bloqueo VARCHAR(30),
    funcionario_responsable VARCHAR(100),
    dias_bloqueado INTEGER,
    total_registros BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count BIGINT;
    v_estado_filtro VARCHAR(30);
BEGIN
    -- Determinar filtro de estado
    IF p_activos_solo THEN
        v_estado_filtro := 'ACTIVO';
    ELSE
        v_estado_filtro := COALESCE(p_estado_bloqueo, 'ACTIVO');
    END IF;

    -- Contar total de registros
    SELECT COUNT(*) INTO v_total_count
    FROM public.bloqueos_licencias bl
    WHERE (p_numero_licencia IS NULL OR bl.numero_licencia ILIKE '%' || p_numero_licencia || '%')
      AND (p_propietario IS NULL OR bl.propietario ILIKE '%' || p_propietario || '%')
      AND (p_tipo_bloqueo IS NULL OR bl.tipo_bloqueo = upper(p_tipo_bloqueo))
      AND (p_estado_bloqueo IS NULL OR bl.estado_bloqueo = v_estado_filtro)
      AND (p_fecha_desde IS NULL OR bl.fecha_inicio_bloqueo >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR bl.fecha_inicio_bloqueo <= p_fecha_hasta);

    -- Retornar resultados
    RETURN QUERY
    SELECT 
        bl.id,
        bl.folio_bloqueo,
        bl.numero_licencia,
        bl.propietario,
        bl.tipo_bloqueo,
        bl.motivo_bloqueo,
        bl.fecha_inicio_bloqueo,
        bl.fecha_fin_bloqueo,
        bl.estado_bloqueo,
        bl.funcionario_responsable,
        CASE 
            WHEN bl.fecha_fin_bloqueo IS NULL OR bl.estado_bloqueo != 'ACTIVO' THEN 
                (CURRENT_DATE - bl.fecha_inicio_bloqueo)::INTEGER
            ELSE 
                (bl.fecha_fin_bloqueo - bl.fecha_inicio_bloqueo)::INTEGER
        END as dias_bloqueado,
        v_total_count as total_registros
    FROM public.bloqueos_licencias bl
    WHERE (p_numero_licencia IS NULL OR bl.numero_licencia ILIKE '%' || p_numero_licencia || '%')
      AND (p_propietario IS NULL OR bl.propietario ILIKE '%' || p_propietario || '%')
      AND (p_tipo_bloqueo IS NULL OR bl.tipo_bloqueo = upper(p_tipo_bloqueo))
      AND (p_estado_bloqueo IS NULL OR bl.estado_bloqueo = v_estado_filtro)
      AND (p_fecha_desde IS NULL OR bl.fecha_inicio_bloqueo >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR bl.fecha_inicio_bloqueo <= p_fecha_hasta)
    ORDER BY bl.fecha_inicio_bloqueo DESC, bl.id DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$;

-- ============================================

-- SP 2/7: SP_BLOQUEARLIC_GET
-- Tipo: Read
-- Descripción: Obtiene detalle de bloqueo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_BLOQUEARLIC_GET(p_folio_bloqueo VARCHAR(100))
RETURNS TABLE(
    id INTEGER,
    folio_bloqueo VARCHAR(100),
    numero_licencia VARCHAR(100),
    propietario VARCHAR(255),
    razon_social VARCHAR(255),
    rfc VARCHAR(20),
    direccion TEXT,
    giro VARCHAR(255),
    tipo_bloqueo VARCHAR(50),
    motivo_bloqueo TEXT,
    fecha_inicio_bloqueo DATE,
    fecha_fin_bloqueo DATE,
    duracion_dias INTEGER,
    estado_bloqueo VARCHAR(30),
    documento_sustento VARCHAR(255),
    observaciones TEXT,
    funcionario_responsable VARCHAR(100),
    usuario_registro VARCHAR(100),
    fecha_registro TIMESTAMP,
    dias_transcurridos INTEGER,
    esta_vigente BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Validar que el bloqueo existe
    SELECT COUNT(*) INTO v_exists
    FROM public.bloqueos_licencias
    WHERE folio_bloqueo = p_folio_bloqueo;

    IF v_exists = 0 THEN
        RAISE EXCEPTION 'No se encontró el bloqueo: %', p_folio_bloqueo;
    END IF;

    -- Retornar el registro completo
    RETURN QUERY
    SELECT 
        bl.id,
        bl.folio_bloqueo,
        bl.numero_licencia,
        bl.propietario,
        bl.razon_social,
        bl.rfc,
        bl.direccion,
        bl.giro,
        bl.tipo_bloqueo,
        bl.motivo_bloqueo,
        bl.fecha_inicio_bloqueo,
        bl.fecha_fin_bloqueo,
        bl.duracion_dias,
        bl.estado_bloqueo,
        bl.documento_sustento,
        bl.observaciones,
        bl.funcionario_responsable,
        bl.usuario_registro,
        bl.fecha_registro,
        (CURRENT_DATE - bl.fecha_inicio_bloqueo)::INTEGER as dias_transcurridos,
        CASE 
            WHEN bl.estado_bloqueo = 'ACTIVO' AND 
                 (bl.fecha_fin_bloqueo IS NULL OR bl.fecha_fin_bloqueo >= CURRENT_DATE)
            THEN TRUE 
            ELSE FALSE 
        END as esta_vigente
    FROM public.bloqueos_licencias bl
    WHERE bl.folio_bloqueo = p_folio_bloqueo;
END;
$$;

-- ============================================

-- SP 3/7: SP_BLOQUEARLIC_CREATE
-- Tipo: Create
-- Descripción: Crear bloqueo de licencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_BLOQUEARLIC_CREATE(
    p_folio_bloqueo VARCHAR(100),
    p_numero_licencia VARCHAR(100),
    p_tipo_bloqueo VARCHAR(50),
    p_motivo_bloqueo TEXT,
    p_fecha_inicio_bloqueo DATE DEFAULT CURRENT_DATE,
    p_duracion_dias INTEGER DEFAULT NULL,
    p_fecha_fin_bloqueo DATE DEFAULT NULL,
    p_documento_sustento VARCHAR(255) DEFAULT NULL,
    p_funcionario_responsable VARCHAR(100) DEFAULT NULL,
    p_usuario_registro VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT, id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id INTEGER;
    v_exists INTEGER;
    v_lic_exists INTEGER;
    v_lic_estado VARCHAR(20);
    v_bloqueo_activo INTEGER;
    v_fecha_fin_calculada DATE;
BEGIN
    -- Validar campos requeridos
    IF p_folio_bloqueo IS NULL OR trim(p_folio_bloqueo) = '' THEN
        RETURN QUERY SELECT FALSE, 'El folio de bloqueo es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_numero_licencia IS NULL OR trim(p_numero_licencia) = '' THEN
        RETURN QUERY SELECT FALSE, 'El número de licencia es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_motivo_bloqueo IS NULL OR trim(p_motivo_bloqueo) = '' THEN
        RETURN QUERY SELECT FALSE, 'El motivo de bloqueo es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar tipo de bloqueo
    IF upper(p_tipo_bloqueo) NOT IN ('ADMINISTRATIVO', 'JURIDICO', 'FISCAL', 'SANITARIO', 'SEGURIDAD', 'TEMPORAL', 'PREVENTIVO') THEN
        RETURN QUERY SELECT FALSE, 'Tipo de bloqueo no válido. Debe ser: ADMINISTRATIVO, JURIDICO, FISCAL, SANITARIO, SEGURIDAD, TEMPORAL o PREVENTIVO.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que no exista el folio
    SELECT COUNT(*) INTO v_exists
    FROM public.bloqueos_licencias
    WHERE folio_bloqueo = upper(trim(p_folio_bloqueo));

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe un bloqueo con ese folio.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que la licencia existe y obtener estado
    SELECT COUNT(*), MAX(estado) INTO v_lic_exists, v_lic_estado
    FROM public.licencias_comerciales
    WHERE numero_licencia = upper(trim(p_numero_licencia));

    IF v_lic_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'No se encontró la licencia especificada.', NULL::INTEGER;
        RETURN;
    END IF;

    IF v_lic_estado != 'VIGENTE' THEN
        RETURN QUERY SELECT FALSE, 'Solo se pueden bloquear licencias vigentes. Estado actual: ' || v_lic_estado, NULL::INTEGER;
        RETURN;
    END IF;

    -- Verificar que no exista un bloqueo activo
    SELECT COUNT(*) INTO v_bloqueo_activo
    FROM public.bloqueos_licencias
    WHERE numero_licencia = upper(trim(p_numero_licencia)) 
      AND estado_bloqueo = 'ACTIVO'
      AND (fecha_fin_bloqueo IS NULL OR fecha_fin_bloqueo >= CURRENT_DATE);

    IF v_bloqueo_activo > 0 THEN
        RETURN QUERY SELECT FALSE, 'La licencia ya tiene un bloqueo activo.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Calcular fecha fin si se proporciona duración
    IF p_duracion_dias IS NOT NULL AND p_fecha_fin_bloqueo IS NULL THEN
        v_fecha_fin_calculada := p_fecha_inicio_bloqueo + INTERVAL '1 day' * p_duracion_dias;
    ELSE
        v_fecha_fin_calculada := p_fecha_fin_bloqueo;
    END IF;

    -- Insertar el nuevo bloqueo
    INSERT INTO public.bloqueos_licencias (
        folio_bloqueo, numero_licencia, tipo_bloqueo, motivo_bloqueo,
        fecha_inicio_bloqueo, fecha_fin_bloqueo, duracion_dias,
        documento_sustento, funcionario_responsable, usuario_registro
    )
    VALUES (
        upper(trim(p_folio_bloqueo)),
        upper(trim(p_numero_licencia)),
        upper(trim(p_tipo_bloqueo)),
        p_motivo_bloqueo,
        p_fecha_inicio_bloqueo,
        v_fecha_fin_calculada,
        COALESCE(p_duracion_dias, (v_fecha_fin_calculada - p_fecha_inicio_bloqueo)::INTEGER),
        p_documento_sustento,
        upper(trim(p_funcionario_responsable)),
        upper(trim(p_usuario_registro))
    )
    RETURNING public.bloqueos_public.id INTO v_new_id;

    -- Cambiar estado de la licencia a SUSPENDIDA
    UPDATE public.licencias_comerciales
    SET estado = 'SUSPENDIDA',
        observaciones = 'Licencia bloqueada. Folio: ' || upper(trim(p_folio_bloqueo)),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE numero_licencia = upper(trim(p_numero_licencia));

    RETURN QUERY SELECT TRUE, 'Bloqueo aplicado correctamente. Folio: ' || upper(trim(p_folio_bloqueo)), v_new_id;
END;
$$;

-- ============================================

-- SP 4/7: SP_BLOQUEARLIC_UPDATE
-- Tipo: Update
-- Descripción: Actualizar bloqueo de licencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_BLOQUEARLIC_UPDATE(
    p_id INTEGER,
    p_motivo_bloqueo TEXT DEFAULT NULL,
    p_fecha_fin_bloqueo DATE DEFAULT NULL,
    p_duracion_dias INTEGER DEFAULT NULL,
    p_documento_sustento VARCHAR(255) DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_estado VARCHAR(30);
    v_fecha_inicio DATE;
BEGIN
    -- Validar que el bloqueo existe y obtener datos
    SELECT COUNT(*), MAX(estado_bloqueo), MAX(fecha_inicio_bloqueo) 
    INTO v_exists, v_estado, v_fecha_inicio
    FROM public.bloqueos_licencias
    WHERE id = p_id;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El bloqueo no existe.';
        RETURN;
    END IF;

    -- Verificar que se pueda modificar
    IF v_estado IN ('LEVANTADO', 'VENCIDO', 'CANCELADO') THEN
        RETURN QUERY SELECT FALSE, 'No se puede modificar un bloqueo en estado: ' || v_estado;
        RETURN;
    END IF;

    -- Actualizar el bloqueo
    UPDATE public.bloqueos_licencias
    SET motivo_bloqueo = COALESCE(p_motivo_bloqueo, motivo_bloqueo),
        fecha_fin_bloqueo = COALESCE(p_fecha_fin_bloqueo, fecha_fin_bloqueo),
        duracion_dias = CASE 
            WHEN p_duracion_dias IS NOT NULL THEN p_duracion_dias
            WHEN p_fecha_fin_bloqueo IS NOT NULL THEN (p_fecha_fin_bloqueo - v_fecha_inicio)::INTEGER
            ELSE duracion_dias
        END,
        documento_sustento = COALESCE(p_documento_sustento, documento_sustento),
        observaciones = COALESCE(p_observaciones, observaciones),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id = p_id;

    -- Recalcular fecha fin si se cambió duración
    IF p_duracion_dias IS NOT NULL THEN
        UPDATE public.bloqueos_licencias
        SET fecha_fin_bloqueo = v_fecha_inicio + INTERVAL '1 day' * p_duracion_dias
        WHERE id = p_id;
    END IF;

    RETURN QUERY SELECT TRUE, 'Bloqueo actualizado correctamente.';
END;
$$;

-- ============================================

-- SP 5/7: SP_BLOQUEARLIC_LEVANTAR
-- Tipo: Update
-- Descripción: Levantar bloqueo de licencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_BLOQUEARLIC_LEVANTAR(
    p_folio_bloqueo VARCHAR(100),
    p_motivo_levantamiento TEXT DEFAULT NULL,
    p_funcionario_levantamiento VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_estado VARCHAR(30);
    v_numero_licencia VARCHAR(100);
BEGIN
    -- Validar que el bloqueo existe y obtener datos
    SELECT COUNT(*), MAX(estado_bloqueo), MAX(numero_licencia) 
    INTO v_exists, v_estado, v_numero_licencia
    FROM public.bloqueos_licencias
    WHERE folio_bloqueo = p_folio_bloqueo;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El bloqueo no existe.';
        RETURN;
    END IF;

    IF v_estado != 'ACTIVO' THEN
        RETURN QUERY SELECT FALSE, 'Solo se pueden levantar bloqueos activos. Estado actual: ' || v_estado;
        RETURN;
    END IF;

    -- Levantar el bloqueo
    UPDATE public.bloqueos_licencias
    SET estado_bloqueo = 'LEVANTADO',
        fecha_fin_bloqueo = CURRENT_DATE,
        observaciones = COALESCE(observaciones || ' | ', '') || 
                       'Bloqueo levantado: ' || COALESCE(p_motivo_levantamiento, 'Sin motivo especificado'),
        funcionario_responsable = COALESCE(upper(trim(p_funcionario_levantamiento)), funcionario_responsable),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE folio_bloqueo = p_folio_bloqueo;

    -- Verificar si hay otros bloqueos activos para la licencia
    IF NOT EXISTS (
        SELECT 1 FROM public.bloqueos_licencias
        WHERE numero_licencia = v_numero_licencia 
          AND estado_bloqueo = 'ACTIVO'
          AND (fecha_fin_bloqueo IS NULL OR fecha_fin_bloqueo >= CURRENT_DATE)
          AND folio_bloqueo != p_folio_bloqueo
    ) THEN
        -- No hay otros bloqueos, restaurar licencia a VIGENTE
        UPDATE public.licencias_comerciales
        SET estado = 'VIGENTE',
            observaciones = 'Bloqueo levantado. Folio: ' || p_folio_bloqueo,
            fecha_actualizacion = CURRENT_TIMESTAMP
        WHERE numero_licencia = v_numero_licencia;
    END IF;

    RETURN QUERY SELECT TRUE, 'Bloqueo levantado correctamente. Licencia ' || v_numero_licencia || ' restaurada.';
END;
$$;

-- ============================================

-- SP 6/7: SP_BLOQUEARLIC_VENCER_AUTOMATICO
-- Tipo: Update
-- Descripción: Vencer bloqueos automáticamente por fecha
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_BLOQUEARLIC_VENCER_AUTOMATICO()
RETURNS TABLE(success BOOLEAN, message TEXT, bloqueos_vencidos INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_bloqueos_vencidos INTEGER := 0;
    v_licencia VARCHAR(100);
    v_tiene_otros_bloqueos BOOLEAN;
BEGIN
    -- Obtener bloqueos vencidos
    FOR v_licencia IN (
        SELECT DISTINCT numero_licencia 
        FROM public.bloqueos_licencias
        WHERE estado_bloqueo = 'ACTIVO'
          AND fecha_fin_bloqueo IS NOT NULL
          AND fecha_fin_bloqueo < CURRENT_DATE
    )
    LOOP
        -- Marcar bloqueos vencidos para esta licencia
        UPDATE public.bloqueos_licencias
        SET estado_bloqueo = 'VENCIDO',
            observaciones = COALESCE(observaciones || ' | ', '') || 'Vencido automáticamente',
            fecha_actualizacion = CURRENT_TIMESTAMP
        WHERE numero_licencia = v_licencia
          AND estado_bloqueo = 'ACTIVO'
          AND fecha_fin_bloqueo < CURRENT_DATE;

        GET DIAGNOSTICS v_bloqueos_vencidos = ROW_COUNT;

        -- Verificar si quedan bloqueos activos
        SELECT EXISTS (
            SELECT 1 FROM public.bloqueos_licencias
            WHERE numero_licencia = v_licencia 
              AND estado_bloqueo = 'ACTIVO'
              AND (fecha_fin_bloqueo IS NULL OR fecha_fin_bloqueo >= CURRENT_DATE)
        ) INTO v_tiene_otros_bloqueos;

        -- Si no hay más bloqueos activos, restaurar licencia
        IF NOT v_tiene_otros_bloqueos THEN
            UPDATE public.licencias_comerciales
            SET estado = 'VIGENTE',
                observaciones = 'Bloqueos vencidos automáticamente',
                fecha_actualizacion = CURRENT_TIMESTAMP
            WHERE numero_licencia = v_licencia;
        END IF;
    END LOOP;

    RETURN QUERY SELECT TRUE, 'Proceso de vencimiento automático completado.', v_bloqueos_vencidos;
END;
$$;

-- ============================================

-- SP 7/7: SP_BLOQUEARLIC_ACTIVOS
-- Tipo: Read
-- Descripción: Obtener bloqueos activos y próximos a vencer
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_BLOQUEARLIC_ACTIVOS(
    p_dias_alerta INTEGER DEFAULT 7
)
RETURNS TABLE(
    folio_bloqueo VARCHAR(100),
    numero_licencia VARCHAR(100),
    propietario VARCHAR(255),
    tipo_bloqueo VARCHAR(50),
    fecha_inicio_bloqueo DATE,
    fecha_fin_bloqueo DATE,
    dias_restantes INTEGER,
    estado_bloqueo VARCHAR(30),
    alerta VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bl.folio_bloqueo,
        bl.numero_licencia,
        bl.propietario,
        bl.tipo_bloqueo,
        bl.fecha_inicio_bloqueo,
        bl.fecha_fin_bloqueo,
        CASE 
            WHEN bl.fecha_fin_bloqueo IS NULL THEN NULL
            ELSE (bl.fecha_fin_bloqueo - CURRENT_DATE)::INTEGER
        END as dias_restantes,
        bl.estado_bloqueo,
        CASE 
            WHEN bl.fecha_fin_bloqueo IS NULL THEN 'INDEFINIDO'
            WHEN bl.fecha_fin_bloqueo < CURRENT_DATE THEN 'VENCIDO'
            WHEN (bl.fecha_fin_bloqueo - CURRENT_DATE)::INTEGER <= 1 THEN 'CRITICO'
            WHEN (bl.fecha_fin_bloqueo - CURRENT_DATE)::INTEGER <= p_dias_alerta THEN 'ALERTA'
            ELSE 'NORMAL'
        END as alerta
    FROM public.bloqueos_licencias bl
    WHERE bl.estado_bloqueo = 'ACTIVO'
    ORDER BY 
        CASE WHEN bl.fecha_fin_bloqueo IS NULL THEN '9999-12-31'::DATE ELSE bl.fecha_fin_bloqueo END ASC,
        bl.fecha_inicio_bloqueo ASC;
END;
$$;

-- ============================================
-- COMENTARIOS DE IMPLEMENTACIÓN
-- ============================================

/*
NOTAS PARA LA IMPLEMENTACIÓN:

1. Tabla requerida: public.bloqueos_licencias
   - Campos únicos: folio_bloqueo
   - Campos requeridos: numero_licencia, tipo_bloqueo, motivo_bloqueo
   - Estados: ACTIVO, LEVANTADO, VENCIDO, CANCELADO
   - Tipos: ADMINISTRATIVO, JURIDICO, FISCAL, SANITARIO, SEGURIDAD, TEMPORAL, PREVENTIVO

2. Endpoints del controlador Laravel:
   - listarBloqueos -> SP_BLOQUEARLIC_LIST(filtros múltiples)
   - obtenerBloqueo -> SP_BLOQUEARLIC_GET(folio_bloqueo)
   - crearBloqueo -> SP_BLOQUEARLIC_CREATE(datos completos)
   - actualizarBloqueo -> SP_BLOQUEARLIC_UPDATE(id, datos)
   - levantarBloqueo -> SP_BLOQUEARLIC_LEVANTAR(folio, motivo)
   - vencerBloqueos -> SP_BLOQUEARLIC_VENCER_AUTOMATICO()
   - bloqueosActivos -> SP_BLOQUEARLIC_ACTIVOS(dias_alerta)

3. Funcionalidades especiales:
   - Control automático de estado de licencia
   - Vencimiento automático por fechas
   - Verificación de bloqueos múltiples
   - Sistema de alertas por tiempo restante
   - Cálculo automático de duración
   - Prevención de bloqueos duplicados

4. Lógica de negocio:
   - Solo licencias VIGENTES pueden bloquearse
   - Al bloquear: licencia pasa a SUSPENDIDA
   - Al levantar: licencia vuelve a VIGENTE (si no hay otros bloqueos)
   - Control de concurrencia de bloqueos
   - Seguimiento completo de fechas y responsables
*/