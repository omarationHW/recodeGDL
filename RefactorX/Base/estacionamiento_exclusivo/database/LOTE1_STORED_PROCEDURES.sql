-- ================================================================
-- LOTE 1: Stored Procedures para Catálogos y ABC
-- Módulo: Estacionamiento Exclusivo
-- Fecha: 2025-12-05
-- ================================================================

-- ================================================================
-- 1. SP_EJECUTORES_LISTAR
-- Lista todos los ejecutores (tabla compartida en padron_licencias)
-- ================================================================
CREATE OR REPLACE FUNCTION public.sp_ejecutores_listar(
    p_q TEXT DEFAULT ''
)
RETURNS TABLE(
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    nombre VARCHAR,
    ini_rfc VARCHAR,
    categoria VARCHAR,
    id_rec SMALLINT,
    observacion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id_ejecutor,
        e.cve_eje,
        e.nombre,
        e.ini_rfc,
        e.categoria,
        e.id_rec,
        e.observacion
    FROM padron_licencias.comun.tb_ejecutores e
    WHERE
        (p_q = '' OR
         e.nombre ILIKE '%' || p_q || '%' OR
         CAST(e.cve_eje AS TEXT) ILIKE '%' || p_q || '%')
    ORDER BY e.nombre;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- 2. SP_REASIGNAR_EJECUTOR
-- Reasigna ejecutor a un rango de folios
-- ================================================================
CREATE OR REPLACE FUNCTION public.sp_reasignar_ejecutor(
    p_folio_desde INTEGER,
    p_folio_hasta INTEGER,
    p_ejecutor INTEGER,
    p_recaudadora INTEGER DEFAULT 1
)
RETURNS TABLE(
    result TEXT,
    registros_afectados INTEGER
) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Actualizar los folios en el rango
    UPDATE public.ta_15_apremios
    SET
        ejecutor = p_ejecutor,
        fecha_actualiz = CURRENT_DATE,
        usuario = CURRENT_USER::INTEGER
    WHERE
        zona = p_recaudadora
        AND folio >= p_folio_desde
        AND folio <= p_folio_hasta
        AND vigencia = '1';

    GET DIAGNOSTICS v_count = ROW_COUNT;

    RETURN QUERY SELECT
        CASE
            WHEN v_count > 0 THEN 'Reasignación exitosa'::TEXT
            ELSE 'No se encontraron folios en el rango'::TEXT
        END,
        v_count;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- 3. SP_AUTORIZAR_DESCUENTO
-- Autoriza descuento en un folio específico
-- ================================================================
CREATE OR REPLACE FUNCTION public.sp_autorizar_descuento(
    p_folio INTEGER,
    p_recaudadora INTEGER,
    p_modulo INTEGER,
    p_porcentaje INTEGER,
    p_cveaut INTEGER DEFAULT 1
)
RETURNS TABLE(
    result TEXT
) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Validar que el porcentaje esté entre 0 y 100
    IF p_porcentaje < 0 OR p_porcentaje > 100 THEN
        RETURN QUERY SELECT 'Porcentaje debe estar entre 0 y 100'::TEXT;
        RETURN;
    END IF;

    -- Actualizar el descuento
    UPDATE public.ta_15_apremios
    SET
        porcentaje_multa = p_porcentaje,
        fecha_actualiz = CURRENT_DATE,
        usuario = CURRENT_USER::INTEGER
    WHERE
        zona = p_recaudadora
        AND folio = p_folio
        AND modulo = p_modulo
        AND vigencia = '1';

    GET DIAGNOSTICS v_count = ROW_COUNT;

    RETURN QUERY SELECT
        CASE
            WHEN v_count > 0 THEN 'Descuento autorizado correctamente'::TEXT
            ELSE 'No se encontró el folio especificado'::TEXT
        END;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- 4. SP_MODIFICAR_APREMIO
-- Modifica un registro de apremio (acepta JSON)
-- ================================================================
CREATE OR REPLACE FUNCTION public.sp_modificar_apremio(
    p_datos JSON
)
RETURNS TABLE(
    result TEXT
) AS $$
DECLARE
    v_folio INTEGER;
    v_zona INTEGER;
    v_count INTEGER;
BEGIN
    -- Extraer valores del JSON
    v_folio := (p_datos->>'folio')::INTEGER;
    v_zona := COALESCE((p_datos->>'zona')::INTEGER, 1);

    -- Actualizar el registro
    UPDATE public.ta_15_apremios
    SET
        diligencia = COALESCE(p_datos->>'diligencia', diligencia),
        importe_global = COALESCE((p_datos->>'importe_global')::NUMERIC, importe_global),
        observaciones = COALESCE(p_datos->>'observaciones', observaciones),
        fecha_actualiz = CURRENT_DATE,
        usuario = CURRENT_USER::INTEGER
    WHERE
        zona = v_zona
        AND folio = v_folio
        AND vigencia = '1';

    GET DIAGNOSTICS v_count = ROW_COUNT;

    RETURN QUERY SELECT
        CASE
            WHEN v_count > 0 THEN 'Registro modificado correctamente'::TEXT
            ELSE 'No se encontró el registro especificado'::TEXT
        END;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- 5. SP_MODIFICAR_BIEN_APREMIO
-- Modifica bienes embargables de un apremio
-- ================================================================
CREATE OR REPLACE FUNCTION public.sp_modificar_bien_apremio(
    p_datos JSON
)
RETURNS TABLE(
    result TEXT
) AS $$
BEGIN
    -- Nota: Esta función requiere tabla de bienes embargables
    -- Por ahora retorna mensaje de no implementado
    RETURN QUERY SELECT 'Función en desarrollo - requiere tabla ta_bienes_apremios'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- 6. SP_MODIFICAR_MASIVA_APREMIOS
-- Modificación masiva de apremios en un rango
-- ================================================================
CREATE OR REPLACE FUNCTION public.sp_modificar_masiva_apremios(
    p_folio_desde INTEGER,
    p_folio_hasta INTEGER,
    p_modulo INTEGER DEFAULT 28,
    p_recaudadora INTEGER DEFAULT 1,
    p_accion VARCHAR DEFAULT 'actualizar'
)
RETURNS TABLE(
    result TEXT,
    registros_afectados INTEGER
) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Realizar la acción según el parámetro
    CASE p_accion
        WHEN 'cancelar' THEN
            UPDATE public.ta_15_apremios
            SET
                vigencia = '3',
                clave_mov = '3',
                fecha_actualiz = CURRENT_DATE,
                usuario = CURRENT_USER::INTEGER
            WHERE
                zona = p_recaudadora
                AND modulo = p_modulo
                AND folio >= p_folio_desde
                AND folio <= p_folio_hasta
                AND vigencia = '1';

        WHEN 'marcar_practicado' THEN
            UPDATE public.ta_15_apremios
            SET
                clave_practicado = 'P',
                fecha_practicado = CURRENT_DATE,
                fecha_actualiz = CURRENT_DATE,
                usuario = CURRENT_USER::INTEGER
            WHERE
                zona = p_recaudadora
                AND modulo = p_modulo
                AND folio >= p_folio_desde
                AND folio <= p_folio_hasta
                AND vigencia = '1';

        ELSE
            UPDATE public.ta_15_apremios
            SET
                fecha_actualiz = CURRENT_DATE,
                usuario = CURRENT_USER::INTEGER
            WHERE
                zona = p_recaudadora
                AND modulo = p_modulo
                AND folio >= p_folio_desde
                AND folio <= p_folio_hasta
                AND vigencia = '1';
    END CASE;

    GET DIAGNOSTICS v_count = ROW_COUNT;

    RETURN QUERY SELECT
        CASE
            WHEN v_count > 0 THEN 'Modificación masiva aplicada: ' || v_count || ' registros'
            ELSE 'No se encontraron registros en el rango especificado'
        END::TEXT,
        v_count;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- 7. SP_CAMBIAR_PASSWORD_USUARIO
-- Cambia la contraseña de un usuario (en padron_licencias.comun)
-- ================================================================
CREATE OR REPLACE FUNCTION padron_licencias.comun.sp_cambiar_password_usuario(
    p_usuario VARCHAR,
    p_password_actual VARCHAR,
    p_password_nuevo VARCHAR
)
RETURNS TABLE(
    result TEXT
) AS $$
DECLARE
    v_count INTEGER;
    v_password_almacenado VARCHAR;
BEGIN
    -- Verificar que el usuario existe y la contraseña actual es correcta
    SELECT password INTO v_password_almacenado
    FROM padron_licencias.comun.tb_usuarios
    WHERE usuario = p_usuario;

    IF NOT FOUND THEN
        RETURN QUERY SELECT 'Usuario no encontrado'::TEXT;
        RETURN;
    END IF;

    -- Verificar password actual (comparación simple, sin encriptación por ahora)
    IF v_password_almacenado != p_password_actual THEN
        RETURN QUERY SELECT 'Contraseña actual incorrecta'::TEXT;
        RETURN;
    END IF;

    -- Actualizar la contraseña
    UPDATE padron_licencias.comun.tb_usuarios
    SET
        password = p_password_nuevo,
        fecha_cambio_password = CURRENT_TIMESTAMP
    WHERE usuario = p_usuario;

    GET DIAGNOSTICS v_count = ROW_COUNT;

    -- Registrar en historial (si existe tabla)
    BEGIN
        INSERT INTO padron_licencias.comun.tb_historial_passwords (
            usuario,
            fecha_cambio,
            ip_origen
        ) VALUES (
            p_usuario,
            CURRENT_TIMESTAMP,
            inet_client_addr()::TEXT
        );
    EXCEPTION WHEN OTHERS THEN
        -- Si no existe la tabla de historial, continuar sin error
        NULL;
    END;

    RETURN QUERY SELECT
        CASE
            WHEN v_count > 0 THEN 'Contraseña actualizada correctamente'::TEXT
            ELSE 'Error al actualizar la contraseña'::TEXT
        END;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- 8. SP_HISTORIAL_PASSWORDS
-- Obtiene el historial de cambios de contraseña
-- ================================================================
CREATE OR REPLACE FUNCTION padron_licencias.comun.sp_historial_passwords()
RETURNS TABLE(
    usuario VARCHAR,
    fecha_cambio TIMESTAMP,
    ip_origen VARCHAR
) AS $$
BEGIN
    -- Intentar obtener historial si existe la tabla
    BEGIN
        RETURN QUERY
        SELECT
            h.usuario,
            h.fecha_cambio,
            h.ip_origen
        FROM padron_licencias.comun.tb_historial_passwords h
        ORDER BY h.fecha_cambio DESC
        LIMIT 100;
    EXCEPTION WHEN OTHERS THEN
        -- Si no existe la tabla, retornar vacío
        RETURN;
    END;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- FIN DE SCRIPT
-- ================================================================
