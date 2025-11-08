-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: DatosRequerimientos
-- Generado: 2025-08-26 23:47:56
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_get_locales
-- Tipo: Catalog
-- Descripción: Obtiene los datos de un local por id_local
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_locales(p_id_local integer)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    descripcion_local varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, letra_local, bloque, nombre, descripcion_local
    FROM public.ta_11_locales
    WHERE id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_get_mercado
-- Tipo: Catalog
-- Descripción: Obtiene los datos de un mercado por oficina y num_mercado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_mercado(p_oficina smallint, p_num_mercado smallint)
RETURNS TABLE (
    oficina smallint,
    num_mercado_nvo smallint,
    categoria smallint,
    descripcion varchar,
    cuenta_ingreso integer,
    cuenta_energia integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia
    FROM public.ta_11_mercados
    WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_get_requerimientos
-- Tipo: Catalog
-- Descripción: Obtiene los datos de requerimiento por modulo, folio y control_otr
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_requerimientos(p_modulo smallint, p_folio integer, p_control_otr integer)
RETURNS TABLE (
    id_control integer,
    modulo smallint,
    control_otr integer,
    folio integer,
    diligencia varchar,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    fecha_emision date,
    clave_practicado varchar,
    vigencia varchar,
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
    clave_remate varchar,
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones varchar,
    fecha_pago date,
    recaudadora smallint,
    caja varchar,
    operacion integer,
    importe_pago numeric,
    clave_mov varchar,
    hora_practicado timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.modulo, a.control_otr, a.folio, a.diligencia, a.importe_global, a.importe_multa, a.importe_recargo, a.importe_gastos, a.fecha_emision, a.clave_practicado, a.vigencia, a.fecha_actualiz, a.usuario, b.id_usuario, b.usuario as usuario_1, b.nombre, b.estado, b.id_rec, b.nivel, a.zona, a.zona_apremio, a.fecha_practicado, a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora, a.ejecutor, a.clave_secuestro, a.clave_remate, a.fecha_remate, a.porcentaje_multa, a.observaciones, a.fecha_pago, a.recaudadora, a.caja, a.operacion, a.importe_pago, a.clave_mov, a.hora_practicado
    FROM public.ta_15_apremios a
    JOIN public.ta_12_passwords b ON a.usuario = b.id_usuario
    WHERE a.modulo = p_modulo AND a.folio = p_folio AND a.control_otr = p_control_otr;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_get_periodos
-- Tipo: Catalog
-- Descripción: Obtiene los periodos de un requerimiento por control_otr
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_periodos(p_control_otr integer)
RETURNS TABLE (
    id_control integer,
    control_otr integer,
    ayo smallint,
    periodo smallint,
    importe numeric,
    recargos numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_control, control_otr, ayo, periodo, importe, recargos
    FROM public.ta_15_periodos
    WHERE control_otr = p_control_otr;
END;
$$ LANGUAGE plpgsql;

-- ============================================

