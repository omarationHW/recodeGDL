-- ============================================
-- CORRECCIÓN DE SPs para ConsRequerimientos
-- Cambia public.ta_* a comun.ta_*
-- ============================================

-- DROP de SPs existentes
DROP FUNCTION IF EXISTS public.sp_get_locales_by_mercado(smallint, smallint, smallint, character, integer, character varying, character varying);
DROP FUNCTION IF EXISTS public.sp_get_locales_by_mercado(smallint, smallint, smallint, varchar, integer, varchar, varchar);
DROP FUNCTION IF EXISTS public.sp_get_requerimientos_by_local(smallint, integer);
DROP FUNCTION IF EXISTS public.sp_get_periodos_by_requerimiento(integer);

-- SP 1: sp_get_locales_by_mercado - CORREGIDO
CREATE OR REPLACE FUNCTION public.sp_get_locales_by_mercado(
    p_oficina smallint,
    p_num_mercado smallint,
    p_categoria smallint,
    p_seccion character(2),
    p_local integer,
    p_letra_local character varying(3),
    p_bloque character varying(2)
)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion character(2),
    local integer,
    letra_local character varying(3),
    bloque character varying(2),
    calcregistro varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_local,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        (l.oficina||'-'||l.num_mercado||'-'||l.categoria||'-'||l.seccion||'-'||l.local||'-'||COALESCE(l.letra_local,' ')||'-'||COALESCE(l.bloque,' '))::varchar AS calcregistro
    FROM comun.ta_11_locales l  -- CORREGIDO: comun en lugar de public
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_num_mercado
      AND l.categoria = p_categoria
      AND l.seccion = p_seccion
      AND l.local = p_local
      AND (p_letra_local IS NULL OR l.letra_local = p_letra_local OR (p_letra_local = '' AND l.letra_local IS NULL))
      AND (p_bloque IS NULL OR l.bloque = p_bloque OR (p_bloque = '' AND l.bloque IS NULL));
END;
$$ LANGUAGE plpgsql;

-- SP 2: sp_get_requerimientos_by_local - CORREGIDO
CREATE OR REPLACE FUNCTION public.sp_get_requerimientos_by_local(
    p_modulo smallint,
    p_control_otr integer
)
RETURNS TABLE (
    id_control integer,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia character(1),
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    fecha_emision date,
    clave_practicado character(1),
    vigencia character(1),
    fecha_actualiz date,
    usuario integer,
    id_usuario integer,
    usuario_1 varchar,
    nombre varchar,
    estado varchar,
    id_rec smallint,
    nivel smallint,
    zona smallint,
    zona_apremio smallint,
    fecha_practicado date,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora timestamp,
    ejecutor smallint,
    clave_secuestro smallint,
    clave_remate character(1),
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar,
    fecha_pago date,
    recaudadora smallint,
    caja character(2),
    operacion integer,
    importe_pago numeric,
    clave_mov character(2),
    hora_practicado timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_control,
        a.modulo,
        a.control_otr,
        a.folio,
        a.diligencia,
        a.importe_global,
        a.importe_multa,
        a.importe_recargo,
        a.importe_gastos,
        a.fecha_emision,
        a.clave_practicado,
        a.vigencia,
        a.fecha_actualiz,
        a.usuario,
        b.id_usuario,
        b.usuario::varchar,
        b.nombre::varchar,
        b.estado::varchar,
        b.id_rec,
        b.nivel,
        a.zona,
        a.zona_apremio,
        a.fecha_practicado,
        a.fecha_entrega1,
        a.fecha_entrega2,
        a.fecha_citatorio,
        a.hora,
        a.ejecutor,
        a.clave_secuestro,
        a.clave_remate,
        a.fecha_remate,
        a.porcentaje_multa,
        a.observaciones,
        a.fecha_pago,
        a.recaudadora,
        a.caja,
        a.operacion,
        a.importe_pago,
        a.clave_mov,
        a.hora_practicado
    FROM comun.ta_15_apremios a  -- CORREGIDO: comun en lugar de public
    LEFT JOIN comun.ta_12_passwords b ON a.usuario = b.id_usuario  -- CORREGIDO: comun en lugar de public
    WHERE a.modulo = p_modulo
      AND a.control_otr = p_control_otr
      AND a.vigencia = 'A'
    ORDER BY a.fecha_emision, a.folio;
END;
$$ LANGUAGE plpgsql;

-- SP 3: sp_get_periodos_by_requerimiento - CORREGIDO
CREATE OR REPLACE FUNCTION public.sp_get_periodos_by_requerimiento(
    p_control_otr integer
)
RETURNS TABLE (
    id_control integer,
    control_otr integer,
    ayo smallint,
    periodo integer,
    importe numeric,
    recargos numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id_control,
        p.control_otr,
        p.ayo,
        p.periodo,
        p.importe,
        p.recargos
    FROM comun.ta_15_periodos p  -- CORREGIDO: comun en lugar de public
    WHERE p.control_otr = p_control_otr;
END;
$$ LANGUAGE plpgsql;
