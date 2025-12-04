-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: mercados
-- ESQUEMA: public
-- ============================================
-- \c mercados;
-- SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CORREGIDOS
-- Formulario: RptAdeudosAbastos1998
-- Fecha Corrección: 2025-12-02
-- Corrección: Esquemas cross-database según postgreok.csv
-- ============================================

-- SP 1/1: sp_get_adeudos_abastos_1998 (SPs auxiliares eliminados, lógica unificada)
-- Tipo: Report
-- Descripción: Obtiene el listado de adeudos de mercados del año 1998
-- Parámetros:
--   p_axo: Año (1998)
--   p_oficina: ID de la recaudadora
--   p_periodo: Periodo (mes) hasta el cual calcular adeudos
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_get_adeudos_abastos_1998(integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_get_adeudos_abastos_1998(
    p_axo integer,
    p_oficina integer,
    p_periodo integer
)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    local smallint,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    superficie numeric,
    clave_cuota smallint,
    adeudo numeric,
    recaudadora varchar,
    descripcion varchar,
    meses varchar,
    datoslocal varchar,
    totmeses integer,
    renta_ea numeric,
    renta_sd numeric,
    id_rec smallint
) AS $$
DECLARE
    r RECORD;
    meses_str TEXT;
    totmeses_val INT;
    renta_ea_val NUMERIC;
    renta_sd_val NUMERIC;
    mesrec RECORD;
BEGIN
    FOR r IN
        SELECT
            c.id_local,
            c.oficina,
            c.num_mercado,
            c.categoria,
            c.seccion,
            c.local,
            c.letra_local,
            c.bloque,
            c.nombre,
            c.superficie,
            c.clave_cuota,
            SUM(a.importe) AS adeudo,
            UPPER(d.recaudadora) AS recaudadora,
            e.descripcion,
            d.id_rec
        FROM comun.ta_11_adeudo_local a
        INNER JOIN comun.ta_11_locales c ON a.id_local = c.id_local
        INNER JOIN comun.ta_12_recaudadoras d ON c.oficina = d.id_rec
        INNER JOIN comun.ta_11_mercados e ON e.oficina = c.oficina AND e.num_mercado_nvo = c.num_mercado
        WHERE a.axo = p_axo
          AND c.oficina = p_oficina
          AND a.periodo <= p_periodo
          AND c.vigencia = 'A'
        GROUP BY
            c.id_local, c.oficina, c.num_mercado, c.categoria, c.seccion, c.local,
            c.letra_local, c.bloque, c.nombre, c.superficie, c.clave_cuota,
            d.recaudadora, e.descripcion, d.id_rec
        ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion, c.local, c.letra_local, c.bloque
    LOOP
        -- Calcular meses y totmeses
        meses_str := '';
        totmeses_val := 0;
        renta_ea_val := 0;
        renta_sd_val := 0;

        FOR mesrec IN
            SELECT periodo, importe
            FROM comun.ta_11_adeudo_local
            WHERE id_local = r.id_local
              AND axo = p_axo
              AND periodo <= p_periodo
            ORDER BY periodo
        LOOP
            meses_str := meses_str || mesrec.periodo || ',';
            totmeses_val := totmeses_val + 1;

            -- Renta E/A (Enero-Agosto, periodos 1-8)
            -- Renta S/D (Septiembre-Diciembre, periodos 9-12)
            IF mesrec.periodo <= 8 THEN
                renta_ea_val := renta_ea_val + mesrec.importe;
            ELSE
                renta_sd_val := renta_sd_val + mesrec.importe;
            END IF;
        END LOOP;

        -- Eliminar última coma
        IF length(meses_str) > 0 THEN
            meses_str := left(meses_str, length(meses_str)-1);
        END IF;

        -- Construir "Datos Local" (formato: oficina mercado categoria seccion local letra bloque)
        datoslocal := CONCAT(
            r.oficina, ' ',
            r.num_mercado, ' ',
            r.categoria, ' ',
            r.seccion, ' ',
            r.local, ' ',
            COALESCE(r.letra_local, ''), ' ',
            COALESCE(r.bloque, '')
        );

        -- Retornar fila
        id_local := r.id_local;
        oficina := r.oficina;
        num_mercado := r.num_mercado;
        categoria := r.categoria;
        seccion := r.seccion;
        local := r.local;
        letra_local := r.letra_local;
        bloque := r.bloque;
        nombre := r.nombre;
        superficie := r.superficie;
        clave_cuota := r.clave_cuota;
        adeudo := r.adeudo;
        recaudadora := r.recaudadora;
        descripcion := r.descripcion;
        meses := meses_str;
        totmeses := totmeses_val;
        renta_ea := renta_ea_val;
        renta_sd := renta_sd_val;
        id_rec := r.id_rec;

        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DEL SCRIPT
-- ============================================
