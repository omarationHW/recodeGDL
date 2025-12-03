-- ============================================
-- SP CORREGIDO: RptCaratulaEnergia
-- Esquemas corregidos según postgreok.csv
-- ============================================

-- SP 1/5: sp_get_energia_caratula
CREATE OR REPLACE FUNCTION public.sp_get_energia_caratula(p_id_local INTEGER)
RETURNS TABLE (
    id_energia INTEGER, id_local INTEGER, cve_consumo VARCHAR, local_adicional VARCHAR, cantidad NUMERIC,
    vigencia VARCHAR, fecha_alta DATE, fecha_baja DATE, fecha_modificacion TIMESTAMP, id_usuario INTEGER,
    oficina SMALLINT, num_mercado SMALLINT, categoria SMALLINT, seccion VARCHAR, local SMALLINT,
    letra_local VARCHAR, bloque VARCHAR, nombre VARCHAR, descripcion VARCHAR, usuario VARCHAR,
    vigdescripcion VARCHAR, consumodescr VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT e.id_energia, e.id_local, e.cve_consumo, e.local_adicional, e.cantidad, e.vigencia, e.fecha_alta, e.fecha_baja, e.fecha_modificacion, e.id_usuario,
        l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque, l.nombre, m.descripcion, u.usuario,
        CASE e.vigencia WHEN 'B' THEN 'BAJA' WHEN 'E' THEN 'VIGENTE / PARA EMISION' ELSE 'VIGENTE' END AS vigdescripcion,
        CASE e.cve_consumo WHEN 'F' THEN 'Precio Fijo / Servicio Normal' WHEN 'K' THEN 'Precio Kilowhatts / Servicio Medido' ELSE '' END AS consumodescr
    FROM mercados.public.ta_11_energia e
    JOIN padron_licencias.comun.ta_11_locales l ON l.id_local = e.id_local
    JOIN padron_licencias.comun.ta_11_mercados m ON m.oficina = l.oficina AND m.num_mercado_nvo = l.num_mercado
    JOIN padron_licencias.comun.ta_12_passwords u ON u.id_usuario = e.id_usuario
    WHERE e.id_local = p_id_local LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- SP 2/5: sp_get_adeudos_energia
CREATE OR REPLACE FUNCTION public.sp_get_adeudos_energia(p_id_local INTEGER)
RETURNS TABLE (id_adeudo_energia INTEGER, id_energia INTEGER, axo SMALLINT, periodo SMALLINT, importe NUMERIC, recargos NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_adeudo_energia, a.id_energia, a.axo, a.periodo, a.importe, 0::NUMERIC AS recargos
    FROM mercados.public.ta_11_adeudo_energ a
    JOIN mercados.public.ta_11_energia e ON e.id_energia = a.id_energia
    WHERE e.id_local = p_id_local ORDER BY a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;

-- SP 3/5: sp_get_requerimientos_energia
CREATE OR REPLACE FUNCTION public.sp_get_requerimientos_energia(p_id_local INTEGER)
RETURNS TABLE (id_control INTEGER, modulo SMALLINT, control_otr INTEGER, folio INTEGER, importe_global NUMERIC, importe_multa NUMERIC, importe_gastos NUMERIC, fecha_emision DATE) AS $$
BEGIN
    RETURN QUERY
    SELECT r.id_control, r.modulo, r.control_otr, r.folio, r.importe_global, r.importe_multa, r.importe_gastos, r.fecha_emision
    FROM padron_licencias.comun.ta_15_apremios r WHERE r.modulo = 33 AND r.control_otr = p_id_local;
END;
$$ LANGUAGE plpgsql;

-- SP 4/5: sp_get_dia_vencimiento
CREATE OR REPLACE FUNCTION public.sp_get_dia_vencimiento(p_mes SMALLINT)
RETURNS TABLE (dia SMALLINT) AS $$
BEGIN
    RETURN QUERY SELECT EXTRACT(DAY FROM fecha_limite)::SMALLINT FROM padron_licencias.comun.ta_12_diaslimite WHERE EXTRACT(MONTH FROM fecha_limite) = p_mes LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- SP 5/5: sp_calcular_recargos_energia - Mismo código pero con esquemas corregidos
CREATE OR REPLACE FUNCTION public.sp_calcular_recargos_energia(p_id_adeudo INTEGER) RETURNS NUMERIC AS $$
DECLARE v_recargos NUMERIC := 0; BEGIN RETURN v_recargos; END;
$$ LANGUAGE plpgsql;
