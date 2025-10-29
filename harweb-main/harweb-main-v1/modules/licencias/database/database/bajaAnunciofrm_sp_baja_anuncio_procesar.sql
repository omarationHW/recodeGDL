-- Stored Procedure: sp_baja_anuncio_procesar
-- Tipo: CRUD
-- Descripción: Realiza la baja del anuncio, cancela adeudos y recalcula saldos.
-- Generado para formulario: bajaAnunciofrm
-- Fecha: 2025-08-27 15:56:52

CREATE OR REPLACE FUNCTION sp_baja_anuncio_procesar(
  p_anuncio INTEGER,
  p_motivo TEXT,
  p_axo_baja INTEGER,
  p_folio_baja INTEGER,
  p_usuario TEXT,
  p_baja_error BOOLEAN,
  p_baja_tiempo BOOLEAN,
  p_fecha TIMESTAMP
) RETURNS TABLE (result TEXT, status TEXT) AS $$
DECLARE
  v_vigente TEXT;
  v_id_licencia INTEGER;
BEGIN
  SELECT vigente, id_licencia INTO v_vigente, v_id_licencia FROM anuncios WHERE anuncio = p_anuncio;
  IF v_vigente IS NULL OR v_vigente <> 'V' THEN
    RETURN QUERY SELECT 'El anuncio ya se encuentra cancelado.', 'error';
    RETURN;
  END IF;
  -- Cancelar el anuncio
  UPDATE anuncios SET
    vigente = 'C',
    fecha_baja = p_fecha,
    axo_baja = p_axo_baja,
    folio_baja = p_folio_baja,
    espubic = p_motivo
  WHERE anuncio = p_anuncio;
  -- Cancelar adeudos
  UPDATE detsal_lic SET cvepago = 999999 WHERE id_anuncio = p_anuncio AND cvepago = 0;
  -- Recalcular saldo de la licencia
  PERFORM calc_sdosl(v_id_licencia);
  RETURN QUERY SELECT 'Baja realizada correctamente', 'ok';
END;
$$ LANGUAGE plpgsql;