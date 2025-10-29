-- Stored Procedure: sp_emisionlocales_grabar_emision
-- Tipo: CRUD
-- Descripción: Graba la emisión de recibos en la tabla de adeudos
-- Generado para formulario: EmisionLocales
-- Fecha: 2025-08-26 23:54:25

CREATE OR REPLACE FUNCTION sp_emisionlocales_grabar_emision(
    p_oficina INTEGER,
    p_mercado INTEGER,
    p_axo INTEGER,
    p_periodo INTEGER,
    p_usuario_id INTEGER
) RETURNS TABLE(
    id_local INTEGER,
    status TEXT
) AS $$
DECLARE
    r RECORD;
    v_renta NUMERIC;
BEGIN
    FOR r IN
        SELECT l.id_local, l.superficie, l.seccion, c.importe_cuota, c.clave_cuota
        FROM ta_11_locales l
        JOIN ta_11_cuo_locales c ON c.axo = p_axo AND l.categoria = c.categoria AND l.seccion = c.seccion AND l.clave_cuota = c.clave_cuota
        WHERE l.oficina = p_oficina AND l.num_mercado = p_mercado AND l.vigencia = 'A' AND l.bloqueo < 4
    LOOP
        IF r.seccion = 'PS' AND r.clave_cuota = 4 THEN
            v_renta := r.superficie * r.importe_cuota;
        ELSIF r.seccion = 'PS' THEN
            v_renta := (r.importe_cuota * r.superficie) * 30;
        ELSE
            v_renta := r.superficie * r.importe_cuota;
        END IF;
        -- Solo insertar si no existe adeudo para ese periodo
        IF NOT EXISTS (
            SELECT 1 FROM ta_11_adeudo_local WHERE id_local = r.id_local AND axo = p_axo AND periodo = p_periodo
        ) THEN
            INSERT INTO ta_11_adeudo_local (id_adeudo_local, id_local, axo, periodo, importe, fecha_alta, id_usuario)
            VALUES (DEFAULT, r.id_local, p_axo, p_periodo, v_renta, now(), p_usuario_id);
            RETURN NEXT (r.id_local, 'insertado');
        ELSE
            RETURN NEXT (r.id_local, 'ya_existe');
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;