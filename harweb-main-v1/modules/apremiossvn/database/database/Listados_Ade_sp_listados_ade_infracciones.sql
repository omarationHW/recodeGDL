-- Stored Procedure: sp_listados_ade_infracciones
-- Tipo: Report
-- Descripción: Obtiene listado de adeudos de infracciones/estacionómetros.
-- Generado para formulario: Listados_Ade
-- Fecha: 2025-08-27 15:21:31

CREATE OR REPLACE PROCEDURE sp_listados_ade_infracciones(
    p_propietario text,
    p_placa text,
    p_axo1 integer,
    p_axo2 integer,
    p_impd numeric,
    p_imph numeric,
    p_tipo text,
    p_id_rec integer
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Ejemplo: buscar por propietario o placa, filtrar por año y adeudo
    SELECT * FROM ta_padron
    WHERE (p_propietario IS NULL OR nombre ILIKE '%'||p_propietario||'%')
      AND (p_placa IS NULL OR placa = p_placa)
      AND id_rec = p_id_rec
      AND axo BETWEEN p_axo1 AND p_axo2
      AND adeudo BETWEEN p_impd AND p_imph;
END;
$$;