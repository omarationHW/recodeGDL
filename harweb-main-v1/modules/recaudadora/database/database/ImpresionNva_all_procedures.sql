-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ImpresionNva
-- Generado: 2025-08-27 12:25:26
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_impresionnva_get_form_data
-- Tipo: CRUD
-- Descripción: Devuelve los datos necesarios para inicializar el formulario ImpresionNva (en este caso, vacío).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_impresionnva_get_form_data()
RETURNS JSON AS $$
BEGIN
    RETURN '{}'::json;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_impresionnva_submit_form
-- Tipo: CRUD
-- Descripción: Procesa el envío del formulario ImpresionNva (no realiza ninguna acción, solo retorna éxito).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_impresionnva_submit_form()
RETURNS JSON AS $$
BEGIN
    RETURN json_build_object('success', true, 'message', 'Formulario enviado correctamente.');
END;
$$ LANGUAGE plpgsql;

-- ============================================

