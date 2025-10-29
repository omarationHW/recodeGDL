-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Listados_Ade
-- Generado: 2025-08-27 15:21:31
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_listados_ade_mercados
-- Tipo: Report
-- Descripción: Obtiene listado de adeudos de mercados según filtros.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_listados_ade_mercados(
    p_oficina integer,
    p_num_mercado1 integer,
    p_num_mercado2 integer,
    p_local1 integer,
    p_local2 integer,
    p_seccion text,
    p_axo integer,
    p_mes integer
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Ejemplo simplificado, adaptar a modelo real
    SELECT a.*, b.*, c.descripcion, b.importe AS renta,
      (SELECT COALESCE(SUM(importe_gastos),0) FROM ta_15_apremios WHERE modulo=11 AND control_otr=a.id_local AND clave_practicado='P' AND vigencia='1') AS total_gasto
    FROM ta_11_locales a
    JOIN ta_11_adeudo_local b ON a.id_local = b.id_local
    JOIN ta_11_mercados c ON a.oficina = c.oficina AND a.num_mercado = c.num_mercado_nvo
    WHERE a.oficina = p_oficina
      AND a.num_mercado BETWEEN p_num_mercado1 AND p_num_mercado2
      AND (p_seccion IS NULL OR a.seccion = p_seccion)
      AND a.local BETWEEN p_local1 AND p_local2
      AND ((b.axo < p_axo) OR (b.axo = p_axo AND b.periodo <= p_mes))
    ORDER BY a.id_local, b.axo, b.periodo;
END;
$$;

-- ============================================

-- SP 2/5: sp_listados_ade_aseo
-- Tipo: Report
-- Descripción: Obtiene listado de adeudos de aseo según filtros.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_listados_ade_aseo(
    p_tipo_aseo text,
    p_contrato1 integer,
    p_contrato2 integer,
    p_id_rec integer,
    p_axo integer,
    p_mes integer
)
LANGUAGE plpgsql AS $$
BEGIN
    SELECT a.*, b.*, c.descripcion,
      (SELECT COALESCE(SUM(importe_gastos),0) FROM ta_15_apremios WHERE modulo=16 AND control_otr=a.control_contrato AND clave_practicado='P' AND vigencia='1') AS total_gasto
    FROM ta_16_contratos a
    JOIN ta_16_pagos b ON a.control_contrato = b.control_contrato
    JOIN ta_16_tipo_aseo c ON a.ctrol_aseo = c.ctrol_aseo
    WHERE a.id_rec = p_id_rec
      AND (p_tipo_aseo IS NULL OR c.tipo_aseo = p_tipo_aseo)
      AND a.num_contrato BETWEEN p_contrato1 AND p_contrato2
      AND EXTRACT(YEAR FROM b.aso_mes_pago) <= p_axo
      AND EXTRACT(MONTH FROM b.aso_mes_pago) <= p_mes
    ORDER BY a.num_contrato;
END;
$$;

-- ============================================

-- SP 3/5: sp_listados_ade_publicos
-- Tipo: Report
-- Descripción: Obtiene listado de adeudos de estacionamientos públicos.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_listados_ade_publicos(
    p_numesta1 integer,
    p_numesta2 integer,
    p_axo integer,
    p_mes integer,
    p_impd numeric,
    p_imph numeric,
    p_id_rec integer
)
LANGUAGE plpgsql AS $$
BEGIN
    SELECT a.*, b.*, c.tipo, b.ade_importe AS adeudo,
      (SELECT COALESCE(SUM(importe_gastos),0) FROM ta_15_apremios WHERE modulo=24 AND control_otr=a.id AND clave_practicado='P' AND vigencia='1') AS total_gasto
    FROM pubmain a
    JOIN pubadeudo b ON b.pubmain_id = a.id
    JOIN pubtipoadeudo c ON c.tipo_id = b.tipo
    WHERE a.fecha_baja IS NULL
      AND a.numesta BETWEEN p_numesta1 AND p_numesta2
      AND ((b.axo < p_axo) OR (b.axo = p_axo AND b.mes <= p_mes))
      AND b.ade_importe BETWEEN p_impd AND p_imph
      AND a.id_rec = p_id_rec
    ORDER BY a.numesta, b.axo, b.mes;
END;
$$;

-- ============================================

-- SP 4/5: sp_listados_ade_exclusivos
-- Tipo: Report
-- Descripción: Obtiene listado de adeudos de estacionamientos exclusivos.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_listados_ade_exclusivos(
    p_no_exclusivo1 integer,
    p_no_exclusivo2 integer,
    p_axo integer,
    p_mes integer,
    p_impd numeric,
    p_imph numeric,
    p_id_rec integer
)
LANGUAGE plpgsql AS $$
BEGIN
    SELECT a.*, b.*, c.tipo, b.ade_importe AS adeudo, d.propietario, e.calle,
      (SELECT COALESCE(SUM(importe_gastos),0) FROM ta_15_apremios WHERE modulo=28 AND control_otr=a.id AND clave_practicado='P' AND vigencia='1') AS total_gasto
    FROM ex_contrato a
    JOIN ex_adeudo b ON b.ex_contrato_id = a.id
    JOIN pubtipoadeudo c ON c.tipo_id = b.tipo
    JOIN ex_propietario d ON d.id = a.ex_propietario_id
    JOIN ex_ubicacion e ON e.ex_contrato_id = a.id
    WHERE a.estatus = 'V'
      AND a.no_exclusivo BETWEEN p_no_exclusivo1 AND p_no_exclusivo2
      AND ((b.axo < p_axo) OR (b.axo = p_axo AND b.mes <= p_mes))
      AND b.ade_importe BETWEEN p_impd AND p_imph
      AND a.id_rec = p_id_rec
    ORDER BY a.no_exclusivo, b.axo, b.mes;
END;
$$;

-- ============================================

-- SP 5/5: sp_listados_ade_infracciones
-- Tipo: Report
-- Descripción: Obtiene listado de adeudos de infracciones/estacionómetros.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_listados_ade_infracciones(
    p_propietario text,
    p_placa text,
    p_axo1 integer,
    p_axo2 integer,
    p_impd numeric,
    p_imph numeric,
    p_tipo text,
    p_id_rec integer
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Ejemplo: buscar por propietario o placa, filtrar por año y adeudo
    SELECT * FROM ta_padron
    WHERE (p_propietario IS NULL OR nombre ILIKE '%'||p_propietario||'%')
      AND (p_placa IS NULL OR placa = p_placa)
      AND id_rec = p_id_rec
      AND axo BETWEEN p_axo1 AND p_axo2
      AND adeudo BETWEEN p_impd AND p_imph;
END;
$$;

-- ============================================

