-- Stored Procedure: spd_chg_conci
-- Tipo: CRUD
-- Descripción: Realiza el cambio de placa o folio en la conciliación Banorte. Opción 1: cambiar placa, Opción 2/3: cambiar folio.
-- Generado para formulario: srfrm_conci_banorte
-- Fecha: 2025-08-27 15:02:35

CREATE OR REPLACE FUNCTION spd_chg_conci(
    p_control integer,
    p_idbanco integer,
    p_axo smallint,
    p_folio integer,
    p_placa varchar(7),
    p_id_usuario integer,
    p_opcion smallint
) RETURNS TABLE (clave smallint) AS $$
DECLARE
    v_clave smallint := 0;
BEGIN
    -- Opción 1: Cambiar placa
    IF p_opcion = 1 THEN
        UPDATE ta14_fol_banorte
        SET placa_cambio = upper(trim(p_placa)),
            fec_placa_cambio = now(),
            usu_carga = p_id_usuario
        WHERE rowid = p_idbanco;
        v_clave := 0;
    -- Opción 2: Cambiar folio (existe folio)
    ELSIF p_opcion = 2 THEN
        UPDATE ta14_fol_banorte
        SET axo = p_axo, folio = p_folio, usu_carga = p_id_usuario
        WHERE rowid = p_idbanco;
        v_clave := 0;
    -- Opción 3: Cambiar folio (no existe folio)
    ELSIF p_opcion = 3 THEN
        UPDATE ta14_fol_banorte
        SET axo = p_axo, folio = p_folio, usu_carga = p_id_usuario
        WHERE rowid = p_idbanco;
        v_clave := 0;
    ELSE
        v_clave := 1;
    END IF;
    RETURN QUERY SELECT v_clave;
END;
$$ LANGUAGE plpgsql;