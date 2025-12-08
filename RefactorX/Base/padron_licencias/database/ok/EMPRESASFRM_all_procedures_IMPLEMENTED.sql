-- ============================================
-- STORED PROCEDURES - BATCH 11
-- Component: empresasfrm
-- Description: CRUD completo de empresas/negocios (businesses/establishments)
-- Schema: public (module-specific)
-- Total SPs: 5
-- Generated: 2025-11-21
-- Status: COMPLETED
-- ============================================
-- PROGRESS: Batch 11/95 - Component 68/95 (71.6%)
-- Previous Batches: 67 components completed
-- ============================================

-- ============================================
-- TABLA PRINCIPAL: empresas
-- Descripción: Catálogo maestro de empresas/establecimientos comerciales
-- Campos clave: 42 campos totales incluyendo:
--   - Identificación: empresa (PK auto-generado), propietario, RFC, CURP
--   - Domicilio propietario: domicilio, numext_prop, numint_prop, colonia_prop, telefono_prop, email
--   - Ubicación establecimiento: cvecalle, ubicacion, numext_ubic, letraext_ubic, numint_ubic, letraint_ubic, colonia_ubic
--   - Características: sup_construida, sup_autorizada, num_cajones, num_empleados, aforo, inversion
--   - Operación: rhorario, fecha_consejo, fecha_otorgamiento, bloqueado, vigente
--   - Clasificación: zona, subzona, recaud, id_giro, base_impuesto
--   - Control de bajas: fecha_baja, axo_baja, folio_baja
--   - Geolocalización: x, y, espubic
--   - Referencias: cvecuenta (catastro), cp
-- ============================================

-- ============================================
-- SP 1/5: sp_empresas_create
-- Type: CRUD Create
-- Description: Crea una nueva empresa con auto-generación de ID y validación
--              completa de campos. Maneja 42 campos incluyendo información del
--              propietario, ubicación del establecimiento, características físicas,
--              datos operacionales y clasificación administrativa.
-- Returns: Registro completo de la empresa creada
-- Dependencies: Table empresas
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_empresas_create(
    p_propietario TEXT,
    p_rfc TEXT,
    p_curp TEXT DEFAULT NULL,
    p_domicilio TEXT DEFAULT NULL,
    p_numext_prop INTEGER DEFAULT NULL,
    p_numint_prop TEXT DEFAULT NULL,
    p_colonia_prop TEXT DEFAULT NULL,
    p_telefono_prop TEXT DEFAULT NULL,
    p_email TEXT DEFAULT NULL,
    p_cvecalle INTEGER DEFAULT NULL,
    p_ubicacion TEXT DEFAULT NULL,
    p_numext_ubic INTEGER DEFAULT NULL,
    p_letraext_ubic TEXT DEFAULT NULL,
    p_numint_ubic TEXT DEFAULT NULL,
    p_letraint_ubic TEXT DEFAULT NULL,
    p_colonia_ubic TEXT DEFAULT NULL,
    p_sup_construida NUMERIC(10,2) DEFAULT NULL,
    p_sup_autorizada NUMERIC(10,2) DEFAULT NULL,
    p_num_cajones INTEGER DEFAULT 0,
    p_num_empleados INTEGER DEFAULT 0,
    p_aforo INTEGER DEFAULT 0,
    p_inversion NUMERIC(12,2) DEFAULT 0.00,
    p_rhorario TEXT DEFAULT NULL,
    p_fecha_consejo DATE DEFAULT NULL,
    p_bloqueado INTEGER DEFAULT 0,
    p_asiento INTEGER DEFAULT NULL,
    p_vigente TEXT DEFAULT 'S',
    p_fecha_baja DATE DEFAULT NULL,
    p_axo_baja INTEGER DEFAULT NULL,
    p_folio_baja INTEGER DEFAULT NULL,
    p_espubic TEXT DEFAULT NULL,
    p_base_impuesto NUMERIC(12,2) DEFAULT 0.00,
    p_zona INTEGER DEFAULT NULL,
    p_subzona INTEGER DEFAULT NULL,
    p_recaud INTEGER DEFAULT NULL,
    p_fecha_otorgamiento DATE DEFAULT NULL,
    p_id_giro INTEGER DEFAULT NULL,
    p_x NUMERIC(12,6) DEFAULT NULL,
    p_y NUMERIC(12,6) DEFAULT NULL,
    p_cvecuenta INTEGER DEFAULT NULL,
    p_cp INTEGER DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    empresa INTEGER,
    propietario TEXT,
    rfc TEXT,
    curp TEXT,
    ubicacion TEXT,
    numext_ubic INTEGER,
    colonia_ubic TEXT,
    zona INTEGER,
    subzona INTEGER,
    vigente TEXT,
    id_giro INTEGER,
    sup_construida NUMERIC,
    sup_autorizada NUMERIC,
    num_empleados INTEGER,
    fecha_otorgamiento DATE
) AS $$
/**
 * Function: sp_empresas_create
 * Description: Creates a new business/establishment record with automatic ID generation.
 *              Handles complete business information including owner details, physical
 *              location, operational characteristics, and administrative classification.
 *              Implements RFC validation and required field checks.
 *
 * Parameters:
 *   @p_propietario - Owner name (REQUIRED)
 *   @p_rfc - Tax ID (RFC) - 12-13 characters (REQUIRED)
 *   @p_curp - Personal ID (CURP) - 18 characters (OPTIONAL)
 *   @p_domicilio - Owner's address (OPTIONAL)
 *   @p_numext_prop - Owner's external number (OPTIONAL)
 *   @p_numint_prop - Owner's internal number (OPTIONAL)
 *   @p_colonia_prop - Owner's neighborhood (OPTIONAL)
 *   @p_telefono_prop - Owner's phone (OPTIONAL)
 *   @p_email - Owner's email (OPTIONAL)
 *   @p_cvecalle - Street code for establishment (OPTIONAL)
 *   @p_ubicacion - Establishment address (OPTIONAL)
 *   @p_numext_ubic - Establishment external number (OPTIONAL)
 *   @p_letraext_ubic - External number letter (OPTIONAL)
 *   @p_numint_ubic - Establishment internal number (OPTIONAL)
 *   @p_letraint_ubic - Internal number letter (OPTIONAL)
 *   @p_colonia_ubic - Establishment neighborhood (OPTIONAL)
 *   @p_sup_construida - Built area in m2 (OPTIONAL)
 *   @p_sup_autorizada - Authorized area in m2 (OPTIONAL)
 *   @p_num_cajones - Number of parking spaces (DEFAULT: 0)
 *   @p_num_empleados - Number of employees (DEFAULT: 0)
 *   @p_aforo - Maximum capacity (DEFAULT: 0)
 *   @p_inversion - Investment amount (DEFAULT: 0.00)
 *   @p_rhorario - Operating schedule (OPTIONAL)
 *   @p_fecha_consejo - Council approval date (OPTIONAL)
 *   @p_bloqueado - Blocked status (0=No, 1=Yes, DEFAULT: 0)
 *   @p_asiento - Registry entry number (OPTIONAL)
 *   @p_vigente - Active status (S=Yes, N=No, DEFAULT: 'S')
 *   @p_fecha_baja - Closure date (OPTIONAL)
 *   @p_axo_baja - Closure year (OPTIONAL)
 *   @p_folio_baja - Closure folio (OPTIONAL)
 *   @p_espubic - Location space type (OPTIONAL)
 *   @p_base_impuesto - Tax base amount (DEFAULT: 0.00)
 *   @p_zona - Zone code (OPTIONAL)
 *   @p_subzona - Subzone code (OPTIONAL)
 *   @p_recaud - Collection office (OPTIONAL)
 *   @p_fecha_otorgamiento - Grant date (OPTIONAL)
 *   @p_id_giro - Business category ID (OPTIONAL)
 *   @p_x - Longitude coordinate (OPTIONAL)
 *   @p_y - Latitude coordinate (OPTIONAL)
 *   @p_cvecuenta - Property tax account (OPTIONAL)
 *   @p_cp - Postal code (OPTIONAL)
 *
 * Returns:
 *   - success: Operation success flag
 *   - message: Descriptive message
 *   - empresa: Generated business ID
 *   - propietario: Owner name
 *   - rfc: Tax ID
 *   - curp: Personal ID
 *   - ubicacion: Establishment address
 *   - numext_ubic: External number
 *   - colonia_ubic: Neighborhood
 *   - zona: Zone code
 *   - subzona: Subzone code
 *   - vigente: Active status
 *   - id_giro: Business category
 *   - sup_construida: Built area
 *   - sup_autorizada: Authorized area
 *   - num_empleados: Employee count
 *   - fecha_otorgamiento: Grant date
 *
 * Business Logic:
 *   - Auto-generates empresa ID using MAX(empresa)+1
 *   - Validates propietario is not empty
 *   - Validates RFC format (12-13 alphanumeric characters)
 *   - Validates CURP format if provided (18 alphanumeric characters)
 *   - Sets default values for numeric fields (0) and vigente ('S')
 *   - All numeric measurements support decimals
 *   - Returns complete record after successful insert
 *
 * Validations:
 *   - propietario cannot be NULL or empty
 *   - RFC cannot be NULL, must be 12-13 characters, alphanumeric
 *   - CURP if provided must be exactly 18 characters
 *   - vigente must be 'S' or 'N'
 *   - bloqueado must be 0 or 1
 *   - Numeric values cannot be negative
 *
 * Example Usage:
 *   -- Minimal create with required fields
 *   SELECT * FROM public.sp_empresas_create(
 *       'Juan Perez Martinez',
 *       'JPM850101ABC'
 *   );
 *
 *   -- Complete create with all fields
 *   SELECT * FROM public.sp_empresas_create(
 *       'Juan Perez Martinez',
 *       'JPM850101ABC',
 *       'PEMJ850101HJCRNS01',
 *       'Av. Juarez 123',
 *       123, 'A', 'Centro', '3312345678', 'juan@example.com',
 *       1500, 'Av. Hidalgo 456', 456, 'B', '2', 'C', 'Americana',
 *       150.50, 200.00, 5, 10, 50, 250000.00,
 *       'Lun-Vie 9:00-18:00', '2025-01-15', 0, 12345, 'S',
 *       NULL, NULL, NULL, 'LOCAL', 50000.00,
 *       1, 2, 3, '2025-01-20', 101,
 *       -103.123456, 20.654321, 987654, 44100
 *   );
 *
 * Indexes Required:
 *   - empresas(empresa) - PK index (auto-created)
 *   - empresas(rfc) - For uniqueness checks and searches
 *   - empresas(vigente) - For active/inactive filtering
 *   - empresas(zona, subzona) - For geographic queries
 *   - empresas(id_giro) - FK index for business category
 *   - empresas(cvecuenta) - FK index for property tax
 *   - empresas(propietario) - For owner searches (consider trigram for ILIKE)
 */
