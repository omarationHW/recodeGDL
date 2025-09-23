-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: TRASLADOSFRM (EXACTO del archivo original)
-- Archivo: 115_SP_RECAUDADORA_TRASLADOSFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: TRASLADOSFRM (EXACTO del archivo original)
-- Archivo: 115_SP_RECAUDADORA_TRASLADOSFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: TRASLADOSFRM (EXACTO del archivo original)
-- Archivo: 115_SP_RECAUDADORA_TRASLADOSFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

