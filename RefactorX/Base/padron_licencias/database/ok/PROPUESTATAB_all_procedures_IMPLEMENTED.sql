-- ============================================
-- STORED PROCEDURES IMPLEMENTADOS - PROPUESTATAB
-- Módulo: padron_licencias
-- Componente: Propuestatab (Consulta Histórica de Cuenta Catastral)
-- Schema: comun
-- Total SPs: 6
-- Fecha: 2025-11-20
-- ============================================
-- Descripción: Funciones para consulta de históricos catastrales
-- Tablas principales: historico, saldos, valores, ubicacion, regprop, valmodif
-- ============================================

\c padron_licencias;
SET search_path TO comun, public;

-- ============================================
-- SP 1/6: sp_propuesta_get_cuenta_historico
-- Tipo: CONSULTA
-- Descripción: Obtiene el histórico completo de la cuenta catastral principal
-- Parámetros:
--   p_cuenta: Número de cuenta catastral
--   p_anio_inicio: Año inicial de consulta (opcional)
--   p_anio_fin: Año final de consulta (opcional)
-- Retorna: Histórico de cuenta ordenado por fecha descendente
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_propuesta_get_cuenta_historico(
    p_cuenta INTEGER,
    p_anio_inicio INTEGER DEFAULT NULL,
    p_anio_fin INTEGER DEFAULT NULL
)
RETURNS TABLE(
    cvecuenta INTEGER,
    urbrus VARCHAR,
    cuenta INTEGER,
    cvecatnva VARCHAR,
    subpredio INTEGER,
    crec INTEGER,
    cur VARCHAR,
    ccta INTEGER,
    cmovto VARCHAR,
    indiviso NUMERIC(10,4),
    tasa NUMERIC(12,2),
    observacion TEXT,
    axocomp INTEGER,
    nocomp INTEGER,
    asiento INTEGER,
    axoultcomp INTEGER,
    ultcomp INTEGER,
    feccap DATE,
    capturista VARCHAR,
    anio_registro INTEGER
) AS $$
BEGIN
    -- Validación de cuenta
    IF p_cuenta IS NULL OR p_cuenta <= 0 THEN
        RAISE EXCEPTION 'Cuenta inválida. Debe proporcionar un número de cuenta válido.';
    END IF;

    -- Validación de rango de años
    IF p_anio_inicio IS NOT NULL AND p_anio_fin IS NOT NULL THEN
        IF p_anio_inicio > p_anio_fin THEN
            RAISE EXCEPTION 'Rango de años inválido. El año inicial no puede ser mayor al año final.';
        END IF;
    END IF;

    -- Validación de años no futuros
    IF p_anio_inicio IS NOT NULL AND p_anio_inicio > EXTRACT(YEAR FROM CURRENT_DATE) THEN
        RAISE EXCEPTION 'El año inicial no puede ser futuro.';
    END IF;

    IF p_anio_fin IS NOT NULL AND p_anio_fin > EXTRACT(YEAR FROM CURRENT_DATE) THEN
        RAISE EXCEPTION 'El año final no puede ser futuro.';
    END IF;

    RETURN QUERY
    SELECT
        h.cvecuenta,
        h.urbrus,
        h.cuenta,
        h.cvecatnva,
        h.subpredio,
        h.crec,
        h.cur,
        h.ccta,
        h.cmovto,
        h.indiviso,
        h.tasa,
        h.observacion,
        h.axocomp,
        h.nocomp,
        h.asiento,
        h.axoultcomp,
        h.ultcomp,
        h.feccap,
        h.capturista,
        EXTRACT(YEAR FROM h.feccap)::INTEGER AS anio_registro
    FROM historico h
    WHERE h.cvecuenta = p_cuenta
      AND (p_anio_inicio IS NULL OR EXTRACT(YEAR FROM h.feccap) >= p_anio_inicio)
      AND (p_anio_fin IS NULL OR EXTRACT(YEAR FROM h.feccap) <= p_anio_fin)
    ORDER BY h.feccap DESC, h.axocomp DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_propuesta_get_cuenta_historico(INTEGER, INTEGER, INTEGER)