DECLARE
    v_empresa INTEGER;
    v_count INTEGER;
BEGIN
    -- Validate required fields
    IF p_propietario IS NULL OR TRIM(p_propietario) = '' THEN
        RETURN QUERY SELECT
            false,
            'Error: El nombre del propietario es obligatorio'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
            NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
            NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;

    IF p_rfc IS NULL OR TRIM(p_rfc) = '' THEN
        RETURN QUERY SELECT
            false,
            'Error: El RFC es obligatorio'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
            NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
            NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;

    -- Validate RFC format (12-13 alphanumeric characters)
    IF LENGTH(TRIM(p_rfc)) NOT BETWEEN 12 AND 13 OR NOT (TRIM(p_rfc) ~ '^[A-Z0-9]+$') THEN
        RETURN QUERY SELECT
            false,
            'Error: RFC inválido. Debe contener entre 12 y 13 caracteres alfanuméricos'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
            NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
            NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;

    -- Validate CURP format if provided (18 alphanumeric characters)
    IF p_curp IS NOT NULL AND (LENGTH(TRIM(p_curp)) != 18 OR NOT (TRIM(p_curp) ~ '^[A-Z0-9]+$')) THEN
        RETURN QUERY SELECT
            false,
            'Error: CURP inválido. Debe contener exactamente 18 caracteres alfanuméricos'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
            NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
            NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;

    -- Validate vigente value
    IF p_vigente NOT IN ('S', 'N') THEN
        RETURN QUERY SELECT
            false,
            'Error: El valor de vigente debe ser S o N'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
            NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
            NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;

    -- Validate bloqueado value
    IF p_bloqueado NOT IN (0, 1) THEN
        RETURN QUERY SELECT
            false,
            'Error: El valor de bloqueado debe ser 0 o 1'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
            NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
            NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;

    -- Validate numeric values are not negative
    IF COALESCE(p_num_cajones, 0) < 0 OR COALESCE(p_num_empleados, 0) < 0 OR
       COALESCE(p_aforo, 0) < 0 OR COALESCE(p_inversion, 0) < 0 OR
       COALESCE(p_sup_construida, 0) < 0 OR COALESCE(p_sup_autorizada, 0) < 0 THEN
        RETURN QUERY SELECT
            false,
            'Error: Los valores numéricos no pueden ser negativos'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
            NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
            NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;

    -- Check if RFC already exists for active businesses
    SELECT COUNT(*) INTO v_count
    FROM public.empresas
    WHERE UPPER(TRIM(rfc)) = UPPER(TRIM(p_rfc))
      AND vigente = 'S';

    IF v_count > 0 THEN
        RETURN QUERY SELECT
            false,
            'Error: Ya existe una empresa activa con este RFC'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
            NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
            NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;

    -- Auto-generate empresa ID
    SELECT COALESCE(MAX(empresa), 0) + 1 INTO v_empresa
    FROM public.empresas;

    -- Insert new empresa record
    BEGIN
        INSERT INTO public.empresas (
            empresa, propietario, rfc, curp, domicilio,
            numext_prop, numint_prop, colonia_prop, telefono_prop, email,
            cvecalle, ubicacion, numext_ubic, letraext_ubic, numint_ubic,
            letraint_ubic, colonia_ubic, sup_construida, sup_autorizada,
            num_cajones, num_empleados, aforo, inversion, rhorario,
            fecha_consejo, bloqueado, asiento, vigente, fecha_baja,
            axo_baja, folio_baja, espubic, base_impuesto, zona,
            subzona, recaud, fecha_otorgamiento, id_giro, x, y,
            cvecuenta, cp
        ) VALUES (
            v_empresa,
            TRIM(p_propietario),
            UPPER(TRIM(p_rfc)),
            CASE WHEN p_curp IS NOT NULL THEN UPPER(TRIM(p_curp)) ELSE NULL END,
            p_domicilio,
            p_numext_prop,
            p_numint_prop,
            p_colonia_prop,
            p_telefono_prop,
            LOWER(TRIM(COALESCE(p_email, ''))),
            p_cvecalle,
            p_ubicacion,
            p_numext_ubic,
            p_letraext_ubic,
            p_numint_ubic,
            p_letraint_ubic,
            p_colonia_ubic,
            p_sup_construida,
            p_sup_autorizada,
            COALESCE(p_num_cajones, 0),
            COALESCE(p_num_empleados, 0),
            COALESCE(p_aforo, 0),
            COALESCE(p_inversion, 0.00),
            p_rhorario,
            p_fecha_consejo,
            COALESCE(p_bloqueado, 0),
            p_asiento,
            p_vigente,
            p_fecha_baja,
            p_axo_baja,
            p_folio_baja,
            p_espubic,
            COALESCE(p_base_impuesto, 0.00),
            p_zona,
            p_subzona,
            p_recaud,
            p_fecha_otorgamiento,
            p_id_giro,
            p_x,
            p_y,
            p_cvecuenta,
            p_cp
        );

        -- Return success with complete record
        RETURN QUERY
        SELECT
            true,
            'Empresa creada exitosamente'::TEXT,
            v_empresa,
            TRIM(p_propietario),
            UPPER(TRIM(p_rfc)),
            CASE WHEN p_curp IS NOT NULL THEN UPPER(TRIM(p_curp)) ELSE NULL END,
            p_ubicacion,
            p_numext_ubic,
            p_colonia_ubic,
            p_zona,
            p_subzona,
            p_vigente,
            p_id_giro,
            p_sup_construida,
            p_sup_autorizada,
            COALESCE(p_num_empleados, 0),
            p_fecha_otorgamiento;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT
                false,
                ('Error al crear empresa: ' || SQLERRM)::TEXT,
                NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
                NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
                NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
                NULL::INTEGER, NULL::DATE;
    END;

