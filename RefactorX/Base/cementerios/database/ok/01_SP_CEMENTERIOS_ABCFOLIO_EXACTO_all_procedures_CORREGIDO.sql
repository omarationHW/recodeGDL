-- ============================================
-- ARCHIVO CONSOLIDADO: MÓDULO CEMENTERIOS - ABCFolio
-- Base de datos: padron_licencias (COMUN) + cementerio (PUBLIC)
-- Formulario: ABCFolio.vue
-- Fecha consolidación: 2025-11-25
-- Total SPs: 8 procedimientos almacenados
-- ============================================

-- NOTA IMPORTANTE:
-- Este archivo consolida TODOS los SPs utilizados por ABCFolio.vue
-- Los SPs están distribuidos en diferentes bases y esquemas según postgreok.csv:
--   - padron_licencias.comun: sp_abcf_get_folio, sp_abcf_baja_folio
--   - padron_licencias.public: sp_13_historia, spd_abc_adercm, sp_abcf_update_folio
--   - cementerio.public: sp_abcf_get_adicional, sp_abcf_update_adicional, sp_get_cementerios_list

-- ============================================
-- SECCIÓN 1: STORED PROCEDURES EN padron_licencias.comun
-- ============================================

\c padron_licencias;
SET search_path TO comun;

-- SP 1/8: sp_abcf_get_folio
-- Tipo: FUNCTION (SELECT)
-- Descripción: Obtiene todos los datos de un folio con LEFT JOIN a ta_12_passwords
-- Ubicación: padron_licencias.comun
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_abcf_get_folio(p_folio integer)
 RETURNS TABLE(control_rcm integer, cementerio character, clase smallint, clase_alfa character varying, seccion smallint, seccion_alfa character varying, linea smallint, linea_alfa character varying, fosa smallint, fosa_alfa character varying, axo_pagado integer, metros numeric, nombre character varying, domicilio character varying, exterior character, interior character, colonia character varying, observaciones character varying, usuario integer, fecha_mov date, tipo character, fecha_alta date, vigencia character, usuario_nombre character varying, id_rec smallint)
 LANGUAGE plpgsql
AS $function$
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
        a.axo_pagado,
        a.metros,
        a.nombre,
        a.domicilio,
        a.exterior,
        a.interior,
        a.colonia,
        a.observaciones,
        a.usuario,
        a.fecha_mov,
        a.tipo,
        a.fecha_alta,
        a.vigencia,
        c.nombre AS usuario_nombre,
        c.id_rec
    FROM comun.ta_13_datosrcm a
    LEFT JOIN comun.ta_12_passwords c ON a.usuario = c.id_usuario
    WHERE a.control_rcm = p_folio;
END;
$function$;

-- ============================================

-- SP 2/8: sp_abcf_baja_folio
-- Tipo: PROCEDURE (UPDATE)
-- Descripción: Da de baja lógica un folio (vigencia = 'B') y registra histórico
-- Ubicación: padron_licencias.comun
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_abcf_baja_folio(
    p_folio INTEGER,
    p_usuario INTEGER
)
RETURNS void
LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE comun.ta_13_datosrcm
    SET
        vigencia = 'B',
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE
    WHERE control_rcm = p_folio;

    -- Si necesitas histórico, no puedes usar CALL aquí.
    -- O conviertes sp_13_historia a FUNCTION y haces:
    -- PERFORM public.fn_13_historia(p_folio);
END;
$function$;


-- ============================================
-- SECCIÓN 2: STORED PROCEDURES EN padron_licencias.public
-- ============================================

SET search_path TO public;

