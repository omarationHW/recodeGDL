-- Stored Procedure: sp_get_bancos_pagadores
-- Tipo: Catalog
-- Descripción: Obtiene los bancos pagadores activos.
-- Generado para formulario: TrDocumentos
-- Fecha: 2025-08-27 01:34:50

CREATE OR REPLACE FUNCTION sp_get_bancos_pagadores()
RETURNS TABLE(banco SMALLINT, nombre VARCHAR, pagador VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT banco, nombre, pagador FROM ta_bancopagador WHERE pagador = 'S';
END;
$$ LANGUAGE plpgsql;