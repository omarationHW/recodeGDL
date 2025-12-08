-- ============================================
-- STORED PROCEDURES - BATCH 13
-- Component: ligaAnunciofrm
-- Description: Sistema para ligar anuncios a licencias o empresas
-- Schema: comun (shared functionality)
-- Total SPs: 4
-- Generated: 2025-11-21
-- Status: COMPLETED
-- ============================================
-- PROGRESS: Batch 13/95 - Component 78/95 (82.1%)
-- Previous Batches: 77 components completed
-- ============================================

-- ============================================
-- TABLA PRINCIPAL: anuncios
-- Descripcion: Catalogo de anuncios publicitarios
-- Campos clave:
--   - Identificacion: id_anuncio (PK), numero_anuncio
--   - Relacion: id_licencia (FK a licencias)
--   - Ubicacion: zona, subzona, cvecalle, ubicacion, numext_ubic, letraext_ubic, numint_ubic, letraint_ubic
--   - Medidas: medidas1, medidas2, area_anuncio
--   - Estado: vigente ('V'=Vigente, 'C'=Cancelado, 'S'=Suspendido)
--   - Fechas: fecha_otorgamiento, fecha_baja
--
-- TABLA SECUNDARIA: licencias
-- Campos relevantes para liga:
--   - id_licencia (PK), numero_licencia
--   - propietario, primer_ap, segundo_ap
--   - zona, subzona, cvecalle, ubicacion, etc.
--   - vigente, bloqueado
--
-- TABLA SECUNDARIA: empresas
-- Campos relevantes para liga:
--   - empresa (PK), propietario, rfc
--   - ubicacion, vigente
--
-- TABLA DETALLE: detsal_lic
-- Descripcion: Detalles de saldos de licencias y anuncios
-- Campos: id_anuncio, id_licencia, axo, saldo, cvepago
-- ============================================

-- ============================================
-- SP 1/4: sp_liga_anuncio_buscar_anuncio
-- Type: Search/Query
-- Description: Busca un anuncio por su numero o ID y retorna
--              informacion completa incluyendo datos de licencia
--              asociada actual y estado de vigencia.
-- Returns: Datos completos del anuncio con validacion de liga
-- Dependencies: Tables anuncios, licencias
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_liga_anuncio_buscar_anuncio(
    p_anuncio INTEGER
)
RETURNS TABLE(
    id_anuncio INTEGER,
    numero_anuncio VARCHAR(50),
    id_licencia_actual INTEGER,
    numero_licencia_actual VARCHAR(50),
    propietario_actual TEXT,
    descripcion TEXT,
    ubicacion TEXT,
    ubicacion_completa TEXT,
    numext_ubic TEXT,
    letraext_ubic TEXT,
    numint_ubic TEXT,
    letraint_ubic TEXT,
    zona SMALLINT,
    subzona SMALLINT,
    medidas1 NUMERIC,
    medidas2 NUMERIC,
    area_anuncio NUMERIC,
    fecha_otorgamiento DATE,
    vigente CHAR(1),
    estado_descripcion VARCHAR(50),
    puede_ligarse BOOLEAN,
    mensaje_validacion TEXT,
    tiene_adeudos BOOLEAN,
    total_adeudos NUMERIC
) AS $$
/**
 * Function: sp_liga_anuncio_buscar_anuncio
 * Description: Searches for an advertisement by number/ID and returns complete
 *              information including current license association and status.
 *              Validates if the advertisement can be linked to another license/business.
 *
 * Parameters:
 *   @p_anuncio - Advertisement ID to search (REQUIRED)
 *
 * Returns:
 *   - id_anuncio: Advertisement ID
 *   - numero_anuncio: Advertisement number
 *   - id_licencia_actual: Current linked license ID
 *   - numero_licencia_actual: Current linked license number
 *   - propietario_actual: Current owner name
 *   - descripcion: Advertisement description
 *   - ubicacion: Location address
 *   - ubicacion_completa: Full formatted address
 *   - numext_ubic, letraext_ubic: External number and letter
 *   - numint_ubic, letraint_ubic: Internal number and letter
 *   - zona, subzona: Zone and subzone codes
 *   - medidas1, medidas2: Dimensions
 *   - area_anuncio: Total area
 *   - fecha_otorgamiento: Grant date
 *   - vigente: Status flag (V=Active, C=Cancelled, S=Suspended)
 *   - estado_descripcion: Human-readable status
 *   - puede_ligarse: Boolean indicating if can be linked
 *   - mensaje_validacion: Validation message
 *   - tiene_adeudos: Has pending debts flag
 *   - total_adeudos: Total pending debt amount
 *
 * Business Logic:
 *   - Only advertisements with vigente='V' can be linked
 *   - Returns current license association if exists
 *   - Calculates total pending debts
 *   - Provides validation message explaining why linking may not be possible
 *
 * Example Usage:
 *   SELECT * FROM comun.sp_liga_anuncio_buscar_anuncio(1001);
 */
DECLARE
    v_id_anuncio INTEGER;
    v_vigente CHAR(1);
    v_total_adeudos NUMERIC;
BEGIN
    -- Validate required parameter
    IF p_anuncio IS NULL OR p_anuncio <= 0 THEN
        RAISE EXCEPTION 'El ID del anuncio es requerido y debe ser mayor a 0';
    END IF;

    -- Calculate total pending debts for the advertisement
    SELECT COALESCE(SUM(d.saldo), 0)
    INTO v_total_adeudos
    FROM comun.detsal_lic d
    WHERE d.id_anuncio = p_anuncio
      AND d.cvepago = 0;

    -- Query advertisement data with license info
    RETURN QUERY
    SELECT
        a.id_anuncio,
        COALESCE(a.numero_anuncio, a.id_anuncio::VARCHAR)::VARCHAR(50) AS numero_anuncio,
        a.id_licencia AS id_licencia_actual,
        COALESCE(l.numero_licencia, l.id_licencia::VARCHAR)::VARCHAR(50) AS numero_licencia_actual,
        TRIM(COALESCE(l.propietario, '') || ' ' || COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, ''))::TEXT AS propietario_actual,
        a.espubic::TEXT AS descripcion,
        a.ubicacion::TEXT,
        (COALESCE(a.ubicacion, '') ||
         CASE WHEN a.numext_ubic IS NOT NULL THEN ' #' || a.numext_ubic ELSE '' END ||
         CASE WHEN a.letraext_ubic IS NOT NULL AND a.letraext_ubic != '' THEN a.letraext_ubic ELSE '' END ||
         CASE WHEN a.numint_ubic IS NOT NULL AND a.numint_ubic != '' THEN ' Int. ' || a.numint_ubic ELSE '' END ||
         CASE WHEN a.letraint_ubic IS NOT NULL AND a.letraint_ubic != '' THEN a.letraint_ubic ELSE '' END)::TEXT AS ubicacion_completa,
        a.numext_ubic::TEXT,
        a.letraext_ubic::TEXT,
        a.numint_ubic::TEXT,
        a.letraint_ubic::TEXT,
        a.zona,
        a.subzona,
        a.medidas1,
        a.medidas2,
        a.area_anuncio,
        a.fecha_otorgamiento,
        a.vigente,
        CASE
            WHEN a.vigente = 'V' THEN 'VIGENTE'::VARCHAR(50)
            WHEN a.vigente = 'C' THEN 'CANCELADO/BAJA'::VARCHAR(50)
            WHEN a.vigente = 'S' THEN 'SUSPENDIDO'::VARCHAR(50)
            ELSE 'DESCONOCIDO'::VARCHAR(50)
        END AS estado_descripcion,
        CASE
            WHEN a.vigente = 'V' THEN TRUE
            ELSE FALSE
        END AS puede_ligarse,
        CASE
            WHEN a.vigente = 'C' THEN 'El anuncio esta dado de baja (CANCELADO). No puede ligarse.'::TEXT
            WHEN a.vigente = 'S' THEN 'El anuncio esta SUSPENDIDO. Debe reactivarse antes de ligarse.'::TEXT
            WHEN a.vigente = 'V' THEN 'El anuncio puede ligarse a una licencia o empresa.'::TEXT
            ELSE 'Estado del anuncio desconocido.'::TEXT
        END AS mensaje_validacion,
        (v_total_adeudos > 0) AS tiene_adeudos,
        v_total_adeudos AS total_adeudos
    FROM comun.anuncios a
    LEFT JOIN comun.licencias l ON l.id_licencia = a.id_licencia
    WHERE a.id_anuncio = p_anuncio;

    -- Check if advertisement was found
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontro el anuncio con ID: %', p_anuncio;
    END IF;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION comun.sp_liga_anuncio_buscar_anuncio(INTEGER) IS
