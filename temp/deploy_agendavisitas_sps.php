<?php
// DESPLEGAR SPs AGENDA DE VISITAS
// Base: padron_licencias
// Esquema: comun

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\\Contracts\\Console\\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "<pre>";
echo "====================================\n";
echo "DESPLEGANDO SPs AGENDA DE VISITAS\n";
echo "====================================\n\n";

try {
    DB::purge('pgsql');
    config(['database.connections.pgsql.database' => 'padron_licencias']);
    DB::reconnect('pgsql');

    echo "Conectado a: " . DB::connection()->getDatabaseName() . "\n";
    echo "Servidor: 192.168.6.146\n\n";

    // 1. FN_DIALETRA (función auxiliar)
    echo "1/3 Creando fn_dialetra...\n";
    DB::statement("
    CREATE OR REPLACE FUNCTION fn_dialetra(p_dia INTEGER)
    RETURNS VARCHAR AS \$\$
    DECLARE
        dias TEXT[] := ARRAY['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    BEGIN
        IF p_dia IS NULL OR p_dia < 0 OR p_dia > 6 THEN
            RETURN '';
        END IF;
        RETURN dias[p_dia+1];
    END;
    \$\$ LANGUAGE plpgsql IMMUTABLE;
    ");
    echo "✓ OK\n\n";

    // 2. SP_GET_DEPENDENCIAS
    echo "2/3 Creando sp_get_dependencias...\n";
    DB::statement("
    CREATE OR REPLACE FUNCTION sp_get_dependencias()
    RETURNS TABLE (
        id_dependencia INTEGER,
        descripcion VARCHAR
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT d.id_dependencia, d.descripcion
        FROM c_dep_horario c
        INNER JOIN c_dependencias d ON c.id_dependencia = d.id_dependencia
        GROUP BY d.id_dependencia, d.descripcion
        ORDER BY d.descripcion;
    END;
    \$\$ LANGUAGE plpgsql;
    ");
    echo "✓ OK\n\n";

    // 3. SP_GET_AGENDA_VISITAS
    echo "3/3 Creando sp_get_agenda_visitas...\n";
    DB::statement("
    CREATE OR REPLACE FUNCTION sp_get_agenda_visitas(
        p_id_dependencia INTEGER,
        p_fechaini DATE,
        p_fechafin DATE
    )
    RETURNS TABLE (
        fecha DATE,
        dia_letras VARCHAR,
        turno VARCHAR,
        hora VARCHAR,
        zona SMALLINT,
        subzona SMALLINT,
        id_tramite INTEGER,
        feccap DATE,
        propietario VARCHAR,
        domcompleto VARCHAR,
        actividad VARCHAR,
        propietarionvo VARCHAR
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            v.fecha,
            fn_dialetra(EXTRACT(DOW FROM v.fecha)::INTEGER) AS dia_letras,
            v.turno,
            v.hora,
            v.zona,
            v.subzona,
            v.id_tramite,
            t.feccap,
            t.propietario,
            TRIM(COALESCE(v.ubicacion, '')) || ' No. ext.:' || COALESCE(v.numext_ubic, '') || ' Letra ext. ' || COALESCE(v.letraext_ubic, '') || ' No. int.' || COALESCE(v.numint_ubic, '') || ' Letra int. ' || COALESCE(v.letraint_ubic, '') AS domcompleto,
            v.actividad,
            TRIM(COALESCE(t.primer_ap, '') || ' ' || COALESCE(t.segundo_ap, '') || ' ' || COALESCE(t.propietario, '')) AS propietarionvo
        FROM tramites_visitas v
        INNER JOIN c_dep_horario h ON h.id = v.c_dep_horario_id AND h.id_dependencia = p_id_dependencia
        INNER JOIN tramites t ON t.id_tramite = v.id_tramite
        WHERE v.fecha BETWEEN p_fechaini AND p_fechafin;
    END;
    \$\$ LANGUAGE plpgsql;
    ");
    echo "✓ OK\n\n";

    echo "====================================\n";
    echo "✓ TODOS LOS SPs CREADOS (3/3)\n";
    echo "====================================\n\n";

    // Verificar
    echo "Verificando instalación...\n";
    $deps = DB::select("SELECT * FROM sp_get_dependencias() LIMIT 5");
    echo "✓ sp_get_dependencias: " . count($deps) . " dependencias encontradas\n";

    if (count($deps) > 0) {
        echo "\nPrimeras dependencias:\n";
        foreach ($deps as $dep) {
            echo "  - ID: {$dep->id_dependencia}, Descripción: {$dep->descripcion}\n";
        }
    }

    echo "\n====================================\n";
    echo "✓ ¡DESPLIEGUE EXITOSO!\n";
    echo "====================================\n\n";

    echo "SPs desplegados:\n";
    echo "1. fn_dialetra() - Función auxiliar para días\n";
    echo "2. sp_get_dependencias() - Catálogo de dependencias\n";
    echo "3. sp_get_agenda_visitas() - Reporte de visitas\n\n";

    echo "✓ El componente Agendavisitasfrm.vue ya puede usarse\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
}

echo "</pre>";
