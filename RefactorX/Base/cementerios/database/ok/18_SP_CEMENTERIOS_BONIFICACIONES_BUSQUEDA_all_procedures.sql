-- =============================================
-- MÓDULO: Bonificaciones de Cementerios - Búsqueda
-- ARCHIVO: 18_SP_CEMENTERIOS_BONIFICACIONES_BUSQUEDA_all_procedures.sql
-- DESCRIPCIÓN: SPs adicionales para búsqueda de oficios y folios
-- FECHA: 2025-11-25
-- NOTA: Complementa a 04_SP_CEMENTERIOS_BONIFICACIONES (CRUD)
-- ESQUEMAS SEGÚN postgreok.csv:
--   - ta_13_bonifrcm → cementerio.public
--   - ta_13_datosrcm → padron_licencias.comun
-- =============================================

-- =============================================
-- SP 1: sp_bonificaciones_buscar_oficio
-- Busca una bonificación por oficio, año y doble
-- Origen: Bonificaciones.vue línea 385-400
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_bonificaciones_buscar_oficio(
    p_oficio INTEGER,
    p_axo SMALLINT,
    p_doble bpchar(1)
)
RETURNS TABLE(
    control_bon INTEGER,
    oficio INTEGER,
    axo SMALLINT,
    doble CHAR(1),
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
    fecha_ofic DATE,
    importe_bonificar NUMERIC(16,2),
    importe_bonificado NUMERIC(16,2),
    importe_resto NUMERIC(16,2),
    usuario INTEGER,
    fecha_mov DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.control_bon,
        b.oficio,
        b.axo,
        b.doble,
        b.control_rcm,
        b.cementerio,
        b.clase,
        b.clase_alfa,
        b.seccion,
        b.seccion_alfa,
        b.linea,
        b.linea_alfa,
        b.fosa,
        b.fosa_alfa,
        b.fecha_ofic,
        b.importe_bonificar,
        b.importe_bonificado,
        b.importe_resto,
        b.usuario,
        b.fecha_mov
    FROM public.ta_13_bonifrcm b
    WHERE b.oficio = p_oficio
      AND b.axo = p_axo
      AND b.doble = p_doble;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- SP 2: sp_bonificaciones_buscar_folio
-- Busca un folio en ta_13_datosrcm
-- Origen: Bonificaciones.vue línea 481-492
-- =============================================
CREATE OR REPLACE FUNCTION cementerio.sp_bonificaciones_buscar_folio(
    p_control_rcm INTEGER
)
RETURNS TABLE(
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
    nombre VARCHAR(60),
    vigencia CHAR(1),
    usuario INTEGER,
    fecha_mov DATE
) AS $$
BEGIN
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
        d.nombre,
        d.vigencia,
        d.usuario,
        d.fecha_mov
    FROM padron_licencias.comun.ta_13_datosrcm d
    WHERE d.control_rcm = p_control_rcm
      AND d.vigencia = 'A';
END;
$$ LANGUAGE plpgsql;


-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: Bonificaciones (EXACTO del archivo original)
-- Archivo: 04_SP_CEMENTERIOS_BONIFICACIONES_EXACTO_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_bonificaciones_create
-- Tipo: CRUD
-- Descripción: Crea una nueva bonificación en ta_13_bonifrcm
-- --------------------------------------------


CREATE OR REPLACE FUNCTION public.sp_bonificaciones_create(
    p_oficio             INTEGER,
    p_axo                SMALLINT,
    p_doble              CHAR(1),
    p_control_rcm        INTEGER,
    p_cementerio         CHAR(1),
    p_clase              SMALLINT,
    p_clase_alfa         VARCHAR(10),
    p_seccion            SMALLINT,
    p_seccion_alfa       VARCHAR(10),
    p_linea              SMALLINT,
    p_linea_alfa         VARCHAR(20),
    p_fosa               SMALLINT,
    p_fosa_alfa          VARCHAR(20),
    p_fecha_ofic         DATE,
    p_importe_bonificar  NUMERIC(16,2),
    p_importe_bonificado NUMERIC(16,2),
    p_importe_resto      NUMERIC(16,2),
    p_usuario            INTEGER,
    p_fecha_mov          DATE DEFAULT CURRENT_DATE
) RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_error TEXT;
BEGIN
    INSERT INTO public.ta_13_bonifrcm (
        oficio, axo, doble,
        control_rcm, cementerio, clase, clase_alfa,
        seccion, seccion_alfa,
        linea, linea_alfa,
        fosa, fosa_alfa,
        fecha_ofic,
        importe_bonificar, importe_bonificado, importe_resto,
        usuario,
        fecha_mov
    ) VALUES (
        p_oficio, p_axo, p_doble,
        p_control_rcm, p_cementerio, p_clase, p_clase_alfa,
        p_seccion, p_seccion_alfa,
        p_linea, p_linea_alfa,
        p_fosa, p_fosa_alfa,
        p_fecha_ofic,
        p_importe_bonificar, p_importe_bonificado, p_importe_resto,
        p_usuario,
        COALESCE(p_fecha_mov, CURRENT_DATE)
    );

    RETURN NULL;

EXCEPTION WHEN OTHERS THEN
    v_error := SQLERRM;
    RETURN v_error;
END;
$$;

-- ============================================

-- SP 2/3: sp_bonificaciones_update
-- Tipo: CRUD
-- Descripción: Actualiza una bonificación existente en ta_13_bonifrcm
-- --------------------------------------------


CREATE OR REPLACE FUNCTION sp_bonificaciones_update(
    p_oficio INTEGER,
    p_axo SMALLINT,
    p_doble CHAR(1),
    p_fecha_ofic DATE,
    p_importe_bonificar NUMERIC(16,2),
    p_importe_bonificado NUMERIC(16,2),
    p_importe_resto NUMERIC(16,2),
    p_usuario INTEGER
) RETURNS void AS $$
BEGIN
    UPDATE public.ta_13_bonifrcm
    SET fecha_ofic = p_fecha_ofic,
        importe_bonificar = p_importe_bonificar,
        importe_bonificado = p_importe_bonificado,
        importe_resto = p_importe_resto,
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE
    WHERE oficio = p_oficio
      AND axo = p_axo
      AND doble = p_doble;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_bonificaciones_delete
-- Tipo: CRUD
-- Descripción: Elimina una bonificación de ta_13_bonifrcm
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bonificaciones_delete(
    p_oficio INTEGER,
    p_axo SMALLINT,
    p_doble CHAR(1),
    p_usuario integer
) RETURNS void AS $$
BEGIN
    DELETE FROM public.ta_13_bonifrcm
    WHERE oficio = p_oficio AND axo = p_axo AND doble = p_doble;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- =============================================
-- COMENTARIOS Y NOTAS:
-- 1. Complementa a 04_SP_CEMENTERIOS_BONIFICACIONES (CRUD)
-- 2. Usa esquemas correctos según postgreok.csv
-- 3. SPs de consulta (solo lectura)
-- =============================================



