-- ============================================
-- LOTE 5 - CONSTANCIA (Constancias/Certificados)
-- STORED PROCEDURES MIGRADAS AL ESQUEMA INFORMIX
-- Base de datos: padron_licencias
-- Esquema: informix
-- Fecha: 2025-09-21
-- Crítico: Certificate generation functionality
-- ============================================

\c padron_licencias;
SET search_path TO informix;

-- ============================================
-- TABLA: constancias (esquema informix)
-- Tabla principal para constancias/certificados migrada de PostgreSQL a INFORMIX
-- ============================================

CREATE TABLE IF NOT EXISTS informix.constancias (
    id SERIAL PRIMARY KEY,
    axo INTEGER NOT NULL, -- Año de expedición
    folio INTEGER NOT NULL, -- Folio consecutivo por año
    id_licencia INTEGER,
    solicita VARCHAR(255) NOT NULL, -- Quien solicita la constancia
    partidapago VARCHAR(100), -- Referencia de pago
    observacion TEXT,
    domicilio TEXT,
    tipo SMALLINT DEFAULT 1, -- Tipo de constancia (1=Vigencia, 2=No Adeudo, etc.)
    vigente VARCHAR(1) DEFAULT 'V', -- V=Vigente, C=Cancelada
    feccap DATE DEFAULT TODAY, -- INFORMIX: CURRENT_DATE -> TODAY
    capturista VARCHAR(100), -- Usuario que captura
    fecha_expedicion DATE DEFAULT TODAY,
    fecha_registro DATETIME YEAR TO FRACTION(3) DEFAULT CURRENT, -- INFORMIX: TIMESTAMP -> DATETIME
    fecha_actualizacion DATETIME YEAR TO FRACTION(3) DEFAULT CURRENT,

    -- Índice único compuesto para axo+folio
    CONSTRAINT uk_informix_constancia_axo_folio UNIQUE (axo, folio)
);

-- Tabla auxiliar para parámetros del sistema
CREATE TABLE IF NOT EXISTS informix.parametros (
    id SERIAL PRIMARY KEY,
    constancia INTEGER DEFAULT 0, -- Último folio usado para constancias
    anio_vigente INTEGER DEFAULT EXTRACT(YEAR FROM TODAY), -- INFORMIX: CURRENT_DATE -> TODAY
    fecha_actualizacion DATETIME YEAR TO FRACTION(3) DEFAULT CURRENT
);

-- Insertar registro inicial de parámetros si no existe
INSERT INTO informix.parametros (constancia, anio_vigente)
SELECT 0, EXTRACT(YEAR FROM TODAY)
WHERE NOT EXISTS (SELECT 1 FROM informix.parametros);

-- Índices para consultas optimizadas
CREATE INDEX IF NOT EXISTS idx_informix_const_axo_folio ON informix.constancias(axo, folio);
CREATE INDEX IF NOT EXISTS idx_informix_const_id_licencia ON informix.constancias(id_licencia);
CREATE INDEX IF NOT EXISTS idx_informix_const_solicita ON informix.constancias(solicita);
CREATE INDEX IF NOT EXISTS idx_informix_const_tipo ON informix.constancias(tipo);
CREATE INDEX IF NOT EXISTS idx_informix_const_vigente ON informix.constancias(vigente);
CREATE INDEX IF NOT EXISTS idx_informix_const_feccap ON informix.constancias(feccap);
CREATE INDEX IF NOT EXISTS idx_informix_const_capturista ON informix.constancias(capturista);

-- ============================================
-- SP 1/6: sp_constancia_create
-- Tipo: CRUD
-- Descripción: Crea una nueva constancia, actualiza el folio en parametros y retorna el registro insertado - INFORMIX Compatible
-- ============================================

