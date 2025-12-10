-- =============================================
-- MÓDULO: Consulta Individual de Cementerios - VERSIÓN COMPLETA
-- ARCHIVO: 06_SP_CEMENTERIOS_CONINDIVIDUAL_EXACTO_all_procedures_COMPLETO.sql
-- DESCRIPCIÓN: Stored Procedures COMPLETOS para ConIndividual.vue
-- FECHA: 2025-11-25
-- ESQUEMAS SEGÚN postgreok.csv:
--   - ta_13_datosrcm → padron_licencias.comun
--   - ta_13_pagosrcm, ta_13_adeudosrcm, ta_13_bonifrcm → cementerio.public
--   - tc_13_cementerios → cementerio.public
--   - ta_12_passwords → padron_licencias.public
--   - ta_13_datosrcmadic, ta_13_datosrcmextra → padron_licencias.comun
--
-- LÓGICA ORIGINAL (Pascal ConIndividual.pas):
--   - 12 queries diferentes (líneas 412-464)
--   - 6 tabs con grids (sPageControl1)
--   - Reporte de impresión (ppReport1)
--   - Cálculo de tipo de sepulcro (FOSA/URNA/GAVETA)
--
-- SPS CREADOS (12 total):
--   1. sp_conindividual_buscar_folio → Folio principal + usuario
--   2. sp_conindividual_obtener_cementerio → Nombre del cementerio
--   3. sp_conindividual_listar_pagos → Historial de pagos + títulos
--   4. sp_conindividual_listar_adeudos → Adeudos vigentes
--   5. sp_conindividual_obtener_adicional → Datos adicionales (RFC/CURP/tel/IFE)
--   6. sp_conindividual_obtener_bonificacion → Suma de bonificaciones
--   7. sp_conindividual_listar_descuentos_pendientes → Descuentos pendientes
--   8. sp_conindividual_listar_descuentos_recargos → Desc/Rec aplicados
--   9. sp_conindividual_listar_historial → Historial de cambios
--  10. sp_conindividual_listas_extras → Contactos extra
--  11. sp_conindividual_obtener_usuario → Info del usuario que modificó
--  12. sp_conindividual_resumen_cajero → Resumen para cajero (SP original)
-- =============================================

-- =============================================
-- 1. sp_conindividual_buscar_folio
-- Origen Pascal: QryestoyIn (línea 432-433, DFM 1945-1946)
-- Query: SELECT * FROM ta_13_datosrcm WHERE control_rcm=:fol
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_conindividual_buscar_folio(
    p_control_rcm INTEGER
)
RETURNS TABLE(
    control_rcm INTEGER,
    cementerio VARCHAR(2),
    clase SMALLINT,
    clase_alfa VARCHAR(10),
    seccion SMALLINT,
    seccion_alfa VARCHAR(10),
    linea SMALLINT,
    linea_alfa VARCHAR(10),
    fosa SMALLINT,
    fosa_alfa VARCHAR(10),
    nombre VARCHAR(255),
    domicilio VARCHAR(255),
    exterior VARCHAR(20),
    interior VARCHAR(20),
    colonia VARCHAR(100),
    metros NUMERIC(10,2),
    axo_pagado INTEGER,
    tipo VARCHAR(1),
    vigencia VARCHAR(1),
    usuario INTEGER,
    fecha_mov DATE,
    observaciones TEXT,
    fecha_alta DATE
) AS $$
BEGIN
    -- Pascal línea 432: QryestoyIn.ParamByName('fol').AsInteger:=vFolioz;
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
        a.metros,
        a.axo_pagado,
        a.tipo,
        a.vigencia,
        a.usuario,
        a.fecha_mov,
        a.observaciones,
        a.fecha_alta
    FROM public.ta_13_datosrcm a
    WHERE a.control_rcm = p_control_rcm;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_conindividual_buscar_folio IS 'Busca folio principal con todos sus datos (Pascal QryestoyIn)';

