-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Componente: formatosEcologiafrm
-- Módulo: padron_licencias
-- Fecha de implementación: 2025-11-20
-- Total SPs: 3
-- ============================================
-- DESCRIPCIÓN:
-- Módulo para la generación de formatos de ecología relacionados con trámites.
-- Incluye consultas para obtener información de trámites y cruces de calles
-- necesarios para la impresión de documentos oficiales de ecología.
--
-- TABLAS PRINCIPALES:
-- - tramites: Tabla principal de trámites de licencias
-- - crucecalles: Tabla de cruces de calles por trámite
-- - c_calles: Catálogo de calles del municipio
--
-- CARACTERÍSTICAS:
-- - Campos calculados: domicilio completo, propietario completo
-- - Soporte para coordenadas geográficas (x, y)
-- - Información completa de ubicación y propietario
-- - Integración con catálogo de calles para cruces
-- ============================================

-- ============================================
-- SP 1/3: sp_get_tramite_by_id
-- Tipo: Consulta (Report)
-- Descripción: Obtiene los datos completos de un trámite específico por su ID,
--              incluyendo campos calculados como domicilio completo y nombre
--              completo del propietario. Usado para generar formatos de ecología.
-- Parámetros:
--   p_id_tramite: ID del trámite a consultar (requerido)
-- Retorna: Registro completo del trámite con campos calculados
-- ============================================

CREATE OR REPLACE FUNCTION sp_get_tramite_by_id(
    p_id_tramite INTEGER
)
RETURNS TABLE (
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR,
    id_giro INTEGER,
    x DOUBLE PRECISION,
    y DOUBLE PRECISION,
    zona SMALLINT,
    subzona SMALLINT,
    actividad VARCHAR,
    cvecuenta INTEGER,
    recaud SMALLINT,
    licencia_ref INTEGER,
    tramita_apoderado VARCHAR,
    propietario VARCHAR,
    primer_ap VARCHAR,
    segundo_ap VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    domicilio VARCHAR,
    numext_prop INTEGER,
    numint_prop VARCHAR,
    colonia_prop VARCHAR,
    telefono_prop VARCHAR,
    email VARCHAR,
    cvecalle INTEGER,
    ubicacion VARCHAR,
    numext_ubic INTEGER,
    letraext_ubic VARCHAR,
    letraint_ubic VARCHAR,
    colonia_ubic VARCHAR,
    espubic VARCHAR,
    documentos TEXT,
    sup_construida DOUBLE PRECISION,
    sup_autorizada DOUBLE PRECISION,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC,
    costo NUMERIC,
    fecha_consejo DATE,
    id_fabricante INTEGER,
    texto_anuncio VARCHAR,
    medidas1 DOUBLE PRECISION,
    medidas2 DOUBLE PRECISION,
    area_anuncio DOUBLE PRECISION,
    num_caras SMALLINT,
    calificacion NUMERIC,
    usr_califica VARCHAR,
    estatus VARCHAR,
    id_licencia INTEGER,
    id_anuncio INTEGER,
    feccap DATE,
    capturista VARCHAR,
    numint_ubic VARCHAR,
    bloqueado SMALLINT,
    dictamen SMALLINT,
    observaciones TEXT,
    rhorario VARCHAR,
    cp INTEGER,
    domcompleto VARCHAR,
    zona_1 SMALLINT,
    subzona_1 SMALLINT,
    propietarionvo VARCHAR
) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Validación: p_id_tramite es requerido
    IF p_id_tramite IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_id_tramite es requerido';
    END IF;

    -- Verificar que el trámite existe
    SELECT COUNT(*) INTO v_count FROM tramites WHERE tramites.id_tramite = p_id_tramite;

    IF v_count = 0 THEN
        RAISE EXCEPTION 'No se encontró el trámite con ID: %', p_id_tramite;
    END IF;

    -- Retornar el trámite con campos calculados
    RETURN QUERY
    SELECT
        t.id_tramite,
        t.folio,
        t.tipo_tramite,
        t.id_giro,
        t.x,
        t.y,
        t.zona,
        t.subzona,
        t.actividad,
        t.cvecuenta,
        t.recaud,
        t.licencia_ref,
        t.tramita_apoderado,
        t.propietario,
        t.primer_ap,
        t.segundo_ap,
        t.rfc,
        t.curp,
        t.domicilio,
        t.numext_prop,
        t.numint_prop,
        t.colonia_prop,
        t.telefono_prop,
        t.email,
        t.cvecalle,
        t.ubicacion,
        t.numext_ubic,
        t.letraext_ubic,
        t.letraint_ubic,
        t.colonia_ubic,
        t.espubic,
        t.documentos,
        t.sup_construida,
        t.sup_autorizada,
        t.num_cajones,
        t.num_empleados,
        t.aforo,
        t.inversion,
        t.costo,
        t.fecha_consejo,
        t.id_fabricante,
        t.texto_anuncio,
        t.medidas1,
        t.medidas2,
        t.area_anuncio,
        t.num_caras,
        t.calificacion,
        t.usr_califica,
        t.estatus,
        t.id_licencia,
        t.id_anuncio,
        t.feccap,
        t.capturista,
        t.numint_ubic,
        t.bloqueado,
        t.dictamen,
        t.observaciones,
        t.rhorario,
        t.cp,
        -- Campo calculado: domicilio completo con formato
        (TRIM(COALESCE(t.ubicacion, '')) ||
         ' No.Ext:' || COALESCE(t.numext_ubic::TEXT, '') ||
         COALESCE(' - ' || t.letraext_ubic, '') ||
         ' No.Int:' || COALESCE(t.numint_ubic, '') ||
         COALESCE(' - ' || t.letraint_ubic, '') ||
         ' CP:' || COALESCE(t.cp::TEXT, ''))::VARCHAR AS domcompleto,
        -- Campos repetidos zona y subzona (zona_1, subzona_1)
        t.zona AS zona_1,
        t.subzona AS subzona_1,
        -- Campo calculado: nombre completo del propietario
        (TRIM(TRIM(COALESCE(t.primer_ap, '')) || ' ' ||
              TRIM(COALESCE(t.segundo_ap, '')) || ' ' ||
              TRIM(COALESCE(t.propietario, ''))))::VARCHAR AS propietarionvo
    FROM tramites t
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

