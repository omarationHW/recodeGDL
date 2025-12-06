<?php
/**
 * COPIA DE TABLA: ta_11_cuo_locales
 * Origen: mercados.public.ta_11_cuo_locales
 * Destino: padron_licencias.comun.ta_11_cuo_locales
 */

// Conexión directa a PostgreSQL
$host = 'localhost';
$port = '5432';
$user = 'postgres';
$password = 'sistemas';

echo "========================================\n";
echo "COPIA DE TABLA: ta_11_cuo_locales\n";
echo "========================================\n\n";

echo "Origen:  mercados.public.ta_11_cuo_locales\n";
echo "Destino: padron_licencias.comun.ta_11_cuo_locales\n\n";

try {
    // Conectar a base origen (mercados)
    echo "1. Conectando a base ORIGEN (mercados)...\n";
    $dsn_origen = "pgsql:host=$host;port=$port;dbname=mercados";
    $pdo_origen = new PDO($dsn_origen, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);
    echo "   ✓ Conectado a mercados\n\n";

    // Conectar a base destino (padron_licencias)
    echo "2. Conectando a base DESTINO (padron_licencias)...\n";
    $dsn_destino = "pgsql:host=$host;port=$port;dbname=padron_licencias";
    $pdo_destino = new PDO($dsn_destino, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);
    echo "   ✓ Conectado a padron_licencias\n\n";

    // Verificar que la tabla origen existe
    echo "3. Verificando tabla origen...\n";
    $stmt = $pdo_origen->query("
        SELECT EXISTS (
            SELECT FROM information_schema.tables
            WHERE table_schema = 'public'
            AND table_name = 'ta_11_cuo_locales'
        )
    ");
    $existe_origen = $stmt->fetchColumn();

    if (!$existe_origen) {
        die("   ✗ ERROR: La tabla public.ta_11_cuo_locales NO EXISTE en mercados\n");
    }
    echo "   ✓ Tabla existe en mercados.public\n\n";

    // Obtener estructura de la tabla
    echo "4. Obteniendo estructura de la tabla...\n";
    $stmt = $pdo_origen->query("
        SELECT column_name, data_type, character_maximum_length, is_nullable, column_default
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'ta_11_cuo_locales'
        ORDER BY ordinal_position
    ");
    $columnas = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   ✓ Estructura obtenida: " . count($columnas) . " columnas\n\n";

    // Mostrar columnas
    echo "   Columnas encontradas:\n";
    foreach ($columnas as $col) {
        $tipo = $col['data_type'];
        if ($col['character_maximum_length']) {
            $tipo .= "({$col['character_maximum_length']})";
        }
        echo "   - {$col['column_name']}: $tipo\n";
    }
    echo "\n";

    // Contar registros en origen
    echo "5. Contando registros en origen...\n";
    $stmt = $pdo_origen->query("SELECT COUNT(*) FROM public.ta_11_cuo_locales");
    $total_registros = $stmt->fetchColumn();
    echo "   ✓ Total registros en origen: $total_registros\n\n";

    // Verificar si existe schema comun en destino
    echo "6. Verificando schema 'comun' en destino...\n";
    $stmt = $pdo_destino->query("
        SELECT EXISTS (
            SELECT FROM information_schema.schemata
            WHERE schema_name = 'comun'
        )
    ");
    $existe_schema = $stmt->fetchColumn();

    if (!$existe_schema) {
        echo "   ⚠ Schema 'comun' no existe, creándolo...\n";
        $pdo_destino->exec("CREATE SCHEMA comun");
        echo "   ✓ Schema 'comun' creado\n\n";
    } else {
        echo "   ✓ Schema 'comun' existe\n\n";
    }

    // Verificar si la tabla destino ya existe
    echo "7. Verificando tabla destino...\n";
    $stmt = $pdo_destino->query("
        SELECT EXISTS (
            SELECT FROM information_schema.tables
            WHERE table_schema = 'comun'
            AND table_name = 'ta_11_cuo_locales'
        )
    ");
    $existe_destino = $stmt->fetchColumn();

    if ($existe_destino) {
        echo "   ⚠ La tabla comun.ta_11_cuo_locales YA EXISTE en padron_licencias\n";
        echo "   ¿Desea eliminarla y recrearla? (esto eliminará todos los datos)\n";
        echo "   Escriba 'SI' para continuar o presione Enter para cancelar: ";
        $confirmacion = trim(fgets(STDIN));

        if (strtoupper($confirmacion) !== 'SI') {
            die("   Operación cancelada por el usuario\n");
        }

        echo "   Eliminando tabla existente...\n";
        $pdo_destino->exec("DROP TABLE IF EXISTS comun.ta_11_cuo_locales CASCADE");
        echo "   ✓ Tabla eliminada\n\n";
    } else {
        echo "   ✓ Tabla no existe en destino, se creará\n\n";
    }

    // Obtener DDL completo de la tabla
    echo "8. Obteniendo definición completa de la tabla...\n";

    // Construir CREATE TABLE
    $create_sql = "CREATE TABLE comun.ta_11_cuo_locales (\n";
    $columnas_def = [];

    foreach ($columnas as $col) {
        $col_def = "  " . $col['column_name'] . " ";

        // Mapear tipos de datos
        switch ($col['data_type']) {
            case 'character varying':
                $col_def .= "VARCHAR(" . $col['character_maximum_length'] . ")";
                break;
            case 'character':
                $col_def .= "CHAR(" . $col['character_maximum_length'] . ")";
                break;
            case 'integer':
                $col_def .= "INTEGER";
                break;
            case 'smallint':
                $col_def .= "SMALLINT";
                break;
            case 'bigint':
                $col_def .= "BIGINT";
                break;
            case 'numeric':
                $col_def .= "NUMERIC";
                break;
            case 'decimal':
                $col_def .= "DECIMAL";
                break;
            case 'real':
                $col_def .= "REAL";
                break;
            case 'double precision':
                $col_def .= "DOUBLE PRECISION";
                break;
            case 'date':
                $col_def .= "DATE";
                break;
            case 'timestamp without time zone':
                $col_def .= "TIMESTAMP";
                break;
            case 'timestamp with time zone':
                $col_def .= "TIMESTAMPTZ";
                break;
            case 'text':
                $col_def .= "TEXT";
                break;
            case 'boolean':
                $col_def .= "BOOLEAN";
                break;
            default:
                $col_def .= strtoupper($col['data_type']);
        }

        // NOT NULL
        if ($col['is_nullable'] === 'NO') {
            $col_def .= " NOT NULL";
        }

        // DEFAULT
        if ($col['column_default']) {
            $col_def .= " DEFAULT " . $col['column_default'];
        }

        $columnas_def[] = $col_def;
    }

    $create_sql .= implode(",\n", $columnas_def);
    $create_sql .= "\n)";

    echo "   ✓ DDL generado\n\n";

    // Crear tabla en destino
    echo "9. Creando tabla en destino...\n";
    $pdo_destino->exec($create_sql);
    echo "   ✓ Tabla comun.ta_11_cuo_locales creada en padron_licencias\n\n";

    // Copiar datos
    if ($total_registros > 0) {
        echo "10. Copiando datos ($total_registros registros)...\n";

        // Obtener nombres de columnas
        $nombres_columnas = array_column($columnas, 'column_name');
        $cols_str = implode(', ', $nombres_columnas);

        // Obtener todos los datos
        $stmt = $pdo_origen->query("SELECT * FROM public.ta_11_cuo_locales");
        $datos = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Preparar INSERT
        $placeholders = implode(', ', array_fill(0, count($nombres_columnas), '?'));
        $insert_sql = "INSERT INTO comun.ta_11_cuo_locales ($cols_str) VALUES ($placeholders)";
        $stmt_insert = $pdo_destino->prepare($insert_sql);

        // Iniciar transacción
        $pdo_destino->beginTransaction();

        $insertados = 0;
        foreach ($datos as $fila) {
            $valores = array_values($fila);
            $stmt_insert->execute($valores);
            $insertados++;

            if ($insertados % 100 == 0) {
                echo "   Progreso: $insertados / $total_registros\r";
            }
        }

        $pdo_destino->commit();
        echo "   ✓ Datos copiados: $insertados registros\n\n";
    } else {
        echo "10. No hay datos para copiar\n\n";
    }

    // Verificar copia
    echo "11. Verificando copia...\n";
    $stmt = $pdo_destino->query("SELECT COUNT(*) FROM comun.ta_11_cuo_locales");
    $total_destino = $stmt->fetchColumn();
    echo "   Registros en destino: $total_destino\n";

    if ($total_destino == $total_registros) {
        echo "   ✓ Verificación exitosa: todos los registros copiados\n\n";
    } else {
        echo "   ⚠ ADVERTENCIA: Diferencia en registros (origen: $total_registros, destino: $total_destino)\n\n";
    }

    // Copiar índices y constraints
    echo "12. Verificando índices y constraints en origen...\n";
    $stmt = $pdo_origen->query("
        SELECT indexname, indexdef
        FROM pg_indexes
        WHERE schemaname = 'public' AND tablename = 'ta_11_cuo_locales'
    ");
    $indices = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($indices) > 0) {
        echo "   Se encontraron " . count($indices) . " índices\n";
        foreach ($indices as $idx) {
            // Adaptar el indexdef para el nuevo schema
            $nuevo_indexdef = str_replace('public.ta_11_cuo_locales', 'comun.ta_11_cuo_locales', $idx['indexdef']);
            $nuevo_indexdef = str_replace('public.' . $idx['indexname'], 'comun.' . $idx['indexname'], $nuevo_indexdef);

            try {
                $pdo_destino->exec($nuevo_indexdef);
                echo "   ✓ Índice creado: {$idx['indexname']}\n";
            } catch (PDOException $e) {
                echo "   ⚠ No se pudo crear índice {$idx['indexname']}: " . $e->getMessage() . "\n";
            }
        }
    } else {
        echo "   ℹ No se encontraron índices\n";
    }

    echo "\n========================================\n";
    echo "COPIA COMPLETADA EXITOSAMENTE\n";
    echo "========================================\n";
    echo "Origen:  mercados.public.ta_11_cuo_locales\n";
    echo "Destino: padron_licencias.comun.ta_11_cuo_locales\n";
    echo "Registros copiados: $total_destino\n";
    echo "========================================\n";

} catch (PDOException $e) {
    echo "\n❌ ERROR: " . $e->getMessage() . "\n";
    if (isset($pdo_destino) && $pdo_destino->inTransaction()) {
        $pdo_destino->rollBack();
        echo "   Transacción revertida\n";
    }
}