END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_empresas_create IS
'CRUD: Creates new business/establishment with auto-generated ID and complete validation';

-- ============================================
-- SP 2/5: sp_empresas_update
-- Type: CRUD Update
-- Description: Actualiza una empresa existente validando que el registro exista
--              y manteniendo la integridad de datos. Maneja todos los campos
--              excepto la clave primaria.
-- Returns: Registro actualizado de la empresa
-- Dependencies: Table empresas
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_empresas_update(
    p_empresa INTEGER,
    p_propietario TEXT,
    p_rfc TEXT,
    p_curp TEXT DEFAULT NULL,
    p_domicilio TEXT DEFAULT NULL,
    p_numext_prop INTEGER DEFAULT NULL,
    p_numint_prop TEXT DEFAULT NULL,
    p_colonia_prop TEXT DEFAULT NULL,
    p_telefono_prop TEXT DEFAULT NULL,
    p_email TEXT DEFAULT NULL,
    p_cvecalle INTEGER DEFAULT NULL,
    p_ubicacion TEXT DEFAULT NULL,
    p_numext_ubic INTEGER DEFAULT NULL,
    p_letraext_ubic TEXT DEFAULT NULL,
    p_numint_ubic TEXT DEFAULT NULL,
    p_letraint_ubic TEXT DEFAULT NULL,
    p_colonia_ubic TEXT DEFAULT NULL,
    p_sup_construida NUMERIC(10,2) DEFAULT NULL,
    p_sup_autorizada NUMERIC(10,2) DEFAULT NULL,
    p_num_cajones INTEGER DEFAULT 0,
    p_num_empleados INTEGER DEFAULT 0,
    p_aforo INTEGER DEFAULT 0,
    p_inversion NUMERIC(12,2) DEFAULT 0.00,
    p_rhorario TEXT DEFAULT NULL,
    p_fecha_consejo DATE DEFAULT NULL,
    p_bloqueado INTEGER DEFAULT 0,
    p_asiento INTEGER DEFAULT NULL,
    p_vigente TEXT DEFAULT 'S',
    p_fecha_baja DATE DEFAULT NULL,
    p_axo_baja INTEGER DEFAULT NULL,
    p_folio_baja INTEGER DEFAULT NULL,
    p_espubic TEXT DEFAULT NULL,
    p_base_impuesto NUMERIC(12,2) DEFAULT 0.00,
    p_zona INTEGER DEFAULT NULL,
    p_subzona INTEGER DEFAULT NULL,
    p_recaud INTEGER DEFAULT NULL,
    p_fecha_otorgamiento DATE DEFAULT NULL,
    p_id_giro INTEGER DEFAULT NULL,
    p_x NUMERIC(12,6) DEFAULT NULL,
    p_y NUMERIC(12,6) DEFAULT NULL,
    p_cvecuenta INTEGER DEFAULT NULL,
    p_cp INTEGER DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    empresa INTEGER,
    propietario TEXT,
    rfc TEXT,
    curp TEXT,
    ubicacion TEXT,
    numext_ubic INTEGER,
    colonia_ubic TEXT,
    zona INTEGER,
    subzona INTEGER,
    vigente TEXT,
    id_giro INTEGER,
    sup_construida NUMERIC,
    sup_autorizada NUMERIC,
    num_empleados INTEGER,
    fecha_otorgamiento DATE
) AS $$
/**
 * Function: sp_empresas_update
 * Description: Updates an existing business/establishment record. Validates record
 *              existence and maintains data integrity. All fields can be updated
 *              except the primary key (empresa ID).
 *
 * Parameters:
 *   @p_empresa - Business ID to update (REQUIRED)
 *   [All other parameters same as sp_empresas_create]
 *
 * Returns:
 *   Same structure as sp_empresas_create
 *
 * Business Logic:
 *   - Validates empresa exists before updating
 *   - Performs same field validations as create
 *   - Checks RFC uniqueness excluding current record
 *   - Updates all provided fields
 *   - Returns updated record
 *
 * Validations:
 *   - empresa must exist
 *   - Same validations as sp_empresas_create
 *   - RFC uniqueness check excludes current empresa
 *
 * Example Usage:
 *   SELECT * FROM public.sp_empresas_update(
 *       1001,
 *       'Juan Perez Martinez',
 *       'JPM850101ABC',
 *       'PEMJ850101HJCRNS01',
 *       'Av. Juarez 123',
 *       123, 'A', 'Centro', '3312345678', 'juan@example.com',
 *       1500, 'Av. Hidalgo 456', 456, 'B', '2', 'C', 'Americana',
 *       150.50, 200.00, 5, 15, 50, 300000.00,
 *       'Lun-Vie 9:00-18:00', '2025-01-15', 0, 12345, 'S',
 *       NULL, NULL, NULL, 'LOCAL', 55000.00,
 *       1, 2, 3, '2025-01-20', 101,
 *       -103.123456, 20.654321, 987654, 44100
 *   );
 *
 * Indexes Required:
 *   Same as sp_empresas_create
 */