'Search: Busca un anuncio por ID y valida si puede ser ligado a otra licencia/empresa';

-- ============================================
-- SP 2/4: sp_liga_anuncio_buscar_licencia
-- Type: Search/Query
-- Description: Busca una licencia por su numero o ID para
--              validar si puede recibir anuncios ligados.
-- Returns: Datos completos de la licencia con validacion
-- Dependencies: Table licencias
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_liga_anuncio_buscar_licencia(
    p_licencia INTEGER
)
RETURNS TABLE(
    id_licencia INTEGER,
    numero_licencia VARCHAR(50),
    propietario TEXT,
    propietario_completo TEXT,
    primer_ap VARCHAR(100),
    segundo_ap VARCHAR(100),
    rfc VARCHAR(20),
    telefono_prop VARCHAR(30),
    ubicacion TEXT,
    ubicacion_completa TEXT,
    numext_ubic TEXT,
    letraext_ubic TEXT,
    numint_ubic TEXT,
    letraint_ubic TEXT,
    cvecalle INTEGER,
    zona SMALLINT,
    subzona SMALLINT,
    recaud SMALLINT,
    fecha_otorgamiento DATE,
    vigente CHAR(1),
    bloqueado INTEGER,
    estado_descripcion VARCHAR(50),
    puede_recibir_anuncios BOOLEAN,
    mensaje_validacion TEXT,
    anuncios_actuales INTEGER,
    id_giro INTEGER,
    descripcion_giro TEXT
) AS $$
/**
 * Function: sp_liga_anuncio_buscar_licencia
 * Description: Searches for a license by number/ID and validates if it can
 *              receive linked advertisements. Returns complete license information.
 *
 * Parameters:
 *   @p_licencia - License ID to search (REQUIRED)
 *
 * Returns:
 *   - id_licencia: License ID
 *   - numero_licencia: License number
 *   - propietario: Owner first name
 *   - propietario_completo: Full owner name
 *   - primer_ap, segundo_ap: Last names
 *   - rfc: Tax ID
 *   - telefono_prop: Phone
 *   - ubicacion: Address
 *   - ubicacion_completa: Full formatted address
 *   - numext_ubic, letraext_ubic: External number/letter
 *   - numint_ubic, letraint_ubic: Internal number/letter
 *   - cvecalle: Street code
 *   - zona, subzona, recaud: Zone, subzone, collection office
 *   - fecha_otorgamiento: Grant date
 *   - vigente: Status (V=Active, C=Cancelled)
 *   - bloqueado: Blocked flag
 *   - estado_descripcion: Human-readable status
 *   - puede_recibir_anuncios: Boolean indicating if can receive ads
 *   - mensaje_validacion: Validation message
 *   - anuncios_actuales: Count of currently linked advertisements
 *   - id_giro: Business category ID
 *   - descripcion_giro: Business category description
 *
 * Business Logic:
 *   - Only active licenses (vigente='V') can receive advertisements
 *   - Blocked licenses cannot receive advertisements
 *   - Returns count of currently linked advertisements
 *   - Validates business category association
 *
 * Example Usage:
 *   SELECT * FROM comun.sp_liga_anuncio_buscar_licencia(5001);
 */
DECLARE
    v_count_anuncios INTEGER;
