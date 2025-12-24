# Documentación Técnica: GruposAnunciosAbcfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario Grupos de Anuncios (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend:** Laravel (API RESTful unificada, endpoint `/api/execute`)
- **Frontend:** Vue.js (SPA, cada formulario es una página independiente)
- **Base de Datos:** PostgreSQL (toda la lógica SQL encapsulada en stored procedures)
- **Patrón de Comunicación:** eRequest/eResponse (peticiones y respuestas estructuradas)

## 2. Endpoint Unificado
- **Ruta:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "anuncios_grupos_list", // o get, insert, update, delete
    "params": { ... } // parámetros según la operación
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ] | { ... } | null,
      "message": "..."
    }
  }
  ```

## 3. Stored Procedures (PostgreSQL)
- Toda la lógica de acceso y manipulación de datos reside en funciones SQL (ver sección `stored_procedures`).
- Cada operación (listar, obtener, insertar, actualizar, eliminar) tiene su propio SP.
- Los SP retornan siempre el registro afectado o la lista de registros.

## 4. Controlador Laravel
- El controlador `ExecuteController` recibe el eRequest y lo enruta al SP correspondiente.
- Maneja errores y formatea la respuesta según el patrón eResponse.
- No expone lógica de negocio fuera de los SP.

## 5. Componente Vue.js
- Página independiente para Grupos de Anuncios.
- Permite buscar, agregar, modificar y eliminar grupos.
- El formulario de edición/agregado aparece como sección aparte (no modal, no tab).
- Navegación breadcrumb incluida.
- Validación básica en frontend.
- Llama siempre al endpoint `/api/execute` con el eRequest adecuado.

## 6. Seguridad
- Se recomienda proteger el endpoint con autenticación (ej: Laravel Sanctum o Passport).
- Validar y sanear los parámetros en backend y frontend.

## 7. Consideraciones de Migración
- El campo `id` es autoincremental y sólo editable en modo lectura.
- El campo `descripcion` se almacena en mayúsculas (UPPER en SP).
- El filtro de búsqueda es por coincidencia parcial (ILIKE en PostgreSQL).
- El formulario Delphi usaba botones habilitados/deshabilitados según modo; en Vue.js se controla por `formMode`.

## 8. Pruebas
- Ver sección `test_cases` para escenarios de prueba recomendados.

## 9. Extensibilidad
- Para agregar más formularios, replicar el patrón: SPs, eRequest, frontend page.

## 10. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 11

## Casos de Prueba

## Casos de Prueba para Grupos de Anuncios

### 1. Alta de grupo válido
- **Acción:** Agregar grupo con descripción 'PUBLICIDAD EXTERIOR'.
- **Esperado:** Grupo creado, aparece en la lista, mensaje de éxito.

### 2. Alta de grupo con descripción vacía
- **Acción:** Intentar agregar grupo sin descripción.
- **Esperado:** Error de validación en frontend, no se envía petición.

### 3. Modificación de grupo existente
- **Acción:** Editar grupo id=2, cambiar descripción a 'ANUNCIOS DIGITALES'.
- **Esperado:** Grupo actualizado, mensaje de éxito.

### 4. Eliminación de grupo
- **Acción:** Eliminar grupo id=4.
- **Esperado:** Grupo eliminado, mensaje de éxito, ya no aparece en la lista.

### 5. Búsqueda parcial
- **Acción:** Buscar 'EXTERIOR' en filtro.
- **Esperado:** Sólo aparecen grupos que contienen 'EXTERIOR' en la descripción.

### 6. Edición cancelada
- **Acción:** Iniciar edición y luego cancelar.
- **Esperado:** No hay cambios, formulario se limpia.

### 7. Eliminación de grupo inexistente
- **Acción:** Intentar eliminar grupo con id=9999.
- **Esperado:** Mensaje de error, no afecta a la lista.

### 8. Duplicidad de descripción
- **Acción:** Agregar grupo con descripción igual a uno existente (si hay restricción).
- **Esperado:** Si hay restricción, error; si no, se permite duplicado.

## Casos de Uso

# Casos de Uso - GruposAnunciosAbcfrm

**Categoría:** Form

## Caso de Uso 1: Agregar un nuevo grupo de anuncio

**Descripción:** El usuario desea crear un nuevo grupo de anuncio con la descripción 'PUBLICIDAD EXTERIOR'.

**Precondiciones:**
El usuario tiene acceso a la página de Grupos de Anuncios y permisos de escritura.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Agregar'.
2. Se muestra el formulario de alta.
3. El usuario ingresa 'PUBLICIDAD EXTERIOR' en el campo Descripción.
4. El usuario hace clic en 'Aceptar'.
5. El sistema envía la petición eRequest 'anuncios_grupos_insert' al endpoint.
6. El backend inserta el registro y retorna el nuevo grupo.

**Resultado esperado:**
El grupo se agrega a la lista, se muestra un mensaje de éxito y el formulario se limpia.

**Datos de prueba:**
{ "descripcion": "PUBLICIDAD EXTERIOR" }

---

## Caso de Uso 2: Modificar la descripción de un grupo existente

**Descripción:** El usuario desea cambiar la descripción del grupo con id=3 a 'ANUNCIOS DIGITALES'.

**Precondiciones:**
Existe un grupo con id=3. El usuario tiene permisos de edición.

**Pasos a seguir:**
1. El usuario localiza el grupo con id=3 en la lista.
2. Hace clic en 'Modificar'.
3. Cambia la descripción a 'ANUNCIOS DIGITALES'.
4. Hace clic en 'Aceptar'.
5. El sistema envía eRequest 'anuncios_grupos_update' con los datos.

**Resultado esperado:**
La descripción del grupo se actualiza y se muestra mensaje de éxito.

**Datos de prueba:**
{ "id": 3, "descripcion": "ANUNCIOS DIGITALES" }

---

## Caso de Uso 3: Buscar grupos de anuncios por descripción parcial

**Descripción:** El usuario desea filtrar la lista de grupos para ver sólo aquellos que contienen la palabra 'EXTERIOR'.

**Precondiciones:**
Existen varios grupos de anuncios en la base de datos.

**Pasos a seguir:**
1. El usuario escribe 'EXTERIOR' en el campo de búsqueda.
2. El sistema envía eRequest 'anuncios_grupos_list' con el parámetro de filtro.
3. Se actualiza la tabla con los resultados filtrados.

**Resultado esperado:**
Sólo se muestran los grupos cuya descripción contiene 'EXTERIOR'.

**Datos de prueba:**
{ "descripcion": "EXTERIOR" }

---
