# Documentación Técnica: Módulo de Condonación de Adeudos

## Descripción General
Este módulo permite la condonación de adeudos de locales comerciales en mercados municipales. Permite buscar un local, listar sus adeudos, condonar uno o varios adeudos (moviéndolos a una tabla de condonados), y deshacer la condonación si es necesario. Todo el flujo está centralizado en un endpoint API único (`/api/execute`) siguiendo el patrón eRequest/eResponse.

## Arquitectura
- **Backend:** Laravel (PHP), PostgreSQL (con stored procedures)
- **Frontend:** Vue.js (SPA, página independiente)
- **API:** Endpoint único `/api/execute` que recibe `{ action, data }` y responde `{ status, data, message }`
- **Seguridad:** Autenticación Laravel (token o session), cada acción requiere usuario autenticado

## Flujo de Trabajo
1. **Búsqueda de Local:**
   - El usuario ingresa los datos del local (oficina, mercado, categoría, sección, local, letra, bloque)
   - Se llama a `buscar_local_condonacion` para validar y obtener el local
2. **Listado de Adeudos:**
   - Se llama a `spd_11_condonacion` para obtener los adeudos vigentes del local
3. **Condonación de Adeudos:**
   - El usuario selecciona uno o varios adeudos y proporciona el número de oficio
   - Por cada adeudo seleccionado, se llama a `condonar_adeudo_local`, que mueve el adeudo a la tabla de condonados y lo elimina de la tabla de adeudos
4. **Listado de Condonados:**
   - Se listan los adeudos condonados actuales del local
5. **Deshacer Condonación:**
   - El usuario puede seleccionar condonaciones y deshacerlas, regresando el adeudo a la tabla de adeudos

## API (Laravel Controller)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  - `action`: string (buscar_local, listar_adeudos, condonar_adeudos, listar_condonados, deshacer_condonacion)
  - `data`: objeto con los parámetros necesarios para cada acción
- **Salida:**
  - `status`: success|error
  - `data`: datos de respuesta (si aplica)
  - `message`: mensaje de error o éxito

## Stored Procedures
- **buscar_local_condonacion:** Busca local vigente y activo
- **spd_11_condonacion:** Lista adeudos del local
- **condonar_adeudo_local:** Realiza la condonación (mueve de adeudo a condonados)
- **deshacer_condonacion_local:** Revierte la condonación

## Frontend (Vue.js)
- Página independiente `/condonacion`
- Formulario de búsqueda de local
- Tabla de adeudos con selección múltiple
- Campo para número de oficio
- Botón para condonar seleccionados
- Tabla de condonados con opción de deshacer
- Mensajes de error y éxito

## Validaciones
- Todos los campos requeridos deben estar completos
- El número de oficio debe tener formato válido
- No se puede condonar si no hay adeudos seleccionados
- No se puede deshacer si no hay condonados seleccionados

## Seguridad
- Todas las acciones requieren usuario autenticado
- El backend valida permisos y existencia de datos

## Manejo de Errores
- Mensajes claros en frontend y backend
- Rollback de transacciones en caso de error

## Integración
- El frontend se comunica exclusivamente con `/api/execute` usando Axios
- El backend enruta cada acción a la función correspondiente

# Tablas Involucradas
- `ta_11_locales`: Locales comerciales
- `ta_11_adeudo_local`: Adeudos vigentes
- `ta_11_ade_loc_canc`: Adeudos condonados

# Notas
- Todas las operaciones de condonación y reversión son transaccionales
- El historial de condonaciones queda en `ta_11_ade_loc_canc`

