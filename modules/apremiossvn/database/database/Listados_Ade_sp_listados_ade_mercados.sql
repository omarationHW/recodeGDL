-- Stored Procedure: sp_listados_ade_mercados
-- Tipo: Report
-- Descripción: Obtiene listado de adeudos de mercados según filtros.
-- Generado para formulario: Listados_Ade
-- Fecha: 2025-08-27 15:21:31

CREATE OR REPLACE PROCEDURE sp_listados_ade_mercados(
    p_oficina integer,
    p_num_mercado1 integer,
    p_num_mercado2 integer,
    p_local1 integer,
    p_local2 integer,
    p_seccion text,
    p_axo integer,
    p_mes integer
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Ejemplo simplificado, adaptar a modelo real
    SELECT a.*, b.*, c.descripcion, b.importe AS renta,
      (SELECT COALESCE(SUM(importe_gastos),0) FROM ta_15_apremios WHERE modulo=11 AND control_otr=a.id_local AND clave_practicado='P' AND vigencia='1') AS total_gasto
    FROM ta_11_locales a
    JOIN ta_11_adeudo_local b ON a.id_local = b.id_local
    JOIN ta_11_mercados c ON a.oficina = c.oficina AND a.num_mercado = c.num_mercado_nvo
    WHERE a.oficina = p_oficina
      AND a.num_mercado BETWEEN p_num_mercado1 AND p_num_mercado2
      AND (p_seccion IS NULL OR a.seccion = p_seccion)
      AND a.local BETWEEN p_local1 AND p_local2
      AND ((b.axo < p_axo) OR (b.axo = p_axo AND b.periodo <= p_mes))
    ORDER BY a.id_local, b.axo, b.periodo;
END;
$$;