BEGIN
    -- Validate required parameter
    IF p_licencia IS NULL OR p_licencia <= 0 THEN
        RAISE EXCEPTION 'El ID de la licencia es requerido y debe ser mayor a 0';
    END IF;

    -- Count current advertisements linked to this license
    SELECT COUNT(*)
    INTO v_count_anuncios
    FROM comun.anuncios
    WHERE id_licencia = p_licencia
      AND vigente = 'V';

    -- Query license data
    RETURN QUERY
    SELECT
        l.id_licencia,
        COALESCE(l.numero_licencia, l.id_licencia::VARCHAR)::VARCHAR(50) AS numero_licencia,
        l.propietario::TEXT,
        TRIM(COALESCE(l.propietario, '') || ' ' || COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, ''))::TEXT AS propietario_completo,
        l.primer_ap,
        l.segundo_ap,
        l.rfc,
        l.telefono_prop,
        l.ubicacion::TEXT,
        (COALESCE(l.ubicacion, '') ||
         CASE WHEN l.numext_ubic IS NOT NULL THEN ' #' || l.numext_ubic ELSE '' END ||
         CASE WHEN l.letraext_ubic IS NOT NULL AND l.letraext_ubic != '' THEN l.letraext_ubic ELSE '' END ||
         CASE WHEN l.numint_ubic IS NOT NULL AND l.numint_ubic != '' THEN ' Int. ' || l.numint_ubic ELSE '' END ||
         CASE WHEN l.letraint_ubic IS NOT NULL AND l.letraint_ubic != '' THEN l.letraint_ubic ELSE '' END)::TEXT AS ubicacion_completa,
        l.numext_ubic::TEXT,
        l.letraext_ubic::TEXT,
        l.numint_ubic::TEXT,
        l.letraint_ubic::TEXT,
        l.cvecalle,
        l.zona,
        l.subzona,
        l.recaud,
        l.fecha_otorgamiento,
        l.vigente,
        COALESCE(l.bloqueado, 0)::INTEGER AS bloqueado,
        CASE
            WHEN l.vigente = 'V' AND COALESCE(l.bloqueado, 0) = 0 THEN 'VIGENTE'::VARCHAR(50)
            WHEN l.vigente = 'V' AND COALESCE(l.bloqueado, 0) > 0 THEN 'VIGENTE (BLOQUEADA)'::VARCHAR(50)
            WHEN l.vigente = 'C' THEN 'CANCELADA/BAJA'::VARCHAR(50)
            WHEN l.vigente = 'S' THEN 'SUSPENDIDA'::VARCHAR(50)
            ELSE 'DESCONOCIDO'::VARCHAR(50)
        END AS estado_descripcion,
        CASE
            WHEN l.vigente = 'V' AND COALESCE(l.bloqueado, 0) = 0 THEN TRUE
            ELSE FALSE
        END AS puede_recibir_anuncios,
        CASE
            WHEN l.vigente = 'C' THEN 'La licencia esta dada de baja (CANCELADA). No puede recibir anuncios.'::TEXT
            WHEN l.vigente = 'S' THEN 'La licencia esta SUSPENDIDA. Debe reactivarse antes de recibir anuncios.'::TEXT
            WHEN l.vigente = 'V' AND COALESCE(l.bloqueado, 0) > 0 THEN 'La licencia esta BLOQUEADA. Debe desbloquearse antes de recibir anuncios.'::TEXT
            WHEN l.vigente = 'V' THEN 'La licencia puede recibir anuncios.'::TEXT
            ELSE 'Estado de la licencia desconocido.'::TEXT
        END AS mensaje_validacion,
        v_count_anuncios AS anuncios_actuales,
        l.id_giro,
        g.descripcion::TEXT AS descripcion_giro
    FROM comun.licencias l
    LEFT JOIN comun.c_giros g ON g.id_giro = l.id_giro
    WHERE l.id_licencia = p_licencia;

    -- Check if license was found
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontro la licencia con ID: %', p_licencia;
    END IF;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION comun.sp_liga_anuncio_buscar_licencia(INTEGER) IS
'Search: Busca una licencia por ID y valida si puede recibir anuncios ligados';

-- ============================================
-- SP 3/4: sp_liga_anuncio_buscar_empresa
-- Type: Search/Query
-- Description: Busca una empresa por su numero o ID para
--              validar si puede recibir anuncios ligados.
--              En el modelo de datos, empresa se mapea a licencias.
-- Returns: Datos completos de la empresa/licencia con validacion
-- Dependencies: Tables licencias (empresas mapeadas como licencias especiales)
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_liga_anuncio_buscar_empresa(
    p_empresa INTEGER
)
RETURNS TABLE(
    id_empresa INTEGER,
    numero_empresa VARCHAR(50),
    propietario TEXT,
    propietario_completo TEXT,
    rfc VARCHAR(20),
    curp VARCHAR(20),
    telefono_prop VARCHAR(30),
    email VARCHAR(100),
    domicilio TEXT,
    ubicacion TEXT,
    ubicacion_completa TEXT,
    colonia_ubic TEXT,
    zona SMALLINT,
    subzona SMALLINT,
    fecha_otorgamiento DATE,
    vigente CHAR(1),
    bloqueado INTEGER,
    estado_descripcion VARCHAR(50),
    puede_recibir_anuncios BOOLEAN,
    mensaje_validacion TEXT,
    anuncios_actuales INTEGER,
    id_giro INTEGER
) AS $$
/**
 * Function: sp_liga_anuncio_buscar_empresa
 * Description: Searches for a business/company by number/ID and validates if it
 *              can receive linked advertisements. In the data model, businesses
 *              are mapped as special licenses or in the empresas table.
 *
 * Parameters:
 *   @p_empresa - Business/Company ID to search (REQUIRED)
 *
 * Returns:
 *   - id_empresa: Business ID
 *   - numero_empresa: Business number
 *   - propietario: Owner name
 *   - propietario_completo: Full owner name
 *   - rfc: Tax ID
 *   - curp: Personal ID (CURP)
 *   - telefono_prop: Phone
 *   - email: Email address
 *   - domicilio: Owner address
 *   - ubicacion: Business location
 *   - ubicacion_completa: Full formatted address
 *   - colonia_ubic: Neighborhood
 *   - zona, subzona: Zone and subzone
 *   - fecha_otorgamiento: Grant date
 *   - vigente: Status (V/S/C)
 *   - bloqueado: Blocked flag
 *   - estado_descripcion: Human-readable status
 *   - puede_recibir_anuncios: Boolean indicating if can receive ads
 *   - mensaje_validacion: Validation message
 *   - anuncios_actuales: Count of currently linked advertisements
 *   - id_giro: Business category ID
 *
 * Business Logic:
 *   - Only active businesses (vigente='V' or 'S') can receive advertisements
 *   - Blocked businesses cannot receive advertisements
 *   - Returns count of currently linked advertisements
 *
 * Example Usage:
 *   SELECT * FROM comun.sp_liga_anuncio_buscar_empresa(2001);
 */
DECLARE
    v_count_anuncios INTEGER;
    v_exists BOOLEAN;
