-- Stored Procedure: sp_padron_adeudos_get
-- Tipo: Report
-- Descripción: Obtiene los adeudos de una concesión
-- Generado para formulario: RRep_Padron
-- Fecha: 2025-08-28 12:31:21

CREATE OR REPLACE FUNCTION sp_padron_adeudos_get(
        p_control integer,
        p_tipo char(1),
        p_fecha varchar(7)
      )
      RETURNS TABLE (
        descripcion varchar(255),
        adeudo numeric(10,2),
        recargo numeric(10,2)
      )
      AS $$
      BEGIN
        RETURN QUERY
        SELECT 
          a.descripcion,
          a.adeudo,
          a.recargo
        FROM adeudos a
        WHERE a.id_34_datos = p_control
        AND a.tipo = p_tipo
        AND to_char(a.fecha, 'YYYY-MM') = p_fecha;
      END;
      $$ LANGUAGE plpgsql;