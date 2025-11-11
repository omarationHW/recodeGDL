-- ================================================================
-- DEPLOYMENT SCRIPT: otras_obligaciones
-- SPs Faltantes: 29
-- Fecha: 2025-11-11
-- ================================================================
--
-- INSTRUCCIONES:
-- 1. Revisar cada SP generado en: ../generated/
-- 2. Implementar la lógica específica de cada SP
-- 3. Ejecutar este script en la base de datos: otras_obligaciones
-- 4. Verificar que todos los SPs se crearon correctamente
--
-- ================================================================

\echo ''
\echo '=================================================='
\echo 'DEPLOYMENT: otras_obligaciones - 29 SPs'
\echo '=================================================='
\echo ''

-- Establecer schema
SET search_path TO public;


-- [1/29] sp_gactualiza_multas_update - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_gactualiza_multas_update...'
\i ../generated/sp_gactualiza_multas_update.sql
\echo '   ✓ OK'

-- [2/29] sp_gactualiza_suspension_create - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_gactualiza_suspension_create...'
\i ../generated/sp_gactualiza_suspension_create.sql
\echo '   ✓ OK'

-- [3/29] sp_rubros_listar - 2 usos (🟡 MEDIA)
\echo 'Creando: sp_rubros_listar...'
\i ../generated/sp_rubros_listar.sql
\echo '   ✓ OK'

-- [4/29] sp_gactualiza_dependencias_get - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gactualiza_dependencias_get...'
\i ../generated/sp_gactualiza_dependencias_get.sql
\echo '   ✓ OK'

-- [5/29] sp_gactualiza_datos_get - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gactualiza_datos_get...'
\i ../generated/sp_gactualiza_datos_get.sql
\echo '   ✓ OK'

-- [6/29] sp_gactualiza_multas_get - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gactualiza_multas_get...'
\i ../generated/sp_gactualiza_multas_get.sql
\echo '   ✓ OK'

-- [7/29] sp_gactualiza_suspension_get - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gactualiza_suspension_get...'
\i ../generated/sp_gactualiza_suspension_get.sql
\echo '   ✓ OK'

-- [8/29] sp_gadeudos_datos_get - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gadeudos_datos_get...'
\i ../generated/sp_gadeudos_datos_get.sql
\echo '   ✓ OK'

-- [9/29] sp_gadeudos_detalle_01 - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gadeudos_detalle_01...'
\i ../generated/sp_gadeudos_detalle_01.sql
\echo '   ✓ OK'

-- [10/29] sp_gadeudos_detalle_02 - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gadeudos_detalle_02...'
\i ../generated/sp_gadeudos_detalle_02.sql
\echo '   ✓ OK'

-- [11/29] sp_gadeudosgral_tablas_get - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gadeudosgral_tablas_get...'
\i ../generated/sp_gadeudosgral_tablas_get.sql
\echo '   ✓ OK'

-- [12/29] sp_gadeudosgral_etiquetas_get - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gadeudosgral_etiquetas_get...'
\i ../generated/sp_gadeudosgral_etiquetas_get.sql
\echo '   ✓ OK'

-- [13/29] spcon34_gcont_01 - 1 usos (⚪ BAJA)
\echo 'Creando: spcon34_gcont_01...'
\i ../generated/spcon34_gcont_01.sql
\echo '   ✓ OK'

-- [14/29] sp_gadeudos_opc_mult_recaudadoras_get - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gadeudos_opc_mult_recaudadoras_get...'
\i ../generated/sp_gadeudos_opc_mult_recaudadoras_get.sql
\echo '   ✓ OK'

-- [15/29] sp_gadeudos_opcmult_ra_tablas_get - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gadeudos_opcmult_ra_tablas_get...'
\i ../generated/sp_gadeudos_opcmult_ra_tablas_get.sql
\echo '   ✓ OK'

-- [16/29] sp_gadeudos_opcmult_ra_etiquetas_get - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gadeudos_opcmult_ra_etiquetas_get...'
\i ../generated/sp_gadeudos_opcmult_ra_etiquetas_get.sql
\echo '   ✓ OK'

-- [17/29] sp_gadeudos_opcmult_ra_datos_get - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gadeudos_opcmult_ra_datos_get...'
\i ../generated/sp_gadeudos_opcmult_ra_datos_get.sql
\echo '   ✓ OK'

-- [18/29] sp_gadeudos_opcmult_ra_reactivar - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gadeudos_opcmult_ra_reactivar...'
\i ../generated/sp_gadeudos_opcmult_ra_reactivar.sql
\echo '   ✓ OK'

-- [19/29] sp_gbaja_datos_get - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gbaja_datos_get...'
\i ../generated/sp_gbaja_datos_get.sql
\echo '   ✓ OK'

-- [20/29] sp_gbaja_adeudos_detalle - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gbaja_adeudos_detalle...'
\i ../generated/sp_gbaja_adeudos_detalle.sql
\echo '   ✓ OK'

-- [21/29] sp_gbaja_adeudos_totales - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gbaja_adeudos_totales...'
\i ../generated/sp_gbaja_adeudos_totales.sql
\echo '   ✓ OK'

-- [22/29] sp_gbaja_pagos_get - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gbaja_pagos_get...'
\i ../generated/sp_gbaja_pagos_get.sql
\echo '   ✓ OK'

-- [23/29] sp_gbaja_aplicar - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gbaja_aplicar...'
\i ../generated/sp_gbaja_aplicar.sql
\echo '   ✓ OK'

-- [24/29] sp_gconsulta_datos_get - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gconsulta_datos_get...'
\i ../generated/sp_gconsulta_datos_get.sql
\echo '   ✓ OK'

-- [25/29] sp_gconsulta_adeudos_get - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gconsulta_adeudos_get...'
\i ../generated/sp_gconsulta_adeudos_get.sql
\echo '   ✓ OK'

-- [26/29] sp_gconsulta_pagados_get - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gconsulta_pagados_get...'
\i ../generated/sp_gconsulta_pagados_get.sql
\echo '   ✓ OK'

-- [27/29] sp_gfacturacion_datos_get - 1 usos (⚪ BAJA)
\echo 'Creando: sp_gfacturacion_datos_get...'
\i ../generated/sp_gfacturacion_datos_get.sql
\echo '   ✓ OK'

-- [28/29] con34_1datos_03 - 1 usos (⚪ BAJA)
\echo 'Creando: con34_1datos_03...'
\i ../generated/con34_1datos_03.sql
\echo '   ✓ OK'

-- [29/29] sp_rfacturacion_obtener - 1 usos (⚪ BAJA)
\echo 'Creando: sp_rfacturacion_obtener...'
\i ../generated/sp_rfacturacion_obtener.sql
\echo '   ✓ OK'

\echo ''
\echo '=================================================='
\echo 'DEPLOYMENT COMPLETADO: 29 SPs creados'
\echo '=================================================='
\echo ''
