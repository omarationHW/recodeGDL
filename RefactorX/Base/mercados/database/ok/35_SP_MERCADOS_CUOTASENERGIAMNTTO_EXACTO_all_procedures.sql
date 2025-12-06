-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: mercados
-- ESQUEMA: public
-- DESPLEGADO: 2025-12-03 (CORREGIDO)
-- ============================================
\c mercados;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CuotasEnergiaMntto
-- Generado: 2025-08-26 23:33:06
-- Corregido: 2025-12-03
-- Total SPs: 4
--
-- CORRECCIONES APLICADAS:
-- 1. Tipos de datos: integer -> smallint para axo y periodo (match con tabla)
-- 2. Eliminado DECLARE y uso de RETURN QUERY directamente
-- 3. Calificación de columnas en RETURNING para evitar ambigüedad
-- 4. JOIN con public.usuarios para obtener nombre de usuario en listado
-- ============================================

-- SP 1/4: sp_insert_cuota_energia
-- Tipo: CRUD
-- Descripción: Inserta una nueva cuota de energía eléctrica en ta_11_kilowhatts.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_insert_cuota_energia(p_axo smallint, p_periodo smallint, p_importe numeric, p_id_usuario integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo smallint,
    periodo smallint,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    INSERT INTO public.ta_11_kilowhatts (axo, periodo, importe, fecha_alta, id_usuario)
    VALUES (p_axo, p_periodo, p_importe, CURRENT_TIMESTAMP, p_id_usuario)
    RETURNING ta_11_kilowhatts.id_kilowhatts, ta_11_kilowhatts.axo, ta_11_kilowhatts.periodo,
              ta_11_kilowhatts.importe, ta_11_kilowhatts.fecha_alta, ta_11_kilowhatts.id_usuario;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_update_cuota_energia
-- Tipo: CRUD
-- Descripción: Actualiza una cuota de energía eléctrica existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_cuota_energia(p_id_kilowhatts integer, p_axo smallint, p_periodo smallint, p_importe numeric, p_id_usuario integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo smallint,
    periodo smallint,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    UPDATE public.ta_11_kilowhatts
    SET importe = p_importe,
        fecha_alta = CURRENT_TIMESTAMP,
        id_usuario = p_id_usuario
    WHERE ta_11_kilowhatts.id_kilowhatts = p_id_kilowhatts
      AND ta_11_kilowhatts.axo = p_axo
      AND ta_11_kilowhatts.periodo = p_periodo
    RETURNING ta_11_kilowhatts.id_kilowhatts, ta_11_kilowhatts.axo, ta_11_kilowhatts.periodo,
              ta_11_kilowhatts.importe, ta_11_kilowhatts.fecha_alta, ta_11_kilowhatts.id_usuario;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_get_cuota_energia
-- Tipo: Catalog
-- Descripción: Obtiene una cuota de energía eléctrica por ID.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cuota_energia(p_id_kilowhatts integer)
RETURNS TABLE (
    id_kilowhatts integer,
    axo smallint,
    periodo smallint,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT k.id_kilowhatts, k.axo, k.periodo, k.importe, k.fecha_alta, k.id_usuario
    FROM public.ta_11_kilowhatts k
    WHERE k.id_kilowhatts = p_id_kilowhatts;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_list_cuotas_energia
-- Tipo: Catalog
-- Descripción: Lista cuotas de energía eléctrica, opcionalmente filtrando por año y/o periodo.
-- Incluye JOIN con tabla usuarios para mostrar nombre de usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_list_cuotas_energia(p_axo smallint DEFAULT NULL, p_periodo smallint DEFAULT NULL)
RETURNS TABLE (
    id_kilowhatts integer,
    axo smallint,
    periodo smallint,
    importe numeric,
    fecha_alta timestamp,
    id_usuario integer,
    usuario varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        k.id_kilowhatts,
        k.axo,
        k.periodo,
        k.importe,
        k.fecha_alta,
        k.id_usuario,
        COALESCE(u.usuario, 'N/A')::varchar AS usuario
    FROM public.ta_11_kilowhatts k
    LEFT JOIN public.usuarios u ON k.id_usuario = u.id
    WHERE (p_axo IS NULL OR k.axo = p_axo)
      AND (p_periodo IS NULL OR k.periodo = p_periodo)
    ORDER BY k.axo DESC, k.periodo DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
