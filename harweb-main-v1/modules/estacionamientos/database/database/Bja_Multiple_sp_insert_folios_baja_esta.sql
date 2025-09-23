-- Stored Procedure: sp_insert_folios_baja_esta
-- Tipo: CRUD
-- Descripción: Inserta un registro en la tabla ta14_folios_baja_esta.
-- Generado para formulario: Bja_Multiple
-- Fecha: 2025-08-27 13:24:39

CREATE OR REPLACE PROCEDURE sp_insert_folios_baja_esta(
    p_archivo VARCHAR,
    p_referencia INTEGER,
    p_folio_archivo INTEGER,
    p_fecha_archivo VARCHAR,
    p_placa VARCHAR,
    p_anomalia VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ta14_folios_baja_esta (
        archivo, referencia, folio_archivo, fecha_archivo, placa, anomalia, tarifa, estatus, fecha_captura, usuario, observaciones
    ) VALUES (
        p_archivo, p_referencia, p_folio_archivo, p_fecha_archivo, p_placa, p_anomalia, NULL, NULL, CURRENT_DATE, NULL, NULL
    );
END;
$$;