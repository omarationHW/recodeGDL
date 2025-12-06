-- ========================================
-- SP: sp_get_locales - VERSIÓN FINAL CORREGIDA
-- Base de datos: padron_licencias
-- TODOS los tipos de datos coinciden con la tabla
-- ========================================

\c padron_licencias;

DROP FUNCTION IF EXISTS sp_get_locales(integer);

CREATE OR REPLACE FUNCTION sp_get_locales(p_id_local integer)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion char(2),
    letra_local varchar(3),
    bloque varchar(3),
    nombre varchar(30),
    descripcion_local varchar(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion,
           a.letra_local, a.bloque, a.nombre, a.descripcion_local
    FROM comun.ta_11_locales a
    WHERE a.id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;

SELECT 'sp_get_locales creado correctamente' as status;

-- Verificar
\df sp_get_locales

-- Probar
SELECT * FROM sp_get_locales(1) LIMIT 1;