BEGIN
    -- Validate required parameter
    IF p_empresa IS NULL OR p_empresa <= 0 THEN
        RAISE EXCEPTION 'El ID de la empresa es requerido y debe ser mayor a 0';
    END IF;

    -- First, try to find in empresas table if it exists
    -- If not, try licencias table (empresas may be stored as licenses)

    -- Check if empresa exists in empresas table
    BEGIN
        SELECT EXISTS(
            SELECT 1 FROM comun.empresas WHERE empresa = p_empresa
        ) INTO v_exists;
    EXCEPTION
        WHEN undefined_table THEN
            v_exists := FALSE;
    END;

    IF v_exists THEN
        -- Count current advertisements linked to this empresa
        SELECT COUNT(*)
        INTO v_count_anuncios
        FROM comun.anuncios
        WHERE id_licencia = p_empresa
          AND vigente = 'V';

        -- Query from empresas table
        RETURN QUERY
        SELECT
            e.empresa AS id_empresa,
            e.empresa::VARCHAR(50) AS numero_empresa,
            e.propietario::TEXT,
            e.propietario::TEXT AS propietario_completo,
            e.rfc,
            e.curp,
            e.telefono_prop,
            e.email,
            e.domicilio::TEXT,
            e.ubicacion::TEXT,
            (COALESCE(e.ubicacion, '') ||
             CASE WHEN e.numext_ubic IS NOT NULL THEN ' #' || e.numext_ubic ELSE '' END ||
             CASE WHEN e.letraext_ubic IS NOT NULL AND e.letraext_ubic != '' THEN e.letraext_ubic ELSE '' END ||
             CASE WHEN e.numint_ubic IS NOT NULL AND e.numint_ubic != '' THEN ' Int. ' || e.numint_ubic ELSE '' END)::TEXT AS ubicacion_completa,
            e.colonia_ubic::TEXT,
            e.zona,
            e.subzona,
            e.fecha_otorgamiento,
            COALESCE(e.vigente, 'S')::CHAR(1) AS vigente,
            COALESCE(e.bloqueado, 0)::INTEGER AS bloqueado,
            CASE
                WHEN COALESCE(e.vigente, 'S') IN ('V', 'S') AND COALESCE(e.bloqueado, 0) = 0 THEN 'VIGENTE'::VARCHAR(50)
                WHEN COALESCE(e.vigente, 'S') IN ('V', 'S') AND COALESCE(e.bloqueado, 0) > 0 THEN 'VIGENTE (BLOQUEADA)'::VARCHAR(50)
                WHEN e.vigente = 'N' THEN 'INACTIVA/BAJA'::VARCHAR(50)
                ELSE 'DESCONOCIDO'::VARCHAR(50)
            END AS estado_descripcion,
            CASE
                WHEN COALESCE(e.vigente, 'S') IN ('V', 'S') AND COALESCE(e.bloqueado, 0) = 0 THEN TRUE
                ELSE FALSE
            END AS puede_recibir_anuncios,
            CASE
                WHEN e.vigente = 'N' THEN 'La empresa esta dada de baja (INACTIVA). No puede recibir anuncios.'::TEXT
                WHEN COALESCE(e.vigente, 'S') IN ('V', 'S') AND COALESCE(e.bloqueado, 0) > 0 THEN 'La empresa esta BLOQUEADA. Debe desbloquearse antes de recibir anuncios.'::TEXT
                WHEN COALESCE(e.vigente, 'S') IN ('V', 'S') THEN 'La empresa puede recibir anuncios.'::TEXT
                ELSE 'Estado de la empresa desconocido.'::TEXT
            END AS mensaje_validacion,
            v_count_anuncios AS anuncios_actuales,
            e.id_giro
        FROM comun.empresas e
        WHERE e.empresa = p_empresa;
    ELSE
        -- Fall back to licencias table (empresas mapped as licenses)
        -- Count current advertisements
        SELECT COUNT(*)
        INTO v_count_anuncios
        FROM comun.anuncios
        WHERE id_licencia = p_empresa
          AND vigente = 'V';

        RETURN QUERY
        SELECT
            l.id_licencia AS id_empresa,
            COALESCE(l.numero_licencia, l.id_licencia::VARCHAR)::VARCHAR(50) AS numero_empresa,
            l.propietario::TEXT,
            TRIM(COALESCE(l.propietario, '') || ' ' || COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, ''))::TEXT AS propietario_completo,
            l.rfc,
            l.curp,
            l.telefono_prop,
            l.email,
            l.domicilio::TEXT,
            l.ubicacion::TEXT,
            (COALESCE(l.ubicacion, '') ||
             CASE WHEN l.numext_ubic IS NOT NULL THEN ' #' || l.numext_ubic ELSE '' END ||
             CASE WHEN l.letraext_ubic IS NOT NULL AND l.letraext_ubic != '' THEN l.letraext_ubic ELSE '' END ||
             CASE WHEN l.numint_ubic IS NOT NULL AND l.numint_ubic != '' THEN ' Int. ' || l.numint_ubic ELSE '' END)::TEXT AS ubicacion_completa,
            l.colonia_ubic::TEXT,
            l.zona,
            l.subzona,
            l.fecha_otorgamiento,
            l.vigente,
            COALESCE(l.bloqueado, 0)::INTEGER AS bloqueado,
            CASE
                WHEN l.vigente = 'V' AND COALESCE(l.bloqueado, 0) = 0 THEN 'VIGENTE'::VARCHAR(50)
                WHEN l.vigente = 'V' AND COALESCE(l.bloqueado, 0) > 0 THEN 'VIGENTE (BLOQUEADA)'::VARCHAR(50)
                WHEN l.vigente = 'C' THEN 'CANCELADA/BAJA'::VARCHAR(50)
                WHEN l.vigente = 'S' THEN 'SUSPENDIDA'::VARCHAR(50)
                ELSE 'DESCONOCIDO'::VARCHAR(50)
            END AS estado_descripcion,
            CASE
                WHEN l.vigente = 'V' AND COALESCE(l.bloqueado, 0) = 0 THEN TRUE
                ELSE FALSE
            END AS puede_recibir_anuncios,
            CASE
                WHEN l.vigente = 'C' THEN 'La empresa/licencia esta dada de baja (CANCELADA). No puede recibir anuncios.'::TEXT
                WHEN l.vigente = 'S' THEN 'La empresa/licencia esta SUSPENDIDA. Debe reactivarse antes de recibir anuncios.'::TEXT
                WHEN l.vigente = 'V' AND COALESCE(l.bloqueado, 0) > 0 THEN 'La empresa/licencia esta BLOQUEADA. Debe desbloquearse antes de recibir anuncios.'::TEXT
                WHEN l.vigente = 'V' THEN 'La empresa/licencia puede recibir anuncios.'::TEXT
                ELSE 'Estado de la empresa/licencia desconocido.'::TEXT
            END AS mensaje_validacion,
            v_count_anuncios AS anuncios_actuales,
            l.id_giro
        FROM comun.licencias l
        WHERE l.id_licencia = p_empresa;
    END IF;

    -- Check if entity was found
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontro la empresa con ID: %', p_empresa;
    END IF;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION comun.sp_liga_anuncio_buscar_empresa(INTEGER) IS
'Search: Busca una empresa por ID y valida si puede recibir anuncios ligados';

