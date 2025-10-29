-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConsRequerimientos
-- Generado: 2025-08-26 23:23:01
-- Total SPs: 8
-- ============================================

-- SP 1/8: sp_get_mercados
-- Tipo: Catalog
-- Descripción: Obtiene la lista de mercados activos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_mercados()
RETURNS TABLE (
    id integer,
    oficina smallint,
    num_mercado_nvo smallint,
    categoria smallint,
    descripcion varchar,
    cuenta_ingreso integer,
    cuenta_energia integer,
    id_zona smallint,
    tipo_emision varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT row_number() OVER (), oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision
    FROM ta_11_mercados
    ORDER BY oficina, num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/8: sp_get_locales_by_mercado
-- Tipo: Catalog
-- Descripción: Obtiene locales por mercado y filtros
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_locales_by_mercado(
    p_oficina smallint,
    p_num_mercado smallint,
    p_categoria smallint,
    p_seccion varchar,
    p_local integer,
    p_letra_local varchar,
    p_bloque varchar
)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    calcregistro varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque,
        (oficina||'-'||num_mercado||'-'||categoria||'-'||seccion||'-'||local||'-'||COALESCE(letra_local,' ')||'-'||COALESCE(bloque,' ')) AS calcregistro
    FROM ta_11_locales
    WHERE oficina = p_oficina
      AND num_mercado = p_num_mercado
      AND categoria = p_categoria
      AND seccion = p_seccion
      AND local = p_local
      AND (p_letra_local IS NULL OR letra_local = p_letra_local OR (p_letra_local = '' AND letra_local IS NULL))
      AND (p_bloque IS NULL OR bloque = p_bloque OR (p_bloque = '' AND bloque IS NULL));
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/8: sp_get_requerimientos_by_local
-- Tipo: Catalog
-- Descripción: Obtiene los requerimientos de un local por módulo y control_otr
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_requerimientos_by_local(
    p_modulo smallint,
    p_control_otr integer
)
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
    SELECT a.id_control, a.modulo, a.control_otr, a.folio, a.diligencia, a.importe_global, a.importe_multa, a.importe_recargo, a.importe_gastos,
           a.fecha_emision, a.clave_practicado, a.vigencia, a.fecha_actualiz, a.usuario, b.id_usuario, b.usuario, b.nombre, b.estado, b.id_rec, b.nivel,
           a.zona, a.zona_apremio, a.fecha_practicado, a.fecha_entrega1, a.fecha_entrega2, a.fecha_citatorio, a.hora, a.ejecutor, a.clave_secuestro,
           a.clave_remate, a.fecha_remate, a.porcentaje_multa, a.observaciones, a.fecha_pago, a.recaudadora, a.caja, a.operacion, a.importe_pago,
           a.clave_mov, a.hora_practicado
    FROM ta_15_apremios a
    JOIN ta_12_passwords b ON a.usuario = b.id_usuario
    WHERE a.modulo = p_modulo AND a.control_otr = p_control_otr
    ORDER BY a.fecha_emision, a.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/8: sp_get_periodos_by_requerimiento
-- Tipo: Catalog
-- Descripción: Obtiene los periodos asociados a un requerimiento
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_periodos_by_requerimiento(
    p_control_otr integer
)
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
    FROM ta_15_periodos
    WHERE control_otr = p_control_otr;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/8: sp_get_ejecutor_by_id
-- Tipo: Catalog
-- Descripción: Obtiene el ejecutor por clave
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_ejecutor_by_id(
    p_ejecutor integer
)
RETURNS TABLE (
    cve_eje integer,
    nombre varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT cve_eje, nombre FROM ta_15_ejecutores WHERE cve_eje = p_ejecutor;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/8: sp_get_clave_by_vigencia
-- Tipo: Catalog
-- Descripción: Obtiene la clave por vigencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_clave_by_vigencia(
    p_vigencia varchar
)
RETURNS TABLE (
    id_clave integer,
    tipo_clave smallint,
    concepto_tipo varchar,
    clave varchar,
    descrip varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_clave, tipo_clave, concepto_tipo, clave, descrip
    FROM ta_15_claves
    WHERE tipo_clave = 5 AND clave = p_vigencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/8: sp_get_clave_by_diligencia
-- Tipo: Catalog
-- Descripción: Obtiene la clave por diligencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_clave_by_diligencia(
    p_diligencia varchar
)
RETURNS TABLE (
    id_clave integer,
    tipo_clave smallint,
    concepto_tipo varchar,
    clave varchar,
    descrip varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_clave, tipo_clave, concepto_tipo, clave, descrip
    FROM ta_15_claves
    WHERE tipo_clave = 4 AND clave = p_diligencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 8/8: sp_get_clave_by_practicado
-- Tipo: Catalog
-- Descripción: Obtiene la clave por clave_practicado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_clave_by_practicado(
    p_clave_practicado varchar
)
RETURNS TABLE (
    id_clave integer,
    tipo_clave smallint,
    concepto_tipo varchar,
    clave varchar,
    descrip varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_clave, tipo_clave, concepto_tipo, clave, descrip
    FROM ta_15_claves
    WHERE tipo_clave = 1 AND clave = p_clave_practicado;
END;
$$ LANGUAGE plpgsql;

-- ============================================