DECLARE
    v_count INTEGER;
    v_exists BOOLEAN;
BEGIN
    -- Validate empresa exists
    SELECT EXISTS(
        SELECT 1 FROM public.empresas WHERE empresa = p_empresa
    ) INTO v_exists;

    IF NOT v_exists THEN
        RETURN QUERY SELECT
            false,
            ('Error: No existe empresa con ID ' || p_empresa)::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
            NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
            NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;

    -- Validate required fields
    IF p_propietario IS NULL OR TRIM(p_propietario) = '' THEN
        RETURN QUERY SELECT
            false,
            'Error: El nombre del propietario es obligatorio'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
            NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
            NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;

    IF p_rfc IS NULL OR TRIM(p_rfc) = '' THEN
        RETURN QUERY SELECT
            false,
            'Error: El RFC es obligatorio'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
            NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
            NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;

    -- Validate RFC format
    IF LENGTH(TRIM(p_rfc)) NOT BETWEEN 12 AND 13 OR NOT (TRIM(p_rfc) ~ '^[A-Z0-9]+$') THEN
        RETURN QUERY SELECT
            false,
            'Error: RFC inválido. Debe contener entre 12 y 13 caracteres alfanuméricos'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
            NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
            NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;

    -- Validate CURP format if provided
    IF p_curp IS NOT NULL AND (LENGTH(TRIM(p_curp)) != 18 OR NOT (TRIM(p_curp) ~ '^[A-Z0-9]+$')) THEN
        RETURN QUERY SELECT
            false,
            'Error: CURP inválido. Debe contener exactamente 18 caracteres alfanuméricos'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
            NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
            NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;

    -- Validate vigente value
    IF p_vigente NOT IN ('S', 'N') THEN
        RETURN QUERY SELECT
            false,
            'Error: El valor de vigente debe ser S o N'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
            NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
            NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;

    -- Validate bloqueado value
    IF p_bloqueado NOT IN (0, 1) THEN
        RETURN QUERY SELECT
            false,
            'Error: El valor de bloqueado debe ser 0 o 1'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
            NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
            NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;

    -- Validate numeric values are not negative
    IF COALESCE(p_num_cajones, 0) < 0 OR COALESCE(p_num_empleados, 0) < 0 OR
       COALESCE(p_aforo, 0) < 0 OR COALESCE(p_inversion, 0) < 0 OR
       COALESCE(p_sup_construida, 0) < 0 OR COALESCE(p_sup_autorizada, 0) < 0 THEN
        RETURN QUERY SELECT
            false,
            'Error: Los valores numéricos no pueden ser negativos'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
            NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
            NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;

    -- Check if RFC already exists for other active businesses
    SELECT COUNT(*) INTO v_count
    FROM public.empresas
    WHERE UPPER(TRIM(rfc)) = UPPER(TRIM(p_rfc))
      AND vigente = 'S'
      AND empresa != p_empresa;

    IF v_count > 0 THEN
        RETURN QUERY SELECT
            false,
            'Error: Ya existe otra empresa activa con este RFC'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
            NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
            NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;

    -- Update empresa record
    BEGIN
        UPDATE public.empresas SET
            propietario = TRIM(p_propietario),
            rfc = UPPER(TRIM(p_rfc)),
            curp = CASE WHEN p_curp IS NOT NULL THEN UPPER(TRIM(p_curp)) ELSE NULL END,
            domicilio = p_domicilio,
            numext_prop = p_numext_prop,
            numint_prop = p_numint_prop,
            colonia_prop = p_colonia_prop,
            telefono_prop = p_telefono_prop,
            email = LOWER(TRIM(COALESCE(p_email, ''))),
            cvecalle = p_cvecalle,
            ubicacion = p_ubicacion,
            numext_ubic = p_numext_ubic,
            letraext_ubic = p_letraext_ubic,
            numint_ubic = p_numint_ubic,
            letraint_ubic = p_letraint_ubic,
            colonia_ubic = p_colonia_ubic,
            sup_construida = p_sup_construida,
            sup_autorizada = p_sup_autorizada,
            num_cajones = COALESCE(p_num_cajones, 0),
            num_empleados = COALESCE(p_num_empleados, 0),
            aforo = COALESCE(p_aforo, 0),
            inversion = COALESCE(p_inversion, 0.00),
            rhorario = p_rhorario,
            fecha_consejo = p_fecha_consejo,
            bloqueado = COALESCE(p_bloqueado, 0),
            asiento = p_asiento,
            vigente = p_vigente,
            fecha_baja = p_fecha_baja,
            axo_baja = p_axo_baja,
            folio_baja = p_folio_baja,
            espubic = p_espubic,
            base_impuesto = COALESCE(p_base_impuesto, 0.00),
            zona = p_zona,
            subzona = p_subzona,
            recaud = p_recaud,
            fecha_otorgamiento = p_fecha_otorgamiento,
            id_giro = p_id_giro,
            x = p_x,
            y = p_y,
            cvecuenta = p_cvecuenta,
            cp = p_cp
        WHERE empresa = p_empresa;

        -- Return success with updated record
        RETURN QUERY
        SELECT
            true,
            'Empresa actualizada exitosamente'::TEXT,
            p_empresa,
            TRIM(p_propietario),
            UPPER(TRIM(p_rfc)),
            CASE WHEN p_curp IS NOT NULL THEN UPPER(TRIM(p_curp)) ELSE NULL END,
            p_ubicacion,
            p_numext_ubic,
            p_colonia_ubic,
            p_zona,
            p_subzona,
            p_vigente,
            p_id_giro,
            p_sup_construida,
            p_sup_autorizada,
            COALESCE(p_num_empleados, 0),
            p_fecha_otorgamiento;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT
                false,
                ('Error al actualizar empresa: ' || SQLERRM)::TEXT,
                NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
                NULL::INTEGER, NULL::TEXT, NULL::INTEGER, NULL::INTEGER,
                NULL::TEXT, NULL::INTEGER, NULL::NUMERIC, NULL::NUMERIC,
                NULL::INTEGER, NULL::DATE;
    END;

END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_empresas_update IS
'CRUD: Updates existing business/establishment with complete validation';

