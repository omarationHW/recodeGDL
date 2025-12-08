-- ============================================
-- STORED PROCEDURES IMPLEMENTADOS
-- Componente: cartonva
-- Módulo: padron_licencias
-- Generado: 2025-11-20
-- Total SPs: 4
-- ============================================
-- Descripción: Gestión de cartografía catastral y conversión de cuentas prediales
-- Schema: comun
-- Tablas principales: convcta
-- ============================================

-- ============================================
-- SP 1/4: sp_get_cartografia_predial
-- Tipo: CRUD - Consulta con URL
-- Descripción: Obtiene la información de la cuenta catastral y genera la URL del visor cartográfico
-- Parámetros:
--   p_cvecuenta: Clave de cuenta catastral (requerido)
-- Retorna: Registro con datos catastrales y URL del visor
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_get_cartografia_predial(
    p_cvecuenta INTEGER
)
RETURNS TABLE (
    cvecuenta INTEGER,
    cvemunicipio SMALLINT,
    recaud SMALLINT,
    urbrus VARCHAR(1),
    cuenta INTEGER,
    digver SMALLINT,
    zonaanter SMALLINT,
    manzanter SMALLINT,
    loteanter SMALLINT,
    cvecatnva VARCHAR(11),
    subpredio SMALLINT,
    crec SMALLINT,
    cur VARCHAR(1),
    ccta INTEGER,
    cip VARCHAR(9),
    vigente VARCHAR(1),
    cvelocalidad SMALLINT,
    coordenada_x DOUBLE PRECISION,
    coordenada_y DOUBLE PRECISION,
    visor_url TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cvecatnva VARCHAR(11);
    v_url TEXT;
    v_record RECORD;
BEGIN
    -- Validación de parámetros requeridos
    IF p_cvecuenta IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_cvecuenta es requerido';
    END IF;

    -- Consulta de datos catastrales
    SELECT
        c.cvecuenta,
        c.cvemunicipio,
        c.recaud,
        c.urbrus,
        c.cuenta,
        c.digver,
        c.zonaanter,
        c.manzanter,
        c.loteanter,
        c.cvecatnva,
        c.subpredio,
        c.crec,
        c.cur,
        c.ccta,
        c.cip,
        c.vigente,
        c.cvelocalidad,
        c.coordenada_x,
        c.coordenada_y
    INTO v_record
    FROM comun.convcta c
    WHERE c.cvecuenta = p_cvecuenta;

    -- Validar que existe el registro
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró la cuenta catastral con cvecuenta: %', p_cvecuenta;
    END IF;

    -- Almacenar clave catastral nueva para generar URL
    v_cvecatnva := v_record.cvecatnva;

    -- Generar URL del visor cartográfico
    v_url := 'http://192.168.4.20:8080/Visor/index.html#user=123&session=se123&clavePredi0=' || COALESCE(v_cvecatnva, '');

    -- Retornar resultado con URL generada
    RETURN QUERY
    SELECT
        v_record.cvecuenta,
        v_record.cvemunicipio,
        v_record.recaud,
        v_record.urbrus,
        v_record.cuenta,
        v_record.digver,
        v_record.zonaanter,
        v_record.manzanter,
        v_record.loteanter,
        v_record.cvecatnva,
        v_record.subpredio,
        v_record.crec,
        v_record.cur,
        v_record.ccta,
        v_record.cip,
        v_record.vigente,
        v_record.cvelocalidad,
        v_record.coordenada_x,
        v_record.coordenada_y,
        v_url;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION comun.sp_get_cartografia_predial(INTEGER) IS
'Obtiene información de cuenta catastral y genera URL del visor cartográfico - Componente: cartonva';

-- ============================================
-- SP 2/4: sp_get_cuenta_by_cvecuenta
-- Tipo: Catalog - Consulta básica
-- Descripción: Obtiene la información básica de la cuenta catastral por cvecuenta
-- Parámetros:
--   p_cvecuenta: Clave de cuenta catastral (requerido)
-- Retorna: Registro con datos básicos catastrales
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_get_cuenta_by_cvecuenta(
    p_cvecuenta INTEGER
)
RETURNS TABLE (
    cvecuenta INTEGER,
    cvemunicipio SMALLINT,
    recaud SMALLINT,
    urbrus VARCHAR(1),
    cuenta INTEGER,
    digver SMALLINT,
    zonaanter SMALLINT,
    manzanter SMALLINT,
    loteanter SMALLINT,
    cvecatnva VARCHAR(11),
    subpredio SMALLINT,
    crec SMALLINT,
    cur VARCHAR(1),
    ccta INTEGER,
    cip VARCHAR(9),
    vigente VARCHAR(1),
    cvelocalidad SMALLINT,
    coordenada_x DOUBLE PRECISION,
    coordenada_y DOUBLE PRECISION
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validación de parámetros requeridos
    IF p_cvecuenta IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_cvecuenta es requerido';
    END IF;

    -- Consulta de datos catastrales básicos
    RETURN QUERY
    SELECT
        c.cvecuenta,
        c.cvemunicipio,
        c.recaud,
        c.urbrus,
        c.cuenta,
        c.digver,
        c.zonaanter,
        c.manzanter,
        c.loteanter,
        c.cvecatnva,
        c.subpredio,
        c.crec,
        c.cur,
        c.ccta,
        c.cip,
        c.vigente,
        c.cvelocalidad,
        c.coordenada_x,
        c.coordenada_y
    FROM comun.convcta c
    WHERE c.cvecuenta = p_cvecuenta;

    -- Validar que se encontró al menos un registro
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró la cuenta catastral con cvecuenta: %', p_cvecuenta;
    END IF;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION comun.sp_get_cuenta_by_cvecuenta(INTEGER) IS
'Obtiene información básica de cuenta catastral por cvecuenta - Componente: cartonva';

-- ============================================
-- SP 3/4: sp_get_convcta_by_cvecuenta
-- Tipo: Catalog - Consulta completa
-- Descripción: Obtiene todos los datos de la cuenta catastral incluyendo campos de auditoría
-- Parámetros:
--   p_cvecuenta: Clave de cuenta catastral (requerido)
-- Retorna: Registro completo con todos los campos de la tabla convcta
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_get_convcta_by_cvecuenta(
    p_cvecuenta INTEGER
)
RETURNS TABLE (
    cvecuenta INTEGER,
    cvemunicipio SMALLINT,
    recaud SMALLINT,
    urbrus VARCHAR(1),
    cuenta INTEGER,
    digver SMALLINT,
    zonaanter SMALLINT,
    manzanter SMALLINT,
    loteanter SMALLINT,
    cvecatnva VARCHAR(11),
    subpredio SMALLINT,
    crec SMALLINT,
    cur VARCHAR(1),
    ccta INTEGER,
    cip VARCHAR(9),
    vigente VARCHAR(1),
    cvelocalidad SMALLINT,
    coordenada_x DOUBLE PRECISION,
    coordenada_y DOUBLE PRECISION,
    por_construccion VARCHAR(1),
    crea_fecha TIMESTAMP,
    crea_usuario VARCHAR(15),
    crea_computer VARCHAR(50),
    baja_fecha TIMESTAMP,
    baja_usuario VARCHAR(15),
    baja_computer VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validación de parámetros requeridos
    IF p_cvecuenta IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_cvecuenta es requerido';
    END IF;

    -- Consulta completa de datos catastrales con auditoría
    RETURN QUERY
    SELECT
        c.cvecuenta,
        c.cvemunicipio,
        c.recaud,
        c.urbrus,
        c.cuenta,
        c.digver,
        c.zonaanter,
        c.manzanter,
        c.loteanter,
        c.cvecatnva,
        c.subpredio,
        c.crec,
        c.cur,
        c.ccta,
        c.cip,
        c.vigente,
        c.cvelocalidad,
        c.coordenada_x,
        c.coordenada_y,
        c.por_construccion,
        c.crea_fecha,
        c.crea_usuario,
        c.crea_computer,
        c.baja_fecha,
        c.baja_usuario,
        c.baja_computer
    FROM comun.convcta c
    WHERE c.cvecuenta = p_cvecuenta;

    -- Validar que se encontró al menos un registro
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró la cuenta catastral con cvecuenta: %', p_cvecuenta;
    END IF;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION comun.sp_get_convcta_by_cvecuenta(INTEGER) IS
'Obtiene información completa de cuenta catastral incluyendo auditoría - Componente: cartonva';

-- ============================================
-- SP 4/4: sp_get_convcta_by_cvecatnva_subpredio
-- Tipo: Catalog - Búsqueda por clave catastral
-- Descripción: Obtiene datos de la cuenta catastral por clave catastral nueva y subpredio
-- Parámetros:
--   p_cvecatnva: Clave catastral nueva (requerido)
--   p_subpredio: Número de subpredio (requerido)
-- Retorna: Registro completo con todos los campos de la tabla convcta
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_get_convcta_by_cvecatnva_subpredio(
    p_cvecatnva VARCHAR(11),
    p_subpredio INTEGER
)
RETURNS TABLE (
    cvecuenta INTEGER,
    cvemunicipio SMALLINT,
    recaud SMALLINT,
    urbrus VARCHAR(1),
    cuenta INTEGER,
    digver SMALLINT,
    zonaanter SMALLINT,
    manzanter SMALLINT,
    loteanter SMALLINT,
    cvecatnva VARCHAR(11),
    subpredio SMALLINT,
    crec SMALLINT,
    cur VARCHAR(1),
    ccta INTEGER,
    cip VARCHAR(9),
    vigente VARCHAR(1),
    cvelocalidad SMALLINT,
    coordenada_x DOUBLE PRECISION,
    coordenada_y DOUBLE PRECISION,
    por_construccion VARCHAR(1),
    crea_fecha TIMESTAMP,
    crea_usuario VARCHAR(15),
    crea_computer VARCHAR(50),
    baja_fecha TIMESTAMP,
    baja_usuario VARCHAR(15),
    baja_computer VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validación de parámetros requeridos
    IF p_cvecatnva IS NULL OR TRIM(p_cvecatnva) = '' THEN
        RAISE EXCEPTION 'El parámetro p_cvecatnva es requerido';
    END IF;

    IF p_subpredio IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_subpredio es requerido';
    END IF;

    -- Consulta completa por clave catastral y subpredio
    RETURN QUERY
    SELECT
        c.cvecuenta,
        c.cvemunicipio,
        c.recaud,
        c.urbrus,
        c.cuenta,
        c.digver,
        c.zonaanter,
        c.manzanter,
        c.loteanter,
        c.cvecatnva,
        c.subpredio,
        c.crec,
        c.cur,
        c.ccta,
        c.cip,
        c.vigente,
        c.cvelocalidad,
        c.coordenada_x,
        c.coordenada_y,
        c.por_construccion,
        c.crea_fecha,
        c.crea_usuario,
        c.crea_computer,
        c.baja_fecha,
        c.baja_usuario,
        c.baja_computer
    FROM comun.convcta c
    WHERE c.cvecatnva = p_cvecatnva
      AND c.subpredio = p_subpredio;

    -- Validar que se encontró al menos un registro
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró la cuenta catastral con cvecatnva: % y subpredio: %', p_cvecatnva, p_subpredio;
    END IF;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION comun.sp_get_convcta_by_cvecatnva_subpredio(VARCHAR, INTEGER) IS
'Obtiene información completa de cuenta catastral por clave catastral nueva y subpredio - Componente: cartonva';

-- ============================================
-- FIN DE STORED PROCEDURES - CARTONVA
-- ============================================
-- Resumen de implementación:
-- ✓ 4 stored procedures implementados
-- ✓ Validaciones de parámetros requeridos
-- ✓ Manejo de excepciones descriptivo
-- ✓ Consultas optimizadas
-- ✓ Documentación completa
-- ✓ Schema: comun
-- ✓ Tabla principal: convcta
-- ============================================
-- Funcionalidades principales:
-- 1. Consulta de cartografía predial con URL del visor
-- 2. Consulta básica de cuenta catastral
-- 3. Consulta completa con datos de auditoría
-- 4. Búsqueda por clave catastral nueva y subpredio
-- ============================================
-- Características técnicas:
-- - Retorno de múltiples columnas con RETURNS TABLE
-- - Validaciones de parámetros con RAISE EXCEPTION
-- - Uso de COALESCE para valores NULL
-- - Generación dinámica de URLs
-- - Consultas con filtros específicos
-- - Verificación de existencia de registros
-- ============================================
