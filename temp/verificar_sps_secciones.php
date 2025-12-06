<?php
/**
 * Script para verificar y crear SPs de Secciones
 */

$host = "192.168.6.146";
$port = "5432";
$dbname = "mercados";
$user = "refact";
$password = "FF)-BQk2";

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "\n=== VERIFICACIÓN Y CREACIÓN DE SPs DE SECCIONES ===\n\n";

    // 1. Probar sp_secciones_list()
    echo "1. Probando sp_secciones_list()...\n";
    echo str_repeat("-", 80) . "\n";

    try {
        $stmt = $pdo->query("SELECT * FROM sp_secciones_list()");
        $secciones = $stmt->fetchAll();

        if (count($secciones) > 0) {
            echo "✅ SP existe y funciona. Retornó " . count($secciones) . " secciones:\n";
            foreach ($secciones as $s) {
                echo "  - {$s['seccion']}: {$s['descripcion']}\n";
            }
            echo "\n";
        } else {
            echo "⚠️  SP funciona pero no retornó datos\n\n";
        }
    } catch (Exception $e) {
        echo "❌ Error: " . $e->getMessage() . "\n";
        echo "Necesita crearse\n\n";
    }

    // 2. Crear/Reemplazar sp_secciones_list
    echo "2. Creando sp_secciones_list()...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
    DROP FUNCTION IF EXISTS sp_secciones_list();

    CREATE OR REPLACE FUNCTION sp_secciones_list()
    RETURNS TABLE(
        seccion CHAR(2),
        descripcion VARCHAR(50),
        cantidad_locales BIGINT
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            s.seccion::CHAR(2),
            s.descripcion::VARCHAR(50),
            COALESCE(COUNT(l.id_local), 0)::BIGINT as cantidad_locales
        FROM publico.ta_11_secciones s
        LEFT JOIN publico.ta_11_locales l ON l.seccion = s.seccion
        GROUP BY s.seccion, s.descripcion
        ORDER BY s.seccion;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    $pdo->exec($sql);
    echo "✅ sp_secciones_list creado/actualizado\n\n";

    // 3. Crear sp_secciones_get
    echo "3. Creando sp_secciones_get()...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
    DROP FUNCTION IF EXISTS sp_secciones_get(CHAR(2));

    CREATE OR REPLACE FUNCTION sp_secciones_get(p_seccion CHAR(2))
    RETURNS TABLE(
        seccion CHAR(2),
        descripcion VARCHAR(50),
        cantidad_locales BIGINT
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            s.seccion::CHAR(2),
            s.descripcion::VARCHAR(50),
            COALESCE(COUNT(l.id_local), 0)::BIGINT as cantidad_locales
        FROM publico.ta_11_secciones s
        LEFT JOIN publico.ta_11_locales l ON l.seccion = s.seccion
        WHERE s.seccion = p_seccion
        GROUP BY s.seccion, s.descripcion;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    $pdo->exec($sql);
    echo "✅ sp_secciones_get creado\n\n";

    // 4. Crear sp_secciones_create
    echo "4. Creando sp_secciones_create()...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
    DROP FUNCTION IF EXISTS sp_secciones_create(CHAR(2), VARCHAR(50));

    CREATE OR REPLACE FUNCTION sp_secciones_create(
        p_seccion CHAR(2),
        p_descripcion VARCHAR(50)
    )
    RETURNS TABLE(
        success BOOLEAN,
        message TEXT
    ) AS \$\$
    BEGIN
        -- Verificar si ya existe
        IF EXISTS (SELECT 1 FROM publico.ta_11_secciones WHERE seccion = p_seccion) THEN
            RETURN QUERY SELECT FALSE, 'La sección ya existe'::TEXT;
            RETURN;
        END IF;

        -- Insertar
        INSERT INTO publico.ta_11_secciones (seccion, descripcion)
        VALUES (p_seccion, p_descripcion);

        RETURN QUERY SELECT TRUE, 'Sección creada correctamente'::TEXT;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT FALSE, SQLERRM::TEXT;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    $pdo->exec($sql);
    echo "✅ sp_secciones_create creado\n\n";

    // 5. Crear sp_secciones_update
    echo "5. Creando sp_secciones_update()...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
    DROP FUNCTION IF EXISTS sp_secciones_update(CHAR(2), VARCHAR(50));

    CREATE OR REPLACE FUNCTION sp_secciones_update(
        p_seccion CHAR(2),
        p_descripcion VARCHAR(50)
    )
    RETURNS TABLE(
        success BOOLEAN,
        message TEXT
    ) AS \$\$
    BEGIN
        -- Verificar si existe
        IF NOT EXISTS (SELECT 1 FROM publico.ta_11_secciones WHERE seccion = p_seccion) THEN
            RETURN QUERY SELECT FALSE, 'La sección no existe'::TEXT;
            RETURN;
        END IF;

        -- Actualizar
        UPDATE publico.ta_11_secciones
        SET descripcion = p_descripcion
        WHERE seccion = p_seccion;

        RETURN QUERY SELECT TRUE, 'Sección actualizada correctamente'::TEXT;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT FALSE, SQLERRM::TEXT;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    $pdo->exec($sql);
    echo "✅ sp_secciones_update creado\n\n";

    // 6. Crear sp_secciones_delete
    echo "6. Creando sp_secciones_delete()...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
    DROP FUNCTION IF EXISTS sp_secciones_delete(CHAR(2));

    CREATE OR REPLACE FUNCTION sp_secciones_delete(p_seccion CHAR(2))
    RETURNS TABLE(
        success BOOLEAN,
        message TEXT
    ) AS \$\$
    DECLARE
        v_count INTEGER;
    BEGIN
        -- Verificar si existe
        IF NOT EXISTS (SELECT 1 FROM publico.ta_11_secciones WHERE seccion = p_seccion) THEN
            RETURN QUERY SELECT FALSE, 'La sección no existe'::TEXT;
            RETURN;
        END IF;

        -- Verificar si tiene locales asociados
        SELECT COUNT(*) INTO v_count
        FROM publico.ta_11_locales
        WHERE seccion = p_seccion;

        IF v_count > 0 THEN
            RETURN QUERY SELECT FALSE, ('No se puede eliminar. Hay ' || v_count || ' locales asociados')::TEXT;
            RETURN;
        END IF;

        -- Eliminar
        DELETE FROM publico.ta_11_secciones WHERE seccion = p_seccion;

        RETURN QUERY SELECT TRUE, 'Sección eliminada correctamente'::TEXT;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT FALSE, SQLERRM::TEXT;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    $pdo->exec($sql);
    echo "✅ sp_secciones_delete creado\n\n";

    // 7. Verificar todos los SPs
    echo "7. Verificando SPs creados...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
        SELECT
            proname as nombre_sp,
            pg_get_function_arguments(oid) as argumentos
        FROM pg_proc
        WHERE proname LIKE 'sp_secciones_%'
        ORDER BY proname
    ";

    $stmt = $pdo->query($sql);
    $sps = $stmt->fetchAll();

    foreach ($sps as $sp) {
        echo "✅ {$sp['nombre_sp']}({$sp['argumentos']})\n";
    }
    echo "\n";

    // 8. Probar sp_secciones_list
    echo "8. Probando sp_secciones_list()...\n";
    echo str_repeat("-", 80) . "\n";

    $stmt = $pdo->query("SELECT * FROM sp_secciones_list()");
    $resultados = $stmt->fetchAll();

    if (count($resultados) > 0) {
        echo "✅ SP funciona. Retornó " . count($resultados) . " secciones:\n\n";
        echo sprintf("%-10s %-40s %15s\n", "Sección", "Descripción", "Cant. Locales");
        echo str_repeat("-", 80) . "\n";
        foreach ($resultados as $r) {
            echo sprintf(
                "%-10s %-40s %15s\n",
                $r['seccion'],
                $r['descripcion'],
                number_format($r['cantidad_locales'])
            );
        }
    } else {
        echo "⚠️  No se encontraron secciones\n";
    }

    echo "\n" . str_repeat("=", 80) . "\n";
    echo "✅ PROCESO COMPLETADO\n\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