IS 'Obtiene el histórico completo de la cuenta catastral con filtros opcionales por rango de años';

-- ============================================
-- SP 2/6: sp_propuesta_get_predial_historico
-- Tipo: CONSULTA
-- Descripción: Obtiene el histórico de saldos prediales de la cuenta
-- Parámetros:
--   p_cuenta: Número de cuenta catastral
--   p_anio_inicio: Año inicial de consulta (opcional)
--   p_anio_fin: Año final de consulta (opcional)
-- Retorna: Histórico de saldos ordenado por fecha descendente
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_propuesta_get_predial_historico(
    p_cuenta INTEGER,
    p_anio_inicio INTEGER DEFAULT NULL,
    p_anio_fin INTEGER DEFAULT NULL
)
RETURNS TABLE(
    cvecuenta INTEGER,
    impuesto NUMERIC(12,2),
    recargos NUMERIC(12,2),
    multa NUMERIC(12,2),
    gasto NUMERIC(12,2),
    saldo NUMERIC(12,2),
    impuestotal NUMERIC(12,2),
    rectotal NUMERIC(12,2),
    multavir NUMERIC(12,2),
    saldototal NUMERIC(12,2),
    feccap DATE,
    anio_registro INTEGER
) AS $$
BEGIN
    -- Validación de cuenta
    IF p_cuenta IS NULL OR p_cuenta <= 0 THEN
        RAISE EXCEPTION 'Cuenta inválida. Debe proporcionar un número de cuenta válido.';
    END IF;

    -- Validación de rango de años
    IF p_anio_inicio IS NOT NULL AND p_anio_fin IS NOT NULL THEN
        IF p_anio_inicio > p_anio_fin THEN
            RAISE EXCEPTION 'Rango de años inválido. El año inicial no puede ser mayor al año final.';
        END IF;
    END IF;

    -- Validación de años no futuros
    IF p_anio_inicio IS NOT NULL AND p_anio_inicio > EXTRACT(YEAR FROM CURRENT_DATE) THEN
        RAISE EXCEPTION 'El año inicial no puede ser futuro.';
    END IF;

    IF p_anio_fin IS NOT NULL AND p_anio_fin > EXTRACT(YEAR FROM CURRENT_DATE) THEN
        RAISE EXCEPTION 'El año final no puede ser futuro.';
    END IF;

    RETURN QUERY
    SELECT
        s.cvecuenta,
        s.impuesto,
        s.recargos,
        s.multa,
        s.gasto,
        s.saldo,
        s.impuestotal,
        s.rectotal,
        s.multavir,
        s.saldototal,
        s.feccap,
        EXTRACT(YEAR FROM s.feccap)::INTEGER AS anio_registro
    FROM saldos s
    WHERE s.cvecuenta = p_cuenta
      AND (p_anio_inicio IS NULL OR EXTRACT(YEAR FROM s.feccap) >= p_anio_inicio)
      AND (p_anio_fin IS NULL OR EXTRACT(YEAR FROM s.feccap) <= p_anio_fin)
    ORDER BY s.feccap DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_propuesta_get_predial_historico(INTEGER, INTEGER, INTEGER)
IS 'Obtiene el histórico de saldos prediales de la cuenta con filtros opcionales por rango de años';

