-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: AplicaMultas (AplicaMultasNormal.pas)
-- Base de datos: aseo_contratado
-- Actualizado: 2025-12-07
-- Total SPs: 2
-- ============================================
-- Descripcion: Configuracion de aplicacion normal de requerimientos
-- La tabla ta_aplicareq contiene un solo registro con:
--   descripcion: texto descriptivo
--   aplica: 'S' o 'N'
--   porc: porcentaje de aplicacion (cuando aplica='N')
-- ============================================

-- SP 1/2: sp_aseo_get_config_aplicareq
-- Tipo: Select
-- Descripcion: Obtiene la configuracion actual de aplicacion de requerimientos
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_get_config_aplicareq();

CREATE OR REPLACE FUNCTION public.sp_aseo_get_config_aplicareq()
RETURNS TABLE (
    descripcion VARCHAR,
    aplica VARCHAR,
    porc INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(a.descripcion, 'Aplicacion Normal de Requerimientos para Cobro')::VARCHAR,
        COALESCE(a.aplica, 'S')::VARCHAR,
        COALESCE(a.porc, 0)::INTEGER
    FROM ta_aplicareq a
    LIMIT 1;

    -- Si no hay registro, devolver valores por defecto
    IF NOT FOUND THEN
        RETURN QUERY SELECT
            'Aplicacion Normal de Requerimientos para Cobro'::VARCHAR,
            'S'::VARCHAR,
            0::INTEGER;
    END IF;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_get_config_aplicareq() TO PUBLIC;

-- SP 2/2: sp_aseo_update_config_aplicareq
-- Tipo: Update
-- Descripcion: Actualiza la configuracion de aplicacion de requerimientos
-- Parametros:
--   p_aplica: 'S' para aplicacion normal, 'N' para no aplicar con porcentaje
--   p_porc: porcentaje (requerido cuando p_aplica='N')
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_update_config_aplicareq(VARCHAR, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_update_config_aplicareq(
    p_aplica VARCHAR,
    p_porc INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    mensaje VARCHAR
) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Validar que si aplica='N', debe tener porcentaje > 0
    IF p_aplica = 'N' AND (p_porc IS NULL OR p_porc <= 0) THEN
        RETURN QUERY SELECT
            FALSE::BOOLEAN,
            'Falta el porcentaje de Aplicacion de Multa'::VARCHAR;
        RETURN;
    END IF;

    -- Verificar si existe registro
    SELECT COUNT(*) INTO v_count FROM ta_aplicareq;

    IF v_count = 0 THEN
        -- Insertar registro si no existe
        INSERT INTO ta_aplicareq (descripcion, aplica, porc)
        VALUES ('Aplicacion Normal de Requerimientos para Cobro', p_aplica, p_porc);
    ELSE
        -- Actualizar registro existente
        UPDATE ta_aplicareq SET
            aplica = p_aplica,
            porc = p_porc;
    END IF;

    -- Mensaje segun tipo de aplicacion
    IF p_aplica = 'S' THEN
        RETURN QUERY SELECT
            TRUE::BOOLEAN,
            'La Aplicacion Normal Realizada'::VARCHAR;
    ELSE
        RETURN QUERY SELECT
            TRUE::BOOLEAN,
            'La NO Aplicacion Normal CON PORCENTAJE Realizada'::VARCHAR;
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT
        FALSE::BOOLEAN,
        ('Error al actualizar configuracion: ' || SQLERRM)::VARCHAR;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_update_config_aplicareq(VARCHAR, INTEGER) TO PUBLIC;

-- ============================================
-- DDL: Crear tabla ta_aplicareq si no existe
-- ============================================
-- CREATE TABLE IF NOT EXISTS ta_aplicareq (
--     descripcion VARCHAR(50),
--     aplica CHAR(1) DEFAULT 'S',
--     porc INTEGER DEFAULT 0
-- );

-- INSERT INTO ta_aplicareq (descripcion, aplica, porc)
-- SELECT 'Aplicacion Normal de Requerimientos para Cobro', 'S', 0
-- WHERE NOT EXISTS (SELECT 1 FROM ta_aplicareq);

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
