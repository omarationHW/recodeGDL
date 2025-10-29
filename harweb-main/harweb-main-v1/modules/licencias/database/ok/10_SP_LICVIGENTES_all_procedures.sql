-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES PARA LICENCIAS VIGENTES
-- Convención: SP_LICVIGENTES_XXX
-- Generado: 2025-09-09
-- Módulo: 10 - LICENCIASVIGENTESFRM (Prioridad Media)
-- ============================================

-- SP 1/5: SP_LICVIGENTES_LIST
-- Tipo: List/Read
-- Descripción: Lista licencias vigentes con filtros
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_LICVIGENTES_LIST(
    p_numero_licencia VARCHAR(100) DEFAULT NULL,
    p_propietario VARCHAR(255) DEFAULT NULL,
    p_giro VARCHAR(255) DEFAULT NULL,
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_tipo_licencia VARCHAR(50) DEFAULT NULL,
    p_proximas_vencer INTEGER DEFAULT NULL,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    numero_licencia VARCHAR(100),
    folio VARCHAR(100),
    tipo_licencia VARCHAR(50),
    propietario VARCHAR(255),
    razon_social VARCHAR(255),
    direccion TEXT,
    colonia VARCHAR(100),
    giro VARCHAR(255),
    fecha_expedicion DATE,
    fecha_vencimiento DATE,
    dias_para_vencer INTEGER,
    estado_vigencia VARCHAR(30),
    superficie_autorizada NUMERIC(10,2),
    numero_empleados INTEGER,
    total_registros BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count BIGINT;
    v_fecha_limite DATE;
BEGIN
    -- Calcular fecha límite para próximas a vencer
    IF p_proximas_vencer IS NOT NULL THEN
        v_fecha_limite := CURRENT_DATE + INTERVAL '1 day' * p_proximas_vencer;
    END IF;

    -- Contar total de registros
    SELECT COUNT(*) INTO v_total_count
    FROM public.licencias_comerciales lc
    WHERE lc.estado = 'VIGENTE'
      AND (p_numero_licencia IS NULL OR lc.numero_licencia ILIKE '%' || p_numero_licencia || '%')
      AND (p_propietario IS NULL OR lc.propietario ILIKE '%' || p_propietario || '%')
      AND (p_giro IS NULL OR lc.giro ILIKE '%' || p_giro || '%')
      AND (p_colonia IS NULL OR lc.colonia ILIKE '%' || p_colonia || '%')
      AND (p_tipo_licencia IS NULL OR lc.tipo_licencia = upper(p_tipo_licencia))
      AND (v_fecha_limite IS NULL OR lc.fecha_vencimiento <= v_fecha_limite);

    -- Retornar resultados
    RETURN QUERY
    SELECT 
        lc.id,
        lc.numero_licencia,
        lc.folio,
        lc.tipo_licencia,
        lc.propietario,
        lc.razon_social,
        lc.direccion,
        lc.colonia,
        lc.giro,
        lc.fecha_expedicion,
        lc.fecha_vencimiento,
        CASE 
            WHEN lc.fecha_vencimiento IS NULL THEN NULL
            ELSE (lc.fecha_vencimiento - CURRENT_DATE)::INTEGER
        END as dias_para_vencer,
        CASE 
            WHEN lc.fecha_vencimiento IS NULL THEN 'INDEFINIDA'
            WHEN lc.fecha_vencimiento < CURRENT_DATE THEN 'VENCIDA'
            WHEN (lc.fecha_vencimiento - CURRENT_DATE)::INTEGER <= 30 THEN 'POR_VENCER'
            ELSE 'VIGENTE'
        END as estado_vigencia,
        lc.superficie_autorizada,
        lc.numero_empleados,
        v_total_count as total_registros
    FROM public.licencias_comerciales lc
    WHERE lc.estado = 'VIGENTE'
      AND (p_numero_licencia IS NULL OR lc.numero_licencia ILIKE '%' || p_numero_licencia || '%')
      AND (p_propietario IS NULL OR lc.propietario ILIKE '%' || p_propietario || '%')
      AND (p_giro IS NULL OR lc.giro ILIKE '%' || p_giro || '%')
      AND (p_colonia IS NULL OR lc.colonia ILIKE '%' || p_colonia || '%')
      AND (p_tipo_licencia IS NULL OR lc.tipo_licencia = upper(p_tipo_licencia))
      AND (v_fecha_limite IS NULL OR lc.fecha_vencimiento <= v_fecha_limite)
    ORDER BY 
        CASE WHEN lc.fecha_vencimiento IS NULL THEN '9999-12-31'::DATE ELSE lc.fecha_vencimiento END ASC,
        lc.propietario ASC
    LIMIT p_limite OFFSET p_offset;
END;
$$;

-- ============================================

-- SP 2/5: SP_LICVIGENTES_ESTADISTICAS
-- Tipo: Read
-- Descripción: Estadísticas de licencias vigentes
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_LICVIGENTES_ESTADISTICAS()
RETURNS TABLE(
    total_vigentes INTEGER,
    por_vencer_30_dias INTEGER,
    por_vencer_7_dias INTEGER,
    vencidas_no_renovadas INTEGER,
    comerciales INTEGER,
    industriales INTEGER,
    servicios INTEGER,
    promedio_empleados NUMERIC(5,2),
    superficie_total_autorizada NUMERIC(12,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::INTEGER as total_vigentes,
        COUNT(CASE 
            WHEN fecha_vencimiento IS NOT NULL AND 
                 (fecha_vencimiento - CURRENT_DATE)::INTEGER BETWEEN 1 AND 30 
            THEN 1 
        END)::INTEGER as por_vencer_30_dias,
        COUNT(CASE 
            WHEN fecha_vencimiento IS NOT NULL AND 
                 (fecha_vencimiento - CURRENT_DATE)::INTEGER BETWEEN 1 AND 7 
            THEN 1 
        END)::INTEGER as por_vencer_7_dias,
        COUNT(CASE 
            WHEN fecha_vencimiento IS NOT NULL AND 
                 fecha_vencimiento < CURRENT_DATE 
            THEN 1 
        END)::INTEGER as vencidas_no_renovadas,
        COUNT(CASE WHEN tipo_licencia = 'COMERCIAL' THEN 1 END)::INTEGER as comerciales,
        COUNT(CASE WHEN tipo_licencia = 'INDUSTRIAL' THEN 1 END)::INTEGER as industriales,
        COUNT(CASE WHEN tipo_licencia = 'SERVICIOS' THEN 1 END)::INTEGER as servicios,
        AVG(numero_empleados)::NUMERIC(5,2) as promedio_empleados,
        SUM(superficie_autorizada)::NUMERIC(12,2) as superficie_total_autorizada
    FROM public.licencias_comerciales
    WHERE estado = 'VIGENTE';
END;
$$;

-- ============================================

-- SP 3/5: SP_LICVIGENTES_POR_GIRO
-- Tipo: Read
-- Descripción: Licencias vigentes agrupadas por giro
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_LICVIGENTES_POR_GIRO(
    p_limite INTEGER DEFAULT 20
)
RETURNS TABLE(
    giro VARCHAR(255),
    cantidad_licencias INTEGER,
    total_empleados INTEGER,
    superficie_promedio NUMERIC(8,2),
    licencias_proximas_vencer INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        lc.giro,
        COUNT(*)::INTEGER as cantidad_licencias,
        COALESCE(SUM(lc.numero_empleados), 0)::INTEGER as total_empleados,
        AVG(lc.superficie_autorizada)::NUMERIC(8,2) as superficie_promedio,
        COUNT(CASE 
            WHEN lc.fecha_vencimiento IS NOT NULL AND 
                 (lc.fecha_vencimiento - CURRENT_DATE)::INTEGER <= 30 
            THEN 1 
        END)::INTEGER as licencias_proximas_vencer
    FROM public.licencias_comerciales lc
    WHERE lc.estado = 'VIGENTE'
      AND lc.giro IS NOT NULL
    GROUP BY lc.giro
    ORDER BY COUNT(*) DESC, lc.giro ASC
    LIMIT p_limite;
END;
$$;

-- ============================================

-- SP 4/5: SP_LICVIGENTES_POR_COLONIA
-- Tipo: Read
-- Descripción: Licencias vigentes agrupadas por colonia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_LICVIGENTES_POR_COLONIA(
    p_limite INTEGER DEFAULT 15
)
RETURNS TABLE(
    colonia VARCHAR(100),
    cantidad_licencias INTEGER,
    tipos_actividad INTEGER,
    empleos_generados INTEGER,
    densidad_comercial NUMERIC(6,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        lc.colonia,
        COUNT(*)::INTEGER as cantidad_licencias,
        COUNT(DISTINCT lc.giro)::INTEGER as tipos_actividad,
        COALESCE(SUM(lc.numero_empleados), 0)::INTEGER as empleos_generados,
        (COUNT(*) * 100.0 / NULLIF(SUM(COUNT(*)) OVER(), 0))::NUMERIC(6,2) as densidad_comercial
    FROM public.licencias_comerciales lc
    WHERE lc.estado = 'VIGENTE'
      AND lc.colonia IS NOT NULL
    GROUP BY lc.colonia
    ORDER BY COUNT(*) DESC, lc.colonia ASC
    LIMIT p_limite;
END;
$$;

-- ============================================

-- SP 5/5: SP_LICVIGENTES_RENOVACIONES_PROXIMAS
-- Tipo: Read
-- Descripción: Licencias que requieren renovación próxima
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_LICVIGENTES_RENOVACIONES_PROXIMAS(
    p_dias_adelanto INTEGER DEFAULT 60
)
RETURNS TABLE(
    numero_licencia VARCHAR(100),
    propietario VARCHAR(255),
    razon_social VARCHAR(255),
    telefono VARCHAR(20),
    email VARCHAR(100),
    giro VARCHAR(255),
    fecha_vencimiento DATE,
    dias_para_vencer INTEGER,
    prioridad_renovacion VARCHAR(20),
    direccion TEXT,
    observaciones_contacto TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        lc.numero_licencia,
        lc.propietario,
        lc.razon_social,
        lc.telefono,
        lc.email,
        lc.giro,
        lc.fecha_vencimiento,
        (lc.fecha_vencimiento - CURRENT_DATE)::INTEGER as dias_para_vencer,
        CASE 
            WHEN (lc.fecha_vencimiento - CURRENT_DATE)::INTEGER <= 7 THEN 'URGENTE'
            WHEN (lc.fecha_vencimiento - CURRENT_DATE)::INTEGER <= 15 THEN 'ALTA'
            WHEN (lc.fecha_vencimiento - CURRENT_DATE)::INTEGER <= 30 THEN 'MEDIA'
            ELSE 'BAJA'
        END as prioridad_renovacion,
        lc.direccion,
        CASE 
            WHEN lc.telefono IS NULL AND lc.email IS NULL THEN 'Sin datos de contacto'
            WHEN lc.telefono IS NULL THEN 'Sin teléfono registrado'
            WHEN lc.email IS NULL THEN 'Sin email registrado'
            ELSE 'Contacto completo'
        END as observaciones_contacto
    FROM public.licencias_comerciales lc
    WHERE lc.estado = 'VIGENTE'
      AND lc.fecha_vencimiento IS NOT NULL
      AND lc.fecha_vencimiento <= CURRENT_DATE + INTERVAL '1 day' * p_dias_adelanto
    ORDER BY lc.fecha_vencimiento ASC, lc.propietario ASC;
END;
$$;

-- ============================================
-- COMENTARIOS DE IMPLEMENTACIÓN
-- ============================================

/*
NOTAS PARA LA IMPLEMENTACIÓN:

1. Funciones enfocadas en public.licencias_comerciales con estado = 'VIGENTE'

2. Endpoints del controlador Laravel:
   - listarLicenciasVigentes -> SP_LICVIGENTES_LIST(filtros múltiples)
   - estadisticasVigentes -> SP_LICVIGENTES_ESTADISTICAS()
   - vigentesAgrupadas -> SP_LICVIGENTES_POR_GIRO(limite)
   - vigentesPorelonia -> SP_LICVIGENTES_POR_COLONIA(limite)
   - proximasRenovaciones -> SP_LICVIGENTES_RENOVACIONES_PROXIMAS(dias_adelanto)

3. Funcionalidades especiales:
   - Clasificación automática por estado de vigencia
   - Estadísticas consolidadas del sector comercial
   - Análisis por giros y colonias
   - Sistema de alertas para renovaciones
   - Cálculo de densidad comercial
   - Priorización de contactos para renovación

4. Campos calculados:
   - dias_para_vencer: Días restantes hasta vencimiento
   - estado_vigencia: INDEFINIDA, VIGENTE, POR_VENCER, VENCIDA
   - prioridad_renovacion: URGENTE, ALTA, MEDIA, BAJA
   - densidad_comercial: Porcentaje relativo por zona
   - empleos_generados: Suma de empleos por sector/colonia

5. Uso para dashboards:
   - Métricas de negocio
   - Mapas de calor comercial
   - Reportes regulatorios
   - Campañas de renovación
   - Análisis sectorial
*/