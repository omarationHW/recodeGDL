# RecargosMntto

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario RecargosMntto (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la gestión de los recargos de mantenimiento por año y periodo. Incluye la inserción, modificación y consulta de recargos, así como la visualización de todos los registros existentes. La migración implementa una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos), centralizando la lógica de negocio en stored procedures y exponiendo la funcionalidad a través de un endpoint API unificado.

## 2. Arquitectura
- **Backend:** Laravel 10+, controlador único (`RecargosMnttoController`) que expone el endpoint `/api/execute` para todas las operaciones (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js independiente, página completa, sin tabs, con navegación breadcrumb y tabla de recargos editable.
- **Base de Datos:** PostgreSQL, toda la lógica de negocio encapsulada en stored procedures (`sp_insert_recargo`, `sp_update_recargo`, `sp_get_recargo`, `sp_list_recargos`).

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "nombre_accion", // Ej: "insert_recargo", "update_recargo", "get_recargo", "list_recargos"
    "params": { ... } // Parámetros requeridos por la acción
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "data": [ ... ], // o null
    "message": "Mensaje de éxito o error"
  }
  ```

## 4. Stored Procedures
- Toda la lógica de inserción, actualización y consulta reside en funciones PL/pgSQL.
- Se validan duplicados y existencia antes de insertar/actualizar.
- Se retorna siempre un mensaje y un flag de éxito.

## 5. Frontend (Vue.js)
- Página independiente `/recargos-mntto`.
- Formulario para alta/modificación de recargos.
- Tabla con todos los recargos existentes.
- Edición inline (al hacer click en editar, el formulario se llena y permite actualizar).
- Mensajes de éxito/error en pantalla.
- Navegación breadcrumb.

## 6. Seguridad
- El endpoint espera que el usuario autenticado esté disponible (en este ejemplo, se usa `id_usuario: 1` por defecto, pero debe integrarse con el sistema de autenticación real).
- Validaciones de datos tanto en frontend como en backend.

## 7. Consideraciones de Migración
- El formulario Delphi usaba transacciones y control de errores; esto se replica en los stored procedures y el controlador Laravel.
- El frontend es completamente reactivo y no usa tabs ni componentes compartidos con otros formularios.
- El endpoint `/api/execute` puede ser extendido para otros formularios siguiendo el mismo patrón.

## 8. Instalación y Despliegue
- Crear las funciones PL/pgSQL en la base de datos PostgreSQL.
- Registrar el controlador en `routes/api.php`:
  ```php
  Route::post('/execute', [RecargosMnttoController::class, 'execute']);
  ```
- Agregar el componente Vue.js en la SPA y registrar la ruta `/recargos-mntto`.

## 9. Ejemplo de Request/Response
- **Alta de recargo:**
  ```json
  {
    "action": "insert_recargo",
    "params": {
      "axo": 2024,
      "periodo": 6,
      "porcentaje": 2.5,
      "id_usuario": 1
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "message": "Recargo insertado correctamente."
  }
  ```

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones y stored procedures sin modificar la estructura del endpoint.
- El frontend puede ser extendido para otros catálogos siguiendo el mismo patrón de página independiente.


## Casos de Uso

# Casos de Uso - RecargosMntto

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo recargo de mantenimiento

**Descripción:** El usuario desea registrar un nuevo recargo para el año y periodo actual.

**Precondiciones:**
El usuario tiene permisos de alta. No existe ya un recargo para ese año y periodo.

**Pasos a seguir:**
1. El usuario accede a la página de Recargos de Mantenimiento.
2. Llena el formulario con año=2024, periodo=7, porcentaje=1.75.
3. Presiona el botón 'Agregar'.
4. El sistema valida que no exista ya un recargo para ese año y periodo.
5. El sistema inserta el registro y muestra mensaje de éxito.

**Resultado esperado:**
El recargo es insertado y aparece en la tabla de recargos. Se muestra mensaje 'Recargo insertado correctamente.'

**Datos de prueba:**
{ "axo": 2024, "periodo": 7, "porcentaje": 1.75, "id_usuario": 1 }

---

## Caso de Uso 2: Modificación de un recargo existente

**Descripción:** El usuario necesita actualizar el porcentaje de un recargo ya registrado.

**Precondiciones:**
Existe un recargo para año=2024, periodo=7.

**Pasos a seguir:**
1. El usuario accede a la página y localiza el recargo 2024-7 en la tabla.
2. Hace click en 'Editar'.
3. Cambia el porcentaje a 2.00.
4. Presiona 'Actualizar'.
5. El sistema valida existencia y actualiza el registro.

**Resultado esperado:**
El porcentaje se actualiza y la tabla refleja el nuevo valor. Mensaje: 'Recargo actualizado correctamente.'

**Datos de prueba:**
{ "axo": 2024, "periodo": 7, "porcentaje": 2.00, "id_usuario": 1 }

---

## Caso de Uso 3: Intento de alta duplicada

**Descripción:** El usuario intenta registrar un recargo para un año y periodo que ya existen.

**Precondiciones:**
Ya existe un recargo para año=2024, periodo=7.

**Pasos a seguir:**
1. El usuario llena el formulario con año=2024, periodo=7, porcentaje=1.5.
2. Presiona 'Agregar'.
3. El sistema detecta duplicado y rechaza la operación.

**Resultado esperado:**
No se inserta el registro. Mensaje: 'Ya existe un recargo para ese año y periodo.'

**Datos de prueba:**
{ "axo": 2024, "periodo": 7, "porcentaje": 1.5, "id_usuario": 1 }

---



## Casos de Prueba

# Casos de Prueba para RecargosMntto

## 1. Alta exitosa de recargo
- **Input:** { "action": "insert_recargo", "params": { "axo": 2024, "periodo": 8, "porcentaje": 2.5, "id_usuario": 1 } }
- **Resultado esperado:** success=true, message='Recargo insertado correctamente.'
- **Verificación:** El registro aparece en la tabla con los datos correctos.

## 2. Alta duplicada
- **Input:** { "action": "insert_recargo", "params": { "axo": 2024, "periodo": 8, "porcentaje": 2.5, "id_usuario": 1 } }
- **Resultado esperado:** success=false, message='Ya existe un recargo para ese año y periodo.'

## 3. Modificación exitosa
- **Input:** { "action": "update_recargo", "params": { "axo": 2024, "periodo": 8, "porcentaje": 3.0, "id_usuario": 1 } }
- **Resultado esperado:** success=true, message='Recargo actualizado correctamente.'
- **Verificación:** El porcentaje se actualiza en la tabla.

## 4. Modificación de recargo inexistente
- **Input:** { "action": "update_recargo", "params": { "axo": 2025, "periodo": 1, "porcentaje": 1.5, "id_usuario": 1 } }
- **Resultado esperado:** success=false, message='No existe el recargo para ese año y periodo.'

## 5. Consulta de recargo existente
- **Input:** { "action": "get_recargo", "params": { "axo": 2024, "periodo": 8 } }
- **Resultado esperado:** data contiene el registro con axo=2024, periodo=8, porcentaje=3.0

## 6. Listado de recargos
- **Input:** { "action": "list_recargos" }
- **Resultado esperado:** data es un array con todos los recargos ordenados por año y periodo descendente.

## 7. Validación de campos obligatorios
- **Input:** { "action": "insert_recargo", "params": { "axo": 2024, "periodo": 8 } }
- **Resultado esperado:** success=false, message indica campo faltante.



