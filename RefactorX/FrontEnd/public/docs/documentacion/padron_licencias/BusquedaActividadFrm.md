# Documentación Técnica: BusquedaActividadFrm

## Análisis Técnico

# Documentación Técnica: Migración de BusquedaActividadFrm a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la funcionalidad de búsqueda de actividades económicas (giro) migrando el formulario Delphi `BusquedaActividadFrm` a una arquitectura moderna basada en Laravel (API), Vue.js (frontend) y PostgreSQL (base de datos).

- **Backend**: Laravel expone un endpoint unificado `/api/execute` que recibe un objeto `eRequest` y parámetros, y responde con `eResponse`.
- **Frontend**: Vue.js implementa una página independiente para la búsqueda y selección de actividades.
- **Base de Datos**: Toda la lógica SQL se encapsula en stored procedures PostgreSQL.

## 2. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": "buscar_actividades",
    "params": {
      "scian": 12345,
      "descripcion": "TEXTO OPCIONAL"
    }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "error": null
    }
  }
  ```

## 3. Stored Procedures
- **buscar_actividades**: Devuelve actividades filtradas por SCIAN y descripción, incluyendo costo y refrendo del año actual.
- **buscar_actividad_por_id**: Devuelve una actividad específica por su id_giro.

## 4. Frontend (Vue.js)
- Página independiente `/busqueda-actividad`.
- Recibe el parámetro `scian` (por query string, prop o route param).
- Permite filtrar por descripción en tiempo real.
- Muestra resultados en tabla y permite seleccionar una actividad.
- Botón "Aceptar" habilitado solo si hay selección.

## 5. Backend (Laravel)
- Controlador `ExecuteController` maneja todas las solicitudes bajo `/api/execute`.
- Llama a los stored procedures según el valor de `eRequest`.
- Maneja errores y responde en formato unificado.

## 6. Seguridad
- Validar que el parámetro `scian` sea numérico y obligatorio.
- Sanitizar la descripción para evitar SQL Injection (los procedimientos usan parámetros tipados).

## 7. Consideraciones
- El frontend espera que el parámetro `scian` esté presente para realizar la búsqueda.
- El stored procedure maneja búsquedas insensibles a mayúsculas/minúsculas (`ILIKE`).
- El endpoint puede ser extendido para otros formularios reutilizando el patrón `eRequest`.

## 8. Estructura de la Base de Datos
- **c_giros**: Catálogo de giros/actividades económicas.
- **c_valoreslic**: Valores de licencia asociados a cada giro y año.

## 9. Ejemplo de Uso
- El usuario ingresa una descripción y el sistema filtra actividades vigentes del SCIAN seleccionado.
- Al seleccionar una fila y presionar "Aceptar", se puede emitir un evento o navegar a otra página.

## 10. Extensibilidad
- Se pueden agregar más stored procedures y casos de uso siguiendo el mismo patrón.

## Casos de Prueba

# Casos de Prueba: BusquedaActividadFrm

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Búsqueda básica por SCIAN | scian=561110, descripcion='' | Lista de actividades vigentes con SCIAN 561110 |
| TC02 | Búsqueda por SCIAN y descripción parcial | scian=561110, descripcion='RESTAURANTE' | Solo actividades que contienen 'RESTAURANTE' en la descripción |
| TC03 | Búsqueda sin resultados | scian=561110, descripcion='ZZZZZZ' | Tabla vacía, mensaje 'No se encontraron actividades.' |
| TC04 | Selección de actividad | Seleccionar fila y presionar 'Aceptar' | Evento emitido con datos de la actividad seleccionada |
| TC05 | Error por SCIAN faltante | scian no enviado | Error en frontend, no se realiza búsqueda |
| TC06 | Error de backend | API responde con error | Mensaje de error visible en frontend |

## Casos de Uso

# Casos de Uso - BusquedaActividadFrm

**Categoría:** Form

## Caso de Uso 1: Búsqueda de actividades por SCIAN y descripción parcial

**Descripción:** El usuario desea buscar actividades económicas cuyo SCIAN es 561110 y la descripción contiene la palabra 'RESTAURANTE'.

**Precondiciones:**
El usuario conoce el código SCIAN y tiene acceso a la página de búsqueda.

**Pasos a seguir:**
1. Ingresar a la página de búsqueda de actividades.
2. El sistema recibe el parámetro scian=561110 (por query string).
3. El usuario escribe 'RESTAURANTE' en el campo de descripción.
4. El sistema consulta el API y muestra las actividades que coinciden.

**Resultado esperado:**
Se muestran todas las actividades vigentes con SCIAN 561110 y descripción que contiene 'RESTAURANTE', junto con su costo y refrendo.

**Datos de prueba:**
{ "scian": 561110, "descripcion": "RESTAURANTE" }

---

## Caso de Uso 2: Selección de actividad y confirmación

**Descripción:** El usuario selecciona una actividad de la lista y confirma su selección.

**Precondiciones:**
La búsqueda previa ha devuelto al menos una actividad.

**Pasos a seguir:**
1. El usuario hace clic en una fila de la tabla.
2. El sistema resalta la fila seleccionada.
3. El usuario presiona el botón 'Aceptar'.

**Resultado esperado:**
El sistema emite un evento o realiza una acción con la actividad seleccionada (por ejemplo, mostrar un mensaje o navegar a otra página).

**Datos de prueba:**
Actividad seleccionada: id_giro=5010, cod_giro=561110, descripcion='RESTAURANTE BAR', costo=1500

---

## Caso de Uso 3: Búsqueda sin resultados

**Descripción:** El usuario realiza una búsqueda con una descripción que no existe.

**Precondiciones:**
El usuario está en la página de búsqueda y el SCIAN es válido.

**Pasos a seguir:**
1. El usuario ingresa una descripción inexistente, por ejemplo 'ZZZZZZ'.
2. El sistema consulta el API.

**Resultado esperado:**
La tabla muestra el mensaje 'No se encontraron actividades.'

**Datos de prueba:**
{ "scian": 561110, "descripcion": "ZZZZZZ" }

---