-- ============================================
-- SP 3/6: sp_propuesta_get_ubicacion_historico
-- Tipo: CONSULTA
-- Descripción: Obtiene el histórico de ubicación física de la cuenta
-- Parámetros:
--   p_cuenta: Número de cuenta catastral
--   p_anio_inicio: Año inicial de consulta (opcional)
--   p_anio_fin: Año final de consulta (opcional)
-- Retorna: Histórico de ubicación ordenado por fecha descendente
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_propuesta_get_ubicacion_historico(
    p_cuenta INTEGER,
    p_anio_inicio INTEGER DEFAULT NULL,
    p_anio_fin INTEGER DEFAULT NULL
)
RETURNS TABLE(
    cvecuenta INTEGER,
    calle VARCHAR,
    noexterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    vigencia VARCHAR,
    obsinter TEXT,
    feccap DATE,
    anio_registro INTEGER
) AS $$
BEGIN
    -- Validación de cuenta
    IF p_cuenta IS NULL OR p_cuenta <= 0 THEN
        RAISE EXCEPTION 'Cuenta inválida. Debe proporcionar un número de cuenta válido.';
    END IF;

    -- Validación de rango de años
    IF p_anio_inicio IS NOT NULL AND p_anio_fin IS NOT NULL THEN
        IF p_anio_inicio > p_anio_fin THEN
            RAISE EXCEPTION 'Rango de años inválido. El año inicial no puede ser mayor al año final.';
        END IF;
    END IF;

    -- Validación de años no futuros
    IF p_anio_inicio IS NOT NULL AND p_anio_inicio > EXTRACT(YEAR FROM CURRENT_DATE) THEN
        RAISE EXCEPTION 'El año inicial no puede ser futuro.';
    END IF;

    IF p_anio_fin IS NOT NULL AND p_anio_fin > EXTRACT(YEAR FROM CURRENT_DATE) THEN
        RAISE EXCEPTION 'El año final no puede ser futuro.';
    END IF;

    RETURN QUERY
    SELECT
        u.cvecuenta,
        u.calle,
        u.noexterior,
        u.interior,
        u.colonia,
        u.vigencia,
        u.obsinter,
        u.feccap,
        EXTRACT(YEAR FROM u.feccap)::INTEGER AS anio_registro
    FROM ubicacion u
    WHERE u.cvecuenta = p_cuenta
      AND (p_anio_inicio IS NULL OR EXTRACT(YEAR FROM u.feccap) >= p_anio_inicio)
      AND (p_anio_fin IS NULL OR EXTRACT(YEAR FROM u.feccap) <= p_anio_fin)
    ORDER BY u.feccap DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_propuesta_get_ubicacion_historico(INTEGER, INTEGER, INTEGER)
IS 'Obtiene el histórico de ubicación física de la cuenta con filtros opcionales por rango de años';

-- ============================================
-- SP 4/6: sp_propuesta_get_valores_historico
-- Tipo: CONSULTA
-- Descripción: Obtiene el histórico de valores catastrales de la cuenta
-- Parámetros:
--   p_cuenta: Número de cuenta catastral
--   p_anio_inicio: Año inicial de consulta (opcional)
--   p_anio_fin: Año final de consulta (opcional)
-- Retorna: Histórico de valores ordenado por fecha descendente
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_propuesta_get_valores_historico(
    p_cuenta INTEGER,
    p_anio_inicio INTEGER DEFAULT NULL,
    p_anio_fin INTEGER DEFAULT NULL
)
RETURNS TABLE(
    cvecuenta INTEGER,
    areaterr NUMERIC(12,2),
    areaconst NUMERIC(12,2),
    valterr NUMERIC(14,2),
    valconst NUMERIC(14,2),
    valfiscal NUMERIC(14,2),
    feccap DATE,
    anio_registro INTEGER
) AS $$
BEGIN
    -- Validación de cuenta
    IF p_cuenta IS NULL OR p_cuenta <= 0 THEN
        RAISE EXCEPTION 'Cuenta inválida. Debe proporcionar un número de cuenta válido.';
    END IF;

    -- Validación de rango de años
    IF p_anio_inicio IS NOT NULL AND p_anio_fin IS NOT NULL THEN
        IF p_anio_inicio > p_anio_fin THEN
            RAISE EXCEPTION 'Rango de años inválido. El año inicial no puede ser mayor al año final.';
        END IF;
    END IF;

    -- Validación de años no futuros
    IF p_anio_inicio IS NOT NULL AND p_anio_inicio > EXTRACT(YEAR FROM CURRENT_DATE) THEN
        RAISE EXCEPTION 'El año inicial no puede ser futuro.';
    END IF;

    IF p_anio_fin IS NOT NULL AND p_anio_fin > EXTRACT(YEAR FROM CURRENT_DATE) THEN
        RAISE EXCEPTION 'El año final no puede ser futuro.';
    END IF;

    RETURN QUERY
    SELECT
        v.cvecuenta,
        v.areaterr,
        v.areaconst,
        v.valterr,
        v.valconst,
        v.valfiscal,
        v.feccap,
        EXTRACT(YEAR FROM v.feccap)::INTEGER AS anio_registro
    FROM valores v
    WHERE v.cvecuenta = p_cuenta
      AND (p_anio_inicio IS NULL OR EXTRACT(YEAR FROM v.feccap) >= p_anio_inicio)
      AND (p_anio_fin IS NULL OR EXTRACT(YEAR FROM v.feccap) <= p_anio_fin)
    ORDER BY v.feccap DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_propuesta_get_valores_historico(INTEGER, INTEGER, INTEGER)
