<?php
// DESPLEGAR SPs GRUPOS DE ANUNCIOS
// Base: padron_licencias
// Esquema: public
// Servidor: 192.168.6.146

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\\Contracts\\Console\\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "<pre>";
echo "====================================\n";
echo "DESPLEGANDO SPs GRUPOS DE ANUNCIOS\n";
echo "====================================\n\n";

try {
    // Configurar conexión a padron_licencias
    DB::purge('pgsql');
    config(['database.connections.pgsql.database' => 'padron_licencias']);
    DB::reconnect('pgsql');

    echo "Conectado a: " . DB::connection()->getDatabaseName() . "\n";
    echo "Servidor: 192.168.6.146\n\n";

    // 1. GET_GRUPOS_ANUNCIOS
    echo "1/8 Creando get_grupos_anuncios...\n";
    DB::statement("
    CREATE OR REPLACE FUNCTION get_grupos_anuncios(p_descripcion TEXT DEFAULT NULL)
    RETURNS TABLE(id INTEGER, descripcion TEXT) AS \$\$
    BEGIN
      RETURN QUERY
        SELECT ag.id, ag.descripcion::TEXT
        FROM public.anun_grupos ag
        WHERE p_descripcion IS NULL OR ag.descripcion ILIKE '%' || p_descripcion || '%'
        ORDER BY ag.descripcion;
    END;
    \$\$ LANGUAGE plpgsql;
    ");
    echo "✓ OK\n\n";

    // 2. INSERT_GRUPO_ANUNCIO
    echo "2/8 Creando insert_grupo_anuncio...\n";
    DB::statement("
    CREATE OR REPLACE FUNCTION insert_grupo_anuncio(p_descripcion TEXT)
    RETURNS TABLE(success BOOLEAN, message TEXT, new_id INTEGER) AS \$\$
    DECLARE
      v_new_id INTEGER;
    BEGIN
      INSERT INTO public.anun_grupos (descripcion)
      VALUES (p_descripcion)
      RETURNING id INTO v_new_id;

      RETURN QUERY SELECT TRUE::BOOLEAN, 'Grupo creado exitosamente'::TEXT, v_new_id;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE::BOOLEAN, 'Error al crear grupo: ' || SQLERRM, NULL::INTEGER;
    END;
    \$\$ LANGUAGE plpgsql;
    ");
    echo "✓ OK\n\n";

    // 3. UPDATE_GRUPO_ANUNCIO
    echo "3/8 Creando update_grupo_anuncio...\n";
    DB::statement("
    CREATE OR REPLACE FUNCTION update_grupo_anuncio(p_id INTEGER, p_descripcion TEXT)
    RETURNS TABLE(success BOOLEAN, message TEXT) AS \$\$
    BEGIN
      UPDATE public.anun_grupos
      SET descripcion = p_descripcion
      WHERE id = p_id;

      IF FOUND THEN
        RETURN QUERY SELECT TRUE::BOOLEAN, 'Grupo actualizado exitosamente'::TEXT;
      ELSE
        RETURN QUERY SELECT FALSE::BOOLEAN, 'Grupo no encontrado'::TEXT;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE::BOOLEAN, 'Error al actualizar grupo: ' || SQLERRM;
    END;
    \$\$ LANGUAGE plpgsql;
    ");
    echo "✓ OK\n\n";

    // 4. DELETE_GRUPO_ANUNCIO
    echo "4/8 Creando delete_grupo_anuncio...\n";
    DB::statement("
    CREATE OR REPLACE FUNCTION delete_grupo_anuncio(p_id INTEGER)
    RETURNS TABLE(success BOOLEAN, message TEXT) AS \$\$
    BEGIN
      -- Primero eliminar las relaciones
      DELETE FROM public.anun_detgrupo WHERE anun_grupos_id = p_id;

      -- Luego eliminar el grupo
      DELETE FROM public.anun_grupos WHERE id = p_id;

      IF FOUND THEN
        RETURN QUERY SELECT TRUE::BOOLEAN, 'Grupo eliminado exitosamente'::TEXT;
      ELSE
        RETURN QUERY SELECT FALSE::BOOLEAN, 'Grupo no encontrado'::TEXT;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE::BOOLEAN, 'Error al eliminar grupo: ' || SQLERRM;
    END;
    \$\$ LANGUAGE plpgsql;
    ");
    echo "✓ OK\n\n";

    // 5. GET_ANUNCIOS_DISPONIBLES
    echo "5/8 Creando get_anuncios_disponibles...\n";
    DB::statement("
    CREATE OR REPLACE FUNCTION get_anuncios_disponibles(
      p_grupo_id INTEGER,
      p_actividad TEXT DEFAULT NULL,
      p_id_giro INTEGER DEFAULT NULL
    )
    RETURNS TABLE(
      anuncio INTEGER,
      propietario TEXT,
      descripcion TEXT,
      id_giro INTEGER,
      zona SMALLINT,
      subzona SMALLINT,
      fecha_otorgamiento DATE,
      medidas1 DOUBLE PRECISION,
      medidas2 DOUBLE PRECISION,
      area_anuncio DOUBLE PRECISION,
      num_caras SMALLINT,
      ubicacion TEXT,
      numext_ubic INTEGER,
      letraext_ubic TEXT,
      numint_ubic TEXT,
      letraint_ubic TEXT,
      colonia_ubic TEXT,
      vigente TEXT,
      espubic TEXT,
      bloqueado SMALLINT,
      licencia INTEGER,
      empresa INTEGER,
      propietarionvo TEXT
    ) AS \$\$
    BEGIN
      RETURN QUERY
        SELECT DISTINCT ON (a.anuncio)
          a.anuncio,
          l.propietario::TEXT,
          a.descripcion::TEXT,
          a.id_giro,
          a.zona,
          a.subzona,
          a.fecha_otorgamiento,
          a.medidas1,
          a.medidas2,
          a.area_anuncio,
          a.num_caras,
          a.ubicacion::TEXT,
          a.numext_ubic,
          a.letraext_ubic::TEXT,
          a.numint_ubic::TEXT,
          a.letraint_ubic::TEXT,
          a.colonia_ubic::TEXT,
          a.vigente::TEXT,
          a.espubic::TEXT,
          a.bloqueado,
          a.licencia,
          a.empresa,
          TRIM(COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, ''))::TEXT AS propietarionvo
        FROM comun.anuncios a
        LEFT JOIN public.anun_detgrupo d ON d.anuncio = a.anuncio AND d.anun_grupos_id = p_grupo_id
        LEFT JOIN comun.licencias l ON l.id_licencia = a.licencia
        WHERE a.vigente = 'V'
          AND d.anuncio IS NULL
          AND (p_actividad IS NULL OR a.descripcion ILIKE '%' || p_actividad || '%')
          AND (p_id_giro IS NULL OR a.id_giro = p_id_giro)
        ORDER BY a.anuncio, a.descripcion;
    END;
    \$\$ LANGUAGE plpgsql;
    ");
    echo "✓ OK\n\n";

    // 6. GET_ANUNCIOS_GRUPO
    echo "6/8 Creando get_anuncios_grupo...\n";
    DB::statement("
    CREATE OR REPLACE FUNCTION get_anuncios_grupo(
      p_grupo_id INTEGER,
      p_actividad TEXT DEFAULT NULL
    )
    RETURNS TABLE(
      anuncio INTEGER,
      propietario TEXT,
      descripcion TEXT,
      id_giro INTEGER,
      zona SMALLINT,
      subzona SMALLINT,
      fecha_otorgamiento DATE,
      medidas1 DOUBLE PRECISION,
      medidas2 DOUBLE PRECISION,
      area_anuncio DOUBLE PRECISION,
      num_caras SMALLINT,
      ubicacion TEXT,
      numext_ubic INTEGER,
      letraext_ubic TEXT,
      numint_ubic TEXT,
      letraint_ubic TEXT,
      colonia_ubic TEXT,
      vigente TEXT,
      espubic TEXT,
      bloqueado SMALLINT,
      licencia INTEGER,
      empresa INTEGER,
      propietarionvo TEXT
    ) AS \$\$
    BEGIN
      RETURN QUERY
        SELECT DISTINCT ON (a.anuncio)
          a.anuncio,
          l.propietario::TEXT,
          a.descripcion::TEXT,
          a.id_giro,
          a.zona,
          a.subzona,
          a.fecha_otorgamiento,
          a.medidas1,
          a.medidas2,
          a.area_anuncio,
          a.num_caras,
          a.ubicacion::TEXT,
          a.numext_ubic,
          a.letraext_ubic::TEXT,
          a.numint_ubic::TEXT,
          a.letraint_ubic::TEXT,
          a.colonia_ubic::TEXT,
          a.vigente::TEXT,
          a.espubic::TEXT,
          a.bloqueado,
          a.licencia,
          a.empresa,
          TRIM(COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, ''))::TEXT AS propietarionvo
        FROM comun.anuncios a
        INNER JOIN public.anun_detgrupo d ON d.anuncio = a.anuncio
        LEFT JOIN comun.licencias l ON l.id_licencia = a.licencia
        WHERE d.anun_grupos_id = p_grupo_id
          AND a.vigente = 'V'
          AND (p_actividad IS NULL OR a.descripcion ILIKE '%' || p_actividad || '%')
        ORDER BY a.anuncio, a.descripcion;
    END;
    \$\$ LANGUAGE plpgsql;
    ");
    echo "✓ OK\n\n";

    // 7. ADD_ANUNCIOS_TO_GRUPO
    echo "7/8 Creando add_anuncios_to_grupo...\n";
    DB::statement("
    CREATE OR REPLACE FUNCTION add_anuncios_to_grupo(p_grupo_id INTEGER, p_anuncios INTEGER[])
    RETURNS TABLE(success BOOLEAN, message TEXT, added_count INTEGER) AS \$\$
    DECLARE
      i INTEGER;
      cnt INTEGER := 0;
    BEGIN
      FOREACH i IN ARRAY p_anuncios LOOP
        INSERT INTO public.anun_detgrupo (anun_grupos_id, anuncio)
        VALUES (p_grupo_id, i)
        ON CONFLICT DO NOTHING;

        IF FOUND THEN
          cnt := cnt + 1;
        END IF;
      END LOOP;

      RETURN QUERY SELECT TRUE::BOOLEAN, cnt || ' anuncio(s) agregado(s) al grupo'::TEXT, cnt;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE::BOOLEAN, 'Error al agregar anuncios: ' || SQLERRM, 0;
    END;
    \$\$ LANGUAGE plpgsql;
    ");
    echo "✓ OK\n\n";

    // 8. REMOVE_ANUNCIOS_FROM_GRUPO
    echo "8/8 Creando remove_anuncios_from_grupo...\n";
    DB::statement("
    CREATE OR REPLACE FUNCTION remove_anuncios_from_grupo(p_grupo_id INTEGER, p_anuncios INTEGER[])
    RETURNS TABLE(success BOOLEAN, message TEXT, removed_count INTEGER) AS \$\$
    DECLARE
      cnt INTEGER;
    BEGIN
      DELETE FROM public.anun_detgrupo
      WHERE anun_grupos_id = p_grupo_id AND anuncio = ANY(p_anuncios);

      GET DIAGNOSTICS cnt = ROW_COUNT;

      IF cnt > 0 THEN
        RETURN QUERY SELECT TRUE::BOOLEAN, cnt || ' anuncio(s) quitado(s) del grupo'::TEXT, cnt;
      ELSE
        RETURN QUERY SELECT FALSE::BOOLEAN, 'No se encontraron anuncios para quitar'::TEXT, 0;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE::BOOLEAN, 'Error al quitar anuncios: ' || SQLERRM, 0;
    END;
    \$\$ LANGUAGE plpgsql;
    ");
    echo "✓ OK\n\n";

    echo "====================================\n";
    echo "✓ TODOS LOS SPs CREADOS (8/8)\n";
    echo "====================================\n\n";

    // Verificar
    echo "Verificando instalación...\n";
    $result = DB::select("SELECT * FROM get_grupos_anuncios(NULL) LIMIT 5");
    echo "✓ get_grupos_anuncios: " . count($result) . " grupos encontrados\n";

    if (count($result) > 0) {
        echo "\nPrimeros grupos:\n";
        foreach ($result as $grupo) {
            echo "  - ID: {$grupo->id}, Descripción: {$grupo->descripcion}\n";
        }
    }

    echo "\n====================================\n";
    echo "✓ ¡DESPLIEGUE EXITOSO!\n";
    echo "====================================\n\n";

    echo "SPs desplegados en esquema 'public':\n";
    echo "1. get_grupos_anuncios()\n";
    echo "2. insert_grupo_anuncio()\n";
    echo "3. update_grupo_anuncio()\n";
    echo "4. delete_grupo_anuncio()\n";
    echo "5. get_anuncios_disponibles()\n";
    echo "6. get_anuncios_grupo()\n";
    echo "7. add_anuncios_to_grupo()\n";
    echo "8. remove_anuncios_from_grupo()\n\n";

    echo "✓ El componente gruposAnunciosfrm.vue ya puede usarse\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
}

echo "</pre>";
