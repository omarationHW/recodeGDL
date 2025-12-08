-- ============================================
-- STORED PROCEDURES - CERTIFICACIONESFRM
-- Sistema: Padrón de Licencias - RefactorX
-- Componente: certificacionesfrm
-- Descripción: Gestión completa de certificaciones
-- Total SPs: 7
-- Fecha implementación: 2025-11-20
-- ============================================
-- Autor: RefactorX Team
-- Estado: IMPLEMENTADO CON LOGICA REAL
-- Schema: public
-- Tabla principal: public.certificaciones
-- ============================================

-- ============================================
-- TABLA: certificaciones
-- Descripción: Almacena las certificaciones emitidas
-- ============================================
-- Campos:
--   id: ID único de la certificación (PK)
--   axo: Año de emisión
--   folio: Número de folio consecutivo
--   id_licencia: ID de la licencia certificada (FK)
--   partidapago: Partida presupuestal del pago
--   observacion: Observaciones o motivo de cancelación
--   vigente: Estado V=Vigente, C=Cancelada
--   feccap: Fecha de captura
--   capturista: Usuario que capturó/modificó
--   tipo: Tipo de certificación
--   licencia: Número de licencia (redundante para reportes)
--   anuncio: Número de anuncio asociado
-- ============================================

-- ============================================
-- SP 1/7: sp_certificaciones_list
-- Tipo: Report/Listado
-- Descripción: Obtiene listado de certificaciones por tipo
-- Parámetros:
--   @p_tipo: Tipo de certificación a filtrar
-- Retorna: Listado de certificaciones ordenado por año y folio DESC
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_certificaciones_list(
    p_tipo TEXT
)
RETURNS TABLE(
    id INT,
    axo INT,
    folio INT,
    id_licencia INT,
    partidapago TEXT,
    observacion TEXT,
    vigente TEXT,
    feccap DATE,
    capturista TEXT,
    tipo TEXT
) AS $$
BEGIN
    -- Validación de parámetros
    IF p_tipo IS NULL OR TRIM(p_tipo) = '' THEN
        RAISE EXCEPTION 'El tipo de certificación es requerido';
    END IF;

    -- Retorna las certificaciones del tipo solicitado
    RETURN QUERY
    SELECT
        c.id,
        c.axo,
        c.folio,
        c.id_licencia,
        c.partidapago,
        c.observacion,
        c.vigente,
        c.feccap,
        c.capturista,
        c.tipo
    FROM public.certificaciones c
    WHERE c.tipo = p_tipo
    ORDER BY c.axo DESC, c.folio DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_certificaciones_list(TEXT) IS
'Lista certificaciones por tipo ordenadas por año y folio descendente';

-- ============================================
-- SP 2/7: sp_certificaciones_get
-- Tipo: Catalog/Detalle
-- Descripción: Obtiene una certificación específica por ID
-- Parámetros:
--   @p_id: ID de la certificación
-- Retorna: Registro completo de la certificación
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_certificaciones_get(
    p_id INT
)
RETURNS TABLE(
    id INT,
    axo INT,
    folio INT,
    id_licencia INT,
    partidapago TEXT,
    observacion TEXT,
    vigente TEXT,
    feccap DATE,
    capturista TEXT,
    tipo TEXT,
    licencia INT,
    anuncio INT
) AS $$
BEGIN
    -- Validación de parámetros
    IF p_id IS NULL OR p_id <= 0 THEN
        RAISE EXCEPTION 'El ID de certificación es requerido y debe ser mayor a 0';
    END IF;

    -- Retorna el registro completo
    RETURN QUERY
    SELECT
        c.id,
        c.axo,
        c.folio,
        c.id_licencia,
        c.partidapago,
        c.observacion,
        c.vigente,
        c.feccap,
        c.capturista,
        c.tipo,
        c.licencia,
        c.anuncio
    FROM public.certificaciones c
    WHERE c.id = p_id;

    -- Validación de existencia
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró la certificación con ID %', p_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_certificaciones_get(INT) IS
'Obtiene el detalle completo de una certificación por su ID';