IS 'Obtiene el histórico de valores catastrales de la cuenta con filtros opcionales por rango de años';

-- ============================================
-- SP 5/6: sp_propuesta_get_diferencias_historico
-- Tipo: CONSULTA COMPARATIVA
-- Descripción: Compara valores entre dos años o muestra todas las diferencias históricas
-- Parámetros:
--   p_cuenta: Número de cuenta catastral
--   p_anio_base: Año base para comparación (opcional, si NULL muestra todo el histórico)
--   p_anio_comparar: Año a comparar (opcional, solo aplica si p_anio_base tiene valor)
-- Retorna: Diferencias de valores con cálculos de cambio y porcentajes
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_propuesta_get_diferencias_historico(
    p_cuenta INTEGER,
    p_anio_base INTEGER DEFAULT NULL,
    p_anio_comparar INTEGER DEFAULT NULL
)
RETURNS TABLE(
    cvecuenta INTEGER,
    concepto VARCHAR,
    bimini INTEGER,
    axoini INTEGER,
    bimfin INTEGER,
    axofin INTEGER,
    tasaant NUMERIC(12,2),
    stasaant NUMERIC(12,2),
    valfisant NUMERIC(14,2),
    tasa NUMERIC(12,2),
    axosobretasa NUMERIC(12,2),
    valfiscal NUMERIC(14,2),
    diferencia_valor NUMERIC(14,2),
    porcentaje_cambio NUMERIC(8,2),
    periodo_meses INTEGER
) AS $$
BEGIN
    -- Validación de cuenta
    IF p_cuenta IS NULL OR p_cuenta <= 0 THEN
        RAISE EXCEPTION 'Cuenta inválida. Debe proporcionar un número de cuenta válido.';
    END IF;

    -- Si se especifican años para comparar, validar
    IF p_anio_base IS NOT NULL AND p_anio_comparar IS NOT NULL THEN
        IF p_anio_base >= p_anio_comparar THEN
            RAISE EXCEPTION 'El año base debe ser anterior al año de comparación.';
        END IF;

        IF p_anio_base > EXTRACT(YEAR FROM CURRENT_DATE) OR p_anio_comparar > EXTRACT(YEAR FROM CURRENT_DATE) THEN
            RAISE EXCEPTION 'Los años especificados no pueden ser futuros.';
        END IF;
    END IF;

    -- Si NO se especifican años, retornar todo el histórico de diferencias
    IF p_anio_base IS NULL THEN
        RETURN QUERY
        SELECT
            vm.cvecuenta,
            'Modificación Histórica'::VARCHAR AS concepto,
            vm.bimini,
            vm.axoini,
            vm.bimfin,
            vm.axofin,
            vm.tasaant,
            vm.stasaant,
            vm.valfisant,
            vm.tasa,
            vm.axosobretasa,
            vm.valfiscal,
            (vm.valfiscal - vm.valfisant) AS diferencia_valor,
            CASE
                WHEN vm.valfisant > 0 THEN
                    ROUND(((vm.valfiscal - vm.valfisant) / vm.valfisant * 100)::NUMERIC, 2)
                ELSE
                    0::NUMERIC
            END AS porcentaje_cambio,
            (((vm.axofin - vm.axoini) * 12) + (vm.bimfin - vm.bimini) * 2) AS periodo_meses
        FROM valmodif vm
        WHERE vm.cvecuenta = p_cuenta
        ORDER BY vm.axoini DESC, vm.bimini DESC;
    ELSE
        -- Si se especifican años, hacer comparación específica
        RETURN QUERY
        WITH valores_base AS (
            SELECT
                vm.cvecuenta,
                vm.bimini,
                vm.axoini,
                vm.tasaant,
                vm.stasaant,
                vm.valfisant
            FROM valmodif vm
            WHERE vm.cvecuenta = p_cuenta
              AND vm.axoini = p_anio_base
            LIMIT 1
        ),
        valores_comparar AS (
            SELECT
                vm.cvecuenta,
                vm.bimfin,
                vm.axofin,
                vm.tasa,
                vm.axosobretasa,
                vm.valfiscal
            FROM valmodif vm
            WHERE vm.cvecuenta = p_cuenta
              AND vm.axofin = p_anio_comparar
            LIMIT 1
        )
        SELECT
            vb.cvecuenta,
            'Comparación Específica'::VARCHAR AS concepto,
            vb.bimini,
            vb.axoini,
            vc.bimfin,
            vc.axofin,
            vb.tasaant,
            vb.stasaant,
            vb.valfisant,
            vc.tasa,
            vc.axosobretasa,
            vc.valfiscal,
            (vc.valfiscal - vb.valfisant) AS diferencia_valor,
            CASE
                WHEN vb.valfisant > 0 THEN
                    ROUND(((vc.valfiscal - vb.valfisant) / vb.valfisant * 100)::NUMERIC, 2)
                ELSE
                    0::NUMERIC
            END AS porcentaje_cambio,
            (((vc.axofin - vb.axoini) * 12) + (vc.bimfin - vb.bimini) * 2) AS periodo_meses
        FROM valores_base vb
        CROSS JOIN valores_comparar vc;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_propuesta_get_diferencias_historico(INTEGER, INTEGER, INTEGER)