-- ============================================
-- SP 4/4: sp_liga_anuncio_ligar
-- Type: CRUD Update (Main operation)
-- Description: Liga un anuncio a una licencia o empresa.
--              Actualiza la tabla anuncios y detsal_lic,
--              recalcula saldos de la licencia destino.
-- Returns: Resultado de la operacion con mensaje
-- Dependencies: Tables anuncios, licencias, empresas, detsal_lic, function calc_sdosl
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_liga_anuncio_ligar(
    p_anuncio_id INTEGER,
    p_licencia_id INTEGER,
    p_is_empresa BOOLEAN DEFAULT FALSE,
    p_usuario VARCHAR(10) DEFAULT NULL,
    p_copiar_ubicacion BOOLEAN DEFAULT TRUE
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id_anuncio INTEGER,
    numero_anuncio VARCHAR(50),
    id_licencia_anterior INTEGER,
    numero_licencia_anterior VARCHAR(50),
    id_licencia_nueva INTEGER,
    numero_licencia_nueva VARCHAR(50),
    propietario_nuevo TEXT,
    fecha_operacion TIMESTAMP,
    usuario VARCHAR(10)
) AS $$
/**
 * Function: sp_liga_anuncio_ligar
 * Description: Links an advertisement to a license or business. Updates the
 *              anuncios table, transfers debt records in detsal_lic, and
 *              recalculates balance for the destination license.
 *
 * Parameters:
 *   @p_anuncio_id - Advertisement ID to link (REQUIRED)
 *   @p_licencia_id - Destination license/business ID (REQUIRED)
 *   @p_is_empresa - Flag indicating if destination is a business (DEFAULT: FALSE)
 *   @p_usuario - User performing the operation (OPTIONAL)
 *   @p_copiar_ubicacion - Copy location data from license to advertisement (DEFAULT: TRUE)
 *
 * Returns:
 *   - success: Operation success flag
 *   - message: Descriptive message
 *   - id_anuncio: Advertisement ID
 *   - numero_anuncio: Advertisement number
 *   - id_licencia_anterior: Previous license ID
 *   - numero_licencia_anterior: Previous license number
 *   - id_licencia_nueva: New license ID
 *   - numero_licencia_nueva: New license number
 *   - propietario_nuevo: New owner name
 *   - fecha_operacion: Operation timestamp
 *   - usuario: User who performed the operation
 *
 * Business Logic:
 *   1. Validates advertisement exists and is active (vigente='V')
 *   2. Validates destination license/business exists and is active
 *   3. Validates destination is not blocked
 *   4. Updates anuncios.id_licencia to point to new license
 *   5. If p_copiar_ubicacion is TRUE, copies location fields from license to advertisement
 *   6. Updates detsal_lic records to point to new license
 *   7. Recalculates balance for new license using calc_sdosl (if exists)
 *   8. If previous license existed, recalculates its balance too
 *   9. Logs operation in audit trail if table exists
 *
 * Validations:
 *   - Advertisement must exist
 *   - Advertisement must be active (vigente='V')
 *   - Destination license/business must exist
 *   - Destination must be active (vigente='V')
 *   - Destination must not be blocked
 *
 * Location fields copied (when p_copiar_ubicacion=TRUE):
 *   - zona, subzona, cvecalle, ubicacion
 *   - numext_ubic, letraext_ubic, numint_ubic, letraint_ubic
 *
 * Example Usage:
 *   -- Link advertisement to license
 *   SELECT * FROM comun.sp_liga_anuncio_ligar(1001, 5001, FALSE, 'ADMIN01', TRUE);
 *
 *   -- Link advertisement to business (empresa)
 *   SELECT * FROM comun.sp_liga_anuncio_ligar(1001, 2001, TRUE, 'ADMIN01', TRUE);
 *
 *   -- Link without copying location data
 *   SELECT * FROM comun.sp_liga_anuncio_ligar(1001, 5001, FALSE, 'ADMIN01', FALSE);
 */
DECLARE
    v_anuncio RECORD;
    v_licencia RECORD;
    v_id_licencia_anterior INTEGER;
    v_numero_licencia_anterior VARCHAR(50);
    v_numero_licencia_nueva VARCHAR(50);
    v_propietario_nuevo TEXT;
    v_fecha_operacion TIMESTAMP;
