-- ============================================
-- STORED PROCEDURE CORREGIDO
-- Formulario: RptEmisionLocales
-- SP: sp_rpt_emision_locales_emit
-- Base: mercados.public
-- Fecha: 2025-12-02
-- ============================================

DROP FUNCTION IF EXISTS sp_rpt_emision_locales_emit(integer, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_rpt_emision_locales_emit(
    p_oficina integer,
    p_axo integer,
    p_periodo integer,
    p_mercado integer,
    p_usuario_id integer
) RETURNS TABLE(
    id_local integer,
    status text,
    message text
) AS $$
DECLARE
    rec RECORD;
    per integer;
    axo1 integer;
    existe integer;
    total_inserted integer := 0;
    total_exists integer := 0;
BEGIN
    IF p_periodo = 1 THEN
        per := 12;
        axo1 := p_axo - 1;
    ELSE
        per := p_periodo - 1;
        axo1 := p_axo;
    END IF;

    FOR rec IN
        SELECT l.id_local
        FROM comun.ta_11_locales l
        WHERE l.oficina = p_oficina
          AND l.num_mercado = p_mercado
          AND l.vigencia = 'A'
          AND l.bloqueo < 4
    LOOP
        SELECT COUNT(*) INTO existe
        FROM comun.ta_11_adeudo_local
        WHERE id_local = rec.id_local
          AND axo = p_axo
          AND periodo = p_periodo;

        IF existe = 0 THEN
            -- Calcular renta e insertar adeudo
            INSERT INTO comun.ta_11_adeudo_local (
                id_adeudo_local, id_local, axo, periodo, importe, fecha_alta, id_usuario
            )
            VALUES (
                DEFAULT,
                rec.id_local,
                p_axo,
                p_periodo,
                (
                    SELECT CASE
                        WHEN l.seccion = 'PS' AND c.clave_cuota = 4 THEN l.superficie * c.importe_cuota
                        WHEN l.seccion = 'PS' THEN (c.importe_cuota * l.superficie) * 30
                        ELSE l.superficie * c.importe_cuota
                    END
                    FROM comun.ta_11_locales l
                    JOIN public.ta_11_cuo_locales c
                      ON c.axo = p_axo
                      AND l.categoria = c.categoria
                      AND l.seccion = c.seccion
                      AND l.clave_cuota = c.clave_cuota
                    WHERE l.id_local = rec.id_local
                ),
                NOW(),
                p_usuario_id
            );
            total_inserted := total_inserted + 1;
            id_local := rec.id_local;
            status := 'inserted';
            message := 'Recibo emitido correctamente';
            RETURN NEXT;
        ELSE
            total_exists := total_exists + 1;
            id_local := rec.id_local;
            status := 'exists';
            message := 'Recibo ya existe para este periodo';
            RETURN NEXT;
        END IF;
    END LOOP;

    -- Registro resumen final
    id_local := -1;
    status := 'summary';
    message := 'Insertados: ' || total_inserted || ' | Ya existían: ' || total_exists;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;