-- ============================================
-- SP 3/5: sp_empresas_delete
-- Type: CRUD Delete
-- Description: Realiza baja lógica de una empresa (marca vigente='N' y registra
--              fecha de baja). No elimina físicamente el registro para mantener
--              histórico y trazabilidad.
-- Returns: Confirmación de operación
-- Dependencies: Table empresas
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_empresas_delete(
    p_empresa INTEGER,
    p_axo_baja INTEGER DEFAULT NULL,
    p_folio_baja INTEGER DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    empresa INTEGER,
    propietario TEXT,
    rfc TEXT,
    fecha_baja DATE,
    axo_baja INTEGER,
    folio_baja INTEGER
) AS $$
/**
 * Function: sp_empresas_delete
 * Description: Performs logical deletion of a business (soft delete). Sets vigente='N'
 *              and records closure date and details. Physical record is preserved for
 *              historical tracking and audit trail.
 *
 * Parameters:
 *   @p_empresa - Business ID to delete (REQUIRED)
 *   @p_axo_baja - Closure year (OPTIONAL)
 *   @p_folio_baja - Closure folio number (OPTIONAL)
 *
 * Returns:
 *   - success: Operation success flag
 *   - message: Descriptive message
 *   - empresa: Business ID
 *   - propietario: Owner name
 *   - rfc: Tax ID
 *   - fecha_baja: Closure date (current date)
 *   - axo_baja: Closure year
 *   - folio_baja: Closure folio
 *
 * Business Logic:
 *   - Validates empresa exists and is active (vigente='S')
 *   - Performs soft delete (vigente='N')
 *   - Records fecha_baja as current date
 *   - Records axo_baja and folio_baja if provided
 *   - Preserves all historical data
 *
 * Validations:
 *   - empresa must exist
 *   - empresa must be active (vigente='S')
 *   - Cannot delete already deleted records
 *
 * Example Usage:
 *   -- Simple delete
 *   SELECT * FROM public.sp_empresas_delete(1001);
 *
 *   -- Delete with closure details
 *   SELECT * FROM public.sp_empresas_delete(1001, 2025, 1234);
 *
 * Indexes Required:
 *   - empresas(empresa) - PK index
 *   - empresas(vigente) - For active status checks
 */
DECLARE
    v_exists BOOLEAN;
    v_vigente TEXT;
    v_propietario TEXT;
    v_rfc TEXT;
BEGIN
    -- Validate empresa exists
    SELECT
        EXISTS(SELECT 1 FROM public.empresas WHERE empresa = p_empresa),
        (SELECT vigente FROM public.empresas WHERE empresa = p_empresa),
        (SELECT propietario FROM public.empresas WHERE empresa = p_empresa),
        (SELECT rfc FROM public.empresas WHERE empresa = p_empresa)
    INTO v_exists, v_vigente, v_propietario, v_rfc;

    IF NOT v_exists THEN
        RETURN QUERY SELECT
            false,
            ('Error: No existe empresa con ID ' || p_empresa)::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT,
            NULL::DATE, NULL::INTEGER, NULL::INTEGER;
        RETURN;
    END IF;

    -- Check if already deleted
    IF v_vigente = 'N' THEN
        RETURN QUERY SELECT
            false,
            'Error: La empresa ya está dada de baja'::TEXT,
            p_empresa, v_propietario, v_rfc,
            NULL::DATE, NULL::INTEGER, NULL::INTEGER;
        RETURN;
    END IF;

    -- Perform logical delete
    BEGIN
        UPDATE public.empresas SET
            vigente = 'N',
            fecha_baja = CURRENT_DATE,
            axo_baja = COALESCE(p_axo_baja, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER),
            folio_baja = p_folio_baja
        WHERE empresa = p_empresa;

        -- Return success
        RETURN QUERY
        SELECT
            true,
            'Empresa dada de baja exitosamente'::TEXT,
            p_empresa,
            v_propietario,
            v_rfc,
            CURRENT_DATE,
            COALESCE(p_axo_baja, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER),
            p_folio_baja;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT
                false,
                ('Error al dar de baja empresa: ' || SQLERRM)::TEXT,
                NULL::INTEGER, NULL::TEXT, NULL::TEXT,
                NULL::DATE, NULL::INTEGER, NULL::INTEGER;
    END;

END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_empresas_delete IS
'CRUD: Performs logical deletion (soft delete) of business with closure tracking';

-- ============================================
-- SP 4/5: sp_empresas_list
-- Type: Report/Query with Filters
-- Description: Lista empresas con múltiples filtros opcionales, paginación y ordenamiento.
--              Soporta búsqueda por propietario, RFC, ubicación, zona, giro y estado.
--              Incluye conteo total para implementación de paginación en UI.
-- Returns: Lista de empresas con campos relevantes y total count
-- Dependencies: Table empresas, c_giros (optional)
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_empresas_list(
    p_propietario TEXT DEFAULT NULL,
    p_rfc TEXT DEFAULT NULL,
    p_ubicacion TEXT DEFAULT NULL,
    p_colonia TEXT DEFAULT NULL,
    p_zona INTEGER DEFAULT NULL,
    p_subzona INTEGER DEFAULT NULL,
    p_id_giro INTEGER DEFAULT NULL,
    p_vigente TEXT DEFAULT NULL,
    p_bloqueado INTEGER DEFAULT NULL,
    p_limit INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0,
    p_order_by TEXT DEFAULT 'empresa',
    p_order_dir TEXT DEFAULT 'ASC'
)
RETURNS TABLE (
    total_count BIGINT,
    empresa INTEGER,
    propietario TEXT,
    rfc TEXT,
    curp TEXT,
    ubicacion TEXT,
    numext_ubic INTEGER,
    letraext_ubic TEXT,
    colonia_ubic TEXT,
    zona INTEGER,
    subzona INTEGER,
    recaud INTEGER,
    vigente TEXT,
    bloqueado INTEGER,
    id_giro INTEGER,
    sup_construida NUMERIC,
    sup_autorizada NUMERIC,
    num_empleados INTEGER,
    num_cajones INTEGER,
    aforo INTEGER,
    fecha_otorgamiento DATE,
    fecha_baja DATE,
    email TEXT,
    telefono_prop TEXT
) AS $$
/**
 * Function: sp_empresas_list
 * Description: Lists businesses with multiple optional filters, pagination, and sorting.
 *              Supports search by owner, RFC, location, zone, business category, and status.
 *              Returns total count for UI pagination implementation.
 *
 * Parameters:
 *   @p_propietario - Filter by owner name (partial match, case-insensitive)
 *   @p_rfc - Filter by RFC (partial match, case-insensitive)
 *   @p_ubicacion - Filter by establishment address (partial match)
 *   @p_colonia - Filter by neighborhood (partial match)
 *   @p_zona - Filter by zone (exact match)
 *   @p_subzona - Filter by subzone (exact match)
 *   @p_id_giro - Filter by business category (exact match)
 *   @p_vigente - Filter by active status ('S', 'N', or NULL for all)
 *   @p_bloqueado - Filter by blocked status (0, 1, or NULL for all)
 *   @p_limit - Maximum records to return (DEFAULT: 100)
 *   @p_offset - Records to skip for pagination (DEFAULT: 0)
 *   @p_order_by - Sort column (DEFAULT: 'empresa')
 *   @p_order_dir - Sort direction ('ASC' or 'DESC', DEFAULT: 'ASC')
 *
 * Returns:
 *   - total_count: Total matching records (for pagination)
 *   - empresa: Business ID
 *   - propietario: Owner name
 *   - rfc: Tax ID
 *   - curp: Personal ID
 *   - ubicacion: Establishment address
 *   - numext_ubic: External number
 *   - letraext_ubic: External letter
 *   - colonia_ubic: Neighborhood
 *   - zona: Zone code
 *   - subzona: Subzone code
 *   - recaud: Collection office
 *   - vigente: Active status
 *   - bloqueado: Blocked status
 *   - id_giro: Business category
 *   - sup_construida: Built area
 *   - sup_autorizada: Authorized area
 *   - num_empleados: Employee count
 *   - num_cajones: Parking spaces
 *   - aforo: Maximum capacity
 *   - fecha_otorgamiento: Grant date
 *   - fecha_baja: Closure date
 *   - email: Owner email
 *   - telefono_prop: Owner phone
 *
 * Business Logic:
 *   - All filters are optional (NULL = no filter)
 *   - Text filters use ILIKE for case-insensitive partial matching
 *   - Default limit of 100 records prevents excessive data transfer
 *   - Total count included in every row for pagination UI
 *   - Supports dynamic sorting by column and direction
 *
 * Example Usage:
 *   -- List all active businesses
 *   SELECT * FROM public.sp_empresas_list(p_vigente := 'S');
 *
 *   -- Search by owner name with pagination
 *   SELECT * FROM public.sp_empresas_list(
 *       p_propietario := 'Juan',
 *       p_limit := 20,
 *       p_offset := 0
 *   );
 *
 *   -- Filter by zone and giro
 *   SELECT * FROM public.sp_empresas_list(
 *       p_zona := 1,
 *       p_id_giro := 101,
 *       p_vigente := 'S'
 *   );
 *
 *   -- List all with custom sorting
 *   SELECT * FROM public.sp_empresas_list(
 *       p_order_by := 'propietario',
 *       p_order_dir := 'ASC',
 *       p_limit := 50
 *   );
 *
 * Indexes Required:
 *   - empresas(propietario) - Consider GIN/trigram for ILIKE
 *   - empresas(rfc) - For RFC searches
 *   - empresas(vigente) - For status filtering
 *   - empresas(bloqueado) - For blocked status filtering
 *   - empresas(zona, subzona) - Composite for geographic queries
 *   - empresas(id_giro) - For category filtering
 *   - empresas(fecha_otorgamiento) - For date-based queries
 */
