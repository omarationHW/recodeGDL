-- Stored Procedure: sp_baja_anuncio
-- Tipo: CRUD
-- Descripción: Realiza la baja lógica de un anuncio, cancela adeudos y recalcula saldos de la licencia relacionada.
-- Generado para formulario: bajaAnunciofrm
-- Fecha: 2025-08-26 14:30:28

-- sp_baja_anuncio(anuncio_id integer, usuario text, motivo text, axo_baja integer, folio_baja integer)
CREATE OR REPLACE FUNCTION sp_baja_anuncio(
    p_anuncio_id integer,
    p_usuario text,
    p_motivo text,
    p_axo_baja integer,
    p_folio_baja integer
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_anuncio RECORD;
    v_id_licencia integer;
BEGIN
    SELECT * INTO v_anuncio FROM anuncios WHERE anuncio = p_anuncio_id FOR UPDATE;
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'No se encontró el anuncio';
        RETURN;
    END IF;
    IF v_anuncio.vigente <> 'V' THEN
        RETURN QUERY SELECT false, 'El anuncio ya se encuentra cancelado.';
        RETURN;
    END IF;
    -- Actualizar anuncio
    UPDATE anuncios SET
        vigente = 'C',
        fecha_baja = CURRENT_DATE,
        axo_baja = p_axo_baja,
        folio_baja = p_folio_baja,
        espubic = p_motivo
    WHERE anuncio = p_anuncio_id;
    -- Cancelar adeudos
    UPDATE detsal_lic SET cvepago = 999999 WHERE id_anuncio = v_anuncio.id_anuncio AND cvepago = 0;
    -- Recalcular saldo de la licencia
    v_id_licencia := v_anuncio.id_licencia;
    PERFORM sp_recalcula_saldo_licencia(v_id_licencia);
    RETURN QUERY SELECT true, 'Baja realizada correctamente';
END;
$$ LANGUAGE plpgsql;