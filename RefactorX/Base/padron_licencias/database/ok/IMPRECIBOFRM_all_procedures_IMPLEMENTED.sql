-- =============================================
-- COMPONENTE: ImpRecibofrm
-- MÓDULO: padron_licencias
-- DESCRIPCIÓN: Stored Procedures para impresión de recibos de pago
-- TOTAL SPs: 4
-- SCHEMA: comun
-- FECHA: 2025-11-20
-- =============================================

-- =============================================
-- SP 1: sp_imp_recibo_buscar_licencia
-- Descripción: Busca una licencia vigente por número y retorna datos completos
-- Parámetros:
--   p_numero_licencia: Número de licencia a buscar
-- Retorna: Datos completos de la licencia incluyendo domicilio y propietario
-- =============================================
CREATE OR REPLACE FUNCTION comun.sp_imp_recibo_buscar_licencia(
    p_numero_licencia VARCHAR
)
RETURNS TABLE(
    id_licencia INTEGER,
    numero_licencia VARCHAR,
    empresa INTEGER,
    recaud INTEGER,
    id_giro INTEGER,
    x DOUBLE PRECISION,
    y DOUBLE PRECISION,
    zona INTEGER,
    subzona INTEGER,
    tipo_registro VARCHAR,
    actividad VARCHAR,
    cvecuenta INTEGER,
    fecha_otorgamiento DATE,
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
    numint_ubic VARCHAR,
    letrain_ubic VARCHAR,
    colonia_ubic VARCHAR,
    sup_construida DOUBLE PRECISION,
    sup_autorizada DOUBLE PRECISION,
    num_cajones INTEGER,
    num_empleados INTEGER,
    aforo INTEGER,
    inversion NUMERIC,
    rhorario VARCHAR,
    fecha_consejo DATE,
    bloqueado INTEGER,
    asiento INTEGER,
    vigente VARCHAR,
    fecha_baja DATE,
    axo_baja INTEGER,
    folio_baja INTEGER,
    espubic VARCHAR,
    base_impuesto NUMERIC,
    cp INTEGER,
    dom_completo VARCHAR,
    propietario_completo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_licencia,
        l.licencia::VARCHAR as numero_licencia,
        l.empresa,
        l.recaud,
        l.id_giro,
        l.x,
        l.y,
        l.zona,
        l.subzona,
        l.tipo_registro,
        l.actividad,
        l.cvecuenta,
        l.fecha_otorgamiento,
        l.propietario,
        l.primer_ap,
        l.segundo_ap,
        l.rfc,
        l.curp,
        l.domicilio,
        l.numext_prop,
        l.numint_prop,
        l.colonia_prop,
        l.telefono_prop,
        l.email,
        l.cvecalle,
        l.ubicacion,
        l.numext_ubic,
        l.letraext_ubic,
        l.numint_ubic,
        l.letrain_ubic,
        l.colonia_ubic,
        l.sup_construida,
        l.sup_autorizada,
        l.num_cajones,
        l.num_empleados,
        l.aforo,
        l.inversion,
        l.rhorario,
        l.fecha_consejo,
        l.bloqueado,
        l.asiento,
        l.vigente,
        l.fecha_baja,
        l.axo_baja,
        l.folio_baja,
        l.espubic,
        l.base_impuesto,
        l.cp,
        (COALESCE(l.ubicacion, '') || ' ' ||
         COALESCE(l.numext_ubic::TEXT, '') ||
         CASE WHEN l.letraext_ubic IS NOT NULL THEN '-' || l.letraext_ubic ELSE '' END ||
         CASE WHEN l.numint_ubic IS NOT NULL THEN '-' || l.numint_ubic ELSE '' END ||
         CASE WHEN l.letrain_ubic IS NOT NULL THEN '-' || l.letrain_ubic ELSE '' END ||
         CASE WHEN l.colonia_ubic IS NOT NULL THEN ', ' || l.colonia_ubic ELSE '' END)::VARCHAR AS dom_completo,
        (COALESCE(l.primer_ap, '') || ' ' ||
         COALESCE(l.segundo_ap, '') || ' ' ||
         COALESCE(l.propietario, ''))::VARCHAR AS propietario_completo
    FROM comun.licencias l
    WHERE l.licencia::VARCHAR = UPPER(TRIM(p_numero_licencia))
      AND l.vigente = 'V';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_imp_recibo_buscar_licencia(VARCHAR) IS
'Busca una licencia vigente por número para generación de recibo - ImpRecibofrm';


-- =============================================
-- SP 2: sp_imp_recibo_get_licencia_recibo
-- Descripción: Obtiene los datos simplificados de la licencia para el recibo
-- Parámetros:
--   p_numero_licencia: Número de licencia
-- Retorna: Datos esenciales para el recibo (licencia, nombre, domicilio)
-- =============================================
CREATE OR REPLACE FUNCTION comun.sp_imp_recibo_get_licencia_recibo(
    p_numero_licencia VARCHAR
)
RETURNS TABLE(
    licencia VARCHAR,
    nombre TEXT,
    domicilio TEXT,
    id_licencia INTEGER,
    dom_completo TEXT,
    propietario_completo TEXT,
    rfc VARCHAR,
    giro VARCHAR,
    fecha_otorgamiento DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.licencia::VARCHAR,
        (COALESCE(l.primer_ap, '') || ' ' ||
         COALESCE(l.segundo_ap, '') || ' ' ||
         COALESCE(l.propietario, ''))::TEXT AS nombre,
        (COALESCE(l.ubicacion, '') || ' ' ||
         COALESCE(l.numext_ubic::TEXT, '') ||
         CASE WHEN l.letraext_ubic IS NOT NULL THEN '-' || l.letraext_ubic ELSE '' END ||
         CASE WHEN l.numint_ubic IS NOT NULL THEN '-' || l.numint_ubic ELSE '' END ||
         CASE WHEN l.letrain_ubic IS NOT NULL THEN '-' || l.letrain_ubic ELSE '' END)::TEXT AS domicilio,
        l.id_licencia,
        (COALESCE(l.ubicacion, '') || ' ' ||
         COALESCE(l.numext_ubic::TEXT, '') ||
         CASE WHEN l.letraext_ubic IS NOT NULL THEN '-' || l.letraext_ubic ELSE '' END ||
         CASE WHEN l.numint_ubic IS NOT NULL THEN '-' || l.numint_ubic ELSE '' END ||
         CASE WHEN l.letrain_ubic IS NOT NULL THEN '-' || l.letrain_ubic ELSE '' END ||
         CASE WHEN l.colonia_ubic IS NOT NULL THEN ', ' || l.colonia_ubic ELSE '' END)::TEXT AS dom_completo,
        (COALESCE(l.primer_ap, '') || ' ' ||
         COALESCE(l.segundo_ap, '') || ' ' ||
         COALESCE(l.propietario, ''))::TEXT AS propietario_completo,
        l.rfc,
        COALESCE(g.giro, 'SIN GIRO')::VARCHAR AS giro,
        l.fecha_otorgamiento
    FROM comun.licencias l
    LEFT JOIN comun.cat_giros g ON l.id_giro = g.id_giro
    WHERE l.licencia::VARCHAR = UPPER(TRIM(p_numero_licencia))
      AND l.vigente = 'V';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_imp_recibo_get_licencia_recibo(VARCHAR) IS
'Obtiene datos simplificados de licencia para impresión de recibo - ImpRecibofrm';


-- =============================================
-- SP 3: sp_imp_recibo_get_parametros_recibo
-- Descripción: Obtiene los costos configurados para certificación y constancia
-- Parámetros: Ninguno
-- Retorna: Costos de certificación y constancia
-- =============================================
CREATE OR REPLACE FUNCTION comun.sp_imp_recibo_get_parametros_recibo()
RETURNS TABLE(
    costo_certific NUMERIC(10,2),
    costo_constancia NUMERIC(10,2),
    iva_porcentaje NUMERIC(5,2),
    ejercicio_actual INTEGER,
    folio_actual INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(p.costo_certific, 0.00)::NUMERIC(10,2) AS costo_certific,
        COALESCE(p.costo_constancia, 0.00)::NUMERIC(10,2) AS costo_constancia,
        COALESCE(p.iva, 16.00)::NUMERIC(5,2) AS iva_porcentaje,
        COALESCE(p.ejercicio_actual, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER) AS ejercicio_actual,
        COALESCE(p.folio_recibo_actual, 1)::INTEGER AS folio_actual
    FROM comun.parametros_lic p
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_imp_recibo_get_parametros_recibo() IS
'Obtiene parámetros de configuración para recibos (costos, IVA, folios) - ImpRecibofrm';


-- =============================================
-- SP 4: sp_imp_recibo_numero_a_letras
-- Descripción: Convierte un número decimal a su representación en letras (español)
-- Parámetros:
--   p_numero: Cantidad numérica a convertir (formato monetario)
-- Retorna: Texto con el número en letras + formato monetario XX/100 M.N.
-- Nota: Implementación completa para cantidades hasta 999,999,999.99
-- =============================================
CREATE OR REPLACE FUNCTION comun.sp_imp_recibo_numero_a_letras(
    p_numero NUMERIC(12,2)
)
RETURNS TEXT AS $$
DECLARE
    v_entero BIGINT;
    v_decimales INTEGER;
    v_texto TEXT := '';
    v_millones INTEGER;
    v_miles INTEGER;
    v_cientos INTEGER;
BEGIN
    -- Validar número
    IF p_numero IS NULL OR p_numero < 0 THEN
        RETURN 'CANTIDAD INVÁLIDA';
    END IF;

    -- Separar enteros y decimales
    v_entero := FLOOR(p_numero)::BIGINT;
    v_decimales := ROUND((p_numero - v_entero) * 100)::INTEGER;

    -- Caso especial: cero
    IF v_entero = 0 THEN
        v_texto := 'CERO';
    ELSE
        -- Extraer millones, miles y centenas
        v_millones := (v_entero / 1000000)::INTEGER;
        v_miles := ((v_entero % 1000000) / 1000)::INTEGER;
        v_cientos := (v_entero % 1000)::INTEGER;

        -- Procesar millones
        IF v_millones > 0 THEN
            IF v_millones = 1 THEN
                v_texto := 'UN MILLÓN';
            ELSE
                v_texto := comun.sp_imp_recibo_convertir_grupo(v_millones) || ' MILLONES';
            END IF;
        END IF;

        -- Procesar miles
        IF v_miles > 0 THEN
            IF v_texto != '' THEN
                v_texto := v_texto || ' ';
            END IF;

            IF v_miles = 1 THEN
                v_texto := v_texto || 'MIL';
            ELSE
                v_texto := v_texto || comun.sp_imp_recibo_convertir_grupo(v_miles) || ' MIL';
            END IF;
        END IF;

        -- Procesar centenas
        IF v_cientos > 0 THEN
            IF v_texto != '' THEN
                v_texto := v_texto || ' ';
            END IF;
            v_texto := v_texto || comun.sp_imp_recibo_convertir_grupo(v_cientos);
        END IF;
    END IF;

    -- Agregar formato monetario
    v_texto := v_texto || ' PESOS ' || LPAD(v_decimales::TEXT, 2, '0') || '/100 M.N.';

    RETURN v_texto;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION comun.sp_imp_recibo_numero_a_letras(NUMERIC) IS
'Convierte número a letras en español con formato monetario - ImpRecibofrm';


-- =============================================
-- FUNCIÓN AUXILIAR: sp_imp_recibo_convertir_grupo
-- Descripción: Convierte un grupo de hasta 3 dígitos (0-999) a letras
-- Parámetros:
--   p_numero: Número entre 0 y 999
-- Retorna: Representación en letras del número
-- Uso: Función auxiliar interna para sp_imp_recibo_numero_a_letras
-- =============================================
CREATE OR REPLACE FUNCTION comun.sp_imp_recibo_convertir_grupo(
    p_numero INTEGER
)
RETURNS TEXT AS $$
DECLARE
    v_unidades TEXT[] := ARRAY[
        '', 'UNO', 'DOS', 'TRES', 'CUATRO', 'CINCO',
        'SEIS', 'SIETE', 'OCHO', 'NUEVE'
    ];
    v_decenas TEXT[] := ARRAY[
        '', 'DIEZ', 'VEINTE', 'TREINTA', 'CUARENTA', 'CINCUENTA',
        'SESENTA', 'SETENTA', 'OCHENTA', 'NOVENTA'
    ];
    v_especiales TEXT[] := ARRAY[
        'DIEZ', 'ONCE', 'DOCE', 'TRECE', 'CATORCE', 'QUINCE',
        'DIECISÉIS', 'DIECISIETE', 'DIECIOCHO', 'DIECINUEVE'
    ];
    v_centenas TEXT[] := ARRAY[
        '', 'CIENTO', 'DOSCIENTOS', 'TRESCIENTOS', 'CUATROCIENTOS',
        'QUINIENTOS', 'SEISCIENTOS', 'SETECIENTOS', 'OCHOCIENTOS', 'NOVECIENTOS'
    ];
    v_centena INTEGER;
    v_decena INTEGER;
    v_unidad INTEGER;
    v_texto TEXT := '';
BEGIN
    IF p_numero = 0 THEN
        RETURN '';
    END IF;

    IF p_numero > 999 THEN
        RETURN 'ERROR';
    END IF;

    v_centena := (p_numero / 100)::INTEGER;
    v_decena := ((p_numero % 100) / 10)::INTEGER;
    v_unidad := (p_numero % 10)::INTEGER;

    -- Procesar centenas
    IF v_centena > 0 THEN
        IF p_numero = 100 THEN
            v_texto := 'CIEN';
            RETURN v_texto;
        ELSE
            v_texto := v_centenas[v_centena + 1];
        END IF;
    END IF;

    -- Procesar decenas y unidades
    IF v_decena = 0 THEN
        -- Solo unidades
        IF v_unidad > 0 THEN
            IF v_texto != '' THEN
                v_texto := v_texto || ' ';
            END IF;
            v_texto := v_texto || v_unidades[v_unidad + 1];
        END IF;
    ELSIF v_decena = 1 THEN
        -- Casos especiales 10-19
        IF v_texto != '' THEN
            v_texto := v_texto || ' ';
        END IF;
        v_texto := v_texto || v_especiales[v_unidad + 1];
    ELSIF v_decena = 2 THEN
        -- Veinti-
        IF v_texto != '' THEN
            v_texto := v_texto || ' ';
        END IF;
        IF v_unidad = 0 THEN
            v_texto := v_texto || 'VEINTE';
        ELSE
            v_texto := v_texto || 'VEINTI' || v_unidades[v_unidad + 1];
        END IF;
    ELSE
        -- 30-99
        IF v_texto != '' THEN
            v_texto := v_texto || ' ';
        END IF;
        v_texto := v_texto || v_decenas[v_decena + 1];
        IF v_unidad > 0 THEN
            v_texto := v_texto || ' Y ' || v_unidades[v_unidad + 1];
        END IF;
    END IF;

    RETURN v_texto;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION comun.sp_imp_recibo_convertir_grupo(INTEGER) IS
'Función auxiliar para convertir grupos de 3 dígitos a letras - ImpRecibofrm';


-- =============================================
-- VERIFICACIÓN DE INSTALACIÓN
-- =============================================
DO $$
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE 'INSTALACIÓN COMPLETADA: ImpRecibofrm';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Total Stored Procedures: 4 + 1 auxiliar';
    RAISE NOTICE '  1. comun.sp_imp_recibo_buscar_licencia';
    RAISE NOTICE '  2. comun.sp_imp_recibo_get_licencia_recibo';
    RAISE NOTICE '  3. comun.sp_imp_recibo_get_parametros_recibo';
    RAISE NOTICE '  4. comun.sp_imp_recibo_numero_a_letras';
    RAISE NOTICE '  + comun.sp_imp_recibo_convertir_grupo (auxiliar)';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Schema: comun';
    RAISE NOTICE 'Nomenclatura: sp_imp_recibo_*';
    RAISE NOTICE 'Estado: IMPLEMENTADO Y FUNCIONAL';
    RAISE NOTICE '============================================';
END $$;
