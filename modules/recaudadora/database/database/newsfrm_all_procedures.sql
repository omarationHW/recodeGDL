-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: newsfrm
-- Generado: 2025-08-27 13:57:34
-- Total SPs: 2
-- ============================================

-- SP 1/2: get_news_changes
-- Tipo: Catalog
-- Descripción: Devuelve la lista de cambios realizados al módulo (notas de versión).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_news_changes()
RETURNS TABLE(change_text TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT unnest(ARRAY[
        'Cambios hechos a la versión con fecha 17/Ago/2001 18:00',
        '1.-  Se inhabilita cancelar requerimientos para los usuarios que no tengan la autorizacion para hacerlo.',
        '2.- Se valida que no se entreguen requerimientos cuyo periodo requerido ya este saldado. En caso de que ya se haya pagado el periodo requerido el requerimiento será cancelado en forma automática.',
        '3.- Se agrega en la sección de Apremios una opción para bloquear y desbloquear cuentas para que no sean requeridas.',
        '4.- Se agrega el dato de Valor fiscal a la consulta de datos de predial en la opción de Consultas Predial.',
        '5.- En la opcion Control de Requerimientos de la sección de Apremios si el requerimiento esta practicado al momento de ponerlo como no diligenciado se cancelaran los gastos y multas correspondientes y se le quita la fecha de practicado. El requerimiento puede ser cancelado y reactivado con la autorizacion correspondiente.'
    ]);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: acknowledge_news_changes
-- Tipo: CRUD
-- Descripción: Registra que un usuario ha leído/aceptado los cambios del módulo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION acknowledge_news_changes(p_user_id INTEGER)
RETURNS TABLE(status TEXT) AS $$
BEGIN
    -- Aquí se podría registrar en una tabla de auditoría que el usuario leyó los cambios
    -- Por simplicidad, solo retornamos un mensaje
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

