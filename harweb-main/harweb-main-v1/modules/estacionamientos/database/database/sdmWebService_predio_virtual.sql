-- Stored Procedure: predio_virtual
-- Tipo: Catalog
-- Descripción: Tabla para almacenar los datos de predios virtuales consultados.
-- Generado para formulario: sdmWebService
-- Fecha: 2025-08-27 13:58:58

CREATE TABLE IF NOT EXISTS predio_virtual (
    id serial PRIMARY KEY,
    cvecuenta integer,
    recaud smallint,
    tipo varchar(20),
    cuenta integer,
    cvecatastral varchar(20),
    subpredio smallint,
    propietario varchar(20),
    calle varchar(20),
    numext varchar(20),
    numint varchar(20),
    colonia varchar(20),
    zona integer,
    subzona integer,
    status smallint,
    mensaje varchar(20),
    created_at timestamp DEFAULT now()
);