-- Stored Procedure: spd_17_calc_fechav
-- Tipo: CRUD
-- Descripción: Calcula la fecha de vencimiento para ampliación de plazo de convenio.
-- Generado para formulario: ActualizaPlazo
-- Fecha: 2025-08-27 13:36:02

-- PostgreSQL stored procedure para calcular fecha de vencimiento
CREATE OR REPLACE FUNCTION spd_17_calc_fechav(
    parm_colonia integer,
    parm_calle integer,
    parm_folio integer,
    parm_fecha_inicio date,
    parm_parcialidad integer,
    parm_tipo varchar
) RETURNS TABLE(expression integer, expression_1 date) AS $$
DECLARE
    v_id_convenio integer;
    v_fecha_venc date;
BEGIN
    -- Buscar el id_convenio
    SELECT id_convenio INTO v_id_convenio
    FROM ta_17_convenios
    WHERE colonia = parm_colonia AND calle = parm_calle AND folio = parm_folio
    LIMIT 1;
    -- Calcular fecha de vencimiento (ejemplo: sumar meses/quincenas/semanas)
    IF parm_tipo = 'M' THEN
        v_fecha_venc := parm_fecha_inicio + INTERVAL '1 month' * parm_parcialidad;
    ELSIF parm_tipo = 'Q' THEN
        v_fecha_venc := parm_fecha_inicio + INTERVAL '15 days' * parm_parcialidad;
    ELSIF parm_tipo = 'S' THEN
        v_fecha_venc := parm_fecha_inicio + INTERVAL '7 days' * parm_parcialidad;
    ELSE
        v_fecha_venc := parm_fecha_inicio;
    END IF;
    RETURN QUERY SELECT v_id_convenio, v_fecha_venc::date;
END;
$$ LANGUAGE plpgsql;