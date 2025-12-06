-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: mercados
-- ESQUEMA: public
-- ============================================
\c mercados;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: FechaDescuento
-- Generado: 2025-08-27 00:02:50
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_fechadescuento_list
-- Tipo: Catalog
-- Descripción: Devuelve todas las filas de fechas de descuento con usuario
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_fechadescuento_list()
RETURNS TABLE (
    mes smallint,
    fecha_descuento date,
    fecha_alta timestamp,
    id_usuario integer,
    usuario varchar(50),
    fecha_recargos date
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.mes, a.fecha_descuento, a.fecha_alta, a.id_usuario, b.usuario, a.fecha_recargos
    FROM padron_licencias.comun.ta_11_fecha_desc a
    JOIN padron_licencias.comun.ta_12_passwords b ON a.id_usuario = b.id_usuario
    ORDER BY a.mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_fechadescuento_get
-- Tipo: Catalog
-- Descripción: Obtiene una fila específica de fecha de descuento por mes
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_fechadescuento_get(p_mes smallint)
RETURNS TABLE (
    mes smallint,
    fecha_descuento date,
    fecha_alta timestamp,
    id_usuario integer,
    usuario varchar(50),
    fecha_recargos date
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.mes, a.fecha_descuento, a.fecha_alta, a.id_usuario, b.usuario, a.fecha_recargos
    FROM padron_licencias.comun.ta_11_fecha_desc a
    JOIN padron_licencias.comun.ta_12_passwords b ON a.id_usuario = b.id_usuario
    WHERE a.mes = p_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_fechadescuento_update
-- Tipo: CRUD
-- Descripción: Actualiza la fecha de descuento y recargos para un mes dado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_fechadescuento_update(
    p_mes smallint,
    p_fecha_descuento date,
    p_fecha_recargos date,
    p_id_usuario integer
) RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_count integer;
BEGIN
    SELECT COUNT(*) INTO v_count FROM padron_licencias.comun.ta_11_fecha_desc WHERE mes = p_mes;
    IF v_count = 0 THEN
        RETURN QUERY SELECT false, 'No existe el mes especificado';
        RETURN;
    END IF;
    UPDATE padron_licencias.comun.ta_11_fecha_desc
    SET fecha_descuento = p_fecha_descuento,
        fecha_recargos = p_fecha_recargos,
        fecha_alta = NOW(),
        id_usuario = p_id_usuario
    WHERE mes = p_mes;
    RETURN QUERY SELECT true, 'Actualización exitosa';
END;
$$ LANGUAGE plpgsql;

-- ============================================

