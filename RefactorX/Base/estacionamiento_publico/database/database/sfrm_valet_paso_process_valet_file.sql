-- Stored Procedure: process_valet_file
-- Tipo: CRUD
-- Descripción: Procesa un archivo de valet (CSV) y lo inserta en la tabla valet_data. Retorna resumen de inserciones.
-- Generado para formulario: sfrm_valet_paso
-- Fecha: 2025-08-27 14:45:05

CREATE OR REPLACE FUNCTION process_valet_file(p_file_path text)
RETURNS TABLE(row_num integer, status text, message text) AS $$
DECLARE
    v_line text;
    v_fields text[];
    v_row integer := 0;
    v_inserted integer := 0;
    v_failed integer := 0;
    v_error text;
    v_file_handle refcursor;
    v_fd integer;
BEGIN
    -- Open file
    v_fd := pg_read_file(p_file_path, 0, 0);
    IF v_fd IS NULL THEN
        row_num := 0;
        status := 'ERROR';
        message := 'No se pudo abrir el archivo';
        RETURN NEXT;
        RETURN;
    END IF;
    FOR v_line IN EXECUTE format('COPY (SELECT * FROM pg_read_file(%L, 0, 1000000)) TO STDOUT', p_file_path)
    LOOP
        v_row := v_row + 1;
        BEGIN
            v_fields := string_to_array(v_line, ',');
            -- Ajustar los campos según la estructura real
            INSERT INTO valet_data(col1, col2, col3) VALUES (v_fields[1], v_fields[2], v_fields[3]);
            v_inserted := v_inserted + 1;
            row_num := v_row;
            status := 'OK';
            message := 'Insertado';
            RETURN NEXT;
        EXCEPTION WHEN OTHERS THEN
            v_failed := v_failed + 1;
            v_error := SQLERRM;
            row_num := v_row;
            status := 'ERROR';
            message := v_error;
            RETURN NEXT;
        END;
    END LOOP;
    RETURN;
END;
$$ LANGUAGE plpgsql;