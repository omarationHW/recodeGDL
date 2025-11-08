-- Stored Procedure: sp_baja_licencias
-- Tipo: CRUD
-- Descripción: Aplica la baja masiva de licencias y sus anuncios ligados, actualizando los campos de baja y cancelando adeudos.
-- Generado para formulario: LicenciasVigentesfrm
-- Fecha: 2025-08-26 17:08:11

-- Parámetro: baja_params JSON con axo, folio, motivo, licencias[]
CREATE OR REPLACE FUNCTION sp_baja_licencias(baja_params JSON)
RETURNS TABLE(licencia integer, status text, message text) AS $$
DECLARE
    lic integer;
    axo integer := (baja_params->>'axo')::integer;
    folio integer := (baja_params->>'folio')::integer;
    motivo text := baja_params->>'motivo';
    licencias_arr json := baja_params->'licencias';
    anuncios_cur refcursor;
    anun_id integer;
BEGIN
    FOR lic IN SELECT json_array_elements_text(licencias_arr) LOOP
        -- Baja de anuncios ligados
        OPEN anuncios_cur FOR SELECT id_anuncio FROM anuncios WHERE id_licencia = lic::integer AND vigente = 'V';
        LOOP
            FETCH anuncios_cur INTO anun_id;
            EXIT WHEN NOT FOUND;
            -- Cancela adeudo del anuncio
            UPDATE detsal_lic SET cvepago = 999999 WHERE id_anuncio = anun_id AND cvepago = 0;
            -- Da de baja el anuncio
            UPDATE anuncios SET vigente = 'C', fecha_baja = CURRENT_DATE, axo_baja = axo, folio_baja = folio, espubic = motivo WHERE id_anuncio = anun_id;
        END LOOP;
        CLOSE anuncios_cur;
        -- Cancela adeudo de la licencia
        UPDATE detsal_lic SET cvepago = 999999 WHERE id_licencia = lic::integer AND (id_anuncio IS NULL OR id_anuncio = 0) AND cvepago = 0;
        -- Da de baja la licencia
        UPDATE licencias SET vigente = 'C', fecha_baja = CURRENT_DATE, axo_baja = axo, folio_baja = folio, espubic = motivo WHERE licencia = lic::integer;
        RETURN NEXT (lic::integer, 'OK', 'Baja realizada');
    END LOOP;
END;
$$ LANGUAGE plpgsql;