-- Comentario de la función
COMMENT ON FUNCTION sp_get_tramite_by_id(INTEGER) IS
'Obtiene datos completos de un trámite por ID para formatos de ecología.
Incluye campos calculados: domcompleto (dirección formateada) y propietarionvo (nombre completo).
Autor: RefactorX - Implementado: 2025-11-20';

-- ============================================
-- SP 2/3: sp_get_tramites_by_fecha
-- Tipo: Consulta (Report)
-- Descripción: Obtiene todos los trámites capturados en una fecha específica,
--              incluyendo campos calculados. Usado para reportes diarios de
--              trámites de ecología y generación de formatos en lote.
-- Parámetros:
--   p_fecha: Fecha de captura de los trámites (requerido)
-- Retorna: Lista de trámites capturados en la fecha con campos calculados
-- ============================================

CREATE OR REPLACE FUNCTION sp_get_tramites_by_fecha(
    p_fecha DATE
)
RETURNS TABLE (
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR,
    id_giro INTEGER,
    x DOUBLE PRECISION,
    y DOUBLE PRECISION,
    zona SMALLINT,
    subzona SMALLINT,
    actividad VARCHAR,
    cvecuenta INTEGER,
    recaud SMALLINT,
    licencia_ref INTEGER,
    tramita_apoderado VARCHAR,
    propietario VARCHAR,
    primer_ap VARCHAR,
    segundo_ap VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    domicilio VARCHAR,
    numext_prop INTEGER,
    numint_prop VARCHAR,
    colonia_prop VARCHAR,
    telefono_prop VARCHAR,
    email VARCHAR,
    cvecalle INTEGER,
    ubicacion VARCHAR,
    numext_ubic INTEGER,
    letraext_ubic VARCHAR,
    letraint_ubic VARCHAR,
    colonia_ubic VARCHAR,
    espubic VARCHAR,
    documentos TEXT,
    sup_construida DOUBLE PRECISION,
    sup_autorizada DOUBLE PRECISION,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC,
    costo NUMERIC,
    fecha_consejo DATE,
    id_fabricante INTEGER,
    texto_anuncio VARCHAR,
    medidas1 DOUBLE PRECISION,
    medidas2 DOUBLE PRECISION,
    area_anuncio DOUBLE PRECISION,
    num_caras SMALLINT,
    calificacion NUMERIC,
    usr_califica VARCHAR,
    estatus VARCHAR,
    id_licencia INTEGER,
    id_anuncio INTEGER,
    feccap DATE,
    capturista VARCHAR,
    numint_ubic VARCHAR,
    bloqueado SMALLINT,
    dictamen SMALLINT,
    observaciones TEXT,
    rhorario VARCHAR,
    cp INTEGER,
    domcompleto VARCHAR,
    zona_1 SMALLINT,
    subzona_1 SMALLINT,
    propietarionvo VARCHAR
) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Validación: p_fecha es requerido
    IF p_fecha IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_fecha es requerido';
    END IF;

    -- Validar que la fecha no sea futura
    IF p_fecha > CURRENT_DATE THEN
        RAISE WARNING 'La fecha proporcionada (%) es futura', p_fecha;
    END IF;

    -- Retornar los trámites de la fecha con campos calculados
    RETURN QUERY
    SELECT
        t.id_tramite,
        t.folio,
        t.tipo_tramite,
        t.id_giro,
        t.x,
        t.y,
        t.zona,
        t.subzona,
        t.actividad,
        t.cvecuenta,
        t.recaud,
        t.licencia_ref,
        t.tramita_apoderado,
        t.propietario,
        t.primer_ap,
        t.segundo_ap,
        t.rfc,
        t.curp,
        t.domicilio,
        t.numext_prop,
        t.numint_prop,
        t.colonia_prop,
        t.telefono_prop,
        t.email,
        t.cvecalle,
        t.ubicacion,
        t.numext_ubic,
        t.letraext_ubic,
        t.letraint_ubic,
        t.colonia_ubic,
        t.espubic,
        t.documentos,
        t.sup_construida,
        t.sup_autorizada,
        t.num_cajones,
        t.num_empleados,
        t.aforo,
        t.inversion,
        t.costo,
        t.fecha_consejo,
        t.id_fabricante,
        t.texto_anuncio,
        t.medidas1,
        t.medidas2,
        t.area_anuncio,
        t.num_caras,
        t.calificacion,
        t.usr_califica,
        t.estatus,
        t.id_licencia,
        t.id_anuncio,
        t.feccap,
        t.capturista,
        t.numint_ubic,
        t.bloqueado,
        t.dictamen,
        t.observaciones,
        t.rhorario,
        t.cp,
        -- Campo calculado: domicilio completo con formato
        (TRIM(COALESCE(t.ubicacion, '')) ||
         ' No.Ext:' || COALESCE(t.numext_ubic::TEXT, '') ||
         COALESCE(' - ' || t.letraext_ubic, '') ||
         ' No.Int:' || COALESCE(t.numint_ubic, '') ||
         COALESCE(' - ' || t.letraint_ubic, '') ||
         ' CP:' || COALESCE(t.cp::TEXT, ''))::VARCHAR AS domcompleto,
        -- Campos repetidos zona y subzona (zona_1, subzona_1)
        t.zona AS zona_1,
        t.subzona AS subzona_1,
        -- Campo calculado: nombre completo del propietario
        (TRIM(TRIM(COALESCE(t.primer_ap, '')) || ' ' ||
              TRIM(COALESCE(t.segundo_ap, '')) || ' ' ||
              TRIM(COALESCE(t.propietario, ''))))::VARCHAR AS propietarionvo
    FROM tramites t
    WHERE t.feccap = p_fecha
    ORDER BY t.folio, t.id_tramite;
