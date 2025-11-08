-- Stored Procedure: sp_imp_oficio_print
-- Tipo: Report
-- Descripción: Devuelve los datos necesarios para imprimir el oficio seleccionado.
-- Generado para formulario: ImpOficiofrm
-- Fecha: 2025-08-26 17:03:12

CREATE OR REPLACE FUNCTION sp_imp_oficio_print(
    p_tramite_id INTEGER,
    p_oficio_type INTEGER
) RETURNS TABLE(
    tramite_id INTEGER,
    propietario TEXT,
    ubicacion TEXT,
    tipo_tramite TEXT,
    oficio_type INTEGER,
    plantilla TEXT,
    fecha TIMESTAMP
) AS $$
DECLARE
    plantilla_text TEXT;
BEGIN
    -- Selecciona la plantilla según el tipo de oficio
    IF p_oficio_type = 1 THEN
        plantilla_text := 'Plantilla UNO';
    ELSIF p_oficio_type = 2 THEN
        plantilla_text := 'Plantilla DOS';
    ELSIF p_oficio_type = 3 THEN
        plantilla_text := 'Plantilla M24BIS';
    ELSIF p_oficio_type = 4 THEN
        plantilla_text := 'Plantilla INFORMATIVO';
    ELSE
        plantilla_text := 'Plantilla DESCONOCIDA';
    END IF;
    RETURN QUERY
    SELECT t.id_tramite, t.propietario, t.ubicacion, t.tipo_tramite, p_oficio_type, plantilla_text, NOW()
    FROM tramites t
    WHERE t.id_tramite = p_tramite_id;
END;
$$ LANGUAGE plpgsql;
