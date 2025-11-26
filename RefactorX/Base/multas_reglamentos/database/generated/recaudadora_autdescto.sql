-- ================================================================
-- SP: recaudadora_autdescto
-- Módulo: multas_reglamentos
-- Descripción: Lista todos los descuentos de predial para una cuenta
-- Tablas: descpred, c_descpred
-- ================================================================

-- Eliminar función existente si existe
DROP FUNCTION IF EXISTS recaudadora_autdescto(VARCHAR);

CREATE OR REPLACE FUNCTION recaudadora_autdescto(
    p_clave_cuenta VARCHAR
)
RETURNS TABLE(
    cvecuenta INTEGER,
    cvedescuento SMALLINT,
    bimini SMALLINT,
    bimfin SMALLINT,
    fecalta DATE,
    captalta CHARACTER(10),
    fecbaja DATE,
    captbaja CHARACTER(10),
    propie CHARACTER(50),
    solicitante CHARACTER(30),
    observaciones VARCHAR(255),
    recaud SMALLINT,
    foliodesc INTEGER,
    status CHARACTER(1),
    identificacion CHARACTER(20),
    fecnac DATE,
    institucion SMALLINT,
    rfc VARCHAR(13),
    curp VARCHAR(18),
    descripcion CHARACTER(30)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cvecuenta INTEGER;
BEGIN
    -- Convertir la clave cuenta a entero
    v_cvecuenta := p_clave_cuenta::INTEGER;

    -- Retornar los descuentos de la cuenta usando el esquema correcto
    RETURN QUERY
    SELECT d.cvecuenta, d.cvedescuento, d.bimini, d.bimfin,
           d.fecalta, d.captalta, d.fecbaja, d.captbaja,
           d.propie, d.solicitante, d.observaciones, d.recaud, d.foliodesc,
           d.status, d.identificacion, d.fecnac, d.institucion,
           d.rfc, d.curp, c.descripcion
    FROM catastro_gdl.descpred d
    LEFT JOIN catastro_gdl.c_descpred c ON c.cvedescuento = d.cvedescuento
    WHERE d.cvecuenta = v_cvecuenta
    ORDER BY d.fecalta DESC;

EXCEPTION
    WHEN invalid_text_representation THEN
        RAISE EXCEPTION 'El valor de clave_cuenta debe ser un número válido';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al consultar descuentos: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION recaudadora_autdescto(VARCHAR)
IS 'Lista todos los descuentos de predial para una cuenta específica';
