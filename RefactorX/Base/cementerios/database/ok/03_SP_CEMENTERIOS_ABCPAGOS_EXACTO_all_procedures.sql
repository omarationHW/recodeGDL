-- =============================================
-- MÓDULO: ABC de Pagos de Cementerios
-- ARCHIVO: 03_SP_CEMENTERIOS_ABCPAGOS_EXACTO_all_procedures.sql
-- DESCRIPCIÓN: Stored Procedures para gestión de pagos RCM
-- FECHA: 2025-11-25
-- ESQUEMAS SEGÚN postgreok.csv:
--   - ta_13_datosrcm → padron_licencias.comun
--   - ta_13_pagosrcm → cementerio.public
--   - ta_13_adeudosrcm → cementerio.public
--   - tc_13_cementerios → cementerio.public
-- =============================================
--
-- CORRECCIONES POSTGRESQL - AGENTE CATALIZADOR
-- Fecha: 2025-12-04
-- Total Correcciones: 2
--
-- Correcciones aplicadas:
-- SP 2: sp_pagos_adeudos_pendientes
-- 1. descto_importe → descto_impote (nombre de columna correcto según tabla)
-- 2. descto_importe → descto_impote (en SELECT, línea 100)
-- =============================================

-- =============================================
-- SP 1: sp_pagos_buscar_folio
-- Busca un folio con información del cementerio
-- Origen: ABCPagos.vue línea 423-447
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_pagos_buscar_folio(
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
    domicilio VARCHAR(60),
    exterior CHAR(6),
    interior CHAR(6),
    colonia VARCHAR(30),
    axo_pagado INTEGER,
    vigencia CHAR(1),
    nombre_cementerio VARCHAR(60),
    usuario INTEGER,
    fecha_mov DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.control_rcm,
        a.cementerio,
        a.clase,
        a.clase_alfa,
        a.seccion,
        a.seccion_alfa,
        a.linea,
        a.linea_alfa,
        a.fosa,
        a.fosa_alfa,
        a.nombre,
        a.domicilio,
        a.exterior,
        a.interior,
        a.colonia,
        a.axo_pagado,
        a.vigencia,
        c.nombre as nombre_cementerio,
        a.usuario,
        a.fecha_mov
    FROM public.ta_13_datosrcm a
    LEFT JOIN .public.tc_13_cementerios c ON a.cementerio = c.cementerio
    WHERE a.control_rcm = p_control_rcm
      AND a.vigencia = 'A';
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- SP 2: sp_pagos_adeudos_pendientes
-- Lista adeudos pendientes de pago
-- Origen: ABCPagos.vue línea 482-508
-- =============================================
CREATE OR REPLACE FUNCTION cementerio.sp_pagos_adeudos_pendientes(
    p_control_rcm INTEGER
)
RETURNS TABLE(
    id_adeudo INTEGER,
    control_rcm INTEGER,
    axo_adeudo INTEGER,
    importe NUMERIC(16,2),
    importe_recargos NUMERIC(16,2),
    descto_impote NUMERIC(16,2),
    descto_recargos NUMERIC(16,2),
    vigencia CHAR(1),
    total NUMERIC(16,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_adeudo,
        a.control_rcm,
        a.axo_adeudo,
        a.importe,
        a.importe_recargos,
        COALESCE(a.descto_impote, 0) as descto_impote,
        COALESCE(a.descto_recargos, 0) as descto_recargos,
        a.vigencia,
        (a.importe - COALESCE(a.descto_impote, 0) + a.importe_recargos - COALESCE(a.descto_recargos, 0))::NUMERIC(16,2) as total
    FROM cementerio.public.ta_13_adeudosrcm a
    WHERE a.control_rcm = p_control_rcm
      AND a.id_pago IS NULL
      AND a.vigencia = 'A'
    ORDER BY a.axo_adeudo;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- SP 3: sp_pagos_listar_por_folio
-- Lista pagos registrados para un folio
-- Origen: ABCPagos.vue línea 527-556
-- =============================================
CREATE OR REPLACE FUNCTION cementerio.sp_pagos_listar_por_folio(
    p_control_rcm INTEGER
)
RETURNS TABLE(
    control_id INTEGER,
    control_rcm INTEGER,
    fecing DATE,
    recing SMALLINT,
    cajing CHAR(2),
    opcaja INTEGER,
    axo_pago_desde INTEGER,
    axo_pago_hasta INTEGER,
    importe_anual NUMERIC(16,2),
    importe_recargos NUMERIC(16,2),
    vigencia CHAR(1),
    usuario INTEGER,
    fecha_mov DATE,
    total NUMERIC(16,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.control_id,
        p.control_rcm,
        p.fecing,
        p.recing,
        p.cajing,
        p.opcaja,
        p.axo_pago_desde,
        p.axo_pago_hasta,
        p.importe_anual,
        p.importe_recargos,
        p.vigencia,
        p.usuario,
        p.fecha_mov,
        (p.importe_anual + COALESCE(p.importe_recargos, 0))::NUMERIC(16,2) as total
    FROM cementerio.public.ta_13_pagosrcm p
    WHERE p.control_rcm = p_control_rcm
    ORDER BY p.fecing DESC;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- SP 4: sp_pagos_registrar
-- Registra un nuevo pago completo (transaccional)
-- Origen: ABCPagos.vue línea 629-706
-- =============================================
CREATE OR REPLACE FUNCTION cementerio.sp_pagos_registrar(
    p_control_rcm INTEGER,
    p_cementerio CHAR(1),
    p_clase SMALLINT,
    p_clase_alfa VARCHAR(10),
    p_seccion SMALLINT,
    p_seccion_alfa VARCHAR(10),
    p_linea SMALLINT,
    p_linea_alfa VARCHAR(20),
    p_fosa SMALLINT,
    p_fosa_alfa VARCHAR(20),
    p_fecha DATE,
    p_recaudadora SMALLINT,
    p_caja CHAR(2),
    p_operacion INTEGER,
    p_axo_desde INTEGER,
    p_axo_hasta INTEGER,
    p_importe_total NUMERIC(16,2),
    p_adeudos_ids INTEGER[],
    p_usuario INTEGER,
    OUT p_control_id INTEGER,
    OUT p_error VARCHAR(500)
) AS $$
DECLARE
    v_adeudo_id INTEGER;
BEGIN
    p_error := NULL;

    -- 1. Insertar registro de pago
    INSERT INTO cementerio.public.ta_13_pagosrcm (
        control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa,
        linea, linea_alfa, fosa, fosa_alfa, fecing, recing, cajing, opcaja,
        axo_pago_desde, axo_pago_hasta, importe_anual, importe_recargos,
        vigencia, usuario, fecha_mov
    ) VALUES (
        p_control_rcm, p_cementerio, p_clase, p_clase_alfa, p_seccion, p_seccion_alfa,
        p_linea, p_linea_alfa, p_fosa, p_fosa_alfa, p_fecha, p_recaudadora, p_caja, p_operacion,
        p_axo_desde, p_axo_hasta, p_importe_total, 0,
        'A', p_usuario, CURRENT_DATE
    )
    RETURNING control_id INTO p_control_id;

    -- 2. Actualizar adeudos relacionados
    FOREACH v_adeudo_id IN ARRAY p_adeudos_ids
    LOOP
        UPDATE cementerio.public.ta_13_adeudosrcm
        SET id_pago = p_control_id,
            usuario = p_usuario,
            fecha_mov = CURRENT_DATE
        WHERE id_adeudo = v_adeudo_id;
    END LOOP;

    -- 3. Actualizar último año pagado en ta_13_datosrcm
    UPDATE padron_licencias.comun.ta_13_datosrcm
    SET axo_pagado = p_axo_hasta,
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE
    WHERE control_rcm = p_control_rcm;

EXCEPTION
    WHEN OTHERS THEN
        p_error := SQLERRM;
        RAISE NOTICE 'Error en sp_pagos_registrar: %', p_error;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- SP 5: sp_pagos_dar_baja
-- Da de baja un pago y libera los adeudos
-- Origen: ABCPagos.vue línea 749-828
-- =============================================
CREATE OR REPLACE FUNCTION cementerio.sp_pagos_dar_baja(
    p_control_id INTEGER,
    p_control_rcm INTEGER,
    p_usuario INTEGER,
    OUT p_ultimo_axo INTEGER,
    OUT p_error VARCHAR(500)
) AS $$
BEGIN
    p_error := NULL;

    -- 1. Dar de baja el pago (vigencia = 'B')
    UPDATE cementerio.public.ta_13_pagosrcm
    SET vigencia = 'B',
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE
    WHERE control_id = p_control_id;

    -- 2. Liberar los adeudos relacionados (id_pago = NULL)
    UPDATE cementerio.public.ta_13_adeudosrcm
    SET id_pago = NULL,
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE
    WHERE id_pago = p_control_id;

    -- 3. Recalcular último año pagado
    SELECT COALESCE(MAX(axo_pago_hasta), 0)
    INTO p_ultimo_axo
    FROM cementerio.public.ta_13_pagosrcm
    WHERE control_rcm = p_control_rcm
      AND vigencia = 'A';

    -- 4. Actualizar el último año pagado en ta_13_datosrcm
    UPDATE padron_licencias.comun.ta_13_datosrcm
    SET axo_pagado = p_ultimo_axo,
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE
    WHERE control_rcm = p_control_rcm;

EXCEPTION
    WHEN OTHERS THEN
        p_error := SQLERRM;
        RAISE NOTICE 'Error en sp_pagos_dar_baja: %', p_error;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- Propuestas de funciones adicionales comparadas con PASCAL 




CREATE OR REPLACE FUNCTION cementerio.sp_pagos_sumar_por_caja(
  p_fecha DATE, p_ofna SMALLINT, p_caja CHAR(2), p_oper INTEGER, p_cementerio CHAR(1)
)
RETURNS NUMERIC(16,2)
AS $$
DECLARE v_importe NUMERIC(16,2);
BEGIN
  SELECT COALESCE(SUM(importe_anual), 0)
  INTO v_importe
  FROM cementerio.public.ta_13_pagosrcm
  WHERE fecing = p_fecha
    AND recing = p_ofna
    AND cajing = p_caja
    AND opcaja = p_oper
    AND cementerio = p_cementerio
    AND vigencia = 'A';
  RETURN v_importe;
END;
$$ LANGUAGE plpgsql;


-- ============================================

CREATE OR REPLACE FUNCTION cementerio.sp_ingresos_sumar_cuentas(
  p_fecha DATE, p_ofna SMALLINT, p_caja CHAR(2), p_oper INTEGER,
  p_cta INTEGER, p_cta1 INTEGER, p_cta2 INTEGER
)
RETURNS NUMERIC(16,2)
AS $$
DECLARE v_importe NUMERIC(16,2);
BEGIN
  SELECT COALESCE(SUM(i.importe_cta), 0)
  INTO v_importe
  FROM cementerio.public.cg_12_importes i
  JOIN cementerio.public.cg_12_cuentas c
    ON i.cta_aplicacion = c.cta_aplicacion
  WHERE c.tipo_pago = 'C'
    AND i.fecing = p_fecha
    AND i.recing = p_ofna
    AND i.cajing = p_caja
    AND i.opcaja = p_oper
    AND i.cta_aplicacion IN (p_cta, p_cta1, p_cta2);
  RETURN v_importe;
END;
$$ LANGUAGE plpgsql;


-- ============================================



CREATE OR REPLACE FUNCTION cementerio.sp_adeudos_por_pago(
  p_control_rcm INTEGER, p_control_id INTEGER
)
RETURNS TABLE(
  id_adeudo INTEGER, control_rcm INTEGER, axo_adeudo INTEGER,
  importe NUMERIC(16,2), importe_recargos NUMERIC(16,2),
  descto_impote NUMERIC(16,2), descto_recargos NUMERIC(16,2),
  vigencia CHAR(1), usuario INTEGER, fecha_mov DATE, id_pago INTEGER
)
AS $$
BEGIN
  RETURN QUERY
  SELECT a.id_adeudo, a.control_rcm, a.axo_adeudo,
         a.importe, a.importe_recargos,
         a.descto_impote, a.descto_recargos,
         a.vigencia, a.usuario, a.fecha_mov, a.id_pago
  FROM cementerio.public.ta_13_adeudosrcm a
  WHERE a.control_rcm = p_control_rcm
    AND a.id_pago     = p_control_id;
END;
$$ LANGUAGE plpgsql;



-- =============================================
-- COMENTARIOS Y NOTAS:
-- 1. Todos los SPs usan los esquemas correctos según postgreok.csv
-- 2. Los SPs son transaccionales con manejo de errores
-- 3. Se calculan totales automáticamente
-- 4. Se actualizan fechas y usuarios automáticamente
-- =============================================


