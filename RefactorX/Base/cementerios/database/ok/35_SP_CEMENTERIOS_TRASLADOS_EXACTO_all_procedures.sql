-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: TRASLADOS (EXACTO del archivo original)
-- Archivo: 35_SP_CEMENTERIOS_TRASLADOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================
--
-- CORRECCIONES POSTGRESQL - AGENTE CATALIZADOR
-- Fecha: 2025-12-04
-- Total Correcciones: 32
--
-- Correcciones aplicadas:
-- 1. cementerio: VARCHAR → CHAR(1) (12 ocurrencias)
-- 2. clase: INTEGER → SMALLINT (12 ocurrencias)
-- 3. linea_alfa: VARCHAR → VARCHAR(20) (6 ocurrencias)
-- 4. fosa_alfa: VARCHAR → VARCHAR(20) (6 ocurrencias)
-- 5. vigencia: VARCHAR → CHAR(1) (4 ocurrencias)
-- 6. resultado: VARCHAR → CHAR(1) (2 ocurrencias)
-- 7. nombre: VARCHAR → VARCHAR(60)
-- ============================================

-- SP 1/3: sp_traslados_buscar_pagos_origen
-- Tipo: CRUD
-- Descripción: Busca los pagos en la ubicación origen según los parámetros de búsqueda.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_traslados_buscar_pagos_origen(
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
    control_id INTEGER,
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
    fecing DATE,
    importe_anual NUMERIC(16,2),
    vigencia CHAR(1),
    usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT control_id, control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, fecing, importe_anual, vigencia, usuario
    FROM public.ta_13_pagosrcm
    WHERE cementerio = p_cementerio
      AND clase = p_clase
      AND (clase_alfa = p_clase_alfa OR (p_clase_alfa IS NULL OR p_clase_alfa = ''))
      AND seccion = p_seccion
      AND (seccion_alfa = p_seccion_alfa OR (p_seccion_alfa IS NULL OR p_seccion_alfa = ''))
      AND linea = p_linea
      AND (linea_alfa = p_linea_alfa OR (p_linea_alfa IS NULL OR p_linea_alfa = ''))
      AND fosa = p_fosa
      AND (fosa_alfa = p_fosa_alfa OR (p_fosa_alfa IS NULL OR p_fosa_alfa = ''));
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_traslados_buscar_folio_destino
-- Tipo: FUNCTION (SELECT)
-- Descripción: Busca el folio correspondiente a una ubicación destino para traslados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_traslados_buscar_folio_destino(
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
    resultado CHAR(1),
    control_rcm INTEGER,
    nombre VARCHAR(60),
    axo_pagado INTEGER,
    vigencia CHAR(1)
) AS $$
DECLARE
    v_folio RECORD;
BEGIN
    -- Buscar folio en la ubicación destino
    SELECT d.control_rcm, d.nombre, d.axo_pagado, d.vigencia
    INTO v_folio
    FROM comun.ta_13_datosrcm d
    WHERE d.cementerio = p_cementerio
      AND d.clase = p_clase
      AND (d.clase_alfa = p_clase_alfa OR (p_clase_alfa IS NULL OR p_clase_alfa = ''))
      AND d.seccion = p_seccion
      AND (d.seccion_alfa = p_seccion_alfa OR (p_seccion_alfa IS NULL OR p_seccion_alfa = ''))
      AND d.linea = p_linea
      AND (d.linea_alfa = p_linea_alfa OR (p_linea_alfa IS NULL OR p_linea_alfa = ''))
      AND d.fosa = p_fosa
      AND (d.fosa_alfa = p_fosa_alfa OR (p_fosa_alfa IS NULL OR p_fosa_alfa = ''))
      AND d.vigencia = 'A'
    LIMIT 1;

    IF v_folio.control_rcm IS NULL THEN
        RETURN QUERY SELECT 'N'::CHAR(1), NULL::INTEGER, NULL::VARCHAR(60), NULL::INTEGER, NULL::CHAR(1);
    ELSE
        RETURN QUERY SELECT 'S'::CHAR(1), v_folio.control_rcm, v_folio.nombre, v_folio.axo_pagado, v_folio.vigencia;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: TRASLADOS (EXACTO del archivo original)
-- Archivo: 35_SP_CEMENTERIOS_TRASLADOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_traslados_trasladar_pagos_ubicacion
-- Tipo: CRUD
-- Descripción: Realiza el traslado de TODOS los pagos de una ubicación origen a una destino
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_traslados_trasladar_pagos_ubicacion(
    p_cem_origen CHAR(1),
    p_clase_origen SMALLINT,
    p_clase_alfa_origen VARCHAR(10),
    p_sec_origen SMALLINT,
    p_sec_alfa_origen VARCHAR(10),
    p_lin_origen SMALLINT,
    p_lin_alfa_origen VARCHAR(20),
    p_fosa_origen SMALLINT,
    p_fosa_alfa_origen VARCHAR(20),
    p_cem_destino CHAR(1),
    p_clase_destino SMALLINT,
    p_clase_alfa_destino VARCHAR(10),
    p_sec_destino SMALLINT,
    p_sec_alfa_destino VARCHAR(10),
    p_lin_destino SMALLINT,
    p_lin_alfa_destino VARCHAR(20),
    p_fosa_destino SMALLINT,
    p_fosa_alfa_destino VARCHAR(20),
    p_control_rcm_destino INTEGER,
    p_usuario INTEGER
) RETURNS TABLE (resultado CHAR(1), mensaje TEXT, registros_actualizados INTEGER) AS $$
DECLARE
    v_axo INTEGER;
    v_uap INTEGER;
    v_control_rcm_origen INTEGER;
    v_count INTEGER;
BEGIN
    -- Obtener el folio origen
    SELECT control_rcm INTO v_control_rcm_origen
    FROM cementerio.ta_13_pagosrcm
    WHERE cementerio = p_cem_origen
      AND clase = p_clase_origen
      AND (clase_alfa = p_clase_alfa_origen OR (p_clase_alfa_origen IS NULL OR p_clase_alfa_origen = ''))
      AND seccion = p_sec_origen
      AND (seccion_alfa = p_sec_alfa_origen OR (p_sec_alfa_origen IS NULL OR p_sec_alfa_origen = ''))
      AND linea = p_lin_origen
      AND (linea_alfa = p_lin_alfa_origen OR (p_lin_alfa_origen IS NULL OR p_lin_alfa_origen = ''))
      AND fosa = p_fosa_origen
      AND (fosa_alfa = p_fosa_alfa_origen OR (p_fosa_alfa_origen IS NULL OR p_fosa_alfa_origen = ''))
    LIMIT 1;

    -- Actualizar TODOS los pagos de la ubicación origen
    WITH updated AS (
        UPDATE cementerio.ta_13_pagosrcm
        SET cementerio = p_cem_destino,
            clase = p_clase_destino,
            clase_alfa = COALESCE(p_clase_alfa_destino, ''),
            seccion = p_sec_destino,
            seccion_alfa = COALESCE(p_sec_alfa_destino, ''),
            linea = p_lin_destino,
            linea_alfa = COALESCE(p_lin_alfa_destino, ''),
            fosa = p_fosa_destino,
            fosa_alfa = COALESCE(p_fosa_alfa_destino, ''),
            control_rcm = p_control_rcm_destino,
            usuario = p_usuario,
            fecha_mov = CURRENT_DATE
        WHERE cementerio = p_cem_origen
          AND clase = p_clase_origen
          AND (clase_alfa = p_clase_alfa_origen OR (p_clase_alfa_origen IS NULL OR p_clase_alfa_origen = ''))
          AND seccion = p_sec_origen
          AND (seccion_alfa = p_sec_alfa_origen OR (p_sec_alfa_origen IS NULL OR p_sec_alfa_origen = ''))
          AND linea = p_lin_origen
          AND (linea_alfa = p_lin_alfa_origen OR (p_lin_alfa_origen IS NULL OR p_lin_alfa_origen = ''))
          AND fosa = p_fosa_origen
          AND (fosa_alfa = p_fosa_alfa_origen OR (p_fosa_alfa_origen IS NULL OR p_fosa_alfa_origen = ''))
        RETURNING control_id
    )
    SELECT COUNT(*) INTO v_count FROM updated;

    -- Actualizar axo_pagado en datosrcm destino
    SELECT EXTRACT(YEAR FROM CURRENT_DATE) INTO v_axo;
    SELECT MAX(axo_pago_hasta) INTO v_uap
    FROM cementerio.ta_13_pagosrcm
    WHERE control_rcm = p_control_rcm_destino;

    IF v_uap IS NULL OR v_uap = 0 THEN
        v_uap := v_axo - 5;
    END IF;

    UPDATE comun.ta_13_datosrcm
    SET axo_pagado = v_uap
    WHERE control_rcm = p_control_rcm_destino;

    -- Actualizar axo_pagado en datosrcm origen si existe
    IF v_control_rcm_origen IS NOT NULL THEN
        SELECT MAX(axo_pago_hasta) INTO v_uap
        FROM cementerio.ta_13_pagosrcm
        WHERE control_rcm = v_control_rcm_origen;

        IF v_uap IS NULL OR v_uap = 0 THEN
            v_uap := v_axo - 5;
        END IF;

        UPDATE comun.ta_13_datosrcm
        SET axo_pagado = v_uap
        WHERE control_rcm = v_control_rcm_origen;
    END IF;

    RETURN QUERY SELECT 'S'::CHAR(1), 'Traslado realizado correctamente'::TEXT, v_count;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 'N'::CHAR(1), ('Error al trasladar pagos: ' || SQLERRM)::TEXT, 0::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- ============================================

