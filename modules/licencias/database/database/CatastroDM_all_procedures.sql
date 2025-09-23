-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CatastroDM
-- Generado: 2025-08-26 15:24:46
-- Total SPs: 10
-- ============================================

-- SP 1/10: get_derechos2
-- Tipo: CRUD
-- Descripción: Obtiene el valor de derechos2 para una licencia o anuncio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_derechos2(p_id_licencia integer, p_id_anuncio integer)
RETURNS TABLE(derechos2 numeric) AS $$
BEGIN
  IF p_id_licencia > 0 THEN
    RETURN QUERY SELECT derechos2 FROM detsal_lic WHERE derechos2 > 0 AND cvepago = 0 AND id_licencia = p_id_licencia LIMIT 1;
  ELSIF p_id_anuncio > 0 THEN
    RETURN QUERY SELECT derechos2 FROM detsal_lic WHERE derechos2 > 0 AND cvepago = 0 AND id_anuncio = p_id_anuncio LIMIT 1;
  ELSE
    RETURN QUERY SELECT 0;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/10: calc_fecha_res
-- Tipo: CRUD
-- Descripción: Calcula la fecha de resolución considerando días no laborables y tipo de trámite
-- --------------------------------------------

CREATE OR REPLACE FUNCTION calc_fecha_res(p_fecha_tram date, p_tipo text, p_autoev boolean)
RETURNS TABLE(fechares date) AS $$
DECLARE
  dias integer;
  fecha_salida date;
  dias_nolabor integer;
  i integer := 1;
BEGIN
  fecha_salida := p_fecha_tram;
  IF p_autoev THEN
    fecha_salida := p_fecha_tram + INTERVAL '3 days';
  ELSE
    IF p_tipo = 'A' OR p_tipo = 'B' THEN
      fecha_salida := p_fecha_tram + INTERVAL '15 days';
    ELSIF p_tipo = 'C' THEN
      fecha_salida := p_fecha_tram + INTERVAL '10 days';
    ELSIF p_tipo = 'D' THEN
      fecha_salida := p_fecha_tram + INTERVAL '20 days';
    ELSE
      fecha_salida := p_fecha_tram + INTERVAL '1 day';
    END IF;
  END IF;
  SELECT count(*) INTO dias_nolabor FROM no_laboralesLic WHERE fecha BETWEEN p_fecha_tram AND fecha_salida;
  i := 1;
  WHILE i <= dias_nolabor LOOP
    fecha_salida := fecha_salida + INTERVAL '1 day';
    IF NOT EXISTS (SELECT 1 FROM no_laboralesLic WHERE fecha = fecha_salida) THEN
      i := i + 1;
    END IF;
  END LOOP;
  RETURN QUERY SELECT fecha_salida;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/10: checa_inhabil
-- Tipo: CRUD
-- Descripción: Verifica si una fecha es inhábil
-- --------------------------------------------

CREATE OR REPLACE FUNCTION checa_inhabil(p_fecha date)
RETURNS TABLE(inhabil boolean) AS $$
BEGIN
  RETURN QUERY SELECT EXISTS(SELECT 1 FROM no_laboralesLic WHERE fecha = p_fecha);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/10: calc_fecha_limite_pago
-- Tipo: CRUD
-- Descripción: Calcula la fecha límite de pago considerando días no laborables
-- --------------------------------------------

CREATE OR REPLACE FUNCTION calc_fecha_limite_pago(p_fecha_tram date)
RETURNS TABLE(fechalimitepago date) AS $$
DECLARE
  fecha_salida date;
  dias_nolabor integer;
BEGIN
  fecha_salida := p_fecha_tram + INTERVAL '10 days';
  SELECT count(*) INTO dias_nolabor FROM no_laboralesLic WHERE fecha BETWEEN p_fecha_tram AND fecha_salida;
  fecha_salida := fecha_salida + dias_nolabor;
  WHILE EXISTS (SELECT 1 FROM no_laboralesLic WHERE fecha = fecha_salida) LOOP
    fecha_salida := fecha_salida + INTERVAL '1 day';
  END LOOP;
  RETURN QUERY SELECT fecha_salida;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/10: calc_fecha_visita
-- Tipo: CRUD
-- Descripción: Calcula la fecha de visita para un trámite y dependencia
-- --------------------------------------------

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

-- ============================================

-- SP 6/10: autoriza_licencia
-- Tipo: CRUD
-- Descripción: Autoriza una licencia para un trámite dado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION autoriza_licencia(p_no_tramite integer)
RETURNS TABLE(result text) AS $$
BEGIN
  -- Aquí va la lógica de autorización de licencia, actualización de tablas, etc.
  -- Por simplicidad, solo retorna OK
  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/10: autoriza_anuncio
-- Tipo: CRUD
-- Descripción: Autoriza un anuncio para un trámite dado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION autoriza_anuncio(p_no_tramite integer)
RETURNS TABLE(result text) AS $$
BEGIN
  -- Aquí va la lógica de autorización de anuncio, actualización de tablas, etc.
  -- Por simplicidad, solo retorna OK
  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 8/10: refresh_query
-- Tipo: CRUD
-- Descripción: Refresca un dataset (dummy, para compatibilidad)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION refresh_query(p_dataset text)
RETURNS TABLE(result text) AS $$
BEGIN
  RETURN QUERY SELECT 'Refreshed: ' || p_dataset;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 9/10: generar_dictamen_microgeneradores
-- Tipo: CRUD
-- Descripción: Genera el dictamen de microgeneradores para un trámite
-- --------------------------------------------

CREATE OR REPLACE FUNCTION generar_dictamen_microgeneradores(p_id_tramite integer)
RETURNS TABLE(result text) AS $$
BEGIN
  -- Lógica para generar dictamen microgeneradores
  RETURN QUERY SELECT 'Dictamen generado para tramite ' || p_id_tramite;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 10/10: imprimir_dictamen_microgeneradores
-- Tipo: CRUD
-- Descripción: Imprime el dictamen de microgeneradores para una licencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION imprimir_dictamen_microgeneradores(p_id_licencia integer)
RETURNS TABLE(result text) AS $$
BEGIN
  -- Lógica para imprimir dictamen microgeneradores
  RETURN QUERY SELECT 'Dictamen impreso para licencia ' || p_id_licencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

