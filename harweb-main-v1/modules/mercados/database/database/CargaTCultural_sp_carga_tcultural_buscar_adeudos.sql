-- Stored Procedure: sp_carga_tcultural_buscar_adeudos
-- Tipo: CRUD
-- Descripción: Obtiene la lista de adeudos de locales del tianguis cultural para un rango de folios, periodo y año.
-- Generado para formulario: CargaTCultural
-- Fecha: 2025-08-26 19:09:26

CREATE OR REPLACE FUNCTION sp_carga_tcultural_buscar_adeudos(local1 integer, local2 integer, periodo smallint, axo smallint)
RETURNS TABLE(
    id_local integer,
    local integer,
    nombre text,
    descuento numeric,
    axo smallint,
    periodo smallint,
    importe numeric,
    superficie numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_local, l.local, l.nombre, t."Descuento", a.axo, a.periodo, a.importe, l.superficie
    FROM ta_11_adeudo_local a
    JOIN ta_11_locales l ON a.id_local = l.id_local
    LEFT JOIN cobrotrimestral t ON t."Folio" = l.local
    WHERE l.local BETWEEN local1 AND local2
      AND a.periodo = periodo
      AND a.axo = axo
      AND l.oficina = 1 AND l.num_mercado = 214
    ORDER BY l.local;
END;
$$ LANGUAGE plpgsql;