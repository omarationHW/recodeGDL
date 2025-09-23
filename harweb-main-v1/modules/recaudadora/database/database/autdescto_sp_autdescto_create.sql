-- Stored Procedure: sp_autdescto_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo descuento de predial
-- Generado para formulario: autdescto
-- Fecha: 2025-08-26 20:45:21

CREATE OR REPLACE FUNCTION sp_autdescto_create(
    p_cvecuenta INTEGER,
    p_cvedescuento INTEGER,
    p_bimini INTEGER,
    p_bimfin INTEGER,
    p_solicitante VARCHAR,
    p_observaciones VARCHAR,
    p_institucion INTEGER,
    p_identificacion VARCHAR,
    p_fecnac DATE,
    p_usuario VARCHAR
) RETURNS TABLE(id INTEGER, message TEXT) AS $$
DECLARE
    v_folio INTEGER;
BEGIN
    -- Validación de rango de bimestres
    IF p_bimini > p_bimfin THEN
        RAISE EXCEPTION 'Error en el rango de bimestres';
    END IF;
    -- Validación de duplicidad
    IF EXISTS (SELECT 1 FROM descpred WHERE cvecuenta=p_cvecuenta AND fecbaja IS NULL AND ((bimini BETWEEN p_bimini AND p_bimfin) OR (bimfin BETWEEN p_bimini AND p_bimfin))) THEN
        RAISE EXCEPTION 'Ya existe un descuento vigente sobre este periodo';
    END IF;
    -- Folio automático (ejemplo simple)
    SELECT COALESCE(MAX(foliodesc),0)+1 INTO v_folio FROM descpred WHERE recaud=(SELECT recaud FROM convcta WHERE cvecuenta=p_cvecuenta LIMIT 1);
    INSERT INTO descpred (cvecuenta, cvedescuento, bimini, bimfin, fecalta, captalta, solicitante, observaciones, recaud, foliodesc, status, identificacion, fecnac, institucion)
    VALUES (p_cvecuenta, p_cvedescuento, p_bimini, p_bimfin, CURRENT_DATE, p_usuario, p_solicitante, p_observaciones, (SELECT recaud FROM convcta WHERE cvecuenta=p_cvecuenta LIMIT 1), v_folio, 'V', p_identificacion, p_fecnac, p_institucion)
    RETURNING id, 'Descuento creado correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;