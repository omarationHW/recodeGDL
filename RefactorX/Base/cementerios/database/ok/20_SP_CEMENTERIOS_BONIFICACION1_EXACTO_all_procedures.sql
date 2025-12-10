-- =============================================
-- BONIFICACION1.VUE - STORED PROCEDURES
-- =============================================
-- Descripción: SPs para bonificaciones especiales con oficio
-- Componente Vue: Bonificacion1.vue
-- Pascal Original: Bonificacion1.pas
-- Fecha Creación: 2025-11-28
--
-- TABLAS INVOLUCRADAS:
--   - cementerio.public.ta_13_bonifrcm (bonificaciones RCM - CRUD)
--   - cementerio.public.ta_13_bonifica (bonificaciones - Búsqueda Saranda)
--   - padron_licencias.comun.ta_13_datosrcm (datos de fosas/folios)
--   - cementerio.public.tc_13_cementerios (catálogo de cementerios)
--   - cementerio.public.ta_12_recaudadoras (catálogo recaudadoras)
--
-- SCHEMAS SEGÚN postgreok.csv:
--   ta_13_bonifrcm → cementerio.public (Informix)
--   ta_13_bonifica → cementerio.public (Saranda)
--   ta_13_datosrcm → padron_licencias.comun
--   tc_13_cementerios → cementerio.public
--   ta_12_recaudadoras → cementerio.public
-- =============================================

