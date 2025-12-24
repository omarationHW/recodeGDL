# Documentación Técnica: GruposLicenciasAbcfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario GruposLicenciasAbcfrm a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la administración de los grupos de licencias (catálogo `lic_grupos`) mediante una API unificada, frontend Vue.js y lógica de negocio en stored procedures PostgreSQL. Incluye operaciones de alta, modificación, consulta, filtrado y eliminación.

## 2. Arquitectura
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (SPA, página independiente)
- **Base de Datos:** PostgreSQL (toda la lógica SQL en stored procedures)

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "eRequest": {
      "operation": "nombre_operacion",
      "params": { ... }
    }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": ..., // resultado de la operación
      "message": "mensaje de error o éxito"
    }
  }
  ```

### Operaciones soportadas
- `list_grupos_licencias` (params: { descripcion })
- `get_grupo_licencia` (params: { id })
- `insert_grupo_licencia` (params: { descripcion })
- `update_grupo_licencia` (params: { id, descripcion })
- `delete_grupo_licencia` (params: { id })

## 4. Stored Procedures
Toda la lógica de acceso y manipulación de datos reside en funciones PL/pgSQL:
- **sp_list_grupos_licencias:** Listado y filtrado por descripción.
- **sp_get_grupo_licencia:** Consulta por ID.
- **sp_insert_grupo_licencia:** Alta de grupo.
- **sp_update_grupo_licencia:** Modificación de grupo.
- **sp_delete_grupo_licencia:** Eliminación de grupo.

## 5. Frontend Vue.js
- Página independiente `/grupos-licencias`.
- Tabla con listado y filtro por descripción.
- Formulario modal para alta/modificación.
- Acciones: agregar, editar, eliminar.
- Mensajes de éxito/error.
- Navegación breadcrumb.

## 6. Seguridad
- Validación de campos en frontend y backend.
- Uso de parámetros en las llamadas a stored procedures (previene SQL Injection).
- El endpoint puede protegerse con middleware de autenticación según necesidades del proyecto.

## 7. Consideraciones
- El campo `id` es autoincremental y no editable en edición.
- El campo `descripcion` se almacena en mayúsculas y es obligatorio.
- El filtrado es insensible a mayúsculas/minúsculas (ILIKE).

## 8. Instalación y Despliegue
1. Crear la tabla `lic_grupos` en PostgreSQL si no existe:
   ```sql
   CREATE TABLE lic_grupos (
     id SERIAL PRIMARY KEY,
     descripcion VARCHAR(255) NOT NULL
   );
   ```
2. Crear los stored procedures proporcionados.
3. Configurar el endpoint `/api/execute` en Laravel y registrar el controlador.
4. Integrar el componente Vue.js en la SPA y configurar la ruta.

## 9. Pruebas
- Ver sección de Casos de Uso y Casos de Prueba.

## Casos de Prueba

# Casos de Prueba para Grupos de Licencias

## Caso 1: Alta de grupo válido
- **Entrada:** { "descripcion": "SOPORTE" }
- **Acción:** POST /api/execute { operation: 'insert_grupo_licencia', params: { descripcion: 'SOPORTE' } }
- **Esperado:** Respuesta success=true, data con id y descripcion='SOPORTE'.

## Caso 2: Alta de grupo con descripción vacía
- **Entrada:** { "descripcion": "" }
- **Acción:** POST /api/execute { operation: 'insert_grupo_licencia', params: { descripcion: '' } }
- **Esperado:** Respuesta success=false, mensaje de error por validación.

## Caso 3: Edición de grupo existente
- **Entrada:** { "id": 2, "descripcion": "VENTAS" }
- **Acción:** POST /api/execute { operation: 'update_grupo_licencia', params: { id: 2, descripcion: 'VENTAS' } }
- **Esperado:** Respuesta success=true, data con id=2 y descripcion='VENTAS'.

## Caso 4: Eliminación de grupo existente
- **Entrada:** { "id": 3 }
- **Acción:** POST /api/execute { operation: 'delete_grupo_licencia', params: { id: 3 } }
- **Esperado:** Respuesta success=true, data con id=3.

## Caso 5: Filtro por descripción parcial
- **Entrada:** { "descripcion": "ADM" }
- **Acción:** POST /api/execute { operation: 'list_grupos_licencias', params: { descripcion: 'ADM' } }
- **Esperado:** Respuesta success=true, data con todos los grupos que contienen 'ADM' en la descripción.

## Caso 6: Consulta de grupo inexistente
- **Entrada:** { "id": 9999 }
- **Acción:** POST /api/execute { operation: 'get_grupo_licencia', params: { id: 9999 } }
- **Esperado:** Respuesta success=true, data=null.

## Casos de Uso

# Casos de Uso - GruposLicenciasAbcfrm

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo grupo de licencia

**Descripción:** El usuario desea agregar un nuevo grupo de licencia con la descripción 'ADMINISTRATIVOS'.

**Precondiciones:**
El usuario tiene acceso a la página de Grupos de Licencias y la tabla está vacía o no contiene el grupo 'ADMINISTRATIVOS'.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Agregar'.
2. Se muestra el formulario de alta.
3. El usuario ingresa 'ADMINISTRATIVOS' en el campo Descripción.
4. El usuario hace clic en 'Aceptar'.
5. El sistema envía la petición a /api/execute con la operación 'insert_grupo_licencia'.
6. El backend inserta el registro y retorna el grupo creado.
7. El frontend muestra mensaje de éxito y actualiza la tabla.

**Resultado esperado:**
El grupo 'ADMINISTRATIVOS' aparece en la tabla con un ID asignado automáticamente.

**Datos de prueba:**
{ "descripcion": "ADMINISTRATIVOS" }

---

## Caso de Uso 2: Edición de un grupo de licencia existente

**Descripción:** El usuario desea modificar la descripción del grupo con ID 1 a 'OPERATIVOS'.

**Precondiciones:**
Existe un grupo con ID 1 y descripción diferente a 'OPERATIVOS'.

**Pasos a seguir:**
1. El usuario localiza el grupo con ID 1 en la tabla.
2. Hace clic en 'Editar'.
3. Se muestra el formulario de edición con los datos actuales.
4. El usuario cambia la descripción a 'OPERATIVOS'.
5. Hace clic en 'Aceptar'.
6. El sistema envía la petición a /api/execute con la operación 'update_grupo_licencia'.
7. El backend actualiza el registro y retorna el grupo actualizado.
8. El frontend muestra mensaje de éxito y actualiza la tabla.

**Resultado esperado:**
El grupo con ID 1 muestra la descripción 'OPERATIVOS' en la tabla.

**Datos de prueba:**
{ "id": 1, "descripcion": "OPERATIVOS" }

---

## Caso de Uso 3: Filtrado de grupos de licencias por descripción

**Descripción:** El usuario desea buscar todos los grupos que contienen la palabra 'ADMIN' en la descripción.

**Precondiciones:**
Existen varios grupos de licencias, algunos con 'ADMIN' en la descripción.

**Pasos a seguir:**
1. El usuario escribe 'ADMIN' en el campo de filtro de descripción.
2. El sistema envía la petición a /api/execute con la operación 'list_grupos_licencias' y el parámetro 'descripcion'.
3. El backend retorna solo los grupos cuyo campo descripción contiene 'ADMIN'.
4. El frontend muestra la tabla filtrada.

**Resultado esperado:**
Solo se muestran los grupos que contienen 'ADMIN' en la descripción.

**Datos de prueba:**
{ "descripcion": "ADMIN" }

---
