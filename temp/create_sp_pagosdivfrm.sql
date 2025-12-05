-- Stored Procedure: recaudadora_pagosdivfrm
-- Descripción: Consulta pagos diversos (líneas de captura)
-- Parámetro: clave_cuenta (opcional) - puede ser folio, linea o id

CREATE OR REPLACE FUNCTION public.recaudadora_pagosdivfrm(
    clave_cuenta CHARACTER VARYING DEFAULT NULL
)
RETURNS TABLE (
    id INTEGER,
    linea CHARACTER VARYING,
    fecha TIMESTAMP,
    fecha_vig DATE,
    folio INTEGER,
    modulo INTEGER,
    total NUMERIC
) AS $$
BEGIN
    IF clave_cuenta IS NULL OR clave_cuenta = '' THEN
        -- Si no hay parámetro, devolver todos los registros (limitado a 100)
        RETURN QUERY
        SELECT 
            lcd.id,
            lcd.linea,
            lcd.fecha,
            lcd.fecha_vig,
            lcd.folio,
            lcd.modulo,
            lcd.total
        FROM comun.linea_capturadiv lcd
        ORDER BY lcd.fecha DESC
        LIMIT 100;
    ELSE
        -- Buscar por folio, id o linea que contenga el valor
        RETURN QUERY
        SELECT 
            lcd.id,
            lcd.linea,
            lcd.fecha,
            lcd.fecha_vig,
            lcd.folio,
            lcd.modulo,
            lcd.total
        FROM comun.linea_capturadiv lcd
        WHERE 
            lcd.folio::TEXT = clave_cuenta
            OR lcd.id::TEXT = clave_cuenta
            OR lcd.linea LIKE '%' || clave_cuenta || '%'
        ORDER BY lcd.fecha DESC
        LIMIT 100;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Agregar comentario
COMMENT ON FUNCTION public.recaudadora_pagosdivfrm IS 'Consulta pagos diversos (líneas de captura) por folio, id o línea';
