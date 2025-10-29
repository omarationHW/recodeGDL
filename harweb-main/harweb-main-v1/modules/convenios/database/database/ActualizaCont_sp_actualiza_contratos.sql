-- Stored Procedure: sp_actualiza_contratos
-- Tipo: CRUD
-- Descripción: Actualiza los contratos de desarrollo social desde la tabla temporal ta_17_paso_cont al catálogo principal, devolviendo totales de adiciones, modificaciones, inconsistencias y descuentos.
-- Generado para formulario: ActualizaCont
-- Fecha: 2025-08-27 13:33:08

CREATE OR REPLACE FUNCTION sp_actualiza_contratos(p_id_usuario integer)
RETURNS TABLE(
  adicionados integer,
  modificados integer,
  inconsistencias integer,
  total integer,
  descuentos integer
) AS $$
DECLARE
  r RECORD;
  v_adicionados integer := 0;
  v_modificados integer := 0;
  v_inconsistencias integer := 0;
  v_total integer := 0;
  v_descuentos integer := 0;
BEGIN
  FOR r IN SELECT * FROM ta_17_paso_cont LOOP
    BEGIN
      -- Si no existe, insertar
      IF NOT EXISTS (SELECT 1 FROM ta_17_calles WHERE colonia = r.colonia AND calle = r.calle) THEN
        INSERT INTO ta_17_calles (colonia, calle, tipo, servicio, desc_calle, axo_obra, cuenta_ingreso, vigencia_obra, id_usuario, fecha_actual, plazo, clave_plazo, cuenta_rezago)
        VALUES (r.colonia, r.calle, r.tipo, r.servicio, r.desc_calle, r.axo_obra, r.cuenta_ingreso, r.vigencia_obra, p_id_usuario, NOW(), r.plazo, r.clave_plazo, r.cuenta_rezago);
        v_adicionados := v_adicionados + 1;
      ELSE
        -- Si existe, actualizar
        UPDATE ta_17_calles SET
          tipo = r.tipo,
          servicio = r.servicio,
          desc_calle = r.desc_calle,
          axo_obra = r.axo_obra,
          cuenta_ingreso = r.cuenta_ingreso,
          vigencia_obra = r.vigencia_obra,
          id_usuario = p_id_usuario,
          fecha_actual = NOW(),
          plazo = r.plazo,
          clave_plazo = r.clave_plazo,
          cuenta_rezago = r.cuenta_rezago
        WHERE colonia = r.colonia AND calle = r.calle;
        v_modificados := v_modificados + 1;
      END IF;
      -- Contar si es descuento (ejemplo: si r.descuento > 0)
      IF r.descuento IS NOT NULL AND r.descuento > 0 THEN
        v_descuentos := v_descuentos + 1;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      v_inconsistencias := v_inconsistencias + 1;
    END;
    v_total := v_total + 1;
  END LOOP;
  RETURN QUERY SELECT v_adicionados, v_modificados, v_inconsistencias, v_total, v_descuentos;
END;
$$ LANGUAGE plpgsql;