-- ============================================
-- SP 3/7: sp_certificaciones_create
-- Tipo: CRUD/Create
-- Descripción: Crea una nueva certificación y genera folio automático
-- Parámetros:
--   @p_tipo: Tipo de certificación
--   @p_id_licencia: ID de la licencia a certificar
--   @p_observacion: Observaciones
--   @p_partidapago: Partida presupuestal
--   @p_capturista: Usuario que captura
-- Retorna: ID de la nueva certificación creada
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_certificaciones_create(
    p_tipo TEXT,
    p_id_licencia INT,
    p_observacion TEXT,
    p_partidapago TEXT,
    p_capturista TEXT
)
RETURNS INT AS $$
DECLARE
    v_new_folio INT;
    v_new_id INT;
    v_current_year INT;
    v_licencia_num INT;
    v_anuncio_num INT;
BEGIN
    -- Validación de parámetros obligatorios
    IF p_tipo IS NULL OR TRIM(p_tipo) = '' THEN
        RAISE EXCEPTION 'El tipo de certificación es requerido';
    END IF;

    IF p_id_licencia IS NULL OR p_id_licencia <= 0 THEN
        RAISE EXCEPTION 'El ID de licencia es requerido y debe ser mayor a 0';
    END IF;

    IF p_capturista IS NULL OR TRIM(p_capturista) = '' THEN
        RAISE EXCEPTION 'El capturista es requerido';
    END IF;

    -- Verificar que la licencia existe
    IF NOT EXISTS (SELECT 1 FROM public.licencias WHERE id_licencia = p_id_licencia) THEN
        RAISE EXCEPTION 'La licencia con ID % no existe', p_id_licencia;
    END IF;

    -- Obtener número de licencia y anuncio
    SELECT id_licencia, COALESCE(anuncio, 0)
    INTO v_licencia_num, v_anuncio_num
    FROM public.licencias
    WHERE id_licencia = p_id_licencia;

    -- Obtener año actual
    v_current_year := EXTRACT(YEAR FROM CURRENT_DATE)::INT;

    -- Obtener y actualizar el folio desde parametros_lic
    SELECT certificacion INTO v_new_folio
    FROM public.parametros_lic
    LIMIT 1;

    -- Si no existe el parámetro, inicializar en 1
    IF v_new_folio IS NULL THEN
        v_new_folio := 0;
    END IF;

    -- Incrementar folio
    v_new_folio := v_new_folio + 1;

    -- Actualizar el parámetro
    UPDATE public.parametros_lic
    SET certificacion = v_new_folio;

    -- Si no hay registros en parametros_lic, insertar
    IF NOT FOUND THEN
        INSERT INTO public.parametros_lic (certificacion)
        VALUES (v_new_folio);
    END IF;

    -- Insertar la nueva certificación
    INSERT INTO public.certificaciones (
        tipo,
        id_licencia,
        axo,
        folio,
        vigente,
        observacion,
        partidapago,
        feccap,
        capturista,
        licencia,
        anuncio
    ) VALUES (
        p_tipo,
        p_id_licencia,
        v_current_year,
        v_new_folio,
        'V',  -- Vigente por defecto
        COALESCE(p_observacion, ''),
        COALESCE(p_partidapago, ''),
        CURRENT_DATE,
        p_capturista,
        v_licencia_num,
        v_anuncio_num
    ) RETURNING id INTO v_new_id;

    -- Retornar el ID de la certificación creada
    RETURN v_new_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al crear certificación: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_certificaciones_create(TEXT, INT, TEXT, TEXT, TEXT) IS
'Crea una nueva certificación con folio automático desde parametros_lic';