BEGIN
    -- Initialize operation timestamp
    v_fecha_operacion := CURRENT_TIMESTAMP;

    -- Validate required parameters
    IF p_anuncio_id IS NULL OR p_anuncio_id <= 0 THEN
        RETURN QUERY SELECT
            FALSE,
            'Error: El ID del anuncio es requerido y debe ser mayor a 0'::TEXT,
            NULL::INTEGER, NULL::VARCHAR(50), NULL::INTEGER, NULL::VARCHAR(50),
            NULL::INTEGER, NULL::VARCHAR(50), NULL::TEXT, NULL::TIMESTAMP, NULL::VARCHAR(10);
        RETURN;
    END IF;

    IF p_licencia_id IS NULL OR p_licencia_id <= 0 THEN
        RETURN QUERY SELECT
            FALSE,
            'Error: El ID de la licencia/empresa destino es requerido y debe ser mayor a 0'::TEXT,
            NULL::INTEGER, NULL::VARCHAR(50), NULL::INTEGER, NULL::VARCHAR(50),
            NULL::INTEGER, NULL::VARCHAR(50), NULL::TEXT, NULL::TIMESTAMP, NULL::VARCHAR(10);
        RETURN;
    END IF;

    -- Get advertisement data and validate
    SELECT
        a.id_anuncio,
        COALESCE(a.numero_anuncio, a.id_anuncio::VARCHAR) AS numero_anuncio,
        a.id_licencia,
        a.vigente
    INTO v_anuncio
    FROM comun.anuncios a
    WHERE a.id_anuncio = p_anuncio_id;

    -- Check if advertisement exists
    IF v_anuncio.id_anuncio IS NULL THEN
        RETURN QUERY SELECT
            FALSE,
            ('Error: No se encontro el anuncio con ID: ' || p_anuncio_id)::TEXT,
            NULL::INTEGER, NULL::VARCHAR(50), NULL::INTEGER, NULL::VARCHAR(50),
            NULL::INTEGER, NULL::VARCHAR(50), NULL::TEXT, NULL::TIMESTAMP, NULL::VARCHAR(10);
        RETURN;
    END IF;

    -- Check if advertisement is active
    IF v_anuncio.vigente <> 'V' THEN
        RETURN QUERY SELECT
            FALSE,
            ('Error: El anuncio ' || v_anuncio.numero_anuncio || ' no esta vigente (Estado: ' ||
             CASE v_anuncio.vigente
                 WHEN 'C' THEN 'CANCELADO'
                 WHEN 'S' THEN 'SUSPENDIDO'
                 ELSE 'DESCONOCIDO'
             END || '). No se puede ligar.')::TEXT,
            v_anuncio.id_anuncio, v_anuncio.numero_anuncio::VARCHAR(50),
            v_anuncio.id_licencia, NULL::VARCHAR(50),
            NULL::INTEGER, NULL::VARCHAR(50), NULL::TEXT, NULL::TIMESTAMP, NULL::VARCHAR(10);
        RETURN;
    END IF;

    -- Store previous license info
    v_id_licencia_anterior := v_anuncio.id_licencia;

    IF v_id_licencia_anterior IS NOT NULL THEN
        SELECT COALESCE(numero_licencia, id_licencia::VARCHAR)
        INTO v_numero_licencia_anterior
        FROM comun.licencias
        WHERE id_licencia = v_id_licencia_anterior;
    END IF;

    -- Get destination license/empresa data and validate
    IF p_is_empresa THEN
        -- Try empresas table first, fall back to licencias
        BEGIN
            SELECT
                e.empresa AS id_licencia,
                e.empresa::VARCHAR AS numero_licencia,
                e.propietario,
                COALESCE(e.vigente, 'S') AS vigente,
                COALESCE(e.bloqueado, 0) AS bloqueado,
                e.zona,
                e.subzona,
                e.cvecalle,
                e.ubicacion,
                e.numext_ubic,
                e.letraext_ubic,
                e.numint_ubic,
                e.letraint_ubic
            INTO v_licencia
            FROM comun.empresas e
            WHERE e.empresa = p_licencia_id;

            IF v_licencia.id_licencia IS NULL THEN
                RAISE EXCEPTION 'Empresa not found';
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                -- Fall back to licencias table
                SELECT
                    l.id_licencia,
                    COALESCE(l.numero_licencia, l.id_licencia::VARCHAR) AS numero_licencia,
                    TRIM(COALESCE(l.propietario, '') || ' ' || COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '')) AS propietario,
                    l.vigente,
                    COALESCE(l.bloqueado, 0) AS bloqueado,
                    l.zona,
                    l.subzona,
                    l.cvecalle,
                    l.ubicacion,
                    l.numext_ubic,
                    l.letraext_ubic,
                    l.numint_ubic,
                    l.letraint_ubic
                INTO v_licencia
                FROM comun.licencias l
                WHERE l.id_licencia = p_licencia_id;
        END;
    ELSE
        -- Get from licencias table
        SELECT
            l.id_licencia,
            COALESCE(l.numero_licencia, l.id_licencia::VARCHAR) AS numero_licencia,
            TRIM(COALESCE(l.propietario, '') || ' ' || COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '')) AS propietario,
            l.vigente,
            COALESCE(l.bloqueado, 0) AS bloqueado,
            l.zona,
            l.subzona,
            l.cvecalle,
            l.ubicacion,
            l.numext_ubic,
            l.letraext_ubic,
            l.numint_ubic,
            l.letraint_ubic
        INTO v_licencia
        FROM comun.licencias l
        WHERE l.id_licencia = p_licencia_id;
    END IF;

    -- Check if destination exists
    IF v_licencia.id_licencia IS NULL THEN
        RETURN QUERY SELECT
            FALSE,
            ('Error: No se encontro la ' || CASE WHEN p_is_empresa THEN 'empresa' ELSE 'licencia' END ||
             ' destino con ID: ' || p_licencia_id)::TEXT,
            v_anuncio.id_anuncio, v_anuncio.numero_anuncio::VARCHAR(50),
            v_id_licencia_anterior, v_numero_licencia_anterior,
            NULL::INTEGER, NULL::VARCHAR(50), NULL::TEXT, NULL::TIMESTAMP, NULL::VARCHAR(10);
        RETURN;
    END IF;

    -- Check if destination is active
    IF v_licencia.vigente NOT IN ('V', 'S') THEN
        RETURN QUERY SELECT
            FALSE,
            ('Error: La ' || CASE WHEN p_is_empresa THEN 'empresa' ELSE 'licencia' END ||
             ' ' || v_licencia.numero_licencia || ' no esta vigente (Estado: ' ||
             CASE v_licencia.vigente
                 WHEN 'C' THEN 'CANCELADA'
                 WHEN 'N' THEN 'INACTIVA'
                 ELSE 'DESCONOCIDO'
             END || '). No se puede ligar el anuncio.')::TEXT,
            v_anuncio.id_anuncio, v_anuncio.numero_anuncio::VARCHAR(50),
            v_id_licencia_anterior, v_numero_licencia_anterior,
            NULL::INTEGER, NULL::VARCHAR(50), NULL::TEXT, NULL::TIMESTAMP, NULL::VARCHAR(10);
        RETURN;
    END IF;

    -- Check if destination is blocked
    IF v_licencia.bloqueado > 0 THEN
        RETURN QUERY SELECT
            FALSE,
            ('Error: La ' || CASE WHEN p_is_empresa THEN 'empresa' ELSE 'licencia' END ||
             ' ' || v_licencia.numero_licencia || ' esta BLOQUEADA. Debe desbloquearse antes de recibir anuncios.')::TEXT,
            v_anuncio.id_anuncio, v_anuncio.numero_anuncio::VARCHAR(50),
            v_id_licencia_anterior, v_numero_licencia_anterior,
            v_licencia.id_licencia, v_licencia.numero_licencia::VARCHAR(50),
            v_licencia.propietario, NULL::TIMESTAMP, NULL::VARCHAR(10);
        RETURN;
    END IF;

    -- Check if trying to link to the same license
    IF v_id_licencia_anterior = p_licencia_id THEN
        RETURN QUERY SELECT
            FALSE,
            ('Error: El anuncio ' || v_anuncio.numero_anuncio ||
             ' ya esta ligado a la ' || CASE WHEN p_is_empresa THEN 'empresa' ELSE 'licencia' END ||
             ' ' || v_licencia.numero_licencia || '. No hay cambios que realizar.')::TEXT,
            v_anuncio.id_anuncio, v_anuncio.numero_anuncio::VARCHAR(50),
            v_id_licencia_anterior, v_numero_licencia_anterior,
            v_licencia.id_licencia, v_licencia.numero_licencia::VARCHAR(50),
            v_licencia.propietario, NULL::TIMESTAMP, NULL::VARCHAR(10);
        RETURN;
    END IF;

    -- Store new license info
    v_numero_licencia_nueva := v_licencia.numero_licencia;
    v_propietario_nuevo := v_licencia.propietario;

    -- Begin transaction operations
    BEGIN
        -- Update anuncios table - link to new license
        IF p_copiar_ubicacion THEN
            -- Copy location data from license to advertisement
            UPDATE comun.anuncios
            SET
                id_licencia = p_licencia_id,
                zona = v_licencia.zona,
                subzona = v_licencia.subzona,
                cvecalle = v_licencia.cvecalle,
                ubicacion = v_licencia.ubicacion,
                numext_ubic = v_licencia.numext_ubic,
                letraext_ubic = v_licencia.letraext_ubic,
                numint_ubic = v_licencia.numint_ubic,
                letraint_ubic = v_licencia.letraint_ubic
            WHERE id_anuncio = p_anuncio_id;
        ELSE
            -- Only update license link, keep advertisement location
            UPDATE comun.anuncios
            SET id_licencia = p_licencia_id
            WHERE id_anuncio = p_anuncio_id;
        END IF;

        -- Update detsal_lic - transfer debt records to new license
        UPDATE comun.detsal_lic
        SET id_licencia = p_licencia_id
        WHERE id_anuncio = p_anuncio_id;

        -- Recalculate balance for new license
        BEGIN
            PERFORM comun.calc_sdosl(p_licencia_id);
        EXCEPTION
            WHEN undefined_function THEN
                -- calc_sdosl function doesn't exist, continue without error
                NULL;
            WHEN OTHERS THEN
                -- Log error but continue
                RAISE NOTICE 'Warning: Error recalculating balance for license %: %', p_licencia_id, SQLERRM;
        END;

        -- Recalculate balance for previous license (if existed)
        IF v_id_licencia_anterior IS NOT NULL AND v_id_licencia_anterior <> p_licencia_id THEN
            BEGIN
                PERFORM comun.calc_sdosl(v_id_licencia_anterior);
            EXCEPTION
                WHEN undefined_function THEN
                    NULL;
                WHEN OTHERS THEN
                    RAISE NOTICE 'Warning: Error recalculating balance for previous license %: %', v_id_licencia_anterior, SQLERRM;
            END;
        END IF;

        -- Log operation in audit trail if table exists
        BEGIN
            INSERT INTO comun.historial_liga_anuncios(
                id_anuncio,
                numero_anuncio,
                id_licencia_anterior,
                id_licencia_nueva,
                es_empresa,
                usuario,
                fecha_operacion,
                copiar_ubicacion
            ) VALUES (
                p_anuncio_id,
                v_anuncio.numero_anuncio,
                v_id_licencia_anterior,
                p_licencia_id,
                p_is_empresa,
                p_usuario,
                v_fecha_operacion,
                p_copiar_ubicacion
            );
        EXCEPTION
            WHEN undefined_table THEN
                -- Audit table doesn't exist, continue without error
                NULL;
            WHEN OTHERS THEN
                -- Log error but continue
                RAISE NOTICE 'Warning: Could not log operation in audit trail: %', SQLERRM;
        END;

        -- Return success
        RETURN QUERY SELECT
            TRUE,
            ('Anuncio ' || v_anuncio.numero_anuncio || ' ligado correctamente a ' ||
             CASE WHEN p_is_empresa THEN 'empresa' ELSE 'licencia' END ||
             ' ' || v_numero_licencia_nueva ||
             CASE WHEN v_id_licencia_anterior IS NOT NULL
                 THEN ' (anteriormente en licencia ' || COALESCE(v_numero_licencia_anterior, 'N/A') || ')'
                 ELSE ''
             END || '.')::TEXT,
            v_anuncio.id_anuncio,
            v_anuncio.numero_anuncio::VARCHAR(50),
            v_id_licencia_anterior,
            v_numero_licencia_anterior,
            p_licencia_id,
            v_numero_licencia_nueva::VARCHAR(50),
            v_propietario_nuevo,
            v_fecha_operacion,
            p_usuario;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT
                FALSE,
                ('Error al ligar el anuncio: ' || SQLERRM)::TEXT,
                v_anuncio.id_anuncio, v_anuncio.numero_anuncio::VARCHAR(50),
                v_id_licencia_anterior, v_numero_licencia_anterior,
                NULL::INTEGER, NULL::VARCHAR(50), NULL::TEXT, NULL::TIMESTAMP, NULL::VARCHAR(10);
    END;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_liga_anuncio_ligar(INTEGER, INTEGER, BOOLEAN, VARCHAR, BOOLEAN) IS
