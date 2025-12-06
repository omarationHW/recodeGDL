-- ============================================
-- FIX: sp_get_locales para DatosRequerimientos
-- Problema: Tabla ta_11_locales sin schema
-- Solución: Agregar schema public
-- ============================================

\c ingresos;

DROP FUNCTION IF EXISTS sp_get_locales(integer);

CREATE OR REPLACE FUNCTION sp_get_locales(p_id_local integer)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    descripcion_local varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion,
           a.letra_local, a.bloque, a.nombre, a.descripcion_local
    FROM public.ta_11_locales a
    WHERE a.id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;

-- Verificación
SELECT 'SP sp_get_locales creado correctamente' AS status;
\df sp_get_locales
