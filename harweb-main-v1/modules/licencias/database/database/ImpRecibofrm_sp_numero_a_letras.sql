-- Stored Procedure: sp_numero_a_letras
-- Tipo: CRUD
-- Descripción: Convierte un número a letras en español (simplificado, para montos menores a 1000000)
-- Generado para formulario: ImpRecibofrm
-- Fecha: 2025-08-27 18:32:11

-- NOTA: Para producción, usar una extensión o función más robusta
CREATE OR REPLACE FUNCTION sp_numero_a_letras(p_numero NUMERIC)
RETURNS TEXT AS $$
DECLARE
    unidades TEXT[] := ARRAY['CERO','UNO','DOS','TRES','CUATRO','CINCO','SEIS','SIETE','OCHO','NUEVE'];
    decenas TEXT[] := ARRAY['', 'DIEZ','VEINTE','TREINTA','CUARENTA','CINCUENTA','SESENTA','SETENTA','OCHENTA','NOVENTA'];
    centenas TEXT[] := ARRAY['','CIEN','DOSCIENTOS','TRESCIENTOS','CUATROCIENTOS','QUINIENTOS','SEISCIENTOS','SETECIENTOS','OCHOCIENTOS','NOVECIENTOS'];
    n INT := p_numero;
    resultado TEXT := '';
BEGIN
    IF n < 10 THEN
        resultado := unidades[n+1];
    ELSIF n < 100 THEN
        resultado := decenas[n/10] || CASE WHEN n%10 > 0 THEN ' Y ' || unidades[(n%10)+1] ELSE '' END;
    ELSIF n < 1000 THEN
        resultado := centenas[n/100] || CASE WHEN n%100 > 0 THEN ' ' || decenas[(n%100)/10] END;
    ELSE
        resultado := 'CANTIDAD ALTA';
    END IF;
    RETURN resultado;
END;
$$ LANGUAGE plpgsql;