-- Stored Procedure: sp_padron_concesiones_get
-- Tipo: Report
-- Descripción: Obtiene el listado de concesiones según los filtros aplicados
-- Generado para formulario: RRep_Padron
-- Fecha: 2025-08-28 12:31:21

CREATE OR REPLACE FUNCTION sp_padron_concesiones_get(
        p_vigencia char(1),
        p_tipo_adeudo char(1),
        p_anio integer,
        p_mes char(2)
      )
      RETURNS TABLE (
        id_34_datos integer,
        control varchar(10),
        concesionario varchar(200),
        ubicacion varchar(200),
        superficie numeric(10,2),
        fecha_inicio date,
        fecha_fin date,
        id_recaudadora integer,
        sector char(1),
        id_zona integer,
        licencia integer
      )
      AS $$
      BEGIN
        RETURN QUERY
        SELECT 
          a.id_34_datos, a.control, a.concesionario, a.ubicacion, 
          a.superficie, a.fecha_inicio, a.fecha_fin, a.id_recaudadora,
          a.sector, a.id_zona, a.licencia
        FROM t34_datos a
        INNER JOIN t34_status b ON b.id_34_stat = a.id_stat
        WHERE a.cve_tab = 3
        AND CASE 
          WHEN p_vigencia = 'T' THEN true
          ELSE b.cve_stat = p_vigencia
        END
        ORDER BY a.control;
      END;
      $$ LANGUAGE plpgsql;