DECLARE
    v_total_count BIGINT;
    v_query TEXT;
BEGIN
    -- Validate order_by to prevent SQL injection
    IF p_order_by NOT IN ('empresa', 'propietario', 'rfc', 'ubicacion', 'zona', 'subzona',
                          'vigente', 'fecha_otorgamiento', 'num_empleados') THEN
        p_order_by := 'empresa';
    END IF;

    -- Validate order_dir
    IF p_order_dir NOT IN ('ASC', 'DESC') THEN
        p_order_dir := 'ASC';
    END IF;

    -- Validate limit and offset
    IF p_limit IS NULL OR p_limit < 1 THEN
        p_limit := 100;
    END IF;

    IF p_limit > 1000 THEN
        p_limit := 1000; -- Maximum safety limit
    END IF;

    IF p_offset IS NULL OR p_offset < 0 THEN
        p_offset := 0;
    END IF;

    -- Get total count with filters
    SELECT COUNT(*) INTO v_total_count
    FROM public.empresas e
    WHERE (p_propietario IS NULL OR e.propietario ILIKE '%' || p_propietario || '%')
      AND (p_rfc IS NULL OR e.rfc ILIKE '%' || p_rfc || '%')
      AND (p_ubicacion IS NULL OR e.ubicacion ILIKE '%' || p_ubicacion || '%')
      AND (p_colonia IS NULL OR e.colonia_ubic ILIKE '%' || p_colonia || '%')
      AND (p_zona IS NULL OR e.zona = p_zona)
      AND (p_subzona IS NULL OR e.subzona = p_subzona)
      AND (p_id_giro IS NULL OR e.id_giro = p_id_giro)
      AND (p_vigente IS NULL OR e.vigente = p_vigente)
      AND (p_bloqueado IS NULL OR e.bloqueado = p_bloqueado);

    -- Return paginated results with total count
    RETURN QUERY EXECUTE format('
        SELECT
            %s::BIGINT as total_count,
            e.empresa,
            e.propietario,
            e.rfc,
            e.curp,
            e.ubicacion,
            e.numext_ubic,
            e.letraext_ubic,
            e.colonia_ubic,
            e.zona,
            e.subzona,
            e.recaud,
            e.vigente,
            e.bloqueado,
            e.id_giro,
            e.sup_construida,
            e.sup_autorizada,
            e.num_empleados,
            e.num_cajones,
            e.aforo,
            e.fecha_otorgamiento,
            e.fecha_baja,
            e.email,
            e.telefono_prop
        FROM public.empresas e
        WHERE ($1 IS NULL OR e.propietario ILIKE ''%%'' || $1 || ''%%'')
          AND ($2 IS NULL OR e.rfc ILIKE ''%%'' || $2 || ''%%'')
          AND ($3 IS NULL OR e.ubicacion ILIKE ''%%'' || $3 || ''%%'')
          AND ($4 IS NULL OR e.colonia_ubic ILIKE ''%%'' || $4 || ''%%'')
          AND ($5 IS NULL OR e.zona = $5)
          AND ($6 IS NULL OR e.subzona = $6)
          AND ($7 IS NULL OR e.id_giro = $7)
          AND ($8 IS NULL OR e.vigente = $8)
          AND ($9 IS NULL OR e.bloqueado = $9)
        ORDER BY %I %s
        LIMIT $10 OFFSET $11',
        v_total_count,
        p_order_by,
        p_order_dir
    ) USING p_propietario, p_rfc, p_ubicacion, p_colonia, p_zona, p_subzona,
            p_id_giro, p_vigente, p_bloqueado, p_limit, p_offset;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error listing empresas: %', SQLERRM;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION public.sp_empresas_list IS
'Report: Lists businesses with multiple filters, pagination, and sorting';

-- ============================================
-- SP 5/5: sp_empresas_estadisticas
-- Type: Statistics/Dashboard
-- Description: Genera estadísticas generales del catálogo de empresas incluyendo
--              totales por estado, zona, giro, y métricas operacionales.
--              Útil para dashboards y reportes ejecutivos.
-- Returns: JSON object con múltiples métricas estadísticas
-- Dependencies: Table empresas
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_empresas_estadisticas()
RETURNS TABLE (
    total_empresas BIGINT,
    empresas_activas BIGINT,
    empresas_inactivas BIGINT,
    empresas_bloqueadas BIGINT,
    total_empleados BIGINT,
    promedio_empleados NUMERIC,
    total_inversion NUMERIC,
    promedio_inversion NUMERIC,
    total_sup_construida NUMERIC,
    promedio_sup_construida NUMERIC,
    total_sup_autorizada NUMERIC,
    promedio_sup_autorizada NUMERIC,
    empresas_con_giro BIGINT,
    empresas_sin_giro BIGINT,
    empresas_con_ubicacion BIGINT,
    empresas_sin_ubicacion BIGINT,
    empresas_por_zona JSONB,
    empresas_por_subzona JSONB,
    empresas_por_giro JSONB,
    empresas_recientes_30dias BIGINT,
    empresas_bajas_30dias BIGINT
) AS $$
/**
 * Function: sp_empresas_estadisticas
 * Description: Generates comprehensive statistics for the business catalog including
 *              totals by status, zone, business category, and operational metrics.
 *              Useful for dashboards and executive reports.
 *
 * Parameters: None
 *
 * Returns:
 *   - total_empresas: Total business count
 *   - empresas_activas: Active businesses (vigente='S')
 *   - empresas_inactivas: Inactive businesses (vigente='N')
 *   - empresas_bloqueadas: Blocked businesses
 *   - total_empleados: Sum of all employees
 *   - promedio_empleados: Average employees per business
 *   - total_inversion: Total investment amount
 *   - promedio_inversion: Average investment per business
 *   - total_sup_construida: Total built area (m2)
 *   - promedio_sup_construida: Average built area per business
 *   - total_sup_autorizada: Total authorized area (m2)
 *   - promedio_sup_autorizada: Average authorized area per business
 *   - empresas_con_giro: Businesses with category assigned
 *   - empresas_sin_giro: Businesses without category
 *   - empresas_con_ubicacion: Businesses with location data
 *   - empresas_sin_ubicacion: Businesses without location
 *   - empresas_por_zona: Breakdown by zone (JSONB array)
 *   - empresas_por_subzona: Breakdown by subzone (JSONB array)
 *   - empresas_por_giro: Breakdown by business category (JSONB array)
 *   - empresas_recientes_30dias: New businesses in last 30 days
 *   - empresas_bajas_30dias: Closures in last 30 days
 *
 * Business Logic:
 *   - Aggregates data across multiple dimensions
 *   - Calculates averages only for non-zero values
 *   - Groups by zone, subzone, and business category
 *   - Includes time-based metrics (last 30 days)
 *   - Returns structured JSONB for complex groupings
 *
 * Example Usage:
 *   SELECT * FROM public.sp_empresas_estadisticas();
 *
 *   -- Extract specific metrics
 *   SELECT
 *       total_empresas,
 *       empresas_activas,
 *       promedio_empleados,
 *       empresas_por_zona
 *   FROM public.sp_empresas_estadisticas();
 *
 * Performance Notes:
 *   - Uses aggregate functions on full table
 *   - Consider materialized view for large datasets
 *   - JSONB aggregation may be expensive for many groups
 *
 * Indexes Required:
 *   - empresas(vigente) - For status aggregations
 *   - empresas(bloqueado) - For blocked count
 *   - empresas(zona) - For zone grouping
 *   - empresas(subzona) - For subzone grouping
 *   - empresas(id_giro) - For category grouping
 *   - empresas(fecha_otorgamiento) - For time-based queries
 *   - empresas(fecha_baja) - For closure metrics
 */
BEGIN
    RETURN QUERY
    WITH stats AS (
        SELECT
            COUNT(*) as total,
            COUNT(*) FILTER (WHERE vigente = 'S') as activas,
            COUNT(*) FILTER (WHERE vigente = 'N') as inactivas,
            COUNT(*) FILTER (WHERE bloqueado = 1) as bloqueadas,
            COALESCE(SUM(num_empleados), 0) as sum_empleados,
            COALESCE(AVG(NULLIF(num_empleados, 0)), 0) as avg_empleados,
            COALESCE(SUM(inversion), 0) as sum_inversion,
            COALESCE(AVG(NULLIF(inversion, 0)), 0) as avg_inversion,
            COALESCE(SUM(sup_construida), 0) as sum_sup_const,
            COALESCE(AVG(NULLIF(sup_construida, 0)), 0) as avg_sup_const,
            COALESCE(SUM(sup_autorizada), 0) as sum_sup_auto,
            COALESCE(AVG(NULLIF(sup_autorizada, 0)), 0) as avg_sup_auto,
            COUNT(*) FILTER (WHERE id_giro IS NOT NULL) as con_giro,
            COUNT(*) FILTER (WHERE id_giro IS NULL) as sin_giro,
            COUNT(*) FILTER (WHERE ubicacion IS NOT NULL AND ubicacion != '') as con_ubicacion,
            COUNT(*) FILTER (WHERE ubicacion IS NULL OR ubicacion = '') as sin_ubicacion,
            COUNT(*) FILTER (WHERE fecha_otorgamiento >= CURRENT_DATE - INTERVAL '30 days') as recientes_30d,
            COUNT(*) FILTER (WHERE fecha_baja >= CURRENT_DATE - INTERVAL '30 days') as bajas_30d
        FROM public.empresas
    ),
    por_zona AS (
        SELECT jsonb_agg(
            jsonb_build_object(
                'zona', COALESCE(zona, 0),
                'total', count,
                'activas', activas
            ) ORDER BY zona
        ) as zona_data
        FROM (
            SELECT
                zona,
                COUNT(*) as count,
                COUNT(*) FILTER (WHERE vigente = 'S') as activas
            FROM public.empresas
            WHERE zona IS NOT NULL
            GROUP BY zona
        ) z
    ),
    por_subzona AS (
        SELECT jsonb_agg(
            jsonb_build_object(
                'zona', COALESCE(zona, 0),
                'subzona', COALESCE(subzona, 0),
                'total', count,
                'activas', activas
            ) ORDER BY zona, subzona
        ) as subzona_data
        FROM (
            SELECT
                zona,
                subzona,
                COUNT(*) as count,
                COUNT(*) FILTER (WHERE vigente = 'S') as activas
            FROM public.empresas
            WHERE subzona IS NOT NULL
            GROUP BY zona, subzona
        ) s
    ),
    por_giro AS (
        SELECT jsonb_agg(
            jsonb_build_object(
                'id_giro', id_giro,
                'total', count,
                'activas', activas
            ) ORDER BY count DESC
        ) as giro_data
        FROM (
            SELECT
                id_giro,
                COUNT(*) as count,
                COUNT(*) FILTER (WHERE vigente = 'S') as activas
            FROM public.empresas
            WHERE id_giro IS NOT NULL
            GROUP BY id_giro
        ) g
    )
    SELECT
        s.total,
        s.activas,
        s.inactivas,
        s.bloqueadas,
        s.sum_empleados,
        ROUND(s.avg_empleados, 2),
        ROUND(s.sum_inversion, 2),
        ROUND(s.avg_inversion, 2),
        ROUND(s.sum_sup_const, 2),
        ROUND(s.avg_sup_const, 2),
        ROUND(s.sum_sup_auto, 2),
        ROUND(s.avg_sup_auto, 2),
        s.con_giro,
        s.sin_giro,
        s.con_ubicacion,
        s.sin_ubicacion,
        COALESCE(z.zona_data, '[]'::JSONB),
        COALESCE(sz.subzona_data, '[]'::JSONB),
        COALESCE(g.giro_data, '[]'::JSONB),
        s.recientes_30d,
        s.bajas_30d
    FROM stats s
    CROSS JOIN por_zona z
    CROSS JOIN por_subzona sz
    CROSS JOIN por_giro g;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error generating statistics: %', SQLERRM;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION public.sp_empresas_estadisticas IS
