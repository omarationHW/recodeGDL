-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: mercados
-- ESQUEMA: public
-- ============================================
\c mercados;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: FechasDescuentoMntto
-- Generado: 2025-08-27 00:04:11
-- Actualizado: 2025-12-02
-- Total SPs: 3
-- ============================================

-- SP 1/3: fechas_descuento_get_all
-- Tipo: Catalog
-- Descripción: Obtiene todas las fechas de descuento y recargos para el año actual.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION fechas_descuento_get_all()
RETURNS TABLE (
    mes smallint,
    fecha_descuento date,
    fecha_recargos date,
    fecha_alta timestamp,
    id_usuario integer,
    usuario text
) AS $$
BEGIN
    RETURN QUERY
    SELECT f.mes, f.fecha_descuento, f.fecha_recargos, f.fecha_alta, f.id_usuario, u.usuario
    FROM padron_licencias.comun.ta_11_fecha_desc f
    LEFT JOIN padron_licencias.comun.ta_12_passwords u ON u.id_usuario = f.id_usuario
    ORDER BY f.mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: fechas_descuento_get_by_mes
-- Tipo: Catalog
-- Descripción: Obtiene la fecha de descuento y recargos para un mes específico.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION fechas_descuento_get_by_mes(p_mes smallint)
RETURNS TABLE (
    mes smallint,
    fecha_descuento date,
    fecha_recargos date,
    fecha_alta timestamp,
    id_usuario integer,
    usuario text
) AS $$
BEGIN
    RETURN QUERY
    SELECT f.mes, f.fecha_descuento, f.fecha_recargos, f.fecha_alta, f.id_usuario, u.usuario
    FROM padron_licencias.comun.ta_11_fecha_desc f
    LEFT JOIN padron_licencias.comun.ta_12_passwords u ON u.id_usuario = f.id_usuario
    WHERE f.mes = p_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: fechas_descuento_update
-- Tipo: CRUD
-- Descripción: Actualiza la fecha de descuento y recargos para un mes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION fechas_descuento_update(
    p_mes smallint,
    p_fecha_descuento date,
    p_fecha_recargos date,
    p_id_usuario integer
) RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_mes_desc smallint;
    v_mes_rec smallint;
BEGIN
    v_mes_desc := EXTRACT(MONTH FROM p_fecha_descuento);
    v_mes_rec := EXTRACT(MONTH FROM p_fecha_recargos);
    IF v_mes_desc != p_mes OR v_mes_rec != p_mes THEN
        RETURN QUERY SELECT false, 'La fecha de descuento y recargos debe corresponder al mes seleccionado.';
        RETURN;
    END IF;
    UPDATE padron_licencias.comun.ta_11_fecha_desc
    SET fecha_descuento = p_fecha_descuento,
        fecha_alta = NOW(),
        fecha_recargos = p_fecha_recargos,
        id_usuario = p_id_usuario
    WHERE mes = p_mes;
    IF FOUND THEN
        RETURN QUERY SELECT true, 'Actualización exitosa';
    ELSE
        RETURN QUERY SELECT false, 'No se encontró el mes a actualizar';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