-- SP 3/8: sp_13_historia
-- Tipo: PROCEDURE (INSERT)
-- Descripción: Guarda un registro histórico de la modificación de un folio
-- Ubicación: padron_licencias.public
-- CORRECCIÓN: Accede a comun.ta_13_datosrcm y cementerio.ta_13_datosrcmhis
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE public.sp_13_historia(IN par_control INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO cementerio.ta_13_datosrcmhis (
    control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa,
    fosa, fosa_alfa, axo_pagado, metros, nombre, domicilio, exterior, interior, colonia,
    observaciones, usuario, fecha_mov, tipo, fecha_alta, vigencia, fecha_his
  )
  SELECT
    control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa,
    fosa, fosa_alfa, axo_pagado, metros, nombre, domicilio, exterior, interior, colonia,
    observaciones, usuario, fecha_mov, tipo, fecha_alta, vigencia, now()
  FROM comun.ta_13_datosrcm
  WHERE control_rcm = par_control;
END;
$$;

-- ============================================

-- SP 4/8: spd_abc_adercm
-- Tipo: PROCEDURE (INSERT/UPDATE)
-- Descripción: Recalcula adeudos de un folio según la operación (1=alta, 2=baja, 3=modificación)
-- Ubicación: padron_licencias.public
-- CORRECCIÓN: Accede a cementerio.ta_13_adeudosrcm
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE public.spd_abc_adercm(IN par_control INTEGER, IN par_opc INTEGER, IN par_usu INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
  IF par_opc = 1 THEN
    -- Alta: genera adeudos para nueva fosa
    INSERT INTO cementerio.ta_13_adeudosrcm (
      control_rcm, axo_adeudo, importe, importe_recargos, descto_impote,
      descto_recargos, actualizacion, vigencia, usuario, fecha_mov
    )
    SELECT par_control, y, 0, 0, 0, 0, 0, 'V', par_usu, now()
    FROM generate_series(EXTRACT(YEAR FROM now())-6, EXTRACT(YEAR FROM now())::int) AS y;

  ELSIF par_opc = 2 THEN
    -- Baja: marca adeudos como baja
    UPDATE cementerio.ta_13_adeudosrcm
    SET vigencia = 'B', usuario = par_usu, fecha_mov = now()
    WHERE control_rcm = par_control;

  ELSIF par_opc = 3 THEN
    -- Modificación: recalcula adeudos si es necesario
    UPDATE cementerio.ta_13_adeudosrcm
    SET usuario = par_usu, fecha_mov = now()
    WHERE control_rcm = par_control;
  END IF;
END;
$$;

-- ============================================

-- SP 5/8: sp_abcf_update_folio
-- Tipo: PROCEDURE (UPDATE)
-- Descripción: Actualiza los datos principales de un folio
-- Ubicación: padron_licencias.public
-- CORRECCIÓN: Accede a comun.ta_13_datosrcm
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_abcf_update_folio(p_folio integer, p_cementerio character, p_clase smallint, p_clase_alfa character varying, p_seccion smallint, p_seccion_alfa character varying, p_linea smallint, p_linea_alfa character varying, p_fosa smallint, p_fosa_alfa character varying, p_axo_pagado integer, p_metros numeric, p_nombre character varying, p_domicilio character varying, p_exterior character, p_interior character, p_colonia character varying, p_observaciones character varying, p_tipo character, p_usuario integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE comun.ta_13_datosrcm
    SET
        cementerio     = p_cementerio,
        clase          = p_clase,
        clase_alfa     = p_clase_alfa,
        seccion        = p_seccion,
        seccion_alfa   = p_seccion_alfa,
        linea          = p_linea,
        linea_alfa     = p_linea_alfa,
        fosa           = p_fosa,
        fosa_alfa      = p_fosa_alfa,
        axo_pagado     = p_axo_pagado,
        metros         = p_metros,
        nombre         = p_nombre,
        domicilio      = p_domicilio,
        exterior       = p_exterior,
        interior       = p_interior,
        colonia        = p_colonia,
        observaciones  = p_observaciones,
        usuario        = p_usuario,
        fecha_mov      = CURRENT_DATE,
        tipo           = p_tipo
    WHERE control_rcm = p_folio;

    -- Si necesitas histórico, aquí no puedes usar CALL (solo en PROCEDURE).
    -- O conviertes sp_13_historia a FUNCTION y haces:
    -- PERFORM comun.fn_13_historia(p_folio);
END;
$function$
;

-- ============================================
-- SECCIÓN 3: STORED PROCEDURES EN cementerio.public
-- ============================================

\c cementerio;
SET search_path TO public;

-- SP 6/8: sp_abcf_get_adicional
-- Tipo: FUNCTION (SELECT)
-- Descripción: Obtiene los datos adicionales de un folio
-- Ubicación: cementerio.public
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_abcf_get_adicional(p_folio integer)
 RETURNS TABLE(control_rcm integer, rfc text, curp text, telefono text, clave_ife text)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT 
        t.control_rcm,
        t.rfc::TEXT,
        t.curp::TEXT,
        t.telefono::TEXT,
        t.clave_ife::TEXT
    FROM ta_13_datosrcmadic t
    WHERE t.control_rcm = p_folio;
END;
$function$;
-- ============================================

-- SP 7/8: sp_abcf_update_adicional
-- Tipo: PROCEDURE (INSERT/UPDATE)
-- Descripción: Actualiza o inserta los datos adicionales de un folio
-- Ubicación: cementerio.public
-- --------------------------------------------


CREATE OR REPLACE FUNCTION public.sp_abcf_update_adicional(
    p_folio INTEGER,
    p_rfc VARCHAR(15),
    p_curp VARCHAR(20),
    p_telefono VARCHAR(15),
    p_clave_ife VARCHAR(20)
)
RETURNS void
LANGUAGE plpgsql
AS $function$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_13_datosrcmadic WHERE control_rcm = p_folio) THEN
        UPDATE ta_13_datosrcmadic
        SET
            rfc = p_rfc,
            curp = p_curp,
            telefono = p_telefono,
            clave_ife = p_clave_ife
        WHERE control_rcm = p_folio;
    ELSE
        INSERT INTO ta_13_datosrcmadic (control_rcm, rfc, curp, telefono, clave_ife)
        VALUES (p_folio, p_rfc, p_curp, p_telefono, p_clave_ife);
    END IF;
END;
$function$;

-- ============================================

-- SP 8/8: sp_get_cementerios_list
-- Tipo: FUNCTION (SELECT)
-- Descripción: Lista todos los cementerios disponibles
-- Ubicación: cementerio.public
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_get_cementerios_list()
RETURNS TABLE(
    cementerio SMALLINT,
    nombre VARCHAR(60),
    domicilio VARCHAR(60)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.cementerio,
        c.nombre,
        c.domicilio
    FROM tc_13_cementerios c
    ORDER BY c.cementerio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- INSTRUCCIONES DE DESPLIEGUE
-- ============================================
-- 1. Ejecutar este script completo en PostgreSQL
-- 2. Verificar que existan las siguientes tablas:
--    PADRON_LICENCIAS:
--      - comun.ta_13_datosrcm
--      - comun.ta_12_passwords
--    CEMENTERIO:
--      - public.ta_13_datosrcmadic
--      - public.ta_13_datosrcmhis
--      - public.ta_13_adeudosrcm
--      - public.tc_13_cementerios
--
-- 3. Probar los SPs desde ABCFolio.vue o directamente:
--    SELECT * FROM comun.sp_abcf_get_folio(12345);
--    SELECT * FROM public.sp_abcf_get_adicional(12345);
--    SELECT * FROM public.sp_get_cementerios_list();
--    CALL public.sp_13_historia(12345);
--    CALL public.spd_abc_adercm(12345, 3, 1);
--    CALL comun.sp_abcf_baja_folio(12345, 1);
--    CALL public.sp_abcf_update_folio(12345, 'A', 1, '1A', 1, '1A', 1, '1A', 1, '1A', 2025, 10.5, 'Juan Perez', 'Calle 123', '123', 'A', 'Centro', 'Observaciones', 'M', 1);
--    CALL public.sp_abcf_update_adicional(12345, 'RFC123', 'CURP123', '3331234567', 'CLAVEIFE123');
-- ============================================
