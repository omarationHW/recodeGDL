-- Stored Procedure: sp_rpt_emision_locales_emit
-- Tipo: CRUD
-- Descripción: Graba la emisión de recibos de locales para una oficina, año, periodo y mercado.
-- Generado para formulario: RptEmisionLocales
-- Fecha: 2025-08-27 00:57:07

CREATE OR REPLACE FUNCTION sp_rpt_emision_locales_emit(
    p_oficina integer,
    p_axo integer,
    p_periodo integer,
    p_mercado integer,
    p_usuario_id integer
) RETURNS TABLE(
    id_local integer,
    status text
) AS $$
DECLARE
    rec RECORD;
    per integer;
    axo1 integer;
    existe integer;
BEGIN
    IF p_periodo = 1 THEN
        per := 12;
        axo1 := p_axo - 1;
    ELSE
        per := p_periodo - 1;
        axo1 := p_axo;
    END IF;
    FOR rec IN SELECT id_local FROM ta_11_locales WHERE oficina = p_oficina AND num_mercado = p_mercado AND vigencia = 'A' AND bloqueo < 4
    LOOP
        SELECT COUNT(*) INTO existe FROM ta_11_adeudo_local WHERE id_local = rec.id_local AND axo = p_axo AND periodo = p_periodo;
        IF existe = 0 THEN
            -- Calcular renta
            INSERT INTO ta_11_adeudo_local (id_adeudo_local, id_local, axo, periodo, importe, fecha_alta, id_usuario)
            VALUES (DEFAULT, rec.id_local, p_axo, p_periodo,
                (
                    SELECT CASE WHEN l.seccion = 'PS' AND c.clave_cuota = 4 THEN l.superficie * c.importe_cuota
                                WHEN l.seccion = 'PS' THEN (c.importe_cuota * l.superficie) * 30
                                ELSE l.superficie * c.importe_cuota END
                    FROM ta_11_locales l
                    JOIN ta_11_cuo_locales c ON c.axo = p_axo AND l.categoria = c.categoria AND l.seccion = c.seccion AND l.clave_cuota = c.clave_cuota
                    WHERE l.id_local = rec.id_local
                ),
                NOW(), p_usuario_id
            );
            RETURN NEXT (rec.id_local, 'inserted');
        ELSE
            RETURN NEXT (rec.id_local, 'exists');
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;