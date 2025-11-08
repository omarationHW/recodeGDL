<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');

echo "Actualizando SP sp_bloqueorfc_buscar_tramite...\n\n";

// 1. Eliminar SP anterior
echo "1. Eliminando versión anterior...\n";
try {
    $pdo->exec("DROP FUNCTION IF EXISTS public.sp_bloqueorfc_buscar_tramite(integer) CASCADE");
    echo "   ✓ Eliminado\n";
} catch (Exception $e) {
    echo "   - No existía\n";
}

// 2. Crear nueva versión
echo "\n2. Creando nueva versión con consulta a comun.tramites...\n";
$pdo->exec("SET search_path TO public, comun");

$sql = "
CREATE OR REPLACE FUNCTION public.sp_bloqueorfc_buscar_tramite(
    p_id_tramite INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR,
    id_tramite INTEGER,
    id_licencia INTEGER,
    rfc VARCHAR,
    actividad VARCHAR,
    propietario VARCHAR
) AS \$\$
DECLARE
    v_count INTEGER;
BEGIN
    -- Verificar si el trámite existe
    SELECT COUNT(*) INTO v_count
    FROM comun.tramites t
    WHERE t.id_tramite = p_id_tramite;

    IF v_count = 0 THEN
        RETURN QUERY SELECT
            FALSE,
            'No se encontró el trámite con ID: ' || p_id_tramite::VARCHAR,
            NULL::INTEGER,
            NULL::INTEGER,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::VARCHAR;
        RETURN;
    END IF;

    -- Retornar datos del trámite
    RETURN QUERY
    SELECT
        TRUE,
        'Trámite encontrado exitosamente'::VARCHAR,
        t.id_tramite::INTEGER,
        t.id_licencia::INTEGER,
        TRIM(COALESCE(t.rfc, ''))::VARCHAR as rfc,
        TRIM(COALESCE(t.actividad, ''))::VARCHAR as actividad,
        TRIM(TRIM(COALESCE(t.primer_ap, '')) || ' ' ||
             TRIM(COALESCE(t.segundo_ap, '')) || ' ' ||
             TRIM(COALESCE(t.propietario, '')))::VARCHAR as propietario
    FROM comun.tramites t
    WHERE t.id_tramite = p_id_tramite
    LIMIT 1;
END;
\$\$ LANGUAGE plpgsql;
";

$pdo->exec($sql);
echo "   ✓ SP creado\n";

// 3. Probar con el trámite 349786
echo "\n3. Probando con trámite 349786...\n";
$stmt = $pdo->query("SELECT * FROM public.sp_bloqueorfc_buscar_tramite(349786)");
$result = $stmt->fetch(PDO::FETCH_ASSOC);

if ($result) {
    echo "   ✓ Success: " . ($result['success'] ? 'TRUE' : 'FALSE') . "\n";
    echo "   Message: {$result['message']}\n";
    if ($result['success']) {
        echo "   ID Trámite: {$result['id_tramite']}\n";
        echo "   ID Licencia: {$result['id_licencia']}\n";
        echo "   RFC: {$result['rfc']}\n";
        echo "   Actividad: {$result['actividad']}\n";
        echo "   Propietario: {$result['propietario']}\n";
    }
}

echo "\n✓✓✓ ACTUALIZACIÓN COMPLETADA ✓✓✓\n";
