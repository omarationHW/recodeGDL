-- Stored Procedure: calc_fecha_visita
-- Tipo: CRUD
-- Descripción: Calcula la fecha de visita para un trámite y dependencia
-- Generado para formulario: CatastroDM
-- Fecha: 2025-08-26 15:24:46

CREATE OR REPLACE FUNCTION calc_fecha_visita(p_id_tramite integer, p_id_dependencia integer)
RETURNS TABLE(fechavisita date) AS $$
DECLARE
  zona text;
  fecha_visita date;
  sw boolean := true;
  dias_visita_id integer;
  cuantos integer;
BEGIN
  SELECT zona INTO zona FROM tramites WHERE id_tramite = p_id_tramite;
  IF p_id_dependencia = 24 THEN
    fecha_visita := CURRENT_DATE + INTERVAL '2 days';
  ELSE
    fecha_visita := CURRENT_DATE + INTERVAL '1 day';
  END IF;
  LOOP
    EXIT WHEN NOT sw;
    IF EXISTS (SELECT 1 FROM no_laboralesLic WHERE fecha = fecha_visita) THEN
      fecha_visita := fecha_visita + INTERVAL '1 day';
    ELSE
      SELECT id INTO dias_visita_id FROM c_dep_horario h WHERE id_dependencia = p_id_dependencia AND h.zonas LIKE '%' || zona || '%' AND EXTRACT(DOW FROM fecha_visita) = dia LIMIT 1;
      IF dias_visita_id IS NULL THEN
        fecha_visita := fecha_visita + INTERVAL '1 day';
      ELSE
        SELECT count(*) INTO cuantos FROM tramites_visitas WHERE fecha = fecha_visita AND c_dep_horario_id = dias_visita_id;
        IF cuantos = 20 THEN
          fecha_visita := fecha_visita + INTERVAL '1 day';
        ELSE
          sw := false;
        END IF;
      END IF;
    END IF;
  END LOOP;
  RETURN QUERY SELECT fecha_visita;
END;
$$ LANGUAGE plpgsql;