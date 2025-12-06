-- ============================================
-- SP: sp_cons_condonacion_energia (CORREGIDO)
-- Descripción: Consulta las condonaciones de energía de un local
--
-- PROBLEMAS RESUELTOS:
-- 1. Schema usuarios: catastro_gdl → db_ingresos
-- 2. Columna JOIN usuarios: id_usuario → id
-- 3. Schema energía: comunX → db_ingresos (comunX está vacío)
-- 4. Schema adeudos: comunX → db_ingresos (comunX está vacío)
-- 5. Tipos de datos: Ajustados a tipos exactos de las tablas
--
-- Fecha corrección: 2025-01-25
-- ============================================

\c padron_licencias;
SET search_path TO public;

-- Eliminar función existente para cambiar tipos de retorno
DROP FUNCTION IF EXISTS sp_cons_condonacion_energia(integer,integer,integer,character varying,integer,character varying,character varying);

CREATE OR REPLACE FUNCTION sp_cons_condonacion_energia(
    p_oficina integer,
    p_num_mercado integer,
    p_categoria integer,
    p_seccion varchar,
    p_local integer,
    p_letra_local varchar,
    p_bloque varchar
)
RETURNS TABLE (
    id_condonacion integer,
    id_local integer,
    id_energia integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion character(2),
    local integer,
    letra_local varchar,
    bloque varchar,
    nombre_local varchar,
    arrendatario varchar,
    vigencia character(1),
    axo smallint,
    periodo smallint,
    fecha_condonacion timestamp without time zone,
    importe_original numeric,
    importe_condonado numeric,
    motivo character(1),
    observacion character(60),
    usuario character(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id_cancelacion as id_condonacion,
        l.id_local,
        e.id_energia,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        l.nombre as nombre_local,
        l.arrendatario,
        l.vigencia,
        c.axo,
        c.periodo,
        c.fecha_alta as fecha_condonacion,
        ae.importe as importe_original,
        c.importe as importe_condonado,
        c.clave_canc as motivo,
        c.observacion,
        COALESCE(u.usuario, 'SISTEMA'::character(10)) as usuario
    FROM comun.ta_11_locales l
    INNER JOIN db_ingresos.ta_11_energia e ON l.id_local = e.id_local
    INNER JOIN db_ingresos.ta_11_adeudo_energ ae ON e.id_energia = ae.id_energia
    INNER JOIN db_ingresos.ta_11_ade_ene_canc c ON ae.id_energia = c.id_energia
    LEFT JOIN db_ingresos.usuarios u ON c.id_usuario = u.id
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_num_mercado
      AND l.categoria = p_categoria
      AND l.seccion = p_seccion
      AND l.local = p_local
      AND (l.letra_local = p_letra_local OR (p_letra_local IS NULL AND l.letra_local IS NULL))
      AND (l.bloque = p_bloque OR (p_bloque IS NULL AND l.bloque IS NULL))
    ORDER BY c.axo DESC, c.periodo DESC;
END;
$$ LANGUAGE plpgsql;

-- Verificar creación
SELECT 'SP sp_cons_condonacion_energia ' ||
       CASE WHEN COUNT(*) > 0 THEN 'CREADO ✓' ELSE 'ERROR ✗' END as status
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname = 'sp_cons_condonacion_energia';