IS 'Obtiene diferencias históricas de valores catastrales. Si no se especifican años muestra todo el histórico, si se especifican realiza comparación entre dos años específicos';

-- ============================================
-- SP 6/6: sp_propuesta_get_regimen_propiedad_historico
-- Tipo: CONSULTA
-- Descripción: Obtiene el histórico del régimen de propiedad de la cuenta
-- Parámetros:
--   p_cuenta: Número de cuenta catastral
--   p_anio_inicio: Año inicial de consulta (opcional)
--   p_anio_fin: Año final de consulta (opcional)
-- Retorna: Histórico de régimen de propiedad ordenado por fecha descendente
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_propuesta_get_regimen_propiedad_historico(
    p_cuenta INTEGER,
    p_anio_inicio INTEGER DEFAULT NULL,
    p_anio_fin INTEGER DEFAULT NULL
)
RETURNS TABLE(
    cvecuenta INTEGER,
    cvereg INTEGER,
    encabeza VARCHAR,
    porcentaje NUMERIC(5,2),
    descripcion VARCHAR,
    exento VARCHAR,
    ncompleto VARCHAR,
    rfc VARCHAR,
    calle VARCHAR,
    interior VARCHAR,
    noexterior VARCHAR,
    poblacion VARCHAR,
    municipio VARCHAR,
    estado VARCHAR,
    pais VARCHAR,
    feccap DATE,
    anio_registro INTEGER
) AS $$
BEGIN
    -- Validación de cuenta
    IF p_cuenta IS NULL OR p_cuenta <= 0 THEN
        RAISE EXCEPTION 'Cuenta inválida. Debe proporcionar un número de cuenta válido.';
    END IF;

    -- Validación de rango de años
    IF p_anio_inicio IS NOT NULL AND p_anio_fin IS NOT NULL THEN
        IF p_anio_inicio > p_anio_fin THEN
            RAISE EXCEPTION 'Rango de años inválido. El año inicial no puede ser mayor al año final.';
        END IF;
    END IF;

    -- Validación de años no futuros
    IF p_anio_inicio IS NOT NULL AND p_anio_inicio > EXTRACT(YEAR FROM CURRENT_DATE) THEN
        RAISE EXCEPTION 'El año inicial no puede ser futuro.';
    END IF;

    IF p_anio_fin IS NOT NULL AND p_anio_fin > EXTRACT(YEAR FROM CURRENT_DATE) THEN
        RAISE EXCEPTION 'El año final no puede ser futuro.';
    END IF;

    RETURN QUERY
    SELECT
        rp.cvecuenta,
        rp.cvereg,
        rp.encabeza,
        rp.porcentaje,
        rp.descripcion,
        rp.exento,
        rp.ncompleto,
        rp.rfc,
        rp.calle,
        rp.interior,
        rp.noexterior,
        rp.poblacion,
        rp.municipio,
        rp.estado,
        rp.pais,
        rp.feccap,
        EXTRACT(YEAR FROM rp.feccap)::INTEGER AS anio_registro
    FROM regprop rp
    WHERE rp.cvecuenta = p_cuenta
      AND (p_anio_inicio IS NULL OR EXTRACT(YEAR FROM rp.feccap) >= p_anio_inicio)
      AND (p_anio_fin IS NULL OR EXTRACT(YEAR FROM rp.feccap) <= p_anio_fin)
    ORDER BY rp.feccap DESC, rp.porcentaje DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_propuesta_get_regimen_propiedad_historico(INTEGER, INTEGER, INTEGER)
