-- Stored Procedure: date_to_words
-- Tipo: Catalog
-- Descripción: Convierte una fecha a su representación en letras en español.
-- Generado para formulario: ModuloDb
-- Fecha: 2025-08-27 20:58:42

CREATE OR REPLACE FUNCTION date_to_words(p_date DATE)
RETURNS TEXT AS $$
DECLARE
    meses TEXT[] := ARRAY['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    dia INT;
    mes INT;
    anio INT;
BEGIN
    dia := EXTRACT(DAY FROM p_date);
    mes := EXTRACT(MONTH FROM p_date);
    anio := EXTRACT(YEAR FROM p_date);
    RETURN dia::TEXT || ' de ' || meses[mes] || ' de ' || anio::TEXT;
END;
$$ LANGUAGE plpgsql;