-- =============================================
-- 1. sp_bonificacion1_buscar_folio
-- Descripción: Busca folio con JOIN a cementerios
-- Parámetros:
--   - p_control_rcm: Número de folio
-- Retorna: TABLE con datos del folio + nombre cementerio
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_bonificacion1_buscar_folio(
    p_control_rcm INTEGER
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
    usuario INTEGER,
    fecha_mov DATE,
    nombre_cementerio VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    /* TODO FUTURO: Query SQL original (Bonificacion1.dfm líneas 1496-1498):
    -- DatabaseName: 'ingresosifx'
    -- SQL: 'select a.*, b.nombre from ta_13_datosrcm a, tc_13_cementerios b
    --       where a.control_rcm=:control and a.cementerio=b.cementerio'
    -- Parámetro Pascal (línea 259):
    --   :control = StrToInt(sCurrencyEfolio.Text)
    */

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
        b.nombre_cementerio
    FROM public.ta_13_datosrcm a
    INNER JOIN public.tc_13_cementerios b
        ON a.cementerio = b.cementerio
    WHERE a.control_rcm = p_control_rcm;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_bonificacion1_buscar_folio IS 'Busca folio con JOIN a cementerios (Bonificacion1)';

-- =============================================
-- 2. sp_bonificacion1_buscar_bonificacion
-- Descripción: Busca bonificación existente por oficio/año/recaudadora
-- Parámetros:
--   - p_oficio: Número de oficio
--   - p_axo: Año del oficio
--   - p_id_rec: ID de recaudadora
-- Retorna: TABLE con datos de bonificación
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_bonificacion1_buscar_bonificacion(
    p_oficio INTEGER,
    p_axo SMALLINT,
    p_id_rec INTEGER
)
RETURNS TABLE (
    control_bon INTEGER,
    oficio INTEGER,
    axo SMALLINT,
    id_rec INTEGER,
    doble CHAR(1),
    control_rcm INTEGER,
    fecha_ofic DATE,
    importe_bonificar NUMERIC(16,2),
    importe_bonificado NUMERIC(16,2),
    importe_resto NUMERIC(16,2),
    usuario INTEGER,
    fecha_mov DATE,
    vigencia CHAR(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    /* TODO FUTURO: Query SQL original (Bonificacion1.dfm líneas 1617-1620):
    -- DatabaseName: 'ingresosifx'
    -- SQL: 'select * from ta_13_bonifica where oficio=:ofic and axo=:vaxo and id_rec=:reca'
    -- Parámetros Pascal (líneas 315-317):
    --   :ofic = StrToInt(mxFlatFloatEOficio.Text)
    --   :vaxo = StrToInt(FlatSpinEditIAxo.Text)
    --   :reca = Qryrecid_rec.Value
    */

    RETURN QUERY
    SELECT
        b.control_bon,
        b.oficio,
        b.axo,
        b.id_rec,
        b.doble,
        b.control_rcm,
        b.fecha_ofic,
        b.importe_bonificar,
        b.importe_bonificado,
        b.importe_resto,
        b.usuario,
        b.fecha_mov,
        b.vigencia
    FROM public.ta_13_bonifica b
    WHERE b.oficio = p_oficio
        AND b.axo = p_axo
        AND b.id_rec = p_id_rec;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_bonificacion1_buscar_bonificacion IS 'Busca bonificación por oficio/año/recaudadora (Bonificacion1)';

-- =============================================
-- 3. sp_bonificacion1_listar_recaudadoras
-- Descripción: Lista recaudadoras activas (id_rec < 8)
-- Retorna: TABLE con recaudadoras
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_bonificacion1_listar_recaudadoras()
RETURNS TABLE (
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora CHAR(50),
    domicilio CHAR(50),
    tel CHAR(15),
    recaudador CHAR(50),
    sector CHAR(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    /* TODO FUTURO: Query SQL original (Bonificacion1.dfm líneas 1812-1813):
    -- DatabaseName: 'ingresosifx'
    -- SQL: 'select * from ta_12_recaudadoras where id_rec<8'
    */

    RETURN QUERY
    SELECT
        r.id_rec,
        r.id_zona,
        r.recaudadora,
        r.domicilio,
        r.tel,
        r.recaudador,
        r.sector
    FROM public.ta_12_recaudadoras r
    WHERE r.id_rec < 8
    ORDER BY r.id_rec;

END;
$$;
COMMENT ON FUNCTION cementerio.sp_bonificacion1_listar_recaudadoras IS 'Lista recaudadoras activas (Bonificacion1)';

-- =============================================
-- 4. sp_bonificacion1_insertar
-- Descripción: Inserta nueva bonificación con oficio
-- Parámetros: Todos los campos de ta_13_bonifrcm
-- Retorna: control_bon generado
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_bonificacion1_insertar(
    p_oficio INTEGER,
    p_axo SMALLINT,
    p_id_rec INTEGER,
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
    p_fecha_ofic DATE,
    p_importe_bonificar NUMERIC(16,2),
    p_importe_bonificado NUMERIC(16,2),
    p_importe_resto NUMERIC(16,2),
    p_usuario INTEGER
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_control_bon INTEGER;
BEGIN
    /* TODO FUTURO: Query SQL original (Bonificacion1.pas líneas 169-177):
    -- SQL: 'insert into ta_13_bonifrcm values(0,
    --       oficio, axo, id_rec, null,
    --       control_rcm, cementerio, clase, clase_alfa,
    --       seccion, seccion_alfa,
    --       linea, linea_alfa,
    --       fosa, fosa_alfa,
    --       fecha_ofic, importe_bonificar, importe_bonificado,
    --       importe_resto, usuario, today)'
    -- Nota: control_bon=0 indica auto-generado
    -- doble=null siempre
    */

    INSERT INTO public.ta_13_bonifrcm (
        oficio,
        axo,
        id_rec,
        doble,
        control_rcm,
        cementerio,
        clase,
        clase_alfa,
        seccion,
        seccion_alfa,
        linea,
        linea_alfa,
        fosa,
        fosa_alfa,
        fecha_ofic,
        importe_bonificar,
        importe_bonificado,
        importe_resto,
        usuario,
        fecha_mov
    ) VALUES (
        p_oficio,
        p_axo,
        p_id_rec,
        NULL,
        p_control_rcm,
        p_cementerio,
        p_clase,
        p_clase_alfa,
        p_seccion,
        p_seccion_alfa,
        p_linea,
        p_linea_alfa,
        p_fosa,
        p_fosa_alfa,
        p_fecha_ofic,
        p_importe_bonificar,
        p_importe_bonificado,
        p_importe_resto,
        p_usuario,
        CURRENT_DATE
    )
    RETURNING control_bon INTO v_control_bon;

    RETURN v_control_bon;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al insertar bonificación: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION cementerio.sp_bonificacion1_insertar IS 'Inserta nueva bonificación con oficio (Bonificacion1)';

-- =============================================
-- 5. sp_bonificacion1_actualizar
-- Descripción: Actualiza bonificación existente
-- Parámetros: Campos actualizables + clave (oficio/axo/id_rec)
-- Retorna: Cantidad de filas afectadas
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_bonificacion1_actualizar(
    p_oficio INTEGER,
    p_axo SMALLINT,
--    p_id_rec INTEGER,
    p_fecha_ofic DATE,
    p_importe_bonificar NUMERIC(16,2),
    p_importe_bonificado NUMERIC(16,2),
    p_importe_resto NUMERIC(16,2),
    p_usuario INTEGER
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_affected INTEGER;
BEGIN
    /* TODO FUTURO: Query SQL original (Bonificacion1.pas líneas 204-208):
    -- SQL: 'update ta_13_bonifrcm set
    --       fecha_ofic=fecha, importe_bonificar=valor,
    --       importe_bonificado=valor, importe_resto=valor,
    --       usuario=valor, fecha_mov=today
    --       where oficio=valor and axo=valor and id_rec=valor'
    */

    UPDATE public.ta_13_bonifrcm
    SET
        fecha_ofic = p_fecha_ofic,
        importe_bonificar = p_importe_bonificar,
        importe_bonificado = p_importe_bonificado,
        importe_resto = p_importe_resto,
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE
    WHERE oficio = p_oficio
        AND axo = p_axo
    --    AND id_rec = p_id_rec
		;

    GET DIAGNOSTICS v_affected = ROW_COUNT;
    RETURN v_affected;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al actualizar bonificación: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION cementerio.sp_bonificacion1_actualizar IS 'Actualiza bonificación existente (Bonificacion1)';

-- =============================================
-- 6. sp_bonificacion1_eliminar
-- Descripción: Elimina bonificación por clave
-- Parámetros:
--   - p_oficio: Número de oficio
--   - p_axo: Año del oficio
--   - p_id_rec: ID de recaudadora
-- Retorna: Cantidad de filas eliminadas
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_bonificacion1_eliminar(
    p_oficio INTEGER,
    p_axo SMALLINT,
    p_id_rec INTEGER
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_affected INTEGER;
BEGIN
    /* TODO FUTURO: Query SQL original (Bonificacion1.pas líneas 233-234):
    -- SQL: 'delete from ta_13_bonifrcm
    --       where oficio=valor and axo=valor and id_rec=valor'
    */

    DELETE FROM public.ta_13_bonifrcm
    WHERE oficio = p_oficio
        AND axo = p_axo
        --AND id_rec = p_id_rec
        ;

    GET DIAGNOSTICS v_affected = ROW_COUNT;
    RETURN v_affected;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al eliminar bonificación: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION cementerio.sp_bonificacion1_eliminar IS 'Elimina bonificación por oficio/año/recaudadora (Bonificacion1)';

-- =============================================
-- FIN DE ARCHIVO
-- Total SPs creados: 6
-- =============================================
