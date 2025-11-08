-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConsCapturaEnergia
-- Generado: 2025-08-26 23:12:09
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_get_pagos_energia
-- Tipo: Report
-- Descripción: Obtiene todos los pagos de energía eléctrica para un id_energia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_pagos_energia(p_id_energia INTEGER)
RETURNS TABLE (
    id_pago_energia INTEGER,
    id_energia INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago VARCHAR(10),
    operacion_pago INTEGER,
    importe_pago NUMERIC(12,2),
    cve_consumo VARCHAR(2),
    cantidad NUMERIC(12,2),
    folio VARCHAR(20),
    fecha_modificacion TIMESTAMP,
    usuario VARCHAR(50),
    datoslocal TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id_pago_energia,
        p.id_energia,
        p.axo,
        p.periodo,
        p.fecha_pago,
        p.oficina_pago,
        p.caja_pago,
        p.operacion_pago,
        p.importe_pago,
        p.cve_consumo,
        p.cantidad,
        p.folio,
        p.fecha_modificacion,
        u.usuario,
        CONCAT(l.oficina, ' ', l.num_mercado, ' ', l.categoria, ' ', l.seccion, ' ', l.local, ' ', l.letra_local, ' ', l.bloque) AS datoslocal
    FROM ta_11_pago_energia p
    JOIN ta_12_passwords u ON p.id_usuario = u.id_usuario
    JOIN ta_11_energia e ON p.id_energia = e.id_energia
    JOIN ta_11_locales l ON e.id_local = l.id_local
    WHERE p.id_energia = p_id_energia
    ORDER BY p.axo, p.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_delete_pago_energia
-- Tipo: CRUD
-- Descripción: Elimina un pago de energía eléctrica y, si corresponde, restaura el adeudo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_pago_energia(
    p_id_energia INTEGER,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_usuario_id INTEGER
) RETURNS TEXT AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Eliminar el pago
    DELETE FROM ta_11_pago_energia
    WHERE id_energia = p_id_energia AND axo = p_axo AND periodo = p_periodo;
    RETURN 'Pago eliminado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_restore_adeudo_energia
-- Tipo: CRUD
-- Descripción: Restaura el adeudo de energía eléctrica si no existe para el periodo dado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_restore_adeudo_energia(
    p_id_energia INTEGER,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_cve_consumo VARCHAR(2),
    p_cantidad NUMERIC(12,2),
    p_importe NUMERIC(12,2),
    p_usuario_id INTEGER
) RETURNS TEXT AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ta_11_adeudo_energ
    WHERE id_energia = p_id_energia AND axo = p_axo AND periodo = p_periodo;
    IF v_count = 0 THEN
        INSERT INTO ta_11_adeudo_energ (
            id_adeudo_energia, id_energia, axo, periodo, cve_consumo, cantidad, importe, fecha_alta, id_usuario
        ) VALUES (
            DEFAULT, p_id_energia, p_axo, p_periodo, p_cve_consumo, p_cantidad, p_importe, NOW(), p_usuario_id
        );
        RETURN 'Adeudo restaurado correctamente';
    ELSE
        RETURN 'Ya existe el adeudo para este periodo';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

