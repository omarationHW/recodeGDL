-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: trasladosfrm
-- Generado: 2025-08-27 15:54:53
-- Total SPs: 4
-- ============================================

-- SP 1/4: buscar_pago
-- Tipo: CRUD
-- Descripción: Busca un pago en la tabla pagos según recaud, folio, caja, fecha e importe.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION buscar_pago(
    recaud TEXT,
    folio TEXT,
    caja TEXT,
    fecha DATE,
    importe NUMERIC
) RETURNS TABLE(
    id BIGINT,
    cuenta TEXT,
    folio TEXT,
    anio INT,
    importe NUMERIC,
    caja TEXT,
    fecha DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, cuenta, folio, anio, importe, caja, fecha
    FROM pagos
    WHERE recaud = recaud
      AND folio = folio
      AND caja = caja
      AND fecha = fecha
      AND importe = importe;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: obtener_requerimientos
-- Tipo: Catalog
-- Descripción: Obtiene los requerimientos asociados a un pago.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION obtener_requerimientos(
    pago_id BIGINT
) RETURNS TABLE(
    id BIGINT,
    concepto TEXT,
    importe NUMERIC,
    estado TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.id, r.concepto, r.importe, r.estado
    FROM requerimientos r
    WHERE r.pago_id = pago_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: aplicar_traslado
-- Tipo: CRUD
-- Descripción: Aplica el traslado de un pago según el tipo de aplicación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION aplicar_traslado(
    pago_id BIGINT,
    tipo_aplicacion TEXT,
    usuario TEXT
) RETURNS TABLE(
    resultado TEXT
) AS $$
DECLARE
    msg TEXT;
BEGIN
    -- Lógica de aplicación según tipo_aplicacion
    IF tipo_aplicacion = 'futuros' THEN
        -- Marcar pago para futuros pagos
        UPDATE pagos SET estado = 'aplicado_futuros', usuario_aplica = usuario, fecha_aplica = NOW()
        WHERE id = pago_id;
        msg := 'Aplicado a futuros pagos';
    ELSIF tipo_aplicacion = 'saldar' THEN
        -- Saldar adeudos
        UPDATE pagos SET estado = 'saldado', usuario_aplica = usuario, fecha_aplica = NOW()
        WHERE id = pago_id;
        msg := 'Adeudos saldados';
    ELSIF tipo_aplicacion = 'devolucion' THEN
        -- Marcar para devolución
        UPDATE pagos SET estado = 'devolucion', usuario_aplica = usuario, fecha_aplica = NOW()
        WHERE id = pago_id;
        msg := 'Marcado para devolución';
    ELSE
        msg := 'Tipo de aplicación no válido';
    END IF;
    RETURN QUERY SELECT msg;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: liquidar_pago
-- Tipo: CRUD
-- Descripción: Liquida el pago seleccionado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION liquidar_pago(
    pago_id BIGINT,
    usuario TEXT
) RETURNS TABLE(
    resultado TEXT
) AS $$
DECLARE
    msg TEXT;
BEGIN
    UPDATE pagos SET estado = 'liquidado', usuario_liquida = usuario, fecha_liquida = NOW()
    WHERE id = pago_id;
    msg := 'Pago liquidado correctamente';
    RETURN QUERY SELECT msg;
END;
$$ LANGUAGE plpgsql;

-- ============================================