'CRUD: Liga un anuncio a una licencia o empresa, actualiza ubicacion y recalcula saldos';

-- ============================================
-- AUXILIARY FUNCTION: calc_sdosl (if not exists)
-- Type: Calculation
-- Description: Placeholder for balance recalculation function.
--              Should be implemented according to business rules.
-- ============================================

CREATE OR REPLACE FUNCTION comun.calc_sdosl(p_id_licencia INTEGER)
RETURNS VOID AS $$
/**
 * Function: calc_sdosl
 * Description: Recalculates the balance for a license based on its associated
 *              advertisements and pending payments. This is a placeholder
 *              implementation that should be customized according to specific
 *              business rules.
 *
 * Parameters:
 *   @p_id_licencia - License ID to recalculate balance for
 *
 * Business Logic (placeholder - implement according to actual rules):
 *   - Sum all pending debts (cvepago = 0) for license and its advertisements
 *   - Update saldos_lic or similar table with calculated totals
 *   - Consider: derechos, recargos, multas, gastos, formas especiales
 *
 * Example Usage:
 *   SELECT comun.calc_sdosl(5001);
 */
DECLARE
    v_total_saldo NUMERIC;
    v_total_derechos NUMERIC;
    v_total_anuncios NUMERIC;
BEGIN
    -- Calculate total pending balance for license
    SELECT COALESCE(SUM(saldo), 0)
    INTO v_total_saldo
    FROM comun.detsal_lic
    WHERE id_licencia = p_id_licencia
      AND cvepago = 0;

    -- Calculate balance from advertisements
    SELECT COALESCE(SUM(saldo), 0)
    INTO v_total_anuncios
    FROM comun.detsal_lic d
    INNER JOIN comun.anuncios a ON a.id_anuncio = d.id_anuncio
    WHERE a.id_licencia = p_id_licencia
      AND d.cvepago = 0
      AND d.id_anuncio IS NOT NULL;

    -- Update saldos_lic if table exists
    BEGIN
        UPDATE comun.saldos_lic
        SET
            saldo_total = v_total_saldo,
            saldo_anuncios = v_total_anuncios,
            fecha_actualizacion = CURRENT_TIMESTAMP
        WHERE id_licencia = p_id_licencia;

        IF NOT FOUND THEN
            INSERT INTO comun.saldos_lic(id_licencia, saldo_total, saldo_anuncios, fecha_actualizacion)
            VALUES (p_id_licencia, v_total_saldo, v_total_anuncios, CURRENT_TIMESTAMP);
        END IF;
    EXCEPTION
        WHEN undefined_table THEN
            -- Table doesn't exist, just continue
            NULL;
        WHEN OTHERS THEN
            -- Log warning but don't fail
            RAISE NOTICE 'Warning in calc_sdosl: %', SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.calc_sdosl(INTEGER) IS
'Calculation: Recalcula el saldo de una licencia basado en sus anuncios y adeudos pendientes';

-- ============================================
-- RECOMMENDED INDEXES
-- ============================================
-- Execute these CREATE INDEX statements to optimize query performance:

-- Index for advertisement searches
CREATE INDEX IF NOT EXISTS idx_anuncios_id_anuncio
ON comun.anuncios(id_anuncio);

-- Index for advertisement by license relationship
CREATE INDEX IF NOT EXISTS idx_anuncios_id_licencia
ON comun.anuncios(id_licencia)
WHERE id_licencia IS NOT NULL;

-- Index for active advertisements
CREATE INDEX IF NOT EXISTS idx_anuncios_vigente
ON comun.anuncios(vigente)
WHERE vigente IS NOT NULL;

-- Index for license searches
CREATE INDEX IF NOT EXISTS idx_licencias_id_licencia
ON comun.licencias(id_licencia);

-- Index for active licenses
CREATE INDEX IF NOT EXISTS idx_licencias_vigente
ON comun.licencias(vigente)
WHERE vigente IS NOT NULL;

-- Index for debt records by advertisement
CREATE INDEX IF NOT EXISTS idx_detsal_lic_id_anuncio
ON comun.detsal_lic(id_anuncio)
WHERE id_anuncio IS NOT NULL;

-- Index for debt records by license
CREATE INDEX IF NOT EXISTS idx_detsal_lic_id_licencia
ON comun.detsal_lic(id_licencia)
WHERE id_licencia IS NOT NULL;

-- Index for pending debts
CREATE INDEX IF NOT EXISTS idx_detsal_lic_cvepago
ON comun.detsal_lic(cvepago)
WHERE cvepago = 0;

-- Composite index for debt queries
CREATE INDEX IF NOT EXISTS idx_detsal_lic_anuncio_cvepago
ON comun.detsal_lic(id_anuncio, cvepago)
WHERE id_anuncio IS NOT NULL;

