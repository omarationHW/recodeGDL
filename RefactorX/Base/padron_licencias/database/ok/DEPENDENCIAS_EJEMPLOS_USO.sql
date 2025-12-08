-- ============================================
-- EJEMPLOS DE USO - COMPONENTE DEPENDENCIAS
-- Módulo: padron_licencias
-- Fecha: 2025-11-20
-- ============================================
-- IMPORTANTE: Estos son ejemplos ilustrativos
--            Ajustar valores según datos reales
-- ============================================

\c padron_licencias;
SET search_path TO public;

-- ============================================
-- EJEMPLO 1: Obtener catálogo de dependencias
-- ============================================

-- Listar todas las dependencias activas disponibles para licencias
SELECT * FROM public.sp_get_dependencias();

-- Resultado esperado:
-- id_dependencia | descripcion
-- ---------------+----------------------------------
--      1         | Protección Civil
--      2         | Medio Ambiente
--      3         | Desarrollo Urbano
-- ...

-- ============================================
-- EJEMPLO 2: Consultar inspecciones de un trámite
-- ============================================

-- Ver qué inspecciones tiene asignadas el trámite 1001
SELECT * FROM public.sp_get_tramite_inspecciones(1001);

-- Resultado esperado:
-- id_revision | id_dependencia | descripcion
-- ------------+----------------+------------------
--    501      |      1         | Protección Civil
--    502      |      3         | Desarrollo Urbano

-- ============================================
-- EJEMPLO 3: Agregar una nueva inspección
-- ============================================

-- Agregar inspección de "Medio Ambiente" (id=2) al trámite 1001
SELECT * FROM public.sp_add_inspeccion(
    1001,              -- p_id_tramite
    2,                 -- p_id_dependencia
    'jperez'           -- p_usuario
);

-- Resultado esperado:
-- success | message                              | id_revision
-- --------+--------------------------------------+------------
--  true   | Inspección agregada exitosamente     |    503

-- ============================================
-- EJEMPLO 4: Intentar agregar inspección duplicada
-- ============================================

-- Intentar agregar nuevamente la misma inspección
SELECT * FROM public.sp_add_inspeccion(
    1001,
    2,
    'jperez'
);

-- Resultado esperado (error controlado):
-- success | message                                              | id_revision
-- --------+------------------------------------------------------+------------
--  false  | Ya existe una inspección vigente de esta dep...     |    NULL

-- ============================================
-- EJEMPLO 5: Obtener información del trámite
-- ============================================

-- Ver datos básicos del trámite para contexto
SELECT * FROM public.sp_get_tramite_info(1001);

-- Resultado esperado:
-- id_tramite | propietario         | ubicacion                    | estatus
-- -----------+---------------------+------------------------------+---------
--   1001     | Juan Pérez García   | Av. Juárez #123, Col. Centro | ACTIVO

-- ============================================
-- EJEMPLO 6: Eliminar una inspección
-- ============================================

-- Eliminar la inspección de "Protección Civil" (id=1) del trámite 1001
SELECT * FROM public.sp_delete_inspeccion(
    1001,              -- p_id_tramite
    1                  -- p_id_dependencia
);

-- Resultado esperado:
-- success | message
-- --------+-----------------------------------
--  true   | Inspección eliminada exitosamente

-- ============================================
-- EJEMPLO 7: Trabajar con inspecciones en memoria (temporal)
-- ============================================

-- 7.1: Agregar inspección a tabla temporal
SELECT * FROM public.sp_add_dependencia_inspeccion(
    1002,              -- p_tramite_id
    4,                 -- p_id_dependencia
    'mlopez'           -- p_usuario
);

-- Resultado esperado:
-- success | message
-- --------+--------------------------------------------
--  true   | Inspección agregada a memoria exitosamente

-- 7.2: Consultar inspecciones en memoria
SELECT * FROM public.sp_get_inspecciones_memoria(1002);

-- Resultado esperado:
-- id_dependencia | descripcion
-- ---------------+------------------
--      4         | Bomberos

-- 7.3: Remover inspección de memoria
SELECT * FROM public.sp_remove_dependencia_inspeccion(
    1002,              -- p_tramite_id
    4                  -- p_id_dependencia
);

-- Resultado esperado:
-- success | message
-- --------+----------------------------------------------
--  true   | Inspección removida de memoria exitosamente

-- ============================================
-- EJEMPLO 8: Flujo completo de trabajo
-- ============================================

-- PASO 1: Consultar dependencias disponibles
SELECT * FROM public.sp_get_dependencias();

-- PASO 2: Ver información del trámite
SELECT * FROM public.sp_get_tramite_info(1003);

-- PASO 3: Agregar inspecciones a memoria (borrador)
SELECT * FROM public.sp_add_dependencia_inspeccion(1003, 1, 'admin');
SELECT * FROM public.sp_add_dependencia_inspeccion(1003, 2, 'admin');
SELECT * FROM public.sp_add_dependencia_inspeccion(1003, 3, 'admin');

