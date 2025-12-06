-- ============================================
-- DESPLIEGUE FINAL: rpt_factura_energia
-- Componente: RptFacturaEnergia.vue
-- Base de datos: mercados
-- Esquema: public
-- Fecha: 2025-12-04
-- ============================================

\c mercados;
SET search_path TO public;

-- ============================================
-- SP: rpt_factura_energia
-- Tipo: Report
-- Descripción: Devuelve el reporte de factura de energía eléctrica
--              para una oficina, año, periodo y mercado dados.
-- Tablas usadas:
--   - padron_licencias.comun.ta_11_locales (locales)
--   - padron_licencias.comun.ta_11_mercados (mercados)
--   - mercados.public.ta_11_adeudo_energ (adeudos de energía)
--   - mercados.public.ta_11_energia (datos de energía)
--   - mercados.public.ta_11_kilowhatts (tarifas kw/hr)
-- ============================================

DROP FUNCTION IF EXISTS rpt_factura_energia(integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION rpt_factura_energia(
    p_oficina integer,
    p_axo integer,
    p_periodo integer,
    p_mercado integer
)
RETURNS TABLE (
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar(2),
    local smallint,
    letra_local varchar(1),
    bloque varchar(1),
    nombre varchar(30),
    local_adicional varchar(50),
    cantidad numeric,
    importe numeric,
    descripcion varchar(50),
    importe_1 numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.oficina,
        a.num_mercado,
        a.categoria,
        a.seccion,
        a.local,
        a.letra_local,
        a.bloque,
        a.nombre,
        d.local_adicional,
        b.cantidad,
        e.importe,
        c.descripcion,
        b.importe as importe_1
    FROM padron_licencias.comun.ta_11_locales a
    JOIN mercados.public.ta_11_adeudo_energ b ON a.id_local = b.id_local
    JOIN padron_licencias.comun.ta_11_mercados c ON a.oficina = c.oficina AND a.num_mercado = c.num_mercado_nvo
    JOIN mercados.public.ta_11_energia d ON d.id_energia = b.id_energia
    JOIN mercados.public.ta_11_kilowhatts e ON b.axo = e.axo AND b.periodo = e.periodo
    WHERE a.oficina = p_oficina
      AND a.num_mercado = p_mercado
      AND b.axo = p_axo
      AND b.periodo = p_periodo
    ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VERIFICACIÓN
-- ============================================

-- Verificar que el SP se creó correctamente
SELECT
    p.proname as sp_name,
    pg_get_function_identity_arguments(p.oid) as parameters,
    'OK' as status
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname = 'rpt_factura_energia';

-- ============================================
