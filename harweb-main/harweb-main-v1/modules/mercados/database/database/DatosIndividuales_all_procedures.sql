-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: DatosIndividuales
-- Generado: 2025-08-26 23:44:50
-- Total SPs: 8
-- ============================================

-- SP 1/8: sp_get_datos_individuales
-- Tipo: Catalog
-- Descripción: Obtiene los datos individuales de un local
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_datos_individuales(p_id_local INTEGER)
RETURNS TABLE (
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    local INTEGER,
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    id_contribuy_prop INTEGER,
    id_contribuy_renta INTEGER,
    nombre VARCHAR(30),
    arrendatario VARCHAR(30),
    domicilio VARCHAR(40),
    sector VARCHAR(1),
    zona SMALLINT,
    descripcion_local VARCHAR(255),
    superficie FLOAT,
    giro SMALLINT,
    fecha_alta DATE,
    fecha_baja DATE,
    fecha_modificacion TIMESTAMP,
    vigencia VARCHAR(1),
    id_usuario INTEGER,
    clave_cuota SMALLINT,
    num_mercado_nvo SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.*, m.num_mercado_nvo
    FROM ta_11_locales l
    LEFT JOIN ta_11_mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
    WHERE l.id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/8: sp_get_adeudos_local
-- Tipo: Catalog
-- Descripción: Obtiene los adeudos de un local
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_adeudos_local(p_id_local INTEGER)
RETURNS TABLE (
    id_local INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC,
    recargos NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.axo, a.periodo, a.importe,
        (a.importe * COALESCE((SELECT SUM(porcentaje_mes) FROM ta_12_recargos WHERE axo = a.axo AND mes >= a.periodo),0)/100) AS recargos
    FROM ta_11_adeudo_local a
    WHERE a.id_local = p_id_local
    ORDER BY a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/8: sp_get_requerimientos_local
-- Tipo: Catalog
-- Descripción: Obtiene los requerimientos de un local
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_requerimientos_local(p_id_local INTEGER)
RETURNS TABLE (
    id_control INTEGER,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia VARCHAR(1),
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    fecha_emision DATE,
    clave_practicado VARCHAR(1),
    vigencia VARCHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.id_control, r.modulo, r.control_otr, r.folio, r.diligencia, r.importe_global, r.importe_multa, r.importe_recargo, r.importe_gastos, r.fecha_emision, r.clave_practicado, r.vigencia
    FROM ta_15_apremios r
    WHERE r.control_otr = p_id_local AND r.vigencia = '1' AND r.clave_practicado = 'P'
    ORDER BY r.fecha_emision, r.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/8: sp_get_movimientos_local
-- Tipo: Catalog
-- Descripción: Obtiene los movimientos de un local
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_movimientos_local(p_id_local INTEGER)
RETURNS TABLE (
    id_movimiento INTEGER,
    id_local INTEGER,
    axo_memo SMALLINT,
    numero_memo INTEGER,
    nombre VARCHAR(30),
    tipo_movimiento SMALLINT,
    fecha TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_movimiento, id_local, axo_memo, numero_memo, nombre, tipo_movimiento, fecha
    FROM ta_11_movimientos
    WHERE id_local = p_id_local
    ORDER BY axo_memo, numero_memo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/8: sp_get_mercado
-- Tipo: Catalog
-- Descripción: Obtiene los datos del mercado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_mercado(p_oficina SMALLINT, p_num_mercado SMALLINT)
RETURNS TABLE (
    oficina SMALLINT,
    num_mercado_nvo SMALLINT,
    categoria SMALLINT,
    descripcion VARCHAR(30),
    cuenta_ingreso INTEGER,
    cuenta_energia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia
    FROM ta_11_mercados
    WHERE oficina = p_oficina AND num_mercado_nvo = p_num_mercado;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/8: sp_get_cuota
-- Tipo: Catalog
-- Descripción: Obtiene la cuota del local
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cuota(p_axo SMALLINT, p_categoria SMALLINT, p_seccion VARCHAR, p_clave_cuota SMALLINT)
RETURNS TABLE (
    id_cuotas INTEGER,
    axo SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    clave_cuota SMALLINT,
    importe_cuota NUMERIC,
    renta NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_cuotas, axo, categoria, seccion, clave_cuota, importe_cuota,
        importe_cuota AS renta
    FROM ta_11_cuo_locales
    WHERE axo = p_axo AND categoria = p_categoria AND seccion = p_seccion AND clave_cuota = p_clave_cuota;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/8: sp_get_usuario
-- Tipo: Catalog
-- Descripción: Obtiene los datos del usuario
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_usuario(p_id_usuario INTEGER)
RETURNS TABLE (
    id_usuario INTEGER,
    usuario VARCHAR(10),
    nombre VARCHAR(50),
    estado VARCHAR(1),
    id_rec SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_usuario, usuario, nombre, estado, id_rec
    FROM ta_12_passwords
    WHERE id_usuario = p_id_usuario;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 8/8: sp_get_tianguis
-- Tipo: Catalog
-- Descripción: Obtiene los datos del tianguis para locales con num_mercado=214
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tianguis(p_folio INTEGER)
RETURNS TABLE (
    Folio INTEGER,
    Nombre VARCHAR(132),
    Domicilio VARCHAR(60),
    Colonia VARCHAR(40),
    Poblacion VARCHAR(11),
    Superficie FLOAT,
    Giro VARCHAR(40),
    Descuento FLOAT,
    MotivoDescuento VARCHAR(13)
) AS $$
BEGIN
    RETURN QUERY
    SELECT Folio, Nombre, Domicilio, Colonia, Poblacion, Superficie, Giro, Descuento, MotivoDescuento
    FROM cobrotrimestral
    WHERE Folio = p_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

