-- Stored Procedure: checkLicenciaBloqueada
-- Tipo: CRUD
-- Descripción: Verifica si la licencia está bloqueada o el giro no es de clasificación D.
-- Generado para formulario: ImpLicenciaReglamentadaFrm
-- Fecha: 2025-08-26 17:01:24

-- PostgreSQL function to check if licencia is blocked
CREATE OR REPLACE FUNCTION checkLicenciaBloqueada(p_licencia integer)
RETURNS boolean AS $$
DECLARE
    lic record;
    giro record;
BEGIN
    SELECT * INTO lic FROM licencias WHERE licencia = p_licencia AND vigente = 'V';
    IF NOT FOUND THEN
        RETURN TRUE; -- Considerar bloqueada si no existe
    END IF;
    SELECT * INTO giro FROM c_giros WHERE id_giro = lic.id_giro;
    IF lic.bloqueado = 1 OR giro.clasificacion <> 'D' THEN
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;