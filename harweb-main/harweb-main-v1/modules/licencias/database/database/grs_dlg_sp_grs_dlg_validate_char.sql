-- Stored Procedure: sp_grs_dlg_validate_char
-- Tipo: CRUD
-- Descripción: Valida si un carácter es válido para el campo especificado según el tipo de dato.
-- Generado para formulario: grs_dlg
-- Fecha: 2025-08-26 16:42:22

CREATE OR REPLACE FUNCTION sp_grs_dlg_validate_char(
    p_table text,
    p_field text,
    p_char text
) RETURNS boolean AS $$
DECLARE
    data_type text;
    is_valid boolean := true;
BEGIN
    SELECT data_type INTO data_type
    FROM information_schema.columns
    WHERE table_name = p_table AND column_name = p_field;

    IF data_type IS NULL THEN
        RETURN false;
    END IF;

    -- Ejemplo de validación simple por tipo
    IF data_type IN ('integer', 'bigint', 'smallint') THEN
        IF p_char ~ '[0-9]' THEN
            is_valid := true;
        ELSE
            is_valid := false;
        END IF;
    ELSIF data_type IN ('character varying', 'text', 'character') THEN
        -- Permitir cualquier carácter imprimible
        IF length(p_char) = 1 AND ascii(p_char) BETWEEN 32 AND 126 THEN
            is_valid := true;
        ELSE
            is_valid := false;
        END IF;
    ELSE
        -- Otros tipos: permitir solo dígitos y letras
        IF p_char ~ '[A-Za-z0-9]' THEN
            is_valid := true;
        ELSE
            is_valid := false;
        END IF;
    END IF;
    RETURN is_valid;
END;
$$ LANGUAGE plpgsql;