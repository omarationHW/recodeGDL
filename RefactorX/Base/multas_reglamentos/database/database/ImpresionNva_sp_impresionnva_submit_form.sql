-- Stored Procedure: sp_impresionnva_submit_form
-- Tipo: CRUD
-- Descripción: Procesa el envío del formulario ImpresionNva (no realiza ninguna acción, solo retorna éxito).
-- Generado para formulario: ImpresionNva
-- Fecha: 2025-08-27 12:25:26

CREATE OR REPLACE FUNCTION sp_impresionnva_submit_form()
RETURNS JSON AS $$
BEGIN
    RETURN json_build_object('success', true, 'message', 'Formulario enviado correctamente.');
END;
$$ LANGUAGE plpgsql;