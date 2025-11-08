<?php
/**
 * Script para ejecutar los Stored Procedures de bloqueoRFCfrm
 * Fecha: 2025-11-06
 */

// Configuración de conexión
$host = 'localhost';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'postgres';
$password = 'postgres';

try {
    // Conectar a PostgreSQL
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "✓ Conexión exitosa a la base de datos\n\n";

    // 1. Verificar si existe la tabla bloqueo_rfc_lic
    echo "1. Verificando tabla bloqueo_rfc_lic...\n";
    $stmt = $pdo->query("
        SELECT EXISTS (
            SELECT FROM information_schema.tables
            WHERE table_schema = 'comun'
            AND table_name = 'bloqueo_rfc_lic'
        )
    ");
    $exists = $stmt->fetchColumn();

    if (!$exists) {
        echo "   ⚠ Tabla no existe en esquema 'comun', verificando en 'public'...\n";

        $stmt = $pdo->query("
            SELECT EXISTS (
                SELECT FROM information_schema.tables
                WHERE table_schema = 'public'
                AND table_name = 'bloqueo_rfc_lic'
            )
        ");
        $existsPublic = $stmt->fetchColumn();

        if (!$existsPublic) {
            echo "   ✗ Tabla no existe. Creando en esquema 'comun'...\n";

            // Crear esquema comun si no existe
            $pdo->exec("CREATE SCHEMA IF NOT EXISTS comun");

            // Crear tabla
            $pdo->exec("
                CREATE TABLE comun.bloqueo_rfc_lic (
                    rfc VARCHAR(13) NOT NULL,
                    id_tramite INTEGER,
                    licencia INTEGER,
                    hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    vig CHAR(1) DEFAULT 'V',
                    observacion VARCHAR(255),
                    capturista VARCHAR(10),
                    PRIMARY KEY (rfc, hora)
                )
            ");

            echo "   ✓ Tabla creada exitosamente\n";
        } else {
            echo "   ✓ Tabla existe en esquema 'public'\n";
        }
    } else {
        echo "   ✓ Tabla existe en esquema 'comun'\n";
    }

    // 2. Leer y ejecutar los SPs
    echo "\n2. Ejecutando Stored Procedures...\n";
    $sqlFile = __DIR__ . '/DEPLOY_BLOQUEORFC_SPS.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("No se encuentra el archivo: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    // Limpiar comentarios que puedan causar problemas
    $sql = preg_replace('/^--.*$/m', '', $sql);

    // Ejecutar todo el script
    $pdo->exec($sql);
    echo "   ✓ Stored Procedures ejecutados exitosamente\n";

    // 3. Verificar que los SPs se crearon
    echo "\n3. Verificando Stored Procedures creados:\n";
    $stmt = $pdo->query("
        SELECT proname, pg_get_function_identity_arguments(oid) as args
        FROM pg_proc
        WHERE proname LIKE 'sp_bloqueorfc%'
        ORDER BY proname
    ");

    $procedures = $stmt->fetchAll();

    if (count($procedures) === 0) {
        echo "   ⚠ No se encontraron los SPs creados\n";
    } else {
        foreach ($procedures as $proc) {
            echo "   ✓ {$proc['proname']}({$proc['args']})\n";
        }
    }

    // 4. Probar el SP de listado
    echo "\n4. Probando sp_bloqueorfc_list...\n";
    $stmt = $pdo->query("SELECT * FROM sp_bloqueorfc_list(1, 10, NULL, NULL)");
    $results = $stmt->fetchAll();
    echo "   ✓ SP ejecutado. Registros encontrados: " . count($results) . "\n";

    if (count($results) > 0) {
        echo "   Primer registro: RFC={$results[0]['rfc']}, Vigencia={$results[0]['vig']}\n";
    }

    echo "\n✓✓✓ PROCESO COMPLETADO EXITOSAMENTE ✓✓✓\n";
    echo "\nSPs disponibles para el componente bloqueoRFCfrm.vue:\n";
    echo "  - sp_bloqueorfc_list(page, page_size, rfc, tipo_bloqueo)\n";
    echo "  - sp_bloqueorfc_buscar_tramite(id_tramite)\n";
    echo "  - sp_bloqueorfc_create(rfc, id_tramite, licencia, observacion, usuario)\n";
    echo "  - sp_bloqueorfc_desbloquear(rfc, motivo, usuario)\n";

} catch (PDOException $e) {
    echo "\n✗ Error de base de datos: " . $e->getMessage() . "\n";
    echo "Código: " . $e->getCode() . "\n";
    exit(1);
} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
