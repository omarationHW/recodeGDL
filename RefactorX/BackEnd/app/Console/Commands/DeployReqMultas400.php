<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class DeployReqMultas400 extends Command
{
    protected $signature = 'deploy:reqmultas400';
    protected $description = 'Despliega stored procedures de reqmultas400frm y obtiene ejemplos';

    public function handle()
    {
        $this->info('=== DESPLEGANDO STORED PROCEDURES REQMULTAS400FRM ===');
        $this->newLine();

        try {
            // 1. Buscar la tabla primero
            $this->info('1. Buscando tabla req_mul_400...');

            $schemas = ['catastro_gdl', 'comun', 'comunX', 'public', 'db_ingresos', 'multas_reglamentos'];
            $foundSchema = null;

            foreach ($schemas as $schema) {
                $exists = DB::select("
                    SELECT table_name
                    FROM information_schema.tables
                    WHERE table_schema = ? AND table_name = 'req_mul_400'
                ", [$schema]);

                if ($exists) {
                    $foundSchema = $schema;
                    $this->info("   ✓ Tabla encontrada en schema: $schema");
                    break;
                }
            }

            if (!$foundSchema) {
                $this->error('   ✗ Tabla req_mul_400 no encontrada');
                $this->info('   Buscando tablas alternativas...');

                $altTables = DB::select("
                    SELECT table_schema, table_name
                    FROM information_schema.tables
                    WHERE table_name ILIKE '%req%mul%'
                    LIMIT 10
                ");

                foreach ($altTables as $table) {
                    $this->line("      - {$table->table_schema}.{$table->table_name}");
                }

                return Command::FAILURE;
            }

            $this->newLine();

            // 2. Obtener ejemplos ANTES de crear los SPs
            $this->info('2. Obteniendo ejemplos de datos...');

            try {
                $examples = DB::select("SELECT * FROM {$foundSchema}.req_mul_400 ORDER BY axoreq DESC, folreq DESC LIMIT 3");

                if (count($examples) > 0) {
                    $this->info("   ✓ Encontrados " . count($examples) . " registros de ejemplo");
                    $this->newLine();

                    foreach ($examples as $i => $row) {
                        $this->line("   Ejemplo " . ($i + 1) . ":");
                        $rowArray = (array)$row;
                        foreach ($rowArray as $key => $value) {
                            $this->line("      $key: " . ($value ?? 'NULL'));
                        }
                        $this->newLine();
                    }
                } else {
                    $this->warn('   ⚠ No hay datos en la tabla');
                }

                // Contar total
                $count = DB::selectOne("SELECT COUNT(*) as total FROM {$foundSchema}.req_mul_400");
                $this->info("   Total de registros: " . $count->total);

            } catch (\Exception $e) {
                $this->error('   Error obteniendo ejemplos: ' . $e->getMessage());
            }

            $this->newLine();

            // 3. Crear SP 1: Búsqueda por acta
            $this->info('3. Creando req_mul_400_by_acta...');

            DB::statement("DROP FUNCTION IF EXISTS req_mul_400_by_acta(VARCHAR, INTEGER, INTEGER, INTEGER) CASCADE");

            $sql1 = "
            CREATE OR REPLACE FUNCTION req_mul_400_by_acta(
                p_dep VARCHAR,
                p_axo INTEGER,
                p_numacta INTEGER,
                p_tipo INTEGER
            )
            RETURNS TABLE (
                cvelet VARCHAR,
                cvenum INTEGER,
                ctarfc INTEGER,
                cveapl INTEGER,
                axoreq INTEGER,
                folreq INTEGER,
                nombre VARCHAR,
                domicilio VARCHAR,
                importe NUMERIC,
                fecha DATE
            ) AS \$\$
            BEGIN
                RETURN QUERY
                SELECT
                    r.cvelet,
                    r.cvenum,
                    r.ctarfc,
                    r.cveapl,
                    r.axoreq,
                    r.folreq,
                    r.nombre,
                    r.domicilio,
                    r.importe,
                    r.fecha
                FROM {$foundSchema}.req_mul_400 r
                WHERE SUBSTRING(r.cvelet FROM 4 FOR 3) = p_dep
                  AND r.cvenum = p_axo
                  AND r.ctarfc = p_numacta
                  AND r.cveapl = p_tipo
                ORDER BY r.axoreq DESC, r.folreq DESC;
            END;
            \$\$ LANGUAGE plpgsql;
            ";

            DB::statement($sql1);
            $this->info('   ✓ req_mul_400_by_acta creado');

            // 4. Crear SP 2: Búsqueda por folio
            $this->newLine();
            $this->info('4. Creando req_mul_400_by_folio...');

            DB::statement("DROP FUNCTION IF EXISTS req_mul_400_by_folio(INTEGER, INTEGER, INTEGER) CASCADE");

            $sql2 = "
            CREATE OR REPLACE FUNCTION req_mul_400_by_folio(
                p_axo INTEGER,
                p_folio INTEGER,
                p_tipo INTEGER
            )
            RETURNS TABLE (
                cvelet VARCHAR,
                cvenum INTEGER,
                ctarfc INTEGER,
                cveapl INTEGER,
                axoreq INTEGER,
                folreq INTEGER,
                nombre VARCHAR,
                domicilio VARCHAR,
                importe NUMERIC,
                fecha DATE
            ) AS \$\$
            BEGIN
                RETURN QUERY
                SELECT
                    r.cvelet,
                    r.cvenum,
                    r.ctarfc,
                    r.cveapl,
                    r.axoreq,
                    r.folreq,
                    r.nombre,
                    r.domicilio,
                    r.importe,
                    r.fecha
                FROM {$foundSchema}.req_mul_400 r
                WHERE r.axoreq = p_axo
                  AND r.folreq = p_folio
                  AND r.cveapl = p_tipo
                ORDER BY r.axoreq DESC, r.folreq DESC;
            END;
            \$\$ LANGUAGE plpgsql;
            ";

            DB::statement($sql2);
            $this->info('   ✓ req_mul_400_by_folio creado');

            // 5. Crear SP 3: Búsqueda general (principal)
            $this->newLine();
            $this->info('5. Creando recaudadora_reqmultas400frm...');

            DB::statement("DROP FUNCTION IF EXISTS recaudadora_reqmultas400frm(VARCHAR) CASCADE");

            $sql3 = "
            CREATE OR REPLACE FUNCTION recaudadora_reqmultas400frm(
                p_clave_cuenta VARCHAR DEFAULT NULL
            )
            RETURNS TABLE (
                cvelet VARCHAR,
                cvenum INTEGER,
                ctarfc INTEGER,
                cveapl INTEGER,
                axoreq INTEGER,
                folreq INTEGER,
                nombre VARCHAR,
                domicilio VARCHAR,
                importe NUMERIC,
                fecha DATE,
                tipo_multa VARCHAR
            ) AS \$\$
            BEGIN
                RETURN QUERY
                SELECT
                    r.cvelet,
                    r.cvenum,
                    r.ctarfc,
                    r.cveapl,
                    r.axoreq,
                    r.folreq,
                    r.nombre,
                    r.domicilio,
                    r.importe,
                    r.fecha,
                    CASE
                        WHEN r.cveapl = 6 THEN 'Federal'
                        WHEN r.cveapl = 5 THEN 'Municipal'
                        ELSE 'Otro'
                    END::VARCHAR as tipo_multa
                FROM {$foundSchema}.req_mul_400 r
                WHERE p_clave_cuenta IS NULL
                   OR r.cvelet ILIKE '%' || p_clave_cuenta || '%'
                   OR CAST(r.folreq AS VARCHAR) = p_clave_cuenta
                   OR CAST(r.axoreq AS VARCHAR) = p_clave_cuenta
                ORDER BY r.axoreq DESC, r.folreq DESC
                LIMIT 100;
            END;
            \$\$ LANGUAGE plpgsql;
            ";

            DB::statement($sql3);
            $this->info('   ✓ recaudadora_reqmultas400frm creado');

            // 6. Verificar que se crearon
            $this->newLine();
            $this->info('6. Verificando stored procedures...');

            $sps = DB::select("
                SELECT routine_name, routine_type
                FROM information_schema.routines
                WHERE routine_name IN (
                    'req_mul_400_by_acta',
                    'req_mul_400_by_folio',
                    'recaudadora_reqmultas400frm'
                )
                ORDER BY routine_name
            ");

            foreach ($sps as $sp) {
                $this->info("   ✓ {$sp->routine_name} ({$sp->routine_type})");
            }

            // 7. Probar el SP principal
            $this->newLine();
            $this->info('7. Probando recaudadora_reqmultas400frm...');

            try {
                $test = DB::select("SELECT * FROM recaudadora_reqmultas400frm(NULL) LIMIT 3");
                $this->info('   ✓ SP funciona correctamente');
                $this->info('   Retornó ' . count($test) . ' registros');
            } catch (\Exception $e) {
                $this->error('   ✗ Error probando SP: ' . $e->getMessage());
            }

            $this->newLine();
            $this->info('✅ DESPLIEGUE COMPLETADO EXITOSAMENTE');
            $this->newLine();
            $this->info('Puedes probar el formulario en: http://localhost:3000');

            return Command::SUCCESS;

        } catch (\Exception $e) {
            $this->error('❌ ERROR: ' . $e->getMessage());
            $this->error($e->getTraceAsString());
            return Command::FAILURE;
        }
    }
}
