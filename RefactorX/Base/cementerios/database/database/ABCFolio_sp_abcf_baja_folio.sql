-- Stored Procedure: sp_abcf_baja_folio
-- Tipo: CRUD
-- Descripción: Da de baja lógica un folio (vigencia = 'B') y registra histórico.
-- Generado para formulario: ABCFolio
-- Fecha: 2025-08-27 14:01:11

CREATE OR REPLACE PROCEDURE sp_abcf_baja_folio(
    p_folio INTEGER,
    p_usuario INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ta_13_datosrcm SET
        vigencia = 'B',
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE
    WHERE control_rcm = p_folio;
    CALL sp_13_historia(p_folio);
END;
$$;