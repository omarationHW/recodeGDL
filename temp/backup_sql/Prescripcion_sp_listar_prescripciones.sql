-- =============================================
-- SP: sp_listar_prescripciones
-- Descripción: Lista los adeudos de energía que han sido prescritos/condonados
-- Componente: Prescripcion.vue
-- Fecha: 2025-12-05
-- =============================================

DROP FUNCTION IF EXISTS public.sp_listar_prescripciones(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_listar_prescripciones(
    p_id_energia INTEGER
)
RETURNS TABLE(
    id_cancelacion INTEGER,
    id_energia INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    cve_consumo VARCHAR,
    cantidad NUMERIC(10,2),
    importe NUMERIC(12,2),
    clave_canc VARCHAR,
    observacion VARCHAR,
    fecha_alta TIMESTAMP,
    id_usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id_cancelacion,
        c.id_energia,
        c.axo,
        c.periodo,
        c.cve_consumo,
        c.cantidad,
        c.importe,
        c.clave_canc,
        c.observacion,
        c.fecha_alta,
        c.id_usuario
    FROM
        padron_licencias.public.ta_11_ade_ene_canc c
    WHERE
        c.id_energia = p_id_energia
    ORDER BY
        c.axo DESC, c.periodo DESC;
END;
$$ LANGUAGE plpgsql;

-- Comentario del SP
COMMENT ON FUNCTION public.sp_listar_prescripciones(INTEGER) IS
'Lista los adeudos de energía que han sido prescritos o condonados.
Parámetro: p_id_energia (ID del local de energía).
Retorna: listado de prescripciones ordenadas por año y periodo descendente.';