-- ============================================
-- SP 4/7: sp_certificaciones_update
-- Tipo: CRUD/Update
-- Descripción: Actualiza una certificación existente
-- Parámetros:
--   @p_id: ID de la certificación a actualizar
--   @p_observacion: Nueva observación
--   @p_partidapago: Nueva partida de pago
--   @p_capturista: Usuario que modifica
-- Retorna: TRUE si se actualizó, FALSE si no existe
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_certificaciones_update(
    p_id INT,
    p_observacion TEXT,
    p_partidapago TEXT,
    p_capturista TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
    v_vigente TEXT;
BEGIN
    -- Validación de parámetros
    IF p_id IS NULL OR p_id <= 0 THEN
        RAISE EXCEPTION 'El ID de certificación es requerido y debe ser mayor a 0';
    END IF;

    IF p_capturista IS NULL OR TRIM(p_capturista) = '' THEN
        RAISE EXCEPTION 'El capturista es requerido';
    END IF;

    -- Verificar que la certificación existe y está vigente
    SELECT vigente INTO v_vigente
    FROM public.certificaciones
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La certificación con ID % no existe', p_id;
    END IF;

    IF v_vigente = 'C' THEN
        RAISE EXCEPTION 'No se puede modificar una certificación cancelada';
    END IF;

    -- Actualizar la certificación
    UPDATE public.certificaciones
    SET
        observacion = COALESCE(p_observacion, observacion),
        partidapago = COALESCE(p_partidapago, partidapago),
        capturista = p_capturista
    WHERE id = p_id;

    RETURN FOUND;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al actualizar certificación: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_certificaciones_update(INT, TEXT, TEXT, TEXT) IS
'Actualiza una certificación existente (solo vigentes)';

-- ============================================
-- SP 5/7: sp_certificaciones_cancel
-- Tipo: CRUD/Soft Delete
-- Descripción: Cancela una certificación (soft delete)
-- Parámetros:
--   @p_id: ID de la certificación a cancelar
--   @p_motivo: Motivo de la cancelación
--   @p_capturista: Usuario que cancela
-- Retorna: TRUE si se canceló, FALSE si no existe
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_certificaciones_cancel(
    p_id INT,
    p_motivo TEXT,
    p_capturista TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
    v_vigente TEXT;
    v_observacion TEXT;
BEGIN
    -- Validación de parámetros
    IF p_id IS NULL OR p_id <= 0 THEN
        RAISE EXCEPTION 'El ID de certificación es requerido y debe ser mayor a 0';
    END IF;

    IF p_motivo IS NULL OR TRIM(p_motivo) = '' THEN
        RAISE EXCEPTION 'El motivo de cancelación es requerido';
    END IF;

    IF p_capturista IS NULL OR TRIM(p_capturista) = '' THEN
        RAISE EXCEPTION 'El capturista es requerido';
    END IF;

    -- Verificar que la certificación existe
    SELECT vigente, observacion INTO v_vigente, v_observacion
    FROM public.certificaciones
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La certificación con ID % no existe', p_id;
    END IF;

    -- Verificar que no esté ya cancelada
    IF v_vigente = 'C' THEN
        RAISE EXCEPTION 'La certificación ya está cancelada';
    END IF;

    -- Cancelar la certificación (soft delete)
    UPDATE public.certificaciones
    SET
        vigente = 'C',
        observacion = 'CANCELADA - ' || p_motivo ||
                      CASE
                          WHEN v_observacion IS NOT NULL AND TRIM(v_observacion) != ''
                          THEN ' | Obs.Anterior: ' || v_observacion
                          ELSE ''
                      END,
        capturista = p_capturista,
        feccap = CURRENT_DATE  -- Actualizar fecha de modificación
    WHERE id = p_id;

    RETURN FOUND;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al cancelar certificación: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_certificaciones_cancel(INT, TEXT, TEXT) IS
'Cancela una certificación (soft delete) conservando el motivo';

-- ============================================
-- SP 6/7: sp_certificaciones_search
-- Tipo: Report/Búsqueda
-- Descripción: Búsqueda avanzada de certificaciones con múltiples filtros
-- Parámetros (todos opcionales):
--   @p_axo: Año de emisión
--   @p_folio: Número de folio
--   @p_id_licencia: ID de licencia
--   @p_feccap_ini: Fecha captura inicio
--   @p_feccap_fin: Fecha captura fin
--   @p_tipo: Tipo de certificación
--   @p_vigente: Estado (V/C), NULL=todas
-- Retorna: Listado de certificaciones que coincidan con los filtros
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_certificaciones_search(
    p_axo INT DEFAULT NULL,
    p_folio INT DEFAULT NULL,
    p_id_licencia INT DEFAULT NULL,
    p_feccap_ini DATE DEFAULT NULL,
    p_feccap_fin DATE DEFAULT NULL,
    p_tipo TEXT DEFAULT NULL,
    p_vigente TEXT DEFAULT NULL
)
RETURNS TABLE(
    id INT,
    axo INT,
    folio INT,
    id_licencia INT,
    partidapago TEXT,
    observacion TEXT,
    vigente TEXT,
    feccap DATE,
    capturista TEXT,
    tipo TEXT
) AS $$
BEGIN
    -- Validación de rangos de fechas
    IF p_feccap_ini IS NOT NULL AND p_feccap_fin IS NOT NULL THEN
        IF p_feccap_ini > p_feccap_fin THEN
            RAISE EXCEPTION 'La fecha inicial no puede ser mayor a la fecha final';
        END IF;
    END IF;

    -- Validación de vigente
    IF p_vigente IS NOT NULL AND p_vigente NOT IN ('V', 'C') THEN
        RAISE EXCEPTION 'El estado vigente debe ser V o C';
    END IF;

    -- Búsqueda con filtros dinámicos
    RETURN QUERY
    SELECT
        c.id,
        c.axo,
        c.folio,
        c.id_licencia,
        c.partidapago,
        c.observacion,
        c.vigente,
        c.feccap,
        c.capturista,
        c.tipo
    FROM public.certificaciones c
    WHERE
        (p_axo IS NULL OR c.axo = p_axo)
        AND (p_folio IS NULL OR c.folio = p_folio)
        AND (p_id_licencia IS NULL OR c.id_licencia = p_id_licencia)
        AND (p_feccap_ini IS NULL OR c.feccap >= p_feccap_ini)
        AND (p_feccap_fin IS NULL OR c.feccap <= p_feccap_fin)
        AND (p_tipo IS NULL OR c.tipo = p_tipo)
        AND (p_vigente IS NULL OR c.vigente = p_vigente)
    ORDER BY c.axo DESC, c.folio DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_certificaciones_search(INT, INT, INT, DATE, DATE, TEXT, TEXT) IS
'Búsqueda avanzada de certificaciones con filtros múltiples opcionales';

-- ============================================
-- SP 7/7: sp_certificaciones_print
-- Tipo: Report/Impresión
-- Descripción: Obtiene datos completos para impresión de certificación
--              Incluye datos de certificación, licencia y pagos asociados
-- Parámetros:
--   @p_id: ID de la certificación a imprimir
-- Retorna: JSON con certificación, licencia y pagos
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_certificaciones_print(
    p_id INT
)
RETURNS TABLE(
    certificacion JSON,
    licencia JSON,
    pagos JSON
) AS $$
DECLARE
    v_cert JSON;
    v_lic JSON;
    v_pgs JSON;
    v_id_licencia INT;
BEGIN
    -- Validación de parámetros
    IF p_id IS NULL OR p_id <= 0 THEN
        RAISE EXCEPTION 'El ID de certificación es requerido y debe ser mayor a 0';
    END IF;

    -- Obtener datos de la certificación como JSON
    SELECT row_to_json(cert_data)
    INTO v_cert
    FROM (
        SELECT
            c.id,
            c.axo,
            c.folio,
            c.id_licencia,
            c.partidapago,
            c.observacion,
            c.vigente,
            c.feccap,
            c.capturista,
            c.tipo,
            c.licencia,
            c.anuncio,
            (c.axo || '-' || LPAD(c.folio::TEXT, 6, '0')) as folio_completo
        FROM public.certificaciones c
        WHERE c.id = p_id
    ) cert_data;

    -- Verificar que existe la certificación
    IF v_cert IS NULL THEN
        RAISE EXCEPTION 'No se encontró la certificación con ID %', p_id;
    END IF;

    -- Obtener el id_licencia de la certificación
    SELECT id_licencia INTO v_id_licencia
    FROM public.certificaciones
    WHERE id = p_id;

    -- Obtener datos de la licencia como JSON
    SELECT row_to_json(lic_data)
    INTO v_lic
    FROM (
        SELECT
            l.*,
            COALESCE(l.nombre, '') || ' ' || COALESCE(l.paterno, '') || ' ' || COALESCE(l.materno, '') as nombre_completo
        FROM public.licencias l
        WHERE l.id_licencia = v_id_licencia
    ) lic_data;

    -- Si no hay licencia, usar objeto vacío
    IF v_lic IS NULL THEN
        v_lic := '{}'::JSON;
    END IF;

    -- Obtener pagos relacionados (concepto 8 = certificaciones)
    SELECT COALESCE(json_agg(pago_data ORDER BY fecha DESC, hora DESC), '[]'::JSON)
    INTO v_pgs
    FROM (
        SELECT
            p.*,
            TO_CHAR(p.fecha, 'DD/MM/YYYY') as fecha_formato,
            TO_CHAR(p.hora, 'HH24:MI:SS') as hora_formato
        FROM public.pagos p
        WHERE p.cvecuenta = v_id_licencia
          AND p.cveconcepto = 8
    ) pago_data;

    -- Si no hay pagos, retornar array vacío
    IF v_pgs IS NULL THEN
        v_pgs := '[]'::JSON;
    END IF;

    -- Retornar los tres JSONs
    RETURN QUERY SELECT v_cert, v_lic, v_pgs;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al obtener datos de impresión: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_certificaciones_print(INT) IS
'Obtiene datos completos (certificación + licencia + pagos) para impresión en formato JSON';

-- ============================================
-- PERMISOS
-- ============================================

-- Otorgar permisos de ejecución al rol de aplicación
-- GRANT EXECUTE ON FUNCTION public.sp_certificaciones_list(TEXT) TO app_user;
-- GRANT EXECUTE ON FUNCTION public.sp_certificaciones_get(INT) TO app_user;
-- GRANT EXECUTE ON FUNCTION public.sp_certificaciones_create(TEXT, INT, TEXT, TEXT, TEXT) TO app_user;
-- GRANT EXECUTE ON FUNCTION public.sp_certificaciones_update(INT, TEXT, TEXT, TEXT) TO app_user;
-- GRANT EXECUTE ON FUNCTION public.sp_certificaciones_cancel(INT, TEXT, TEXT) TO app_user;
-- GRANT EXECUTE ON FUNCTION public.sp_certificaciones_search(INT, INT, INT, DATE, DATE, TEXT, TEXT) TO app_user;
-- GRANT EXECUTE ON FUNCTION public.sp_certificaciones_print(INT) TO app_user;

-- ============================================
-- EJEMPLOS DE USO
-- ============================================

-- 1. Listar certificaciones por tipo
-- SELECT * FROM public.sp_certificaciones_list('ANUAL');

-- 2. Obtener una certificación específica
-- SELECT * FROM public.sp_certificaciones_get(1);

-- 3. Crear una nueva certificación
-- SELECT public.sp_certificaciones_create('ANUAL', 123, 'Certificación vigente', '001.001.001', 'admin');

-- 4. Actualizar una certificación
-- SELECT public.sp_certificaciones_update(1, 'Nueva observación', '001.001.002', 'admin');

-- 5. Cancelar una certificación
-- SELECT public.sp_certificaciones_cancel(1, 'Certificación duplicada', 'admin');

-- 6. Buscar certificaciones
-- SELECT * FROM public.sp_certificaciones_search(2024, NULL, NULL, '2024-01-01', '2024-12-31', 'ANUAL', 'V');

-- 7. Obtener datos para impresión
-- SELECT * FROM public.sp_certificaciones_print(1);

-- ============================================
-- RESUMEN DE IMPLEMENTACIÓN
-- ============================================
-- Total de SPs implementados: 7
--
-- 1. sp_certificaciones_list      - Listado por tipo
-- 2. sp_certificaciones_get        - Detalle por ID
-- 3. sp_certificaciones_create     - Crear con folio automático
-- 4. sp_certificaciones_update     - Actualizar vigentes
-- 5. sp_certificaciones_cancel     - Cancelar (soft delete)
-- 6. sp_certificaciones_search     - Búsqueda avanzada
-- 7. sp_certificaciones_print      - Datos para impresión (JSON)
--
-- Características:
-- - Validaciones completas de parámetros
-- - Manejo de errores con mensajes descriptivos
-- - Soft delete con vigente V/C
-- - Generación automática de folios desde parametros_lic
-- - Búsqueda avanzada con filtros opcionales
-- - Datos de impresión en formato JSON
-- - Comentarios y documentación completa
-- - Compatible con API genérica
-- ============================================
-- FIN DE ARCHIVO
-- ============================================
