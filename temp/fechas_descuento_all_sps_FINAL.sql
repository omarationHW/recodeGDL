-- ============================================================================
-- STORED PROCEDURES: Mantenimiento de Fechas de Descuento
-- Base de Datos: mercados
-- Esquema: public
-- Tabla: publico.ta_11_fecha_desc
-- Fecha: 2025-12-03
-- Total SPs: 2 (+ 2 alias para compatibilidad)
-- ============================================================================

\c mercados;
SET search_path TO public;

-- ============================================================================
-- SP 1/2: fechas_descuento_get_all()
-- Alias: sp_fechadescuento_list()
-- Descripción: Lista todas las fechas de descuento (12 meses)
-- Retorna: mes, fecha_descuento, fecha_recargos, fecha_alta, id_usuario, usuario
-- Uso: SELECT * FROM fechas_descuento_get_all();
-- ============================================================================

DROP FUNCTION IF EXISTS fechas_descuento_get_all();
DROP FUNCTION IF EXISTS sp_fechadescuento_list();

CREATE OR REPLACE FUNCTION fechas_descuento_get_all()
RETURNS TABLE (
    mes SMALLINT,
    fecha_descuento DATE,
    fecha_recargos DATE,
    fecha_alta TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.mes,
        a.fecha_descuento,
        a.fecha_recargos,
        a.fecha_alta,
        a.id_usuario,
        COALESCE(b.usuario, 'SISTEMA')::VARCHAR(50) as usuario
    FROM publico.ta_11_fecha_desc a
    LEFT JOIN public.usuarios b ON a.id_usuario = b.id
    ORDER BY a.mes ASC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fechas_descuento_get_all() IS 'Lista todas las fechas de descuento por mes (1-12)';

-- Crear alias para compatibilidad con código anterior
CREATE OR REPLACE FUNCTION sp_fechadescuento_list()
RETURNS TABLE (
    mes SMALLINT,
    fecha_descuento DATE,
    fecha_recargos DATE,
    fecha_alta TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM fechas_descuento_get_all();
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_fechadescuento_list() IS 'Alias de fechas_descuento_get_all() para compatibilidad';


-- ============================================================================
-- SP 2/2: fechas_descuento_update()
-- Alias: sp_fechadescuento_update()
-- Descripción: Actualiza o inserta fechas de descuento para un mes específico
-- Parámetros:
--   p_mes: Número del mes (1-12)
--   p_fecha_descuento: Nueva fecha de descuento
--   p_fecha_recargos: Nueva fecha de recargos
--   p_id_usuario: ID del usuario que realiza el cambio
-- Retorna: success (boolean), message (text)
-- Uso: SELECT * FROM fechas_descuento_update(1, '2025-12-05', '2025-12-10', 1);
-- ============================================================================

DROP FUNCTION IF EXISTS fechas_descuento_update(SMALLINT, DATE, DATE, INTEGER);
DROP FUNCTION IF EXISTS sp_fechadescuento_update(SMALLINT, DATE, DATE, INTEGER);

CREATE OR REPLACE FUNCTION fechas_descuento_update(
    p_mes SMALLINT,
    p_fecha_descuento DATE,
    p_fecha_recargos DATE,
    p_id_usuario INTEGER
)
RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Validar que el mes esté en el rango correcto
    IF p_mes < 1 OR p_mes > 12 THEN
        RETURN QUERY SELECT false::BOOLEAN, 'El mes debe estar entre 1 y 12'::TEXT;
        RETURN;
    END IF;

    -- Verificar si existe el mes
    SELECT COUNT(*) INTO v_count
    FROM publico.ta_11_fecha_desc
    WHERE mes = p_mes;

    IF v_count = 0 THEN
        -- El mes no existe, insertarlo
        INSERT INTO publico.ta_11_fecha_desc (
            mes,
            fecha_descuento,
            fecha_recargos,
            fecha_alta,
            id_usuario
        ) VALUES (
            p_mes,
            p_fecha_descuento,
            p_fecha_recargos,
            NOW(),
            p_id_usuario
        );

        RETURN QUERY SELECT true::BOOLEAN, 'Fecha de descuento creada exitosamente'::TEXT;
    ELSE
        -- El mes existe, actualizarlo
        UPDATE publico.ta_11_fecha_desc
        SET
            fecha_descuento = p_fecha_descuento,
            fecha_recargos = p_fecha_recargos,
            fecha_alta = NOW(),
            id_usuario = p_id_usuario
        WHERE mes = p_mes;

        RETURN QUERY SELECT true::BOOLEAN, 'Fecha de descuento actualizada exitosamente'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fechas_descuento_update(SMALLINT, DATE, DATE, INTEGER) IS 'Actualiza o inserta fechas de descuento y recargos para un mes específico';

-- Crear alias para compatibilidad con código anterior
CREATE OR REPLACE FUNCTION sp_fechadescuento_update(
    p_mes SMALLINT,
    p_fecha_descuento DATE,
    p_fecha_recargos DATE,
    p_id_usuario INTEGER
)
RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
BEGIN
    RETURN QUERY SELECT * FROM fechas_descuento_update(p_mes, p_fecha_descuento, p_fecha_recargos, p_id_usuario);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_fechadescuento_update(SMALLINT, DATE, DATE, INTEGER) IS 'Alias de fechas_descuento_update() para compatibilidad';


-- ============================================================================
-- EJEMPLOS DE USO
-- ============================================================================

/*
-- Listar todas las fechas de descuento
SELECT * FROM fechas_descuento_get_all();
SELECT * FROM sp_fechadescuento_list();

-- Actualizar fecha del mes 1 (Enero)
SELECT * FROM fechas_descuento_update(1, '2025-01-05', '2025-01-10', 1);

-- Actualizar fecha del mes 12 (Diciembre)
SELECT * FROM fechas_descuento_update(12, '2025-12-05', '2025-12-10', 1);

-- Usando alias
SELECT * FROM sp_fechadescuento_update(6, '2025-06-05', '2025-06-10', 1);

-- Verificar resultado
SELECT * FROM fechas_descuento_get_all() WHERE mes = 1;
*/

-- ============================================================================
-- FIN DE ARCHIVO
-- ============================================================================
