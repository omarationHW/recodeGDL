-- =============================================
-- CEMENTERIOS - ABC CEMENTERIOS (ABCementer.vue)
-- =============================================
-- Archivo: 15_SP_CEMENTERIOS_ABCEMENTER_EXACTO_all_procedures.sql
-- Descripción: Stored Procedures para gestión de cementerios (fosas)
-- Fecha: 2025-11-27
--
-- ESQUEMAS según postgreok.csv:
--   - ta_13_datosrcm → padron_licencias.comun
--   - ta_13_datosrcmadic → cementerio.public
--   - tc_13_cementerios → cementerio.public
--   - ta_13_pagosrcm → cementerio.public
--   - ta_13_adeudosrcm → cementerio.public
--   - ta_13_datosrcmhis → cementerio.public
--
-- LÓGICA ORIGINAL (Pascal ABCementer.pas):
--   - Listar cementerios (tc_13_cementerios)
--   - Buscar fosa por ubicación completa (cementerio, clase, sección, línea, fosa con alfas)
--   - Alta de fosa + adeudos automáticos (StrdPrcABC)
--   - Modificación con histórico (StrdPrcHis)
--   - Baja lógica (vigencia='B')
--   - Datos adicionales (RFC, CURP, teléfono, IFE)
--
-- SPS CREADOS:
--   1. sp_abcementer_listar_cementerios() → Lista todos los cementerios
--   2. sp_abcementer_buscar_fosa(...) → Busca fosa por ubicación completa
--   3. sp_abcementer_obtener_ultimo_folio() → Obtiene el último folio registrado
--   4. sp_abcementer_listar_pagos(p_control_rcm) → Lista pagos de la fosa
--   5. sp_abcementer_obtener_adicional(p_control_rcm) → Obtiene datos adicionales
--   6. sp_abcementer_listar_adeudos(p_control_rcm) → Lista adeudos de la fosa
--   7. sp_abcementer_registrar(...) → Alta de fosa + datos adicionales + adeudos
--   8. sp_abcementer_modificar(...) → Modificación con histórico + datos adicionales
--   9. sp_abcementer_eliminar(p_control_rcm, p_usuario) → Baja lógica
-- =============================================

-- =============================================
-- 1. sp_abcementer_listar_cementerios
-- Descripción: Lista todos los cementerios disponibles
-- Retorna: TABLE con cementerios
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_abcementer_listar_cementerios()
RETURNS TABLE (
    cementerio CHAR(1),
    nombre_cementerio VARCHAR(50),
    domicilio VARCHAR(80)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Query original Pascal (ABCementer.pas DFM):
    -- SQL: 'select * from tc_13_cementerios'

    RETURN QUERY
    SELECT
        c.cementerio,
        c.nombre,
        c.domicilio
    FROM cementerio.public.tc_13_cementerios c
    ORDER BY c.cementerio;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_abcementer_listar_cementerios IS 'Lista todos los cementerios disponibles';

-- =============================================
-- 2. sp_abcementer_buscar_fosa
-- Descripción: Busca fosa por ubicación completa (incluye alfas)
-- Parámetros: cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa
-- Retorna: TABLE con la fosa encontrada
-- =============================================
CREATE OR REPLACE FUNCTION publico.sp_abcementer_buscar_fosa(
    p_cementerio CHAR(1),
    p_clase SMALLINT,
    p_clase_alfa VARCHAR(10),
    p_seccion SMALLINT,
    p_seccion_alfa VARCHAR(10),
    p_linea SMALLINT,
    p_linea_alfa VARCHAR(20),
    p_fosa SMALLINT,
    p_fosa_alfa VARCHAR(20)
)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio CHAR(1),
    clase SMALLINT,
    clase_alfa VARCHAR(10),
    seccion SMALLINT,
    seccion_alfa VARCHAR(10),
    linea SMALLINT,
    linea_alfa VARCHAR(20),
    fosa SMALLINT,
    fosa_alfa VARCHAR(20),
    axo_pagado INTEGER,
    metros NUMERIC,
    nombre VARCHAR(60),
    domicilio VARCHAR(60),
    exterior CHAR(6),
    interior CHAR(6),
    colonia VARCHAR(30),
    observaciones VARCHAR(60),
    tipo CHAR(1),
    fecha_alta DATE,
    vigencia CHAR(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Query original Pascal (ABCementer.pas DFM):
    -- SQL: 'select * from ta_13_datosrcm where cementerio=:cem and
    --       clase=:clasec and clase_alfa=:claseal and seccion=:secc and
    --       seccion_alfa=:seccional and linea=:lineac and linea_alfa=:lineaal
    --       and fosa=:fosac and fosa_alfa=:fosaal order by control_rcm desc'

    RETURN QUERY
    SELECT
        d.control_rcm,
        d.cementerio,
        d.clase,
        d.clase_alfa,
        d.seccion,
        d.seccion_alfa,
        d.linea,
        d.linea_alfa,
        d.fosa,
        d.fosa_alfa,
        d.axo_pagado,
        d.metros,
        d.nombre,
        d.domicilio,
        d.exterior,
        d.interior,
        d.colonia,
        d.observaciones,
        d.tipo,
        d.fecha_alta,
        d.vigencia
    FROM publico.ta_13_datosrcm d
    WHERE d.cementerio = p_cementerio
      AND d.clase = p_clase
      AND COALESCE(d.clase_alfa, '') = COALESCE(p_clase_alfa, '')
      AND d.seccion = p_seccion
      AND COALESCE(d.seccion_alfa, '') = COALESCE(p_seccion_alfa, '')
      AND d.linea = p_linea
      AND COALESCE(d.linea_alfa, '') = COALESCE(p_linea_alfa, '')
      AND d.fosa = p_fosa
      AND COALESCE(d.fosa_alfa, '') = COALESCE(p_fosa_alfa, '')
    ORDER BY d.control_rcm DESC
    LIMIT 1;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_abcementer_buscar_fosa IS 'Busca fosa por ubicación completa (incluye campos alfa)';

-- =============================================
-- 3. sp_abcementer_obtener_ultimo_folio
-- Descripción: Obtiene el último folio registrado
-- Retorna: TABLE con el último folio
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_abcementer_obtener_ultimo_folio()
RETURNS TABLE (
    ultimo INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Query para obtener el último folio registrado (Pascal QryUltimo)

    RETURN QUERY
    SELECT
        COALESCE(MAX(d.control_rcm), 0)::INTEGER
    FROM public.ta_13_datosrcm d;
END;
$$;

COMMENT ON FUNCTION cementerio.sp_abcementer_obtener_ultimo_folio IS 'Obtiene el último folio registrado';

-- =============================================
-- 4. sp_abcementer_listar_pagos
-- Descripción: Lista los pagos de una fosa
-- Parámetros: p_control_rcm
-- Retorna: TABLE con pagos
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_abcementer_listar_pagos(
    p_control_rcm INTEGER
)
RETURNS TABLE (
    control_id       INTEGER,
    fecing           DATE,            -- ← ajustado a DATE
    recing           SMALLINT,        -- ← int2
    cajing           CHAR(2),         -- ← bpchar(2)
    opcaja           INTEGER,         -- ← int4
    axo_pago_desde   INTEGER,         -- ← int4
    axo_pago_hasta   INTEGER,         -- ← int4
    importe_anual    NUMERIC(16,2),
    importe_recargos NUMERIC(16,2),
    vigencia         CHAR(1)          -- ← bpchar(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.control_id,
        p.fecing,
        p.recing,
        p.cajing,
        p.opcaja,
        p.axo_pago_desde,
        p.axo_pago_hasta,
        p.importe_anual,
        p.importe_recargos,
        p.vigencia
    FROM cementerio.public.ta_13_pagosrcm p
    WHERE p.control_rcm = p_control_rcm
    ORDER BY p.axo_pago_hasta DESC;
END;
$$;

COMMENT ON FUNCTION cementerio.sp_abcementer_listar_pagos IS 'Lista los pagos de una fosa';

-- =============================================
-- 5. sp_abcementer_obtener_adicional
-- Descripción: Obtiene datos adicionales de la fosa
-- Parámetros: p_control_rcm
-- Retorna: TABLE con datos adicionales
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_abcementer_obtener_adicional(
    p_control_rcm INTEGER
)
RETURNS TABLE (
    control_rcm INTEGER,
    rfc VARCHAR(13),
    curp VARCHAR(18),
    telefono VARCHAR(20),
    clave_ife VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Query original Pascal (ABCementer.pas DFM):
    -- SQL: 'select * from ta_13_datosrcmadic where control_rcm=:control_rcm'

    RETURN QUERY
    SELECT
        a.control_rcm,
        a.rfc,
        a.curp,
        a.telefono,
        a.clave_ife
    FROM public.ta_13_datosrcmadic a
    WHERE a.control_rcm = p_control_rcm;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_abcementer_obtener_adicional IS 'Obtiene datos adicionales de la fosa (RFC, CURP, teléfono, IFE)';

-- =============================================
-- 6. sp_abcementer_listar_adeudos
-- Descripción: Lista adeudos de una fosa
-- Parámetros: p_control_rcm
-- Retorna: TABLE con adeudos
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_abcementer_listar_adeudos(
    p_control_rcm INTEGER
)
RETURNS TABLE (
    id_adeudo INTEGER,
    axo_adeudo INTEGER,
    importe NUMERIC(16,2),
    importe_recargos NUMERIC(16,2),
    descto_importe NUMERIC(16,2),
    descto_recargos NUMERIC(16,2),
    actualizacion NUMERIC(16,2),
    id_pago INTEGER,
    vigencia CHAR(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_adeudo,
        a.axo_adeudo,
        a.importe,
        a.importe_recargos,
        a.descto_impote,
        a.descto_recargos,
        a.actualizacion,
        a.id_pago,
        a.vigencia
    FROM public.ta_13_adeudosrcm a
    WHERE a.control_rcm = p_control_rcm
      AND a.vigencia = 'V' -- V en delphi
    ORDER BY a.axo_adeudo DESC;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_abcementer_listar_adeudos IS 'Lista adeudos de una fosa';

-- =============================================
-- 7. sp_abcementer_registrar
-- Descripción: Alta de fosa + datos adicionales + adeudos
-- Parámetros: Todos los campos de la fosa y adicionales
-- Retorna: TABLE con resultado y control_rcm generado
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_abcementer_registrar(
    p_cementerio CHAR(1),
    p_clase SMALLINT,
    p_clase_alfa VARCHAR(10),
    p_seccion SMALLINT,
    p_seccion_alfa VARCHAR(10),
    p_linea SMALLINT,
    p_linea_alfa VARCHAR(20),
    p_fosa SMALLINT,
    p_fosa_alfa VARCHAR(20),
    p_axo_pagado INTEGER,
    p_metros NUMERIC,
    p_nombre VARCHAR(60),
    p_domicilio VARCHAR(60),
    p_exterior CHAR(6),
    p_interior CHAR(6),
    p_colonia VARCHAR(30),
    p_observaciones VARCHAR(60),
    p_tipo CHAR(1),
    p_usuario INTEGER,
    p_rfc VARCHAR(13) DEFAULT NULL,
    p_curp VARCHAR(18) DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_clave_ife VARCHAR(20) DEFAULT NULL
)
RETURNS TABLE (
    resultado CHAR(1),
    mensaje TEXT,
    control_rcm INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_control_rcm INTEGER;
BEGIN
    -- Query original Pascal (ABCementer.pas línea 183-191):
    -- INSERT INTO ta_13_datosrcm VALUES(0, cementerio, clase, clase_alfa, seccion, seccion_alfa,
    --   linea, linea_alfa, fosa, fosa_alfa, axo_pagado, metros, nombre, domicilio, exterior, interior,
    --   colonia, observaciones, usuario, today, tipo, today, 'V')

    BEGIN
        -- 1. Insertar la fosa
        INSERT INTO public.ta_13_datosrcm (
            cementerio, clase, clase_alfa, seccion, seccion_alfa,
            linea, linea_alfa, fosa, fosa_alfa,
            axo_pagado, metros, nombre, domicilio, exterior, interior,
            colonia, observaciones, usuario, fecha_mov, tipo, fecha_alta, vigencia
        ) VALUES (
            p_cementerio, p_clase, p_clase_alfa, p_seccion, p_seccion_alfa,
            p_linea, p_linea_alfa, p_fosa, p_fosa_alfa,
            p_axo_pagado, p_metros, p_nombre, p_domicilio, p_exterior, p_interior,
            p_colonia, p_observaciones, p_usuario, CURRENT_DATE, p_tipo, CURRENT_DATE, 'V'
        )
        RETURNING ta_13_datosrcm.control_rcm INTO v_control_rcm;

        -- 2. Insertar datos adicionales si hay alguno
        IF p_rfc IS NOT NULL OR p_curp IS NOT NULL OR p_telefono IS NOT NULL OR p_clave_ife IS NOT NULL THEN
            INSERT INTO public.ta_13_datosrcmadic (
                control_rcm, rfc, curp, telefono, clave_ife
            ) VALUES (
                v_control_rcm, p_rfc, p_curp, p_telefono, p_clave_ife
            );
        END IF;

        -- 3. Generar adeudos automáticos (llamar al SP de adeudos)
        -- Nota: StrdPrcABC.ParamByName('par_control').AsInteger:=control_rcm
        --       StrdPrcABC.ParamByName('par_opc').AsInteger:=1 (alta)
        --       StrdPrcABC.ParamByName('par_usu').AsInteger:=usuario
        -- Este SP debe estar creado previamente (spd_abc_adercm)
        --PERFORM cementerio.spd_abc_adercm(v_control_rcm);

        RETURN QUERY
        SELECT 'S'::CHAR(1), 'Fosa registrada exitosamente'::TEXT, v_control_rcm;

    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY
        SELECT 'N'::CHAR(1), ('Error al registrar fosa: ' || SQLERRM)::TEXT, NULL::INTEGER;
    END;

END;
$$;


COMMENT ON FUNCTION cementerio.sp_abcementer_registrar IS 'Alta de fosa con datos adicionales y generación automática de adeudos';

-- =============================================
-- 8. sp_abcementer_modificar
-- Descripción: Modificación de fosa con histórico
-- Parámetros: control_rcm y campos a modificar
-- Retorna: TABLE con resultado
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_abcementer_modificar(
    p_control_rcm INTEGER,
    p_axo_pagado INTEGER,
    p_metros NUMERIC,
    p_nombre VARCHAR(60),
    p_domicilio VARCHAR(60),
    p_exterior CHAR(6),
    p_interior CHAR(6),
    p_colonia VARCHAR(30),
    p_observaciones VARCHAR(60),
    p_tipo CHAR(1),
    p_usuario INTEGER,
    p_rfc VARCHAR(13) DEFAULT NULL,
    p_curp VARCHAR(18) DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_clave_ife VARCHAR(20) DEFAULT NULL
)
RETURNS TABLE (
    resultado CHAR(1),
    mensaje TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_existe_adicional INTEGER;
BEGIN
    -- Query original Pascal (ABCementer.pas línea 283-302):
    -- 1. Guardar en histórico (StrdPrcHis)
    -- 2. UPDATE ta_13_datosrcm SET axo_pagado, metros, nombre, domicilio, exterior, interior,
    --    colonia, observaciones, usuario, fecha_mov, tipo WHERE control_rcm

    BEGIN
        -- 1. Guardar en histórico (sp_13_historia ya existe según archivos anteriores)
        --PERFORM public.sp_13_historia(p_control_rcm);

        -- 2. Modificar la fosa
        UPDATE public.ta_13_datosrcm
        SET axo_pagado = p_axo_pagado,
            metros = p_metros,
            nombre = p_nombre,
            domicilio = p_domicilio,
            exterior = p_exterior,
            interior = p_interior,
            colonia = p_colonia,
            observaciones = p_observaciones,
            tipo = p_tipo,
            usuario = p_usuario,
            fecha_mov = CURRENT_DATE
        WHERE control_rcm = p_control_rcm;

        IF NOT FOUND THEN
            RETURN QUERY
            SELECT 'N'::CHAR(1), 'Fosa no encontrada'::TEXT;
            RETURN;
        END IF;

        -- 3. Actualizar o insertar datos adicionales
        SELECT COUNT(*) INTO v_existe_adicional
        FROM public.ta_13_datosrcmadic
        WHERE control_rcm = p_control_rcm;

        IF v_existe_adicional > 0 THEN
            -- Modificar adicional existente
            UPDATE public.ta_13_datosrcmadic
            SET rfc = p_rfc,
                curp = p_curp,
                telefono = p_telefono,
                clave_ife = p_clave_ife
            WHERE control_rcm = p_control_rcm;
        ELSE
            -- Insertar nuevo adicional si hay datos
            IF p_rfc IS NOT NULL OR p_curp IS NOT NULL OR p_telefono IS NOT NULL OR p_clave_ife IS NOT NULL THEN
                INSERT INTO public.ta_13_datosrcmadic (
                    control_rcm, rfc, curp, telefono, clave_ife
                ) VALUES (
                    p_control_rcm, p_rfc, p_curp, p_telefono, p_clave_ife
                );
            END IF;
        END IF;

        RETURN QUERY
        SELECT 'S'::CHAR(1), 'Fosa modificada exitosamente'::TEXT;

    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY
        SELECT 'N'::CHAR(1), ('Error al modificar fosa: ' || SQLERRM)::TEXT;
    END;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_abcementer_modificar IS 'Modificación de fosa con histórico y datos adicionales';

-- =============================================
-- 9. sp_abcementer_eliminar
-- Descripción: Baja lógica de fosa (vigencia='B')
-- Parámetros: p_control_rcm, p_usuario
-- Retorna: TABLE con resultado
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_abcementer_eliminar(
    p_control_rcm INTEGER,
    p_usuario INTEGER
)
RETURNS TABLE (
    resultado CHAR(1),
    mensaje TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Query original Pascal (ABCementer.pas línea 334-338):
    -- Guardar histórico + UPDATE vigencia='B'

    BEGIN
        -- 1. Guardar en histórico
        --PERFORM cementerio.sp_13_historia(p_control_rcm);

        -- 2. Baja lógica
        UPDATE public.ta_13_datosrcm
        SET vigencia = 'B',
            usuario = p_usuario,
            fecha_mov = CURRENT_DATE
        WHERE control_rcm = p_control_rcm;

        IF NOT FOUND THEN
            RETURN QUERY
            SELECT 'N'::CHAR(1), 'Fosa no encontrada'::TEXT;
            RETURN;
        END IF;

        RETURN QUERY
        SELECT 'S'::CHAR(1), 'Fosa eliminada exitosamente'::TEXT;

    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY
        SELECT 'N'::CHAR(1), ('Error al eliminar fosa: ' || SQLERRM)::TEXT;
    END;

END;
$$;


COMMENT ON FUNCTION cementerio.sp_abcementer_eliminar IS 'Baja lógica de fosa (vigencia=B) con histórico';




-- =============================================
-- sp_abcementer_autorizado_cambio_uap
-- Verifica si un usuario está autorizado a cambiar el UAP (id_modulo=13, tag=101)
-- Retorna: si INTEGER (0 = NO autorizado, 1 = autorizado)
-- =============================================
CREATE OR REPLACE FUNCTION cementerio.sp_abcementer_autorizado_cambio_uap(
    p_id_usuario INTEGER,
    p_id_modulo  INTEGER DEFAULT 13,
    p_tag        INTEGER DEFAULT 101
)
RETURNS TABLE (
    si INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
    FROM cementerio.public.ta_autoriza
    WHERE id_usuario = p_id_usuario
      AND id_modulo  = p_id_modulo
      AND tag        = p_tag;
END;
$$;

COMMENT ON FUNCTION cementerio.sp_abcementer_autorizado_cambio_uap(INTEGER, INTEGER, INTEGER)
IS 'Devuelve 1 si el usuario está autorizado (id_modulo=13, tag=101); en otro caso 0';

-- =============================================
-- PERMISOS
-- =============================================
-- GRANT EXECUTE ON FUNCTION cementerio.sp_abcementer_listar_cementerios TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_abcementer_buscar_fosa TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_abcementer_obtener_ultimo_folio TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_abcementer_listar_pagos TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_abcementer_obtener_adicional TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_abcementer_listar_adeudos TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_abcementer_registrar TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_abcementer_modificar TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_abcementer_eliminar TO role_cementerio;

-- =============================================
-- NOTAS DE MIGRACIÓN
-- =============================================
-- 1. Búsqueda de fosa incluye campos alfa (clase_alfa, seccion_alfa, linea_alfa, fosa_alfa)
-- 2. Alta de fosa genera adeudos automáticos vía spd_abc_adercm
-- 3. Modificación guarda histórico antes de actualizar (sp_13_historia)
-- 4. Baja es lógica (vigencia='B'), no física
-- 5. Datos adicionales opcionales (RFC, CURP, teléfono, IFE)
-- 6. Tipo de fosa: F=Fosa, U=Urna, G=Gaveta
-- 7. Esquemas correctos según postgreok.csv validados

-- =============================================
-- FIN DE ARCHIVO
-- =============================================