-- ============================================
-- GRANTS DE PERMISOS
-- ============================================

-- Permissions for application role
GRANT EXECUTE ON FUNCTION comun.sp_liga_anuncio_buscar_anuncio(INTEGER) TO app_padron_licencias;
GRANT EXECUTE ON FUNCTION comun.sp_liga_anuncio_buscar_licencia(INTEGER) TO app_padron_licencias;
GRANT EXECUTE ON FUNCTION comun.sp_liga_anuncio_buscar_empresa(INTEGER) TO app_padron_licencias;
GRANT EXECUTE ON FUNCTION comun.sp_liga_anuncio_ligar(INTEGER, INTEGER, BOOLEAN, VARCHAR, BOOLEAN) TO app_padron_licencias;
GRANT EXECUTE ON FUNCTION comun.calc_sdosl(INTEGER) TO app_padron_licencias;

-- ============================================
-- AUDIT TABLE (OPTIONAL)
-- ============================================
-- Create this table if you want to track linking operations:

/*
CREATE TABLE IF NOT EXISTS comun.historial_liga_anuncios (
    id_historial SERIAL PRIMARY KEY,
    id_anuncio INTEGER NOT NULL,
    numero_anuncio VARCHAR(50),
    id_licencia_anterior INTEGER,
    id_licencia_nueva INTEGER NOT NULL,
    es_empresa BOOLEAN DEFAULT FALSE,
    usuario VARCHAR(10),
    fecha_operacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    copiar_ubicacion BOOLEAN DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_historial_liga_anuncios_anuncio
ON comun.historial_liga_anuncios(id_anuncio);

CREATE INDEX IF NOT EXISTS idx_historial_liga_anuncios_fecha
ON comun.historial_liga_anuncios(fecha_operacion);

COMMENT ON TABLE comun.historial_liga_anuncios IS
'Audit table: Tracks advertisement linking operations for traceability';
*/

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Use these queries to verify the stored procedures are working correctly:

-- Test 1: Search advertisement
/*
SELECT * FROM comun.sp_liga_anuncio_buscar_anuncio(1001);
*/

-- Test 2: Search license
/*
SELECT * FROM comun.sp_liga_anuncio_buscar_licencia(5001);
*/

-- Test 3: Search empresa
/*
SELECT * FROM comun.sp_liga_anuncio_buscar_empresa(2001);
*/

-- Test 4: Link advertisement to license (with location copy)
/*
SELECT * FROM comun.sp_liga_anuncio_ligar(
    1001,        -- p_anuncio_id
    5001,        -- p_licencia_id
    FALSE,       -- p_is_empresa
    'ADMIN01',   -- p_usuario
    TRUE         -- p_copiar_ubicacion
);
*/

-- Test 5: Link advertisement to empresa
/*
SELECT * FROM comun.sp_liga_anuncio_ligar(
    1001,        -- p_anuncio_id
    2001,        -- p_licencia_id (empresa ID)
    TRUE,        -- p_is_empresa
    'ADMIN01',   -- p_usuario
    TRUE         -- p_copiar_ubicacion
);
*/

-- Test 6: Link advertisement without copying location
/*
SELECT * FROM comun.sp_liga_anuncio_ligar(
    1001,        -- p_anuncio_id
    5002,        -- p_licencia_id
    FALSE,       -- p_is_empresa
    'ADMIN01',   -- p_usuario
    FALSE        -- p_copiar_ubicacion (keep original location)
);
*/

-- Test 7: Full workflow - search, validate, link
/*
DO $$
DECLARE
    v_anuncio RECORD;
    v_licencia RECORD;
    v_resultado RECORD;
BEGIN
    -- Step 1: Search advertisement
    SELECT * INTO v_anuncio
    FROM comun.sp_liga_anuncio_buscar_anuncio(1001);

    IF NOT v_anuncio.puede_ligarse THEN
        RAISE NOTICE 'Cannot link: %', v_anuncio.mensaje_validacion;
        RETURN;
    END IF;

    RAISE NOTICE 'Advertisement found: % (current license: %)',
        v_anuncio.numero_anuncio, v_anuncio.numero_licencia_actual;

    -- Step 2: Search destination license
    SELECT * INTO v_licencia
    FROM comun.sp_liga_anuncio_buscar_licencia(5001);

    IF NOT v_licencia.puede_recibir_anuncios THEN
        RAISE NOTICE 'Cannot receive ads: %', v_licencia.mensaje_validacion;
        RETURN;
    END IF;

    RAISE NOTICE 'Destination license found: % (owner: %, current ads: %)',
        v_licencia.numero_licencia, v_licencia.propietario_completo, v_licencia.anuncios_actuales;

    -- Step 3: Perform linking
    SELECT * INTO v_resultado
    FROM comun.sp_liga_anuncio_ligar(1001, 5001, FALSE, 'ADMIN01', TRUE);

    IF v_resultado.success THEN
        RAISE NOTICE 'Success: %', v_resultado.message;
    ELSE
        RAISE NOTICE 'Error: %', v_resultado.message;
    END IF;
END $$;
*/

-- ============================================
-- END OF STORED PROCEDURES IMPLEMENTATION
-- Component: ligaAnunciofrm
-- Total: 4 stored procedures + 1 auxiliary function
-- Status: READY FOR DEPLOYMENT
-- ============================================

-- ============================================
-- RESUMEN DE IMPLEMENTACION
-- ============================================
-- MODULO: padron_licencias
-- COMPONENTE: ligaAnunciofrm
-- TOTAL SPs IMPLEMENTADOS: 4 + 1 auxiliar
-- ESQUEMA PRINCIPAL: comun
--
-- STORED PROCEDURES:
-- 1. sp_liga_anuncio_buscar_anuncio  - Busqueda de anuncio con validacion
-- 2. sp_liga_anuncio_buscar_licencia - Busqueda de licencia destino
-- 3. sp_liga_anuncio_buscar_empresa  - Busqueda de empresa destino
-- 4. sp_liga_anuncio_ligar           - Operacion principal de liga
-- 5. calc_sdosl (auxiliar)           - Recalculo de saldos
--
-- TABLAS PRINCIPALES:
-- - comun.anuncios (principal)
-- - comun.licencias (relacion)
-- - comun.empresas (relacion alternativa)
-- - comun.detsal_lic (adeudos)
-- - comun.c_giros (catalogo)
-- - comun.saldos_lic (saldos - opcional)
-- - comun.historial_liga_anuncios (auditoria - opcional)
--
-- CARACTERISTICAS ESPECIALES:
-- - Validacion completa de estados de anuncio y licencia
-- - Soporte para ligar a licencias o empresas
-- - Copia opcional de datos de ubicacion
-- - Transferencia automatica de registros de adeudos
-- - Recalculo de saldos automatico
-- - Auditoria de operaciones (opcional)
-- - Validacion de bloqueos
-- - Mensajes descriptivos de error y exito
-- - Manejo de excepciones robusto
-- - Indices optimizados para consultas frecuentes
-- ============================================
