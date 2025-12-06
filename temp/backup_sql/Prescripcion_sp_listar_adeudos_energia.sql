-- =============================================
-- SP: sp_listar_adeudos_energia
-- Descripción: Lista los adeudos de energía eléctrica pendientes de un local/energía
-- Componente: Prescripcion.vue
-- Fecha: 2025-12-05
-- =============================================

DROP FUNCTION IF EXISTS public.sp_listar_adeudos_energia(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_listar_adeudos_energia(
    p_id_energia INTEGER
)
RETURNS TABLE(
    id_adeudo_energia INTEGER,
    id_energia INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    cve_consumo VARCHAR,
    cantidad NUMERIC(10,2),
    importe NUMERIC(12,2),
    fecha_alta TIMESTAMP,
    id_usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_adeudo_energia,
        a.id_energia,
        a.axo,
        a.periodo,
        a.cve_consumo,
        a.cantidad,
        a.importe,
        a.fecha_alta,
        a.id_usuario
    FROM
        padron_licencias.public.ta_11_adeudo_energ a
    WHERE
        a.id_energia = p_id_energia
    ORDER BY
        a.axo DESC, a.periodo DESC;
END;
$$ LANGUAGE plpgsql;

-- Comentario del SP
COMMENT ON FUNCTION public.sp_listar_adeudos_energia(INTEGER) IS
'Lista los adeudos de energía eléctrica pendientes de un local.
Parámetro: p_id_energia (ID del local de energía).
Retorna: listado de adeudos ordenados por año y periodo descendente.';
