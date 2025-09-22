-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptPadronLocales
-- Generado: 2025-08-27 01:27:45
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_get_padron_locales
-- Tipo: Report
-- Descripción: Obtiene el padrón de locales para una recaudadora y mercado, incluyendo datos calculados de vigencia y renta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_padron_locales(p_oficina INTEGER, p_mercado INTEGER)
RETURNS TABLE (
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    letra_local VARCHAR(1),
    bloque VARCHAR(1),
    id_contribuy_prop INTEGER,
    id_contribuy_renta INTEGER,
    nombre VARCHAR(60),
    arrendatario VARCHAR(60),
    domicilio VARCHAR(80),
    sector VARCHAR(1),
    zona SMALLINT,
    descripcion_local VARCHAR(80),
    superficie NUMERIC(12,2),
    giro SMALLINT,
    fecha_alta DATE,
    fecha_baja DATE,
    fecha_modificacion TIMESTAMP,
    vigencia VARCHAR(1),
    id_usuario INTEGER,
    clave_cuota SMALLINT,
    descripcion VARCHAR(60),
    datosmercado VARCHAR(60),
    vigdescripcion VARCHAR(30),
    renta NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.letra_local, a.bloque,
        a.id_contribuy_prop, a.id_contribuy_renta, a.nombre, a.arrendatario, a.domicilio, a.sector, a.zona,
        a.descripcion_local, a.superficie, a.giro, a.fecha_alta, a.fecha_baja, a.fecha_modificacion, a.vigencia, a.id_usuario, a.clave_cuota,
        b.descripcion,
        (a.seccion || ' ' || a.local::text || ' ' || COALESCE(a.letra_local,'') || ' ' || COALESCE(a.bloque,'')) AS datosmercado,
        CASE a.vigencia
            WHEN 'B' THEN 'BAJA'
            WHEN 'C' THEN 'BAJA POR ACUERDO'
            WHEN 'D' THEN 'BAJA ADMINISTRATIVA'
            ELSE 'VIGENTE'
        END AS vigdescripcion,
        CASE 
            WHEN a.seccion = 'PS' AND a.clave_cuota = 4 THEN a.superficie * c.importe_cuota
            WHEN a.seccion = 'PS' THEN (c.importe_cuota * a.superficie) * 30
            WHEN a.num_mercado = 214 THEN (a.superficie * c.importe_cuota) * COALESCE(d.sabadosacum, 1)
            ELSE a.superficie * c.importe_cuota
        END AS renta
    FROM public.ta_11_locales a
    JOIN public.ta_11_categoria b ON a.categoria = b.categoria
    LEFT JOIN public.ta_11_cuo_locales c ON c.axo = EXTRACT(YEAR FROM CURRENT_DATE) AND c.categoria = a.categoria AND c.seccion = a.seccion AND c.clave_cuota = a.clave_cuota
    LEFT JOIN public.ta_11_fecha_desc d ON d.mes = EXTRACT(MONTH FROM CURRENT_DATE)
    WHERE a.oficina = p_oficina AND a.num_mercado = p_mercado
    ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_get_recaudadora
-- Tipo: Catalog
-- Descripción: Obtiene información de la recaudadora por id.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recaudadora(p_oficina INTEGER)
RETURNS TABLE (
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora VARCHAR(40),
    domicilio VARCHAR(80),
    tel VARCHAR(15),
    recaudador VARCHAR(40)
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_rec, id_zona, recaudadora, domicilio, tel, recaudador
    FROM public.ta_12_recaudadoras
    WHERE id_rec = p_oficina;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_get_mercado
-- Tipo: Catalog
-- Descripción: Obtiene información de los mercados de una public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_mercado(p_oficina INTEGER)
RETURNS TABLE (
    oficina SMALLINT,
    num_mercado_nvo SMALLINT,
    categoria SMALLINT,
    descripcion VARCHAR(60),
    cuenta_ingreso INTEGER,
    cuenta_energia INTEGER,
    id_zona SMALLINT,
    tipo_emision VARCHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision
    FROM public.ta_11_mercados
    WHERE oficina = p_oficina AND tipo_emision <> 'B'
    ORDER BY oficina, num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_get_renta
-- Tipo: Report
-- Descripción: Obtiene la cuota de renta para un local según año, categoría, sección y clave de cuota.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_renta(p_axo INTEGER, p_categoria INTEGER, p_seccion VARCHAR, p_clave_cuota INTEGER)
RETURNS TABLE (
    id_cuotas INTEGER,
    axo SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    clave_cuota SMALLINT,
    importe_cuota NUMERIC(12,2),
    fecha_alta TIMESTAMP,
    id_usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_cuotas, axo, categoria, seccion, clave_cuota, importe_cuota, fecha_alta, id_usuario
    FROM public.ta_11_cuo_locales
    WHERE axo = p_axo AND categoria = p_categoria AND seccion = p_seccion AND clave_cuota = p_clave_cuota;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_get_vencimiento_rec
-- Tipo: Catalog
-- Descripción: Obtiene la fecha de vencimiento de recargos y descuentos para un mes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_vencimiento_rec(p_mes SMALLINT)
RETURNS TABLE (
    mes SMALLINT,
    fecha_recargos DATE,
    fecha_descuento DATE,
    trimestre SMALLINT,
    sabados SMALLINT,
    sabadosacum SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT mes, fecha_recargos, fecha_descuento, trimestre, sabados, sabadosacum
    FROM public.ta_11_fecha_desc
    WHERE mes = p_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