CREATE OR REPLACE FUNCTION informix.sp_constancia_create(
    p_tipo SMALLINT,
    p_solicita VARCHAR(255),
    p_partidapago VARCHAR(100) DEFAULT NULL,
    p_observacion TEXT DEFAULT NULL,
    p_domicilio TEXT DEFAULT NULL,
    p_id_licencia INTEGER DEFAULT NULL,
    p_capturista VARCHAR(100)
)
RETURNS TABLE(
    axo INTEGER,
    folio INTEGER,
    id_licencia INTEGER,
    solicita VARCHAR(255),
    partidapago VARCHAR(100),
    observacion TEXT,
    domicilio TEXT,
    tipo SMALLINT,
    vigente VARCHAR(1),
    feccap DATE,
    capturista VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_folio INTEGER;
    v_axo INTEGER := EXTRACT(YEAR FROM TODAY); -- INFORMIX: CURRENT_DATE -> TODAY
BEGIN
    -- Obtener el siguiente folio
    SELECT constancia INTO v_folio FROM informix.parametros ORDER BY id DESC LIMIT 1;
    v_folio := COALESCE(v_folio, 0) + 1;

    -- Actualizar el folio en parámetros
    UPDATE informix.parametros
    SET constancia = v_folio,
        fecha_actualizacion = CURRENT
    WHERE id = (SELECT id FROM informix.parametros ORDER BY id DESC LIMIT 1);

    -- Insertar la nueva constancia
    INSERT INTO informix.constancias(
        axo, folio, tipo, solicita, partidapago, observacion, domicilio,
        id_licencia, vigente, feccap, capturista
    )
    VALUES (
        v_axo, v_folio, p_tipo, UPPER(TRIM(p_solicita)), p_partidapago,
        p_observacion, UPPER(TRIM(p_domicilio)), p_id_licencia, 'V', TODAY, UPPER(TRIM(p_capturista))
    );

    -- Retornar el registro creado
    RETURN QUERY
    SELECT
        c.axo, c.folio, c.id_licencia, c.solicita, c.partidapago,
        c.observacion, c.domicilio, c.tipo, c.vigente, c.feccap, c.capturista
    FROM informix.constancias c
    WHERE c.axo = v_axo AND c.folio = v_folio;
END;
$$;

-- ============================================
-- SP 2/6: sp_constancia_update
-- Tipo: CRUD
-- Descripción: Actualiza los campos editables de una constancia - INFORMIX Compatible
-- ============================================

CREATE OR REPLACE FUNCTION informix.sp_constancia_update(
    p_axo INTEGER,
    p_folio INTEGER,
    p_observacion TEXT DEFAULT NULL,
    p_partidapago VARCHAR(100) DEFAULT NULL,
    p_domicilio TEXT DEFAULT NULL,
    p_solicita VARCHAR(255) DEFAULT NULL
)
RETURNS TABLE(
    axo INTEGER,
    folio INTEGER,
    id_licencia INTEGER,
    solicita VARCHAR(255),
    partidapago VARCHAR(100),
    observacion TEXT,
    domicilio TEXT,
    tipo SMALLINT,
    vigente VARCHAR(1),
    feccap DATE,
    capturista VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Validar que la constancia existe
    SELECT COUNT(*) INTO v_exists
    FROM informix.constancias
    WHERE axo = p_axo AND folio = p_folio;

    IF v_exists = 0 THEN
        RAISE EXCEPTION 'No se encontró la constancia con axo: % y folio: %', p_axo, p_folio;
    END IF;

    -- Actualizar los campos especificados
    UPDATE informix.constancias
    SET observacion = COALESCE(p_observacion, observacion),
        partidapago = COALESCE(p_partidapago, partidapago),
        domicilio = COALESCE(UPPER(TRIM(p_domicilio)), domicilio),
        solicita = COALESCE(UPPER(TRIM(p_solicita)), solicita),
        fecha_actualizacion = CURRENT
    WHERE axo = p_axo AND folio = p_folio;

    -- Retornar el registro actualizado
    RETURN QUERY
    SELECT
        c.axo, c.folio, c.id_licencia, c.solicita, c.partidapago,
        c.observacion, c.domicilio, c.tipo, c.vigente, c.feccap, c.capturista
    FROM informix.constancias c
    WHERE c.axo = p_axo AND c.folio = p_folio;
END;
$$;

-- ============================================
-- SP 3/6: sp_constancia_cancel
-- Tipo: CRUD
-- Descripción: Cancela una constancia y registra el motivo en observacion - INFORMIX Compatible
-- ============================================

CREATE OR REPLACE FUNCTION informix.sp_constancia_cancel(
    p_axo INTEGER,
    p_folio INTEGER,
    p_observacion TEXT
)
RETURNS TABLE(
    axo INTEGER,
    folio INTEGER,
    id_licencia INTEGER,
    solicita VARCHAR(255),
    partidapago VARCHAR(100),
    observacion TEXT,
    domicilio TEXT,
    tipo SMALLINT,
    vigente VARCHAR(1),
    feccap DATE,
    capturista VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Validar que la constancia existe y está vigente
    SELECT COUNT(*) INTO v_exists
    FROM informix.constancias
    WHERE axo = p_axo AND folio = p_folio AND vigente = 'V';

    IF v_exists = 0 THEN
        RAISE EXCEPTION 'No se encontró la constancia vigente con axo: % y folio: %', p_axo, p_folio;
    END IF;

    -- Cancelar la constancia
    UPDATE informix.constancias
    SET vigente = 'C',
        observacion = COALESCE(p_observacion, 'CONSTANCIA CANCELADA'),
        fecha_actualizacion = CURRENT
    WHERE axo = p_axo AND folio = p_folio;

    -- Retornar el registro cancelado
    RETURN QUERY
    SELECT
        c.axo, c.folio, c.id_licencia, c.solicita, c.partidapago,
        c.observacion, c.domicilio, c.tipo, c.vigente, c.feccap, c.capturista
    FROM informix.constancias c
    WHERE c.axo = p_axo AND c.folio = p_folio;
END;
$$;

-- ============================================
-- SP 4/6: sp_constancia_list
-- Tipo: Catalog
-- Descripción: Devuelve todas las constancias ordenadas por año y folio descendente - INFORMIX Compatible
-- ============================================

CREATE OR REPLACE FUNCTION informix.sp_constancia_list(
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0,
    p_axo INTEGER DEFAULT NULL,
    p_vigente VARCHAR(1) DEFAULT NULL
)
RETURNS TABLE(
    axo INTEGER,
    folio INTEGER,
    id_licencia INTEGER,
    solicita VARCHAR(255),
    partidapago VARCHAR(100),
    observacion TEXT,
    domicilio TEXT,
    tipo SMALLINT,
    vigente VARCHAR(1),
    feccap DATE,
    capturista VARCHAR(100),
    total_registros BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count BIGINT;
BEGIN
    -- Contar total de registros
    SELECT COUNT(*) INTO v_total_count
    FROM informix.constancias c
    WHERE (p_axo IS NULL OR c.axo = p_axo)
      AND (p_vigente IS NULL OR c.vigente = p_vigente);

    -- Retornar resultados paginados
    RETURN QUERY
    SELECT
        c.axo, c.folio, c.id_licencia, c.solicita, c.partidapago,
        c.observacion, c.domicilio, c.tipo, c.vigente, c.feccap, c.capturista,
        v_total_count as total_registros
    FROM informix.constancias c
    WHERE (p_axo IS NULL OR c.axo = p_axo)
      AND (p_vigente IS NULL OR c.vigente = p_vigente)
    ORDER BY c.axo DESC, c.folio DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$;

-- ============================================
-- SP 5/6: sp_constancia_search
-- Tipo: Catalog
-- Descripción: Busca constancias por axo/folio, id_licencia o fecha de captura - INFORMIX Compatible
-- ============================================

CREATE OR REPLACE FUNCTION informix.sp_constancia_search(
    p_axo INTEGER DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL,
    p_id_licencia INTEGER DEFAULT NULL,
    p_feccap DATE DEFAULT NULL,
    p_solicita VARCHAR(255) DEFAULT NULL,
    p_tipo SMALLINT DEFAULT NULL,
    p_vigente VARCHAR(1) DEFAULT NULL
)
RETURNS TABLE(
    axo INTEGER,
    folio INTEGER,
    id_licencia INTEGER,
    solicita VARCHAR(255),
    partidapago VARCHAR(100),
    observacion TEXT,
    domicilio TEXT,
    tipo SMALLINT,
    vigente VARCHAR(1),
    feccap DATE,
    capturista VARCHAR(100),
    tipo_descripcion VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.axo, c.folio, c.id_licencia, c.solicita, c.partidapago,
        c.observacion, c.domicilio, c.tipo, c.vigente, c.feccap, c.capturista,
        CASE
            WHEN c.tipo = 1 THEN 'CONSTANCIA DE VIGENCIA'
            WHEN c.tipo = 2 THEN 'CONSTANCIA DE NO ADEUDO'
            WHEN c.tipo = 3 THEN 'CONSTANCIA DE FUNCIONAMIENTO'
            WHEN c.tipo = 4 THEN 'CONSTANCIA DE TRAMITE'
            ELSE 'CONSTANCIA GENERAL'
        END as tipo_descripcion
    FROM informix.constancias c
    WHERE (p_axo IS NULL OR c.axo = p_axo)
      AND (p_folio IS NULL OR c.folio = p_folio)
      AND (p_id_licencia IS NULL OR c.id_licencia = p_id_licencia)
      AND (p_feccap IS NULL OR c.feccap = p_feccap)
      AND (p_solicita IS NULL OR UPPER(c.solicita) LIKE '%' || UPPER(p_solicita) || '%')
      AND (p_tipo IS NULL OR c.tipo = p_tipo)
      AND (p_vigente IS NULL OR c.vigente = p_vigente)
    ORDER BY c.axo DESC, c.folio DESC;
END;
$$;

-- ============================================
-- SP 6/6: print_constancia
-- Tipo: Report
-- Descripción: Genera información para el PDF de la constancia - INFORMIX Compatible
-- ============================================

CREATE OR REPLACE FUNCTION informix.print_constancia(
    p_axo INTEGER,
    p_folio INTEGER
)
RETURNS TABLE(
    axo INTEGER,
    folio INTEGER,
    solicita VARCHAR(255),
    domicilio TEXT,
    tipo_descripcion VARCHAR(50),
    feccap DATE,
    vigente VARCHAR(1),
    pdf_filename VARCHAR(255),
    observacion TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_filename VARCHAR(255);
BEGIN
    -- Validar que la constancia existe
    SELECT COUNT(*) INTO v_exists
    FROM informix.constancias
    WHERE axo = p_axo AND folio = p_folio;

    IF v_exists = 0 THEN
        RAISE EXCEPTION 'No se encontró la constancia con axo: % y folio: %', p_axo, p_folio;
    END IF;

    -- Generar nombre de archivo para PDF
    v_filename := 'constancia_' || p_axo || '_' || LPAD(p_folio::TEXT, 6, '0') || '.pdf';

    -- Retornar información para generación de PDF
    RETURN QUERY
    SELECT
        c.axo,
        c.folio,
        c.solicita,
        c.domicilio,
        CASE
            WHEN c.tipo = 1 THEN 'CONSTANCIA DE VIGENCIA'
            WHEN c.tipo = 2 THEN 'CONSTANCIA DE NO ADEUDO'
            WHEN c.tipo = 3 THEN 'CONSTANCIA DE FUNCIONAMIENTO'
            WHEN c.tipo = 4 THEN 'CONSTANCIA DE TRAMITE'
            ELSE 'CONSTANCIA GENERAL'
        END as tipo_descripcion,
        c.feccap,
        c.vigente,
        v_filename as pdf_filename,
        c.observacion
    FROM informix.constancias c
    WHERE c.axo = p_axo AND c.folio = p_folio;
END;
$$;

-- ============================================
-- SP ADICIONAL: sp_constancia_estadisticas
-- Tipo: Report
-- Descripción: Estadísticas de constancias por tipo y período - INFORMIX Compatible
-- ============================================

CREATE OR REPLACE FUNCTION informix.sp_constancia_estadisticas(
    p_axo INTEGER DEFAULT NULL,
    p_tipo SMALLINT DEFAULT NULL
)
RETURNS TABLE(
    axo INTEGER,
    tipo SMALLINT,
    tipo_descripcion VARCHAR(50),
    total_expedidas INTEGER,
    vigentes INTEGER,
    canceladas INTEGER,
    porcentaje_vigentes DECIMAL(5,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.axo,
        c.tipo,
        CASE
            WHEN c.tipo = 1 THEN 'CONSTANCIA DE VIGENCIA'
            WHEN c.tipo = 2 THEN 'CONSTANCIA DE NO ADEUDO'
            WHEN c.tipo = 3 THEN 'CONSTANCIA DE FUNCIONAMIENTO'
            WHEN c.tipo = 4 THEN 'CONSTANCIA DE TRAMITE'
            ELSE 'CONSTANCIA GENERAL'
        END as tipo_descripcion,
        COUNT(*)::INTEGER as total_expedidas,
        COUNT(CASE WHEN c.vigente = 'V' THEN 1 END)::INTEGER as vigentes,
        COUNT(CASE WHEN c.vigente = 'C' THEN 1 END)::INTEGER as canceladas,
        CASE
            WHEN COUNT(*) > 0 THEN
                ROUND((COUNT(CASE WHEN c.vigente = 'V' THEN 1 END)::DECIMAL / COUNT(*)::DECIMAL) * 100, 2)
            ELSE 0.00
        END as porcentaje_vigentes
    FROM informix.constancias c
    WHERE (p_axo IS NULL OR c.axo = p_axo)
      AND (p_tipo IS NULL OR c.tipo = p_tipo)
    GROUP BY c.axo, c.tipo
    ORDER BY c.axo DESC, c.tipo;
END;
$$;

-- ============================================
-- DATOS DE PRUEBA PARA INFORMIX SCHEMA
-- ============================================

-- Actualizar parámetros para el año actual
UPDATE informix.parametros
SET constancia = 5,
    anio_vigente = EXTRACT(YEAR FROM TODAY),
    fecha_actualizacion = CURRENT;

-- Insertar constancias de prueba
INSERT INTO informix.constancias (
    axo, folio, tipo, solicita, partidapago, observacion, domicilio, id_licencia, vigente, feccap, capturista
) VALUES
    (EXTRACT(YEAR FROM TODAY), 1, 1, 'JUAN PÉREZ GARCÍA', 'PAG-2025-001',
     'Constancia de vigencia para licencia comercial', 'AV. JUÁREZ #123, CENTRO', 1, 'V', TODAY, 'ADMIN_INF'),
    (EXTRACT(YEAR FROM TODAY), 2, 2, 'MARÍA LÓPEZ HERNÁNDEZ', 'PAG-2025-002',
     'Constancia de no adeudo para trámite', 'CALLE MORELOS #456, REFORMA', 2, 'V', TODAY, 'ADMIN_INF'),
    (EXTRACT(YEAR FROM TODAY), 3, 3, 'EMPRESA CONSTRUCTORA SA', 'PAG-2025-003',
     'Constancia de funcionamiento industrial', 'BLVD. UNIVERSIDAD #789, UNIVERSITARIA', 3, 'V', TODAY, 'ADMIN_INF'),
    (EXTRACT(YEAR FROM TODAY), 4, 1, 'COMERCIAL GUADALAJARA SA', 'PAG-2025-004',
     'Constancia de vigencia para renovación', 'AV. REVOLUCIÓN #1010, AMERICANA', 4, 'V', TODAY, 'ADMIN_INF'),
    (EXTRACT(YEAR FROM TODAY), 5, 4, 'SERVICIOS TÉCNICOS ESPECIALIZADOS SC', 'PAG-2025-005',
     'Constancia para trámite específico', 'CALLE INDEPENDENCIA #2020, CENTRO', 5, 'C', TODAY, 'ADMIN_INF')
ON CONFLICT (axo, folio) DO NOTHING;

-- ============================================
-- COMENTARIOS DE MIGRACIÓN INFORMIX
-- ============================================

/*
CAMBIOS ESPECÍFICOS PARA INFORMIX:

1. Tipos de datos:
   - TIMESTAMP -> DATETIME YEAR TO FRACTION(3)
   - CURRENT_DATE -> TODAY
   - CURRENT_TIMESTAMP -> CURRENT
   - VARCHAR length specifications maintained

2. Funcionalidades específicas:
   - Sistema de folio automático por año
   - Control de vigencia (V/C)
   - Tipos de constancia categorizados
   - Generación de nombres de archivo PDF
   - Estadísticas por tipo y período

3. Esquema INFORMIX:
   - Todas las funciones en el esquema informix
   - Índices optimizados para consultas frecuentes
   - Tabla de parámetros para control de folios
   - Constraints únicos para axo+folio

4. Validaciones implementadas:
   - Verificación de existencia antes de operaciones
   - Control de estados (vigente/cancelada)
   - Actualización automática de fechas
   - Normalización de datos (UPPER/TRIM)

5. Casos de uso cubiertos:
   - Expedición de constancias con folio automático
   - Actualización de datos editables
   - Cancelación con motivo
   - Listado paginado con filtros
   - Búsqueda multi-criterio
   - Generación de información para PDF
   - Estadísticas para reportes

ENDPOINTS SUGERIDOS:
- expedirConstancia -> informix.sp_constancia_create(datos)
- actualizarConstancia -> informix.sp_constancia_update(axo, folio, datos)
- cancelarConstancia -> informix.sp_constancia_cancel(axo, folio, motivo)
- listarConstancias -> informix.sp_constancia_list(limite, offset, filtros)
- buscarConstancias -> informix.sp_constancia_search(criterios)
- imprimirConstancia -> informix.print_constancia(axo, folio)
- estadisticasConstancias -> informix.sp_constancia_estadisticas(axo, tipo)

TIPOS DE CONSTANCIA:
1 = Constancia de Vigencia
2 = Constancia de No Adeudo
3 = Constancia de Funcionamiento
4 = Constancia de Trámite

ESTADOS:
V = Vigente
C = Cancelada
*/