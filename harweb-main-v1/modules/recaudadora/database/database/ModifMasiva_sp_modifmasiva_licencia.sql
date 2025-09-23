-- Stored Procedure: sp_modifmasiva_licencia
-- Tipo: CRUD
-- Descripción: Marca como practicados/citados los requerimientos de licencias en el rango de folios y recaudadora.
-- Generado para formulario: ModifMasiva
-- Fecha: 2025-08-27 13:09:31

CREATE OR REPLACE FUNCTION sp_modifmasiva_licencia(
    p_recaud INTEGER,
    p_folio_ini INTEGER,
    p_folio_fin INTEGER,
    p_fecha DATE,
    p_user TEXT
) RETURNS TABLE(folios_modificados INTEGER) AS $$
DECLARE
    r RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR r IN SELECT * FROM reqlicencias WHERE recaud = p_recaud AND folioreq BETWEEN p_folio_ini AND p_folio_fin AND vigencia = 'V' AND fecprac IS NULL AND (nodiligenciado IS NULL OR nodiligenciado = 'N')
    LOOP
        IF r.fecentejec <= p_fecha THEN
            UPDATE reqlicencias SET
                fecprac = p_fecha,
                nodiligenciado = 'N',
                feccap = CURRENT_DATE,
                capturista = p_user
            WHERE cvereq = r.cvereq;
            v_count := v_count + 1;
        END IF;
    END LOOP;
    RETURN QUERY SELECT v_count;
END;
$$ LANGUAGE plpgsql;