'Statistics: Generates comprehensive dashboard metrics for business catalog';

-- ============================================
-- RECOMMENDED INDEXES
-- ============================================
-- Execute these CREATE INDEX statements to optimize query performance:
/*
-- Primary Key (usually auto-created)
CREATE UNIQUE INDEX IF NOT EXISTS idx_empresas_pk ON public.empresas(empresa);

-- RFC searches and uniqueness (critical for create/update)
CREATE INDEX IF NOT EXISTS idx_empresas_rfc ON public.empresas(UPPER(rfc));
CREATE INDEX IF NOT EXISTS idx_empresas_rfc_vigente ON public.empresas(UPPER(rfc), vigente);

-- Owner name searches (consider trigram extension for better ILIKE performance)
CREATE INDEX IF NOT EXISTS idx_empresas_propietario ON public.empresas USING gin(propietario gin_trgm_ops);
-- Alternative without trigram: CREATE INDEX idx_empresas_propietario ON public.empresas(propietario);

-- Status filtering (critical for list and statistics)
CREATE INDEX IF NOT EXISTS idx_empresas_vigente ON public.empresas(vigente);
CREATE INDEX IF NOT EXISTS idx_empresas_bloqueado ON public.empresas(bloqueado);

-- Geographic queries
CREATE INDEX IF NOT EXISTS idx_empresas_zona_subzona ON public.empresas(zona, subzona);
CREATE INDEX IF NOT EXISTS idx_empresas_zona ON public.empresas(zona) WHERE zona IS NOT NULL;

-- Business category filtering
CREATE INDEX IF NOT EXISTS idx_empresas_id_giro ON public.empresas(id_giro) WHERE id_giro IS NOT NULL;

-- Foreign keys
CREATE INDEX IF NOT EXISTS idx_empresas_cvecuenta ON public.empresas(cvecuenta) WHERE cvecuenta IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_empresas_cvecalle ON public.empresas(cvecalle) WHERE cvecalle IS NOT NULL;

-- Location searches
CREATE INDEX IF NOT EXISTS idx_empresas_ubicacion ON public.empresas USING gin(ubicacion gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_empresas_colonia_ubic ON public.empresas(colonia_ubic);

-- Date-based queries
CREATE INDEX IF NOT EXISTS idx_empresas_fecha_otorgamiento ON public.empresas(fecha_otorgamiento) WHERE fecha_otorgamiento IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_empresas_fecha_baja ON public.empresas(fecha_baja) WHERE fecha_baja IS NOT NULL;

-- Composite for common filters
CREATE INDEX IF NOT EXISTS idx_empresas_vigente_zona_giro ON public.empresas(vigente, zona, id_giro);

-- Email searches (if needed)
CREATE INDEX IF NOT EXISTS idx_empresas_email ON public.empresas(LOWER(email)) WHERE email IS NOT NULL AND email != '';

-- Geographic coordinates (if using spatial queries)
CREATE INDEX IF NOT EXISTS idx_empresas_coordinates ON public.empresas(x, y) WHERE x IS NOT NULL AND y IS NOT NULL;
*/

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Use these queries to verify the stored procedures are working correctly:

-- Test 1: Create new empresa with minimal fields
/*
SELECT * FROM public.sp_empresas_create(
    'Test Propietario ABC',
    'TST123456789'
);
*/

-- Test 2: Create empresa with all fields
/*
SELECT * FROM public.sp_empresas_create(
    'Juan Perez Martinez',
    'JPM850101ABC',
    'PEMJ850101HJCRNS01',
    'Av. Juarez 123',
    123, 'A', 'Centro', '3312345678', 'juan@example.com',
    1500, 'Av. Hidalgo 456', 456, 'B', '2', 'C', 'Americana',
    150.50, 200.00, 5, 10, 50, 250000.00,
    'Lun-Vie 9:00-18:00', '2025-01-15', 0, 12345, 'S',
    NULL, NULL, NULL, 'LOCAL', 50000.00,
    1, 2, 3, '2025-01-20', 101,
    -103.123456, 20.654321, 987654, 44100
);
*/

-- Test 3: Update existing empresa
/*
SELECT * FROM public.sp_empresas_update(
    1001, -- empresa ID
    'Juan Perez Martinez UPDATED',
    'JPM850101ABC',
    'PEMJ850101HJCRNS01',
    'Av. Juarez 123',
    123, 'A', 'Centro', '3312345678', 'juan.updated@example.com',
    1500, 'Av. Hidalgo 456', 456, 'B', '2', 'C', 'Americana',
    180.75, 220.00, 8, 15, 60, 350000.00,
    'Lun-Sab 9:00-20:00', '2025-01-15', 0, 12345, 'S',
    NULL, NULL, NULL, 'LOCAL', 60000.00,
    1, 2, 3, '2025-01-20', 101,
    -103.123456, 20.654321, 987654, 44100
);
*/

-- Test 4: List all active empresas
/*
SELECT * FROM public.sp_empresas_list(p_vigente := 'S', p_limit := 20);
*/

-- Test 5: Search empresas by propietario
/*
SELECT * FROM public.sp_empresas_list(p_propietario := 'Juan', p_limit := 10);
*/

-- Test 6: Filter by zona and giro
/*
SELECT * FROM public.sp_empresas_list(
    p_zona := 1,
    p_id_giro := 101,
    p_vigente := 'S',
    p_limit := 50
);
*/

-- Test 7: Get statistics
/*
SELECT * FROM public.sp_empresas_estadisticas();
*/

-- Test 8: Delete (soft delete) empresa
/*
SELECT * FROM public.sp_empresas_delete(1001, 2025, 1234);
*/

-- Test 9: Verify RFC validation (should fail)
/*
SELECT * FROM public.sp_empresas_create(
    'Test Invalid RFC',
    'INVALID' -- Too short
);
*/

-- Test 10: Verify duplicate RFC (should fail if RFC exists)
/*
SELECT * FROM public.sp_empresas_create(
    'Test Duplicate',
    'JPM850101ABC' -- Use existing RFC
);
*/

-- ============================================
-- END OF STORED PROCEDURES IMPLEMENTATION
-- Component: empresasfrm
-- Total: 5 stored procedures
-- Status: READY FOR DEPLOYMENT
-- ============================================