END;
$$ LANGUAGE plpgsql;

-- Comentario de la función
COMMENT ON FUNCTION sp_get_tramites_by_fecha(DATE) IS
'Obtiene todos los trámites capturados en una fecha específica para formatos de ecología.
Incluye campos calculados y ordenamiento por folio.
Autor: RefactorX - Implementado: 2025-11-20';

-- ============================================
-- SP 3/3: sp_get_cruce_calles_by_tramite
-- Tipo: Consulta (Report)
-- Descripción: Obtiene los nombres de las calles que se cruzan en la ubicación
--              de un trámite específico. Información requerida para formatos
--              de ecología que necesitan especificar la ubicación exacta.
-- Parámetros:
--   p_id_tramite: ID del trámite (requerido)
-- Retorna: Lista de cruces de calles (calle principal y calle secundaria)
-- ============================================

CREATE OR REPLACE FUNCTION sp_get_cruce_calles_by_tramite(
    p_id_tramite INTEGER
)
RETURNS TABLE (
    calle VARCHAR,
    calle_1 VARCHAR
) AS $$
DECLARE
    v_tramite_exists BOOLEAN;
    v_count INTEGER;
BEGIN
    -- Validación: p_id_tramite es requerido
    IF p_id_tramite IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_id_tramite es requerido';
    END IF;

    -- Verificar que el trámite existe
    SELECT EXISTS(SELECT 1 FROM tramites WHERE id_tramite = p_id_tramite)
    INTO v_tramite_exists;

    IF NOT v_tramite_exists THEN
        RAISE EXCEPTION 'No se encontró el trámite con ID: %', p_id_tramite;
    END IF;

    -- Retornar los cruces de calles del trámite
    RETURN QUERY
    SELECT
        b.calle AS calle,
        c.calle AS calle_1
    FROM crucecalles a
    INNER JOIN c_calles b ON b.cvecalle = a.cvecalle1
    INNER JOIN c_calles c ON c.cvecalle = a.cvecalle2
    WHERE a.id_tramite = p_id_tramite
    ORDER BY a.cvecalle1, a.cvecalle2;

    -- Log de información si no hay cruces
    GET DIAGNOSTICS v_count = ROW_COUNT;

    IF v_count = 0 THEN
        RAISE NOTICE 'El trámite % no tiene cruces de calles registrados', p_id_tramite;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Comentario de la función
