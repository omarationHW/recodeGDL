# Documentación: conscentrosfrm

## Análisis Técnico

# Documentación Técnica: Migración conscentrosfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo corresponde al formulario `conscentrosfrm` de Delphi, que muestra el listado de multas cobradas en centros de recaudación, asociadas al importe del pago. La migración se realiza a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos).

## Arquitectura
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 (Composition API opcional), componente de página independiente
- **Base de datos:** PostgreSQL 14+, lógica SQL en stored procedures

## API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "get_centros_list|get_centros_by_fecha|get_centros_by_dependencia|get_centros_by_acta",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [ ... ]
  }
  ```

## Stored Procedures
Toda la lógica de consulta reside en funciones PostgreSQL (tipo `RETURNS TABLE`).
- `sp_get_centros_list()`
- `sp_get_centros_by_fecha(p_fecha DATE)`
- `sp_get_centros_by_dependencia(p_id_dependencia INTEGER)`
- `sp_get_centros_by_acta(p_axo_acta INTEGER, p_num_acta INTEGER)`

La vista `centros_recaudacion_view` debe existir y contener los campos:
- fecha, abrevia, axo_acta, num_acta, num_recibo, importe_pago, contribuyente, domicilio, id_dependencia

## Laravel Controller
- Controlador: `ConsCentrosController`
- Método principal: `execute(Request $request)`
- Métodos auxiliares para cada acción
- Validación de parámetros
- Uso de DB::select para ejecutar las consultas

## Vue.js Component
- Página independiente (no tabs)
- Filtros: fecha, dependencia, año acta, número acta
- Tabla responsive con los campos requeridos
- Navegación y limpieza de filtros
- Consumo del endpoint `/api/execute`

## Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o Laravel Sanctum
- Validar y sanear todos los parámetros recibidos

## Consideraciones de Migración
- El formulario Delphi sólo mostraba datos, no permitía edición ni acciones sobre los registros
- El grid se reemplaza por una tabla HTML con paginación opcional
- Los stored procedures pueden ser extendidos para paginación si se requiere

## Pruebas y QA
- Se deben realizar pruebas funcionales de todos los filtros
- Validar que los datos coincidan con el sistema original
- Probar casos de error y validación

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint
- El frontend puede ser extendido para exportar a Excel o PDF

## Casos de Uso

# Casos de Uso - conscentrosfrm

**Categoría:** Form

## Caso de Uso 1: Consulta general de multas cobradas en centros de recaudación

**Descripción:** El usuario accede a la página y visualiza el listado completo de multas cobradas en centros de recaudación, sin aplicar ningún filtro.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en la vista centros_recaudacion_view.

**Pasos a seguir:**
1. El usuario ingresa a la página de 'Multas cobradas en centros de Recaudación'.
2. No selecciona ningún filtro y presiona 'Buscar'.
3. El sistema envía una petición POST a /api/execute con action 'get_centros_list'.
4. El backend ejecuta el stored procedure correspondiente y retorna los datos.

**Resultado esperado:**
Se muestra la tabla con todas las multas cobradas, ordenadas por fecha y número de recibo descendente.

**Datos de prueba:**
Registros de ejemplo en centros_recaudacion_view con diferentes fechas, dependencias y actas.

---

## Caso de Uso 2: Filtrar por fecha específica

**Descripción:** El usuario desea ver sólo las multas cobradas en una fecha determinada.

**Precondiciones:**
El usuario tiene acceso y existen registros para la fecha seleccionada.

**Pasos a seguir:**
1. El usuario selecciona una fecha en el filtro.
2. Presiona 'Buscar'.
3. El sistema envía una petición POST a /api/execute con action 'get_centros_by_fecha' y el parámetro fecha.
4. El backend retorna sólo los registros de esa fecha.

**Resultado esperado:**
Se muestran únicamente las multas cobradas en la fecha seleccionada.

**Datos de prueba:**
Registros con fecha '2024-06-01' y otras fechas.

---

## Caso de Uso 3: Filtrar por dependencia y acta

**Descripción:** El usuario busca multas de una dependencia y acta específica.

**Precondiciones:**
El usuario conoce el id de la dependencia y el número/año de acta.

**Pasos a seguir:**
1. El usuario selecciona la dependencia y llena año y número de acta.
2. Presiona 'Buscar'.
3. El sistema envía una petición POST a /api/execute con action 'get_centros_by_acta' y los parámetros axo_acta y num_acta.
4. El backend retorna los registros coincidentes.

**Resultado esperado:**
Se muestran sólo las multas de la dependencia y acta especificada.

**Datos de prueba:**
Registros con id_dependencia=2, axo_acta=2024, num_acta=12345.

---

## Casos de Prueba

# Casos de Prueba para conscentrosfrm migrado

## Caso 1: Consulta general sin filtros
- **Entrada:** POST /api/execute { "action": "get_centros_list" }
- **Esperado:** Respuesta 200, success=true, data contiene lista de registros

## Caso 2: Filtro por fecha válida
- **Entrada:** POST /api/execute { "action": "get_centros_by_fecha", "params": { "fecha": "2024-06-01" } }
- **Esperado:** Respuesta 200, success=true, data sólo con registros de esa fecha

## Caso 3: Filtro por dependencia existente
- **Entrada:** POST /api/execute { "action": "get_centros_by_dependencia", "params": { "id_dependencia": 2 } }
- **Esperado:** Respuesta 200, success=true, data sólo con registros de esa dependencia

## Caso 4: Filtro por acta (año y número)
- **Entrada:** POST /api/execute { "action": "get_centros_by_acta", "params": { "axo_acta": 2024, "num_acta": 12345 } }
- **Esperado:** Respuesta 200, success=true, data sólo con registros coincidentes

## Caso 5: Filtro por fecha inválida
- **Entrada:** POST /api/execute { "action": "get_centros_by_fecha", "params": { "fecha": "2024-99-99" } }
- **Esperado:** Respuesta 422, success=false, errors indica error de validación

## Caso 6: Filtro por dependencia inexistente
- **Entrada:** POST /api/execute { "action": "get_centros_by_dependencia", "params": { "id_dependencia": 999 } }
- **Esperado:** Respuesta 200, success=true, data vacío

## Caso 7: Filtro por acta sin resultados
- **Entrada:** POST /api/execute { "action": "get_centros_by_acta", "params": { "axo_acta": 1900, "num_acta": 1 } }
- **Esperado:** Respuesta 200, success=true, data vacío

## Caso 8: Acción no soportada
- **Entrada:** POST /api/execute { "action": "unknown_action" }
- **Esperado:** Respuesta 400, success=false, message indica acción no soportada

## Integración con Backend

> ⚠️ Pendiente de documentar