IS 'Obtiene el histórico del régimen de propiedad de la cuenta con filtros opcionales por rango de años';

-- ============================================
-- RESUMEN DE STORED PROCEDURES IMPLEMENTADOS
-- ============================================
-- Total: 6 funciones
--
-- 1. sp_propuesta_get_cuenta_historico       - Histórico de cuenta principal
-- 2. sp_propuesta_get_predial_historico      - Histórico de saldos prediales
-- 3. sp_propuesta_get_ubicacion_historico    - Histórico de ubicación física
-- 4. sp_propuesta_get_valores_historico      - Histórico de valores catastrales
-- 5. sp_propuesta_get_diferencias_historico  - Comparación de valores entre años
-- 6. sp_propuesta_get_regimen_propiedad_historico - Histórico de régimen de propiedad
--
-- CARACTERÍSTICAS:
-- - Todas las funciones incluyen validaciones completas de parámetros
-- - Filtros opcionales por rango de años
-- - Ordenamiento consistente por fecha descendente
-- - Cálculos de diferencias y porcentajes en sp_propuesta_get_diferencias_historico
-- - Manejo de errores mediante RAISE EXCEPTION
-- - Documentación completa mediante COMMENT ON FUNCTION
-- - Schema: comun
-- - Prefijo: sp_propuesta_
-- - Nomenclatura de parámetros: p_
--
-- TABLAS UTILIZADAS:
-- - historico: Datos históricos principales de la cuenta
-- - saldos: Histórico de saldos prediales
-- - ubicacion: Histórico de ubicación física
-- - valores: Histórico de valores catastrales (áreas y valores)
-- - valmodif: Modificaciones de valores (diferencias)
-- - regprop: Régimen de propiedad (propietarios)
-- ============================================
