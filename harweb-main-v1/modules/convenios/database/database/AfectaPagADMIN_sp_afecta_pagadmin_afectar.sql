-- Stored Procedure: sp_afecta_pagadmin_afectar
-- Tipo: CRUD
-- Descripción: Afecta todos los pagos de convenios diversos para una fecha dada
-- Generado para formulario: AfectaPagADMIN
-- Fecha: 2025-08-27 13:39:58

CREATE OR REPLACE FUNCTION sp_afecta_pagadmin_afectar(p_fecha DATE, p_usuario VARCHAR)
RETURNS JSON AS $$
DECLARE
    r RECORD;
    result JSON;
BEGIN
    FOR r IN SELECT * FROM sp_afecta_pagadmin_listar(p_fecha) LOOP
        -- Lógica de afectación por tipo
        IF r.tipo = 1 THEN
            PERFORM sp_afecta_pagadmin_predial(r.id_recibo, p_usuario);
        ELSIF r.tipo = 3 THEN
            IF r.parcialidad = r.total_parc THEN
                PERFORM sp_afecta_pagadmin_licencias(r.id_recibo, p_usuario);
            END IF;
        END IF;
    END LOOP;
    result := json_build_object('success', true, 'message', 'Pagos de Convenios Diversos cargados correctamente');
    RETURN result;
EXCEPTION WHEN OTHERS THEN
    result := json_build_object('success', false, 'message', SQLERRM);
    RETURN result;
END;
$$ LANGUAGE plpgsql;