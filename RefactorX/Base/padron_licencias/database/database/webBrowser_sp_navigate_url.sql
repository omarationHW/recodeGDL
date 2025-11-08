-- Stored Procedure: sp_navigate_url
-- Tipo: CRUD
-- Descripción: Valida y retorna la URL a navegar. No realiza operaciones de base de datos, solo valida formato.
-- Generado para formulario: webBrowser
-- Fecha: 2025-08-26 18:24:04

-- No es necesario un stored procedure real ya que no hay lógica SQL ni persistencia.
-- Se incluye un ejemplo de SP de validación para cumplir el requerimiento.

CREATE OR REPLACE FUNCTION sp_navigate_url(p_url TEXT)
RETURNS TABLE(status TEXT, message TEXT, url TEXT) AS $$
BEGIN
    IF p_url IS NULL OR LENGTH(TRIM(p_url)) = 0 THEN
        status := 'error';
        message := 'URL no proporcionada';
        url := NULL;
        RETURN NEXT;
        RETURN;
    END IF;
    IF p_url !~* '^https?://.+' THEN
        status := 'error';
        message := 'URL inválida';
        url := NULL;
        RETURN NEXT;
        RETURN;
    END IF;
    status := 'success';
    message := 'Navegación exitosa';
    url := p_url;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;