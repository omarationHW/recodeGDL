-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public + public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: TITULOS (Gestión de Títulos de Fosas)
-- Archivo: 33_SP_CEMENTERIOS_TITULOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Actualizado: 2025-12-06 (Creados SPs basados en lógica Pascal real)
-- Total SPs: 3 (basados en queries del Titulos.pas)
-- ============================================
--
-- LÓGICA EXTRAÍDA DE: cementerios/Titulos.pas
--
-- Queries originales Pascal:
-- 1. QryFolio (líneas 1794-1810): Buscar título por fecha, folio y operación
-- 2. QryActualiza (líneas 2113-2114): Actualizar número de título
-- 3. spd_13_titextra: SP Informix para datos extras del título
--
-- IMPORTANTE: El Pascal usa una VISTA (v_titulos_cem) para la impresión
-- Esta vista consolida datos de ta_13_titulos + ta_13_datosrcm + ta_13_datosrcmadic
-- ============================================

-- ============================================
-- SP 1/3: sp_titulos_buscar_por_folio_operacion
-- Tipo: FUNCTION (SELECT)
-- Descripción: Busca un título por fecha, folio y operación
-- Lógica original: QryFolio (Titulos.dfm líneas 1794-1810)
-- --------------------------------------------



CREATE OR REPLACE FUNCTION sp_titulos_buscar_por_folio_operacion(
    p_fecha DATE,
    p_folio INTEGER,
    p_operacion INTEGER
)
RETURNS TABLE (
    -- Datos de ta_13_titulos
    tipo SMALLINT,
    titulo INTEGER,
    control_rcm INTEGER,
    fecha DATE,
    id_rec SMALLINT,
    caja CHAR(2),
    operacion INTEGER,
    importe NUMERIC(16,2),
    observaciones VARCHAR(70),
    -- Datos de ta_13_datosrcm (con sufijo _1 para evitar conflictos)
    control_rcm_1 INTEGER,
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
    observaciones_1 VARCHAR(60),
    usuario INTEGER,
    fecha_mov DATE,
    tipo_1 CHAR(1),
    -- Datos de tc_13_cementerios
    nombre_cementerio VARCHAR(60),
    -- Datos de ta_12_passwords
    nombre_usuario VARCHAR(50),
    -- Datos de ta_13_datosrcmadic (OUTER)
    rfc VARCHAR(13),
    curp VARCHAR(18),
    telefono VARCHAR(10),
    -- Campos calculados
    comple VARCHAR(71),
    resultado CHAR(1),
    mensaje TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.tipo,
        a.titulo,
        a.control_rcm,
        a.fecha,
        a.id_rec,
        a.caja,
        a.operacion,
        a.importe,
        a.observaciones,
        b.control_rcm AS control_rcm_1,
        b.cementerio,
        b.clase,
        b.clase_alfa,
        b.seccion,
        b.seccion_alfa,
        b.linea,
        b.linea_alfa,
        b.fosa,
        b.fosa_alfa,
        b.axo_pagado,
        b.metros,
        b.nombre,
        b.domicilio,
        b.exterior,
        b.interior,
        b.colonia,
        b.observaciones AS observaciones_1,
        b.usuario,
        b.fecha_mov,
        b.tipo AS tipo_1,
        c.nombre AS nombre_cementerio,
        e.nombre AS nombre_usuario,
        COALESCE(x.telefono, '')::VARCHAR(20) AS rfc,
        COALESCE(x.clave_ife, '')::VARCHAR(20) AS curp,
        COALESCE(x.telefono, '')::VARCHAR(20) AS telefono,
        (b.domicilio || ' No.' || b.exterior)::VARCHAR(100) AS comple,
        CASE WHEN a.titulo IS NOT NULL THEN 'S' ELSE 'N' ::CHAR(1) END AS resultado,
        CASE WHEN a.titulo IS NOT NULL THEN 'Título encontrado' ELSE 'Título no encontrado' :: text END AS mensaje
    FROM public.ta_13_titulos a
    INNER JOIN public.ta_13_datosrcm b ON a.control_rcm = b.control_rcm
    INNER JOIN public.tc_13_cementerios c ON b.cementerio = c.cementerio
    INNER JOIN public.ta_12_recibos d ON a.fecha = d.fecha
        AND d.id_rec = a.id_rec
        AND d.caja = a.caja
        AND a.operacion = d.operacion
    INNER JOIN public.ta_12_passwords e ON d.id_usuario = e.id_usuario
    LEFT JOIN public.ta_13_datosrcmadic x ON a.control_rcm = x.control_rcm
    WHERE a.fecha = p_fecha
      AND a.control_rcm = p_folio
      AND a.operacion = p_operacion;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION public.sp_titulos_actualizar_datos_extra(
    p_control_rcm INTEGER,
    p_titulo INTEGER,
    p_fecha_imp DATE,
    p_libro INTEGER,
    p_axo INTEGER,
    p_folio INTEGER,
    p_nombre_ben VARCHAR(60),
    p_dom_ben VARCHAR(60),
    p_col_ben VARCHAR(60),
    p_tel_ben VARCHAR(10),
    p_partida VARCHAR(25)
)
RETURNS TABLE (
    resultado CHAR(1),
    mensaje TEXT
) AS $$
DECLARE
    v_existe BOOLEAN;
BEGIN
    -- Validaciones
    IF p_control_rcm IS NULL OR p_titulo IS NULL THEN
        RETURN QUERY SELECT 'N'::CHAR(1), 'Control RCM y Título son requeridos'::TEXT;
        RETURN;
    END IF;

    -- Verificar si ya existe el registro
    SELECT EXISTS(
        SELECT 1 FROM public.ta_13_datosrcmadic
        WHERE control_rcm = p_control_rcm
    ) INTO v_existe;

    IF v_existe THEN
        -- UPDATE: Actualizar datos existentes
        UPDATE public.ta_13_datosrcmadic
        SET
            fecha_imp = p_fecha_imp,
            libro = p_libro,
            axo = p_axo,
            folio = p_folio,
            nombreben = p_nombre_ben,
            domben = p_dom_ben,
            colben = p_col_ben,
            telben = p_tel_ben,
            partida = p_partida
        WHERE control_rcm = p_control_rcm;

        RETURN QUERY SELECT 'S'::CHAR(1), 'Datos adicionales actualizados correctamente'::TEXT;
    ELSE
        -- INSERT: Insertar nuevos datos
        INSERT INTO public.ta_13_datosrcmadic (
            control_rcm,
            fecha_imp,
            libro,
            axo,
            folio,
            nombreben,
            domben,
            colben,
            telben,
            partida
        ) VALUES (
            p_control_rcm,
            p_fecha_imp,
            p_libro,
            p_axo,
            p_folio,
            p_nombre_ben,
            p_dom_ben,
            p_col_ben,
            p_tel_ben,
            p_partida
        );

        RETURN QUERY SELECT 'S'::CHAR(1), 'Datos adicionales insertados correctamente'::TEXT;
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 'N'::CHAR(1), ('Error al actualizar datos adicionales: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_titulos_actualizar_numero
-- Tipo: FUNCTION (UPDATE)
-- Descripción: Actualiza el número de título generado
-- Lógica original: QryActualiza (Titulos.dfm líneas 2113-2114)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_titulos_actualizar_numero(
    p_numero_titulo INTEGER,
    p_fecha DATE,
    p_folio INTEGER,
    p_operacion INTEGER
)
RETURNS TABLE (
    resultado CHAR(1),
    mensaje TEXT,
    titulo_actualizado INTEGER
) AS $$
DECLARE
    v_rows_affected INTEGER;
BEGIN
    -- Validaciones
    IF p_numero_titulo IS NULL OR p_fecha IS NULL OR p_folio IS NULL OR p_operacion IS NULL THEN
        RETURN QUERY SELECT 'N'::CHAR(1), 'Parámetros incompletos'::TEXT, 0::INTEGER;
        RETURN;
    END IF;

    -- Actualizar número de título
    UPDATE public.ta_13_titulos
    SET titulo = p_numero_titulo
    WHERE fecha = p_fecha
      AND control_rcm = p_folio
      AND operacion = p_operacion;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    IF v_rows_affected > 0 THEN
        RETURN QUERY SELECT 'S'::CHAR(1), 'Número de título actualizado correctamente'::TEXT, p_numero_titulo;
    ELSE
        RETURN QUERY SELECT 'N'::CHAR(1), 'No se encontró el título para actualizar'::TEXT, 0::INTEGER;
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 'N'::CHAR(1), ('Error al actualizar título: ' || SQLERRM)::TEXT, 0::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_titulos_actualizar_datos_extra
-- Tipo: FUNCTION (INSERT/UPDATE)
-- Descripción: Actualiza o inserta datos adicionales del título en ta_13_datosrcmadic
-- Lógica original: spd_13_titextra (StoredProc Informix)
-- Parámetros basados en: Titulos.dfm líneas 5810-5858
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_titulos_actualizar_datos_extra(
    p_control_rcm INTEGER,
    p_titulo INTEGER,
    p_fecha_imp DATE,
    p_libro INTEGER,
    p_axo INTEGER,
    p_folio INTEGER,
    p_nombre_ben VARCHAR(60),
    p_dom_ben VARCHAR(60),
    p_col_ben VARCHAR(60),
    p_tel_ben VARCHAR(10),
    p_partida VARCHAR(25)
)
RETURNS TABLE (
    resultado CHAR(1),
    mensaje TEXT
) AS $$
DECLARE
    v_existe BOOLEAN;
BEGIN
    -- Validaciones
    IF p_control_rcm IS NULL OR p_titulo IS NULL THEN
        RETURN QUERY SELECT 'N'::CHAR(1), 'Control RCM y Título son requeridos'::TEXT;
        RETURN;
    END IF;

    -- Verificar si ya existe el registro
    SELECT EXISTS(
        SELECT 1 FROM public.ta_13_datosrcmadic
        WHERE control_rcm = p_control_rcm
    ) INTO v_existe;

    IF v_existe THEN
        -- UPDATE: Actualizar datos existentes
        UPDATE public.ta_13_datosrcmadic
        SET
            fecha_imp = p_fecha_imp,
            libro = p_libro,
            axo = p_axo,
            folio = p_folio,
            nombreben = p_nombre_ben,
            domben = p_dom_ben,
            colben = p_col_ben,
            telben = p_tel_ben,
            partida = p_partida
        WHERE control_rcm = p_control_rcm;

        RETURN QUERY SELECT 'S'::CHAR(1), 'Datos adicionales actualizados correctamente'::TEXT;
    ELSE
        -- INSERT: Insertar nuevos datos
        INSERT INTO public.ta_13_datosrcmadic (
            control_rcm,
            fecha_imp,
            libro,
            axo,
            folio,
            nombreben,
            domben,
            colben,
            telben,
            partida
        ) VALUES (
            p_control_rcm,
            p_fecha_imp,
            p_libro,
            p_axo,
            p_folio,
            p_nombre_ben,
            p_dom_ben,
            p_col_ben,
            p_tel_ben,
            p_partida
        );

        RETURN QUERY SELECT 'S'::CHAR(1), 'Datos adicionales insertados correctamente'::TEXT;
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 'N'::CHAR(1), ('Error al actualizar datos adicionales: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;


-- ============================================

-- SP 3/3: sp_titulos_actualizar_datos_extra
-- Tipo: FUNCTION
-- Descripción:El formulario usa Qryvista para poblar los reportes “CONTRA/SIN” y decidir qué formato imprimir (si la vista está vacía imprime una variante, si no, otra)
-- Lógica original: spd_13_titextra (StoredProc Informix)
-- Parámetros basados en: Titulos.dfm líneas 5810-5858
-- 
CREATE OR REPLACE FUNCTION sp_titulos_vista_por_folio_operacion(
    p_fecha DATE, p_folio INTEGER, p_operacion INTEGER
)
RETURNS TABLE (
    stipo SMALLINT, stitulo INTEGER, scontrol_rcm INTEGER, sfecha DATE,
    sid_rec SMALLINT, scaja CHAR(2), soperacion INTEGER, simporte NUMERIC(16,2),
    sobservaciones VARCHAR(70), sclase SMALLINT, sclase_alfa VARCHAR(10),
    sseccion SMALLINT, sseccion_alfa VARCHAR(10), slinea SMALLINT, slinea_alfa VARCHAR(20),
    sfosa SMALLINT, sfosa_alfa VARCHAR(20), smetros NUMERIC,
    snombre VARCHAR(60), sdomicilio VARCHAR(60), sexterior CHAR(6), sinterior CHAR(6),
    scolonia VARCHAR(30), scementerio VARCHAR(60), snusuario VARCHAR(10),
    srfc VARCHAR(13), scurp VARCHAR(18), stelefono VARCHAR(10), sfecha_imp DATE,
    slibro INTEGER, saxo INTEGER, sfoliot INTEGER,
    snombreben VARCHAR(60), sdomben VARCHAR(60), scolben VARCHAR(60), stelben VARCHAR(10),
    spartida VARCHAR(25)
) AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.v_titulos_cem
  WHERE sfecha = p_fecha
    AND scontrol_rcm = p_folio
    AND soperacion = p_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DE STORED PROCEDURES - TITULOS
-- ============================================