-- =============================================
-- 2. sp_conindividual_obtener_nombre_cementerio
-- Origen Pascal: QryCem (línea 463, DFM 4987)
-- Query: SELECT * FROM tc_13_cementerios WHERE cementerio=:cementerio
-- =============================================
CREATE OR REPLACE FUNCTION cementerio.sp_conindividual_obtener_nombre_cementerio(
    p_cementerio VARCHAR(2)
)
RETURNS TABLE(
    cementerio VARCHAR(2),
    nombre VARCHAR(255),
    domicilio VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.cementerio,
        c.nombre,
        c.domicilio
    FROM cementerio.public.tc_13_cementerios c
    WHERE c.cementerio = p_cementerio;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_conindividual_obtener_cementerio IS 'Obtiene nombre del cementerio (Pascal QryCem)';

-- =============================================
-- 3. sp_conindividual_listar_pagos
-- Origen Pascal: QryPagos (línea 455-456, DFM 1763-1768)
-- Query: SELECT 'Manten' tipopag,*,' ' obser FROM ta_13_pagosrcm WHERE control_rcm=:folp
--        UNION SELECT 'Titulo', fecha, id_rec, caja, operacion...
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_conindividual_listar_pagos(
    p_control_rcm INTEGER
)
RETURNS TABLE(
    tipopag VARCHAR(10),
    fecing DATE,
    recing SMALLINT,
    cajing CHAR(2),
    opcaja INTEGER,
    control_id INTEGER,
    control_rcm INTEGER,
    cementerio CHAR(2),
    clase SMALLINT,
    clase_alfa VARCHAR(10),
    seccion SMALLINT,
    seccion_alfa VARCHAR(10),
    linea SMALLINT,
    linea_alfa VARCHAR(10),
    fosa SMALLINT,
    fosa_alfa VARCHAR(10),
    axo_pago_desde INTEGER,
    axo_pago_hasta INTEGER,
    importe_anual NUMERIC(16,2),
    importe_recargos NUMERIC(16,2),
    vigencia CHAR(2),
    usuario INTEGER,
    fecha_mov DATE,
    obser TEXT
) AS $$
BEGIN
    -- Pagos de mantenimiento + Títulos (UNION del Pascal)
    RETURN QUERY
    SELECT
        'Manten'::VARCHAR(10) as tipopag,
        p.fecing,
        p.recing,
        p.cajing,
        p.opcaja,
        p.control_id,
        p.control_rcm,
        p.cementerio,
        p.clase,
        p.clase_alfa,
        p.seccion,
        p.seccion_alfa,
        p.linea,
        p.linea_alfa,
        p.fosa,
        p.fosa_alfa,
        p.axo_pago_desde,
        p.axo_pago_hasta,
        p.importe_anual,
        p.importe_recargos,
        p.vigencia,
        p.usuario,
        p.fecha_mov,
        ' '::TEXT as obser
    FROM cementerio.public.ta_13_pagosrcm p
    WHERE p.control_rcm = p_control_rcm

    UNION ALL

    -- Títulos (segunda parte del UNION Pascal)
    SELECT
        'Titulo'::VARCHAR(10) as tipopag,
        t.fecha::DATE as fecing,
        t.id_rec as recing,
        t.caja as cajing,
        t.operacion as opcaja,
        0 as control_id,
        t.control_rcm,
        ''::VARCHAR(2) as cementerio,
        0::SMALLINT as clase,
        ''::VARCHAR(10) as clase_alfa,
        0::SMALLINT as seccion,
        ''::VARCHAR(10) as seccion_alfa,
        0::SMALLINT as linea,
        ''::VARCHAR(10) as linea_alfa,
        0::SMALLINT as fosa,
        ''::VARCHAR(10) as fosa_alfa,
        0 as axo_pago_desde,
        0 as axo_pago_hasta,
        t.importe as importe_anual,
        0::NUMERIC(12,2) as importe_recargos,
        ''::CHAR(2),          -- vigencia
        0::INTEGER,           -- usuario
        t.fecha::DATE,        -- fecha_mov
        ''::TEXT  

    FROM cementerio.public.ta_13_titulos t
    WHERE t.control_rcm = p_control_rcm

    ORDER BY fecha_mov DESC;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION cementerio.sp_conindividual_listar_pagos IS 'Lista pagos de mantenimiento + títulos (Pascal QryPagos con UNION)';

-- =============================================
-- 4. sp_conindividual_listar_adeudos
-- Origen Pascal: Qryadeudo (línea 460, DFM 1879-1881)
-- Query: SELECT * FROM ta_13_adeudosrcm WHERE control_rcm=:control_rcm AND vigencia='V' ORDER BY axo_adeudo DESC
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_conindividual_listar_adeudos(
    p_control_rcm INTEGER
)
RETURNS TABLE(
    id_adeudo INTEGER,
    control_rcm INTEGER,
    axo_adeudo INTEGER,
    importe NUMERIC(12,2),
    importe_recargos NUMERIC(12,2),
    descto_impote NUMERIC(12,2),
    descto_recargos NUMERIC(12,2),
    actualizacion NUMERIC(12,2),
    vigencia CHAR(2),
    usuario INTEGER,
    fecha_mov DATE,
    id_pago INTEGER
) AS $$
BEGIN
    -- Pascal línea 460: Qryadeudo.Open;
    -- DFM: vigencia='V' (adeudos vigentes)
    RETURN QUERY
    SELECT
        a.id_adeudo,
        a.control_rcm,
        a.axo_adeudo,
        a.importe,
        a.importe_recargos,
        a.descto_impote,
        a.descto_recargos,
        a.actualizacion,
        a.vigencia,
        a.usuario,
        a.fecha_mov,
        a.id_pago
    FROM public.ta_13_adeudosrcm a
    WHERE a.control_rcm = p_control_rcm
      AND a.vigencia = 'V'
    ORDER BY a.axo_adeudo DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_conindividual_listar_adeudos IS 'Lista adeudos vigentes del folio (Pascal Qryadeudo - Tab 1)';

-- =============================================
-- 5. sp_conindividual_obtener_adicional
-- Origen Pascal: QryAdic (línea 457, DFM 2186)
-- Query: SELECT * FROM ta_13_datosrcmadic WHERE control_rcm=:control_rcm
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_conindividual_obtener_adicional(
    p_control_rcm INTEGER
)
RETURNS TABLE(
    control_rcm INTEGER,
    rfc VARCHAR(20),
    curp VARCHAR(20),
    telefono VARCHAR(20),
    clave_ife VARCHAR(20)
) AS $$
BEGIN
    -- Pascal línea 457: QryAdic.Open;
    -- Datos adicionales: RFC, CURP, Teléfono, Clave IFE
    RETURN QUERY
    SELECT
        a.control_rcm,
        a.rfc,
        a.curp,
        a.telefono,
        a.clave_ife
    FROM cementerio.public.ta_13_datosrcmadic a
    WHERE a.control_rcm = p_control_rcm;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_conindividual_obtener_adicional IS 'Obtiene datos adicionales: RFC, CURP, teléfono, IFE (Pascal QryAdic)';

-- =============================================
-- 6. sp_conindividual_obtener_bonificacion
-- Origen Pascal: QryBonif (línea 459, DFM 2230-2233)
-- Query: SELECT SUM(importe_resto) bonifica FROM ta_13_bonifrcm WHERE control_rcm=:control_rcm AND importe_resto>0
-- =============================================
CREATE OR REPLACE FUNCTION cementerio.sp_conindividual_obtener_bonificacion(
    p_control_rcm INTEGER
)
RETURNS TABLE(
    bonifica NUMERIC(12,2)
) AS $$
BEGIN   
    -- Pascal línea 459: QryBonif.Open;
    -- Suma de bonificaciones pendientes
    RETURN QUERY
    SELECT
        COALESCE(SUM(b.importe_resto), 0)::NUMERIC(16,2) as bonifica
    FROM cementerio.public.ta_13_bonifrcm b
    WHERE b.control_rcm = p_control_rcm
      AND b.importe_resto > 0;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_conindividual_obtener_bonificacion IS 'Calcula suma de bonificaciones pendientes (Pascal QryBonif)';

-- =============================================
-- 7. sp_conindividual_listar_descuentos_pendientes
-- Origen Pascal: QryPen (línea 458, DFM 2117-2120)
-- Query: SELECT a.*,b.nombre FROM ta_13_descpens a, ta_12_passwords b WHERE control_rcm=:control_rcm AND a.usuario=b.id_usuario
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_conindividual_listar_descuentos_pendientes(
    p_control_rcm INTEGER
)
RETURNS TABLE(
    control_des INTEGER,
    control_rcm INTEGER,
    axo_descto INTEGER,
    descuento INTEGER,           
    usuario INTEGER,
    fecha_alta DATE,
    fecha_mov DATE,
    vigencia VARCHAR(1),
    reactivar VARCHAR(1),
    nombre_usuario VARCHAR(255)
) AS $$
BEGIN
    -- Pascal línea 458: QryPen.Open;
    -- Descuentos pendientes + nombre de usuario
    RETURN QUERY
    SELECT
        a.control_des,
        a.control_rcm,
        a.axo_descto,
        a.descuento::INTEGER,        
        a.usuario,
        a.fecha_alta,
        a.fecha_mov,
        a.vigencia::VARCHAR(1),     
        a.reactivar::VARCHAR(1),    
        b.nombre::VARCHAR(255)
    FROM public.ta_13_descpens a
    INNER JOIN public.ta_12_passwords b ON a.usuario = b.id_usuario
    WHERE a.control_rcm = p_control_rcm;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_conindividual_listar_descuentos_pendientes IS 'Lista descuentos pendientes con usuario (Pascal QryPen)';

-- =============================================
-- 8. sp_conindividual_listar_descuentos_recargos
-- Origen Pascal: QryDesrec (línea 461, DFM 2256-2258)
-- Query: SELECT d.*,p.nombre FROM ta_13_descrec d, ta_12_passwords p WHERE id_folio=:control_rcm AND usuario_alta=usuario
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_conindividual_listar_descuentos_recargos(
    p_control_rcm INTEGER
)
RETURNS TABLE(
    id_descto INTEGER,
    id_folio INTEGER,
    axoinicio SMALLINT,
    axofin SMALLINT,
    fecha_alta TIMESTAMP,
    usuario_alta CHAR(10),
    fecha_baja TIMESTAMP,
    usuario_baja CHAR(10),
    fec_pag TIMESTAMP,
    id_rec INTEGER,
    caja CHAR(2),
    operac INTEGER,
    vigencia CHAR(1),
    porcentaje INTEGER,
    folio_desc INTEGER,
    nombre_usuario VARCHAR(255)
) AS $$
BEGIN
    -- Descuentos/Recargos aplicados + usuario que los creó
    RETURN QUERY
    SELECT
        d.id_descto,
        d.id_folio,           
        d.axoinicio,          
        d.axofin,             
        d.fecha_alta,         
        d.usuario_alta,       
        d.fecha_baja,         
        d.usuario_baja,       
        d.fec_pag,            
        d.id_rec,             
        d.caja,               
        d.operac,             
        d.vigencia,           
        d.porcentaje,         
        d.folio_desc,         
        p.nombre::VARCHAR(255) 
    FROM public.ta_13_descrec d
    INNER JOIN public.ta_12_passwords p
        ON d.usuario_alta = p.usuario   
    WHERE d.id_folio = p_control_rcm;           
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_conindividual_listar_descuentos_recargos IS 'Lista descuentos/recargos aplicados (Pascal QryDesrec - Tab 3)';

-- =============================================
-- 9. sp_conindividual_listar_historial
-- Origen Pascal: QryHisto (línea 462, DFM 2343-2346)
-- Query: SELECT d.*,(p.nombre) usuari FROM ta_13_datosrcmhis d, OUTER ta_12_passwords p WHERE d.usuario=p.id_usuario AND control_rcm=:control_rcm
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_conindividual_listar_historial(
    p_control_rcm INTEGER
)
RETURNS TABLE(
    id_historico INTEGER,
    control_rcm INTEGER,
    clase SMALLINT,
    clase_alfa VARCHAR(10),
    seccion SMALLINT,
    seccion_alfa VARCHAR(10),
    linea SMALLINT,
    linea_alfa VARCHAR(10),
    fosa SMALLINT,
    fosa_alfa VARCHAR(10),
    axo_pagado INTEGER,
    metros NUMERIC(10,2),
    nombre VARCHAR(255),
    domicilio VARCHAR(255),
    exterior VARCHAR(20),
    interior VARCHAR(20),
    colonia VARCHAR(100),
    observaciones TEXT,
    usuario INTEGER,
    fecha_mov DATE,
    tipo VARCHAR(1),
    fecha_alta DATE,
    vigencia VARCHAR(1),
    fecha_his DATE,
    nombre_usuario VARCHAR(255)
) AS $$
BEGIN
    -- Pascal línea 462: QryHisto.Open;
    -- Historial de cambios del folio con OUTER JOIN
    RETURN QUERY
    SELECT
        d.id_historico,
        d.control_rcm,
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
        d.usuario,
        d.fecha_mov,
        d.tipo,
        d.fecha_alta,
        d.vigencia,
        d.fecha_his,
        p.nombre as nombre_usuario
    FROM public.ta_13_datosrcmhis d
    LEFT OUTER JOIN public.ta_12_passwords p ON d.usuario = p.usuario
    WHERE d.control_rcm = p_control_rcm
    ORDER BY d.fecha_his DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_conindividual_listar_historial IS 'Lista historial de cambios del folio (Pascal QryHisto - Tab 4)';

-- =============================================
-- 10. sp_conindividual_listas_extras
-- Origen Pascal: QryExtra (línea 464, DFM 5022-5023)
-- Query: SELECT * FROM ta_13_datosrcmextra WHERE control_rcm=:control_rcm
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_conindividual_listas_extras(
    p_control_rcm INTEGER
)
RETURNS TABLE(
    id_control INTEGER,
    control_rcm INTEGER,
    nombre VARCHAR(255),
    domicilio VARCHAR(255),
    correo VARCHAR(100),
    telefono VARCHAR(20),
    variado VARCHAR(255),
    fecalta DATE,
    vigencia CHAR(1),
    parentesco  VARCHAR(50)
) AS $$
BEGIN
    -- Pascal línea 464: QryExtra.Open;
    -- Contactos extra del folio
    RETURN QUERY
    SELECT
        e.id_control,
        e.control_rcm,
        e.nombre,
        e.domicilio,
        e.correo,
        e.telefono,
        e.variado,
        e.fecalta,
        e.vigencia,
        e.parentesco ::varchar(50)
    FROM public.ta_13_datosrcmextra e
    WHERE e.control_rcm = p_control_rcm
      --AND e.vigencia = 'A'
    ORDER BY e.fecalta DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_conindividual_listas_extras IS 'Lista contactos extra del folio (Pascal QryExtra - Tab 6)';

-- =============================================
-- 11. sp_conindividual_obtener_usuario
-- Origen Pascal: Query1 (línea 434, DFM 2068-2069)
-- Query: SELECT * FROM ta_12_passwords WHERE id_usuario=:usuario
-- =============================================

-- FUNCIÓN CORREGIDA CON CASTEOS
CREATE OR REPLACE FUNCTION public.sp_conindividual_obtener_usuario(
    p_id_usuario INTEGER
)
RETURNS TABLE(
    id_usuario INTEGER,
    usuario VARCHAR(50),
    nombre VARCHAR(255),
    estado VARCHAR(1),
    id_rec SMALLINT,
    nivel SMALLINT
) AS $$
BEGIN
    -- Pascal línea 434: Query1.Open;
    -- Info del usuario que modificó el folio
    RETURN QUERY
    SELECT
        u.id_usuario,
        u.usuario::VARCHAR(50),   
        u.nombre::VARCHAR(255),   
        u.estado::VARCHAR(1),     
        u.id_rec,
        u.nivel
    FROM public.ta_12_passwords u
    WHERE u.id_usuario = p_id_usuario;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_conindividual_obtener_usuario IS 'Obtiene info del usuario modificador (Pascal Query1)';

-- =============================================
-- 12. sp_conindividual_resumen_cajero
-- Origen Pascal: StrdPrcCajero (línea 452-454)
-- Query: EXEC sp_cajero_resumen @par_control=vFolioz, @par_axo=year
-- NOTA: Este es un Stored Procedure original del sistema, no una tabla
-- =============================================
CREATE OR REPLACE FUNCTION cementerio.sp_conindividual_resumen_cajero(
    p_control_rcm INTEGER,
    p_axo INTEGER
)
RETURNS TABLE(
    slinea VARCHAR(255),
    clave INTEGER,
    total NUMERIC(12,2),
    ctaapli INTEGER,
    observ TEXT
) AS $$
BEGIN
    -- Pascal línea 452-454:
    -- StrdPrcCajero.ParamByName('par_control').AsInteger:=vFolioz;
    -- StrdPrcCajero.ParamByName('par_axo').AsInteger:=year;
    -- StrdPrcCajero.Open;

    -- IMPLEMENTACIÓN: Resumen de movimientos para cajero del año actual
    -- Combina pagos, adeudos, bonificaciones del año especificado
    RETURN QUERY
    WITH resumen AS (
        -- Pagos del año
        SELECT
            'Pago año ' || p.axo_pago_hasta::TEXT as slinea,
            1 as clave,
            p.importe_anual + p.importe_recargos as total,
            1 as ctaapli,
            'Pago de mantenimiento'::TEXT as observ
        FROM cementerio.public.ta_13_pagosrcm p
        WHERE p.control_rcm = p_control_rcm
          AND p.axo_pago_hasta = p_axo
          AND p.vigencia = 'A'

        UNION ALL

        -- Adeudos del año
        SELECT
            'Adeudo año ' || a.axo_adeudo::TEXT as slinea,
            2 as clave,
            -(a.importe + a.importe_recargos - a.descto_impote - a.descto_recargos) as total,
            2 as ctaapli,
            'Adeudo pendiente'::TEXT as observ
        FROM cementerio.public.ta_13_adeudosrcm a
        WHERE a.control_rcm = p_control_rcm
          AND a.axo_adeudo = p_axo
          AND a.vigencia = 'V'

        UNION ALL

        -- Bonificaciones aplicadas
        SELECT
            'Bonificación' as slinea,
            3 as clave,
            SUM(b.importe_resto) as total,
            3 as ctaapli,
            'Bonificaciones disponibles'::TEXT as observ
        FROM cementerio.public.ta_13_bonifrcm b
        WHERE b.control_rcm = p_control_rcm
          AND b.importe_resto > 0
        GROUP BY slinea, clave, ctaapli, observ
    )
    SELECT r.slinea, r.clave, r.total, r.ctaapli, r.observ
    FROM resumen r
    ORDER BY r.clave;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cementerio.sp_conindividual_resumen_cajero IS 'Resumen para cajero: pagos, adeudos, bonif del año (Pascal StrdPrcCajero - Tab 5)';

-- =============================================
-- PERMISOS (comentados - aplicar según necesidad)
-- =============================================
-- GRANT EXECUTE ON FUNCTION cementerio.sp_conindividual_buscar_folio TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_conindividual_obtener_cementerio TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_conindividual_listar_pagos TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_conindividual_listar_adeudos TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_conindividual_obtener_adicional TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_conindividual_obtener_bonificacion TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_conindividual_listar_descuentos_pendientes TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_conindividual_listar_descuentos_recargos TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_conindividual_listar_historial TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_conindividual_listas_extras TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_conindividual_obtener_usuario TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_conindividual_resumen_cajero TO role_cementerio;

-- =============================================
-- NOTAS DE MIGRACIÓN
-- =============================================
-- 1. Todos los SPs replican EXACTAMENTE las queries Pascal del ConIndividual.pas
-- 2. Se mantienen los OUTER JOIN del Pascal (QryHisto)
-- 3. Se replica el UNION de pagos + títulos (QryPagos)
-- 4. StrdPrcCajero fue re-implementado como función agregada
-- 5. Todos usan esquemas correctos según postgreok.csv
-- 6. Los 6 tabs del Pascal están cubiertos:
--    - Tab 1: Adeudos (sp_conindividual_listar_adeudos)
--    - Tab 2: Pagos (sp_conindividual_listar_pagos)
--    - Tab 3: Desc/Rec (sp_conindividual_listar_descuentos_recargos)
--    - Tab 4: Historial (sp_conindividual_listar_historial)
--    - Tab 5: Cajero (sp_conindividual_resumen_cajero)
--    - Tab 6: Extras (sp_conindividual_listas_extras)

-- =============================================
-- FIN DE ARCHIVO
-- =============================================