-- PASO 4: Verificar inspecciones en memoria
SELECT * FROM public.sp_get_inspecciones_memoria(1003);

-- PASO 5: Confirmar (migrar de memoria a definitivas)
-- Se hace una por una tomando las de memoria
SELECT * FROM public.sp_add_inspeccion(1003, 1, 'admin');
SELECT * FROM public.sp_add_inspeccion(1003, 2, 'admin');
SELECT * FROM public.sp_add_inspeccion(1003, 3, 'admin');

-- PASO 6: Limpiar memoria
SELECT * FROM public.sp_remove_dependencia_inspeccion(1003, 1);
SELECT * FROM public.sp_remove_dependencia_inspeccion(1003, 2);
SELECT * FROM public.sp_remove_dependencia_inspeccion(1003, 3);

-- PASO 7: Verificar inspecciones vigentes
SELECT * FROM public.sp_get_tramite_inspecciones(1003);

-- ============================================
-- EJEMPLO 9: Manejo de errores
-- ============================================

-- Error: Trámite inválido (NULL)
SELECT * FROM public.sp_get_tramite_inspecciones(NULL);
-- Resultado: ERROR - El ID del trámite es requerido y debe ser mayor a cero

-- Error: Trámite con ID cero o negativo
SELECT * FROM public.sp_get_tramite_inspecciones(0);
-- Resultado: ERROR - El ID del trámite es requerido y debe ser mayor a cero

-- Error: Dependencia inválida
SELECT * FROM public.sp_add_inspeccion(1001, NULL, 'admin');
-- Resultado: success=false, message="El ID de la dependencia es requerido..."

-- Error: Usuario vacío
SELECT * FROM public.sp_add_inspeccion(1001, 1, '');
-- Resultado: success=false, message="El usuario es requerido"

-- Error: Trámite no existe
SELECT * FROM public.sp_add_inspeccion(999999, 1, 'admin');
-- Resultado: success=false, message="El trámite especificado no existe"

-- Error: Dependencia no activa o no existe
SELECT * FROM public.sp_add_inspeccion(1001, 999999, 'admin');
-- Resultado: success=false, message="La dependencia especificada no existe..."

-- ============================================
-- EJEMPLO 10: Consultas avanzadas combinadas
-- ============================================

-- Ver trámites con sus inspecciones asignadas
SELECT
    t.id_tramite,
    t.propietario,
    ti.id_dependencia,
    ti.descripcion AS dependencia,
    ti.id_revision
FROM public.tramites t
LEFT JOIN LATERAL public.sp_get_tramite_inspecciones(t.id_tramite) ti ON true
WHERE t.estatus = 'ACTIVO'
ORDER BY t.id_tramite, ti.descripcion;

-- Contar inspecciones por trámite
SELECT
    t.id_tramite,
    t.propietario,
    COUNT(ti.id_revision) AS total_inspecciones
FROM public.tramites t
LEFT JOIN LATERAL public.sp_get_tramite_inspecciones(t.id_tramite) ti ON true
WHERE t.estatus = 'ACTIVO'
GROUP BY t.id_tramite, t.propietario
ORDER BY total_inspecciones DESC;

-- ============================================
-- EJEMPLO 11: Uso desde aplicación PHP/JavaScript
-- ============================================

/*
// PHP - Laravel
$dependencias = DB::select('SELECT * FROM public.sp_get_dependencias()');

$resultado = DB::select(
    'SELECT * FROM public.sp_add_inspeccion(?, ?, ?)',
    [$idTramite, $idDependencia, $usuario]
);

// JavaScript - Node.js
const { rows } = await pool.query(
    'SELECT * FROM public.sp_get_tramite_inspecciones($1)',
    [idTramite]
);

// JavaScript - Frontend (Axios)
const response = await axios.post('/api/inspecciones/add', {
    id_tramite: 1001,
    id_dependencia: 2,
    usuario: 'jperez'
});
*/

-- ============================================
-- NOTAS IMPORTANTES
-- ============================================

/*
1. Los SPs con retorno TABLE(success, message) siempre retornan un resultado,
   nunca lanzan excepciones (excepto validaciones críticas de parámetros).

2. Los SPs de consulta (sp_get_*) pueden lanzar excepciones si los parámetros
   son inválidos (NULL o valores incorrectos).

3. El flujo típico de trabajo:
   - Consultar catálogos (sp_get_dependencias)
   - Trabajar en memoria/borrador (sp_add_dependencia_inspeccion, sp_get_inspecciones_memoria)
   - Confirmar a definitivo (sp_add_inspeccion)
   - Consultar vigentes (sp_get_tramite_inspecciones)
   - Eliminar si necesario (sp_delete_inspeccion)

4. Diferencia entre tablas:
   - dependencias_inspeccion: Temporal/borrador
   - revisiones + seg_revision: Definitivas/confirmadas

5. Siempre validar el resultado success=true antes de proceder en la aplicación.
*/

-- ============================================
-- FIN DE EJEMPLOS DE USO
-- ============================================
