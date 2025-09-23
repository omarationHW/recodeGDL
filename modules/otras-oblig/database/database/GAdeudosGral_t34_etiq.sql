-- Stored Procedure: t34_etiq
-- Tipo: Catalog
-- Descripción: Catálogo de etiquetas de campos por tabla.
-- Generado para formulario: GAdeudosGral
-- Fecha: 2025-08-28 12:53:29

CREATE TABLE IF NOT EXISTS t34_etiq (
  cve_tab integer,
  abreviatura varchar(4),
  etiq_control varchar(50),
  concesionario varchar(100),
  ubicacion varchar(100),
  superficie varchar(50),
  fecha_inicio varchar(20),
  fecha_fin varchar(20),
  recaudadora varchar(50),
  sector varchar(20),
  zona varchar(20),
  licencia varchar(20),
  fecha_cancelacion varchar(20),
  unidad varchar(20),
  categoria varchar(20),
  seccion varchar(20),
  bloque varchar(20),
  nombre_comercial varchar(100),
  lugar varchar(100),
  obs varchar(100)
);