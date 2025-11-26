-- ================================================================
-- SP: recaudadora_bloqctasreqfrm
-- Módulo: multas_reglamentos
-- Descripción: Lista los bloqueos de cuentas no requeribles para una cuenta específica
-- Tablas: norequeribles
-- ================================================================

-- Eliminar función existente si existe
DROP FUNCTION IF EXISTS recaudadora_bloqctasreqfrm(VARCHAR);

CREATE OR REPLACE FUNCTION recaudadora_bloqctasreqfrm(
    p_clave_cuenta VARCHAR
)
RETURNS TABLE(
    recaud SMALLINT,
    urbrus CHARACTER(1),
    cuenta INTEGER,
    feccap DATE,
    capturista CHARACTER(10),
    fecbaja DATE,
    user_baja CHARACTER(10),
    observacion TEXT,
    cvecuenta INTEGER,
    tipo_bloq INTEGER,
    fecha_envio DATE,
    lote_envio INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cvecuenta INTEGER;
BEGIN
    -- Convertir la clave cuenta a entero
    v_cvecuenta := p_clave_cuenta::INTEGER;

    -- Retornar los bloqueos de la cuenta desde el esquema correcto
    RETURN QUERY
    SELECT n.recaud, n.urbrus, n.cuenta, n.feccap, n.capturista,
           n.fecbaja, n.user_baja, n.observacion, n.cvecuenta,
           n.tipo_bloq, n.fecha_envio, n.lote_envio
    FROM catastro_gdl.norequeribles n
    WHERE n.cvecuenta = v_cvecuenta
    ORDER BY n.feccap DESC;

EXCEPTION
    WHEN invalid_text_representation THEN
        RAISE EXCEPTION 'El valor de clave_cuenta debe ser un número válido';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al consultar bloqueos: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION recaudadora_bloqctasreqfrm(VARCHAR)
IS 'Lista todos los bloqueos de cuentas no requeribles para una cuenta específica';
