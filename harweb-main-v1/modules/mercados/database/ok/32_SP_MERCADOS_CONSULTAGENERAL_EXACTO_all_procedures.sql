-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConsultaGeneral
-- Generado: 2025-08-27 20:45:14
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_consulta_general_buscar_local
-- Tipo: CRUD
-- Descripción: Busca locales por parámetros principales
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consulta_general_buscar_local(
    p_oficina integer,
    p_num_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_local integer,
    p_letra_local varchar DEFAULT NULL,
    p_bloque varchar DEFAULT NULL
) RETURNS TABLE(
    id_local integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    arrendatario varchar,
    domicilio varchar,
    sector varchar,
    zona integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, oficina, num_mercado, categoria, seccion, local, letra_local, bloque, nombre, arrendatario, domicilio, sector, zona
    FROM public.ta_11_locales
    WHERE oficina = p_oficina
      AND num_mercado = p_num_mercado
      AND categoria = p_categoria
      AND seccion = p_seccion
      AND local = p_local
      AND ( (p_letra_local IS NULL AND letra_local IS NULL) OR letra_local = p_letra_local )
      AND ( (p_bloque IS NULL AND bloque IS NULL) OR bloque = p_bloque );
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_consulta_general_detalle_local
-- Tipo: CRUD
-- Descripción: Obtiene detalle completo de un local
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consulta_general_detalle_local(
    p_id_local integer
) RETURNS TABLE(
    id_local integer,
    mercado varchar,
    nombre varchar,
    arrendatario varchar,
    domicilio varchar,
    sector varchar,
    zona integer,
    descripcion_local varchar,
    superficie numeric,
    giro integer,
    fecha_alta date,
    fecha_baja date,
    vigencia varchar,
    usuario varchar,
    renta numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_local, m.descripcion as mercado, l.nombre, l.arrendatario, l.domicilio, l.sector, l.zona, l.descripcion_local, l.superficie, l.giro, l.fecha_alta, l.fecha_baja, l.vigencia, u.usuario, c.importe_cuota * l.superficie as renta
    FROM public.ta_11_locales l
    LEFT JOIN public.ta_11_mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
    LEFT JOIN public.ta_12_passwords u ON l.id_usuario = u.id_usuario
    LEFT JOIN public.ta_11_cuo_locales c ON c.axo = EXTRACT(YEAR FROM CURRENT_DATE) AND c.categoria = l.categoria AND c.seccion = l.seccion AND c.clave_cuota = l.clave_cuota
    WHERE l.id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_consulta_general_adeudos_local
-- Tipo: CRUD
-- Descripción: Obtiene adeudos de un local
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consulta_general_adeudos_local(
    p_id_local integer
) RETURNS TABLE(
    axo integer,
    periodo integer,
    importe numeric,
    recargos numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.axo, a.periodo, a.importe,
      COALESCE((a.importe * (
        SELECT SUM(porcentaje_mes) FROM public.ta_12_recargos r
        WHERE (r.axo = a.axo AND r.mes >= a.periodo)
      ) / 100), 0) as recargos
    FROM public.ta_11_adeudo_local a
    WHERE a.id_local = p_id_local
    ORDER BY a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_consulta_general_pagos_local
-- Tipo: CRUD
-- Descripción: Obtiene pagos de un local
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consulta_general_pagos_local(
    p_id_local integer
) RETURNS TABLE(
    axo integer,
    periodo integer,
    fecha_pago date,
    importe_pago numeric,
    usuario varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.axo, p.periodo, p.fecha_pago, p.importe_pago, u.usuario
    FROM public.ta_11_pagos_local p
    LEFT JOIN public.ta_12_passwords u ON p.id_usuario = u.id_usuario
    WHERE p.id_local = p_id_local
    ORDER BY p.axo, p.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_consulta_general_requerimientos_local
-- Tipo: CRUD
-- Descripción: Obtiene requerimientos de un local
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consulta_general_requerimientos_local(
    p_id_local integer
) RETURNS TABLE(
    folio integer,
    fecha_emision date,
    importe_multa numeric,
    importe_gastos numeric,
    vigencia varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.folio, r.fecha_emision, r.importe_multa, r.importe_gastos, r.vigencia
    FROM public.ta_15_apremios r
    WHERE r.control_otr = p_id_local
    ORDER BY r.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