COMMENT ON FUNCTION sp_get_cruce_calles_by_tramite(INTEGER) IS
'Obtiene los cruces de calles de un trámite para formatos de ecología.
Retorna nombres de calles principal y secundaria que se cruzan en la ubicación del trámite.
Autor: RefactorX - Implementado: 2025-11-20';

-- ============================================
-- FIN DE STORED PROCEDURES - formatosEcologiafrm
-- Total de funciones implementadas: 3
-- ============================================
-- NOTAS DE IMPLEMENTACIÓN:
-- 1. Todas las funciones incluyen validaciones de parámetros requeridos
-- 2. Se verifican la existencia de registros antes de procesarlos
-- 3. Los campos calculados mantienen el formato original del sistema legacy
-- 4. Se incluyen comentarios SQL para documentación de base de datos
-- 5. Los mensajes de error son descriptivos y útiles para debugging
-- 6. Se utiliza RAISE NOTICE para información no crítica
-- 7. Ordenamiento consistente en resultados multi-registro
-- 8. Manejo de valores NULL con COALESCE para evitar errores en concatenaciones
--
-- PRUEBAS SUGERIDAS:
-- SELECT * FROM sp_get_tramite_by_id(1234);
-- SELECT * FROM sp_get_tramites_by_fecha('2025-11-20');
-- SELECT * FROM sp_get_cruce_calles_by_tramite(1234);
--
-- DEPENDENCIAS:
-- - Tabla: tramites (schema public)
-- - Tabla: crucecalles (schema public)
-- - Tabla: c_calles (schema public - catálogo de calles)
-- ============================================
