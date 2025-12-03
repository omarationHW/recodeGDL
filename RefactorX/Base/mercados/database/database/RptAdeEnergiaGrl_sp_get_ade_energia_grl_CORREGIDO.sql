-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: mercados
-- ESQUEMA: public
-- ============================================
-- \c mercados;
-- SET search_path TO public;

-- ============================================
-- STORED PROCEDURE CORREGIDO
-- Formulario: RptAdeEnergiaGrl
-- Fecha Corrección: 2025-12-02
-- Corrección: Esquemas cross-database según postgreok.csv
-- ============================================

-- SP: sp_get_ade_energia_grl
-- Tipo: Report
-- Descripción: Obtiene el listado global de adeudos de energía eléctrica por mercado, oficina, año y mes
-- Parámetros:
--   p_oficina: ID de la recaudadora (oficina)
--   p_mercado: Número de mercado
--   p_axo: Año de consulta
--   p_mes: Periodo (mes) de consulta
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_get_ade_energia_grl(integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_get_ade_energia_grl(
    p_oficina integer,
    p_mercado integer,
    p_axo integer,
    p_mes integer
)
RETURNS TABLE (
    id_local integer,
    id_energia integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion varchar,
    local integer,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    local_adicional varchar,
    descripcion varchar,
    datoslocal varchar,
    axo integer,
    adeudo numeric,
    mesesadeudos varchar,
    cuota numeric
) AS $$
DECLARE
    r RECORD;
    m RECORD;
    cad TEXT;
    cuota_val NUMERIC;
    datos_local_str TEXT;
BEGIN
    FOR r IN
        SELECT
            a.id_local,
            b.id_energia,
            a.oficina,
            a.num_mercado,
            a.categoria,
            a.seccion,
            a.local,
            a.letra_local,
            a.bloque,
            a.nombre,
            b.local_adicional,
            d.descripcion,
            c.axo,
            SUM(c.importe) AS adeudo
        FROM padron_licencias.comun.ta_11_locales a
        INNER JOIN public.ta_11_energia b ON a.id_local = b.id_local
        INNER JOIN public.ta_11_adeudo_energ c ON b.id_energia = c.id_energia
        INNER JOIN padron_licencias.comun.ta_11_mercados d ON a.oficina = d.oficina AND a.num_mercado = d.num_mercado_nvo
        WHERE a.oficina = p_oficina
          AND a.num_mercado = p_mercado
          AND ((c.axo = p_axo AND c.periodo <= p_mes) OR (c.axo < p_axo))
        GROUP BY
            a.id_local, b.id_energia, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local,
            a.letra_local, a.bloque, a.nombre, b.local_adicional, d.descripcion, c.axo
        ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, c.axo
    LOOP
        -- Construir "Datos Local" como en el original Pascal
        datos_local_str :=
            COALESCE(r.oficina::text, '') || '-' ||
            COALESCE(r.num_mercado::text, '') || '-' ||
            COALESCE(r.categoria::text, '') || '-' ||
            COALESCE(r.seccion, '') || '-' ||
            COALESCE(r.local::text, '') || '-' ||
            COALESCE(r.letra_local, '') || '-' ||
            COALESCE(r.bloque, '');

        -- Obtener meses de adeudo y cuota (último importe del año)
        cad := '';
        cuota_val := 0;

        FOR m IN
            SELECT periodo, importe
            FROM public.ta_11_adeudo_energ
            WHERE id_energia = r.id_energia
              AND axo = r.axo
              AND periodo <= p_mes
            ORDER BY periodo
        LOOP
            cad := cad || m.periodo || '-';
            cuota_val := m.importe;
        END LOOP;

        mesesadeudos := CASE WHEN length(cad) > 0 THEN left(cad, length(cad)-1) ELSE '' END;
        cuota := cuota_val;

        -- Retornar fila
        id_local := r.id_local;
        id_energia := r.id_energia;
        oficina := r.oficina;
        num_mercado := r.num_mercado;
        categoria := r.categoria;
        seccion := r.seccion;
        local := r.local;
        letra_local := r.letra_local;
        bloque := r.bloque;
        nombre := r.nombre;
        local_adicional := r.local_adicional;
        descripcion := r.descripcion;
        datoslocal := datos_local_str;
        axo := r.axo;
        adeudo := r.adeudo;

        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DEL SCRIPT
-- ============================================
