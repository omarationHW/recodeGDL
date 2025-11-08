<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "VERIFICAR Y CREAR: SPs Registro Solicitud\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa a {$database}\n\n";

    // Paso 1: Verificar si las tablas existen
    echo "PASO 1: Verificando tablas requeridas\n";
    echo "========================================\n";

    $tablasRequeridas = [
        'comun.tramites',
        'comun.tramite_documentos'
    ];

    $tablasExisten = true;

    foreach ($tablasRequeridas as $tabla) {
        list($schema, $tableName) = explode('.', $tabla);

        $stmt = $pdo->prepare("
            SELECT EXISTS (
                SELECT FROM information_schema.tables
                WHERE table_schema = ?
                AND table_name = ?
            )
        ");
        $stmt->execute([$schema, $tableName]);
        $existe = $stmt->fetchColumn();

        if ($existe) {
            echo "  ✅ {$tabla}: EXISTE\n";
        } else {
            echo "  ❌ {$tabla}: NO EXISTE\n";
            $tablasExisten = false;
        }
    }

    echo "\n";

    // Paso 2: Verificar SPs actuales
    echo "PASO 2: Verificando SPs actuales\n";
    echo "========================================\n";

    $spsRequeridos = [
        'sp_registro_solicitud',
        'sp_agregar_documento'
    ];

    foreach ($spsRequeridos as $sp) {
        $stmt = $pdo->prepare("
            SELECT
                n.nspname as schema,
                p.proname as name,
                pg_get_function_arguments(p.oid) as arguments
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE n.nspname = 'comun' AND p.proname = ?
        ");
        $stmt->execute([$sp]);
        $spInfo = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($spInfo) {
            echo "  ℹ️  {$sp}: YA EXISTE\n";
            echo "      Schema: {$spInfo['schema']}\n";
            echo "      Argumentos: " . substr($spInfo['arguments'], 0, 100) . "...\n";
        } else {
            echo "  ❌ {$sp}: NO EXISTE\n";
        }
    }

    echo "\n";

    // Paso 3: Informar sobre las tablas
    if (!$tablasExisten) {
        echo "⚠️  ADVERTENCIA: Las tablas requeridas NO existen.\n";
        echo "No se pueden crear los SPs sin las tablas.\n\n";
        echo "Para crear las tablas, ejecuta el siguiente SQL:\n";
        echo "========================================\n";
        echo "\n";
        echo "-- Tabla de trámites\n";
        echo "CREATE TABLE comun.tramites (\n";
        echo "    id SERIAL PRIMARY KEY,\n";
        echo "    folio VARCHAR(50) UNIQUE NOT NULL,\n";
        echo "    tipo_tramite INTEGER NOT NULL,\n";
        echo "    id_giro INTEGER NOT NULL,\n";
        echo "    actividad VARCHAR(255) NOT NULL,\n";
        echo "    propietario VARCHAR(255) NOT NULL,\n";
        echo "    telefono VARCHAR(20) NOT NULL,\n";
        echo "    email VARCHAR(100),\n";
        echo "    calle VARCHAR(255) NOT NULL,\n";
        echo "    colonia VARCHAR(255) NOT NULL,\n";
        echo "    cp VARCHAR(10),\n";
        echo "    numext VARCHAR(20),\n";
        echo "    numint VARCHAR(20),\n";
        echo "    letraext VARCHAR(5),\n";
        echo "    letraint VARCHAR(5),\n";
        echo "    zona INTEGER,\n";
        echo "    subzona INTEGER,\n";
        echo "    sup_const NUMERIC(10,2),\n";
        echo "    sup_autorizada NUMERIC(10,2),\n";
        echo "    num_cajones INTEGER,\n";
        echo "    num_empleados INTEGER,\n";
        echo "    inversion NUMERIC(15,2),\n";
        echo "    rfc VARCHAR(20),\n";
        echo "    curp VARCHAR(20),\n";
        echo "    especificaciones TEXT,\n";
        echo "    estatus VARCHAR(50) DEFAULT 'REGISTRADO',\n";
        echo "    fecha_registro TIMESTAMP DEFAULT NOW(),\n";
        echo "    usuario_registro VARCHAR(50)\n";
        echo ");\n\n";
        echo "-- Tabla de documentos\n";
        echo "CREATE TABLE comun.tramite_documentos (\n";
        echo "    id SERIAL PRIMARY KEY,\n";
        echo "    id_tramite INTEGER NOT NULL REFERENCES comun.tramites(id),\n";
        echo "    tipo_documento VARCHAR(100) NOT NULL,\n";
        echo "    nombre_archivo VARCHAR(255) NOT NULL,\n";
        echo "    ruta_archivo VARCHAR(500) NOT NULL,\n";
        echo "    observaciones TEXT,\n";
        echo "    fecha_carga TIMESTAMP DEFAULT NOW(),\n";
        echo "    usuario_carga VARCHAR(50)\n";
        echo ");\n\n";
        echo "========================================\n\n";

        echo "¿Deseas que el script cree las tablas automáticamente? (SI/NO): ";
        $respuesta = trim(fgets(STDIN));

        if (strtoupper($respuesta) === 'SI') {
            echo "\nCreando tablas...\n";

            // Crear tabla tramites
            $pdo->exec("
                CREATE TABLE IF NOT EXISTS comun.tramites (
                    id SERIAL PRIMARY KEY,
                    folio VARCHAR(50) UNIQUE NOT NULL,
                    tipo_tramite INTEGER NOT NULL,
                    id_giro INTEGER NOT NULL,
                    actividad VARCHAR(255) NOT NULL,
                    propietario VARCHAR(255) NOT NULL,
                    telefono VARCHAR(20) NOT NULL,
                    email VARCHAR(100),
                    calle VARCHAR(255) NOT NULL,
                    colonia VARCHAR(255) NOT NULL,
                    cp VARCHAR(10),
                    numext VARCHAR(20),
                    numint VARCHAR(20),
                    letraext VARCHAR(5),
                    letraint VARCHAR(5),
                    zona INTEGER,
                    subzona INTEGER,
                    sup_const NUMERIC(10,2),
                    sup_autorizada NUMERIC(10,2),
                    num_cajones INTEGER,
                    num_empleados INTEGER,
                    inversion NUMERIC(15,2),
                    rfc VARCHAR(20),
                    curp VARCHAR(20),
                    especificaciones TEXT,
                    estatus VARCHAR(50) DEFAULT 'REGISTRADO',
                    fecha_registro TIMESTAMP DEFAULT NOW(),
                    usuario_registro VARCHAR(50)
                )
            ");
            echo "  ✅ Tabla comun.tramites creada\n";

            // Crear tabla tramite_documentos
            $pdo->exec("
                CREATE TABLE IF NOT EXISTS comun.tramite_documentos (
                    id SERIAL PRIMARY KEY,
                    id_tramite INTEGER NOT NULL REFERENCES comun.tramites(id),
                    tipo_documento VARCHAR(100) NOT NULL,
                    nombre_archivo VARCHAR(255) NOT NULL,
                    ruta_archivo VARCHAR(500) NOT NULL,
                    observaciones TEXT,
                    fecha_carga TIMESTAMP DEFAULT NOW(),
                    usuario_carga VARCHAR(50)
                )
            ");
            echo "  ✅ Tabla comun.tramite_documentos creada\n";

            // Crear índices
            $pdo->exec("CREATE INDEX IF NOT EXISTS idx_tramites_folio ON comun.tramites(folio)");
            $pdo->exec("CREATE INDEX IF NOT EXISTS idx_tramites_estatus ON comun.tramites(estatus)");
            $pdo->exec("CREATE INDEX IF NOT EXISTS idx_tramites_fecha ON comun.tramites(fecha_registro)");
            $pdo->exec("CREATE INDEX IF NOT EXISTS idx_tramites_propietario ON comun.tramites(propietario)");
            $pdo->exec("CREATE INDEX IF NOT EXISTS idx_tramite_docs_tramite ON comun.tramite_documentos(id_tramite)");
            echo "  ✅ Índices creados\n\n";

            $tablasExisten = true;
        } else {
            echo "\nSaliendo sin crear tablas.\n";
            exit(0);
        }
    }

    // Paso 4: Crear SPs si las tablas existen
    if ($tablasExisten) {
        echo "PASO 3: Creando/Actualizando SPs\n";
        echo "========================================\n";

        // Leer el archivo SQL
        $sqlFile = __DIR__ . '/crear_sp_registro_solicitud.sql';
        if (!file_exists($sqlFile)) {
            throw new Exception("No se encontró el archivo SQL: {$sqlFile}");
        }

        $sql = file_get_contents($sqlFile);

        // Ejecutar el SQL
        $pdo->exec($sql);

        echo "  ✅ SPs creados/actualizados exitosamente\n\n";

        // Verificar nuevamente
        echo "PASO 4: Verificación final\n";
        echo "========================================\n";

        foreach ($spsRequeridos as $sp) {
            $stmt = $pdo->prepare("
                SELECT
                    n.nspname as schema,
                    p.proname as name
                FROM pg_proc p
                JOIN pg_namespace n ON p.pronamespace = n.oid
                WHERE n.nspname = 'comun' AND p.proname = ?
            ");
            $stmt->execute([$sp]);
            $spInfo = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($spInfo) {
                echo "  ✅ {$sp}: CREADO en comun\n";
            } else {
                echo "  ❌ {$sp}: ERROR al crear\n";
            }
        }

        echo "\n========================================\n";
        echo "✅ Proceso completado exitosamente\n";
        echo "========================================\n";
    }

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
