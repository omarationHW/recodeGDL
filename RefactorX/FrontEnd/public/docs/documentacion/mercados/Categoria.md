# Categoria

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Módulo Categoría (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo corresponde a la migración del formulario de "Categoría" desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos). El acceso a la funcionalidad se realiza a través de un endpoint API unificado `/api/execute` usando el patrón eRequest/eResponse.

## 2. Arquitectura
- **Backend:** Laravel 10+, controlador `CategoriaController`, acceso a procedimientos almacenados PostgreSQL.
- **Frontend:** Vue.js 3 SPA, componente de página independiente para Categoría.
- **Base de Datos:** PostgreSQL, tabla `ta_11_categoria` y stored procedures para CRUD.
- **API:** Endpoint único `/api/execute` que recibe un objeto `eRequest` con acción y parámetros, y responde con `eResponse`.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "categoria.create", // o categoria.list, categoria.update, categoria.delete
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true/false,
      "message": "...",
      "data": [ ... ]
    }
  }
  ```

## 4. Stored Procedures PostgreSQL
- **sp_categoria_list:** Devuelve todas las categorías.
- **sp_categoria_create:** Inserta una nueva categoría (valida duplicados).
- **sp_categoria_update:** Actualiza la descripción de una categoría existente.
- **sp_categoria_delete:** Elimina una categoría existente.

## 5. Laravel Controller
- Un solo método `execute` que despacha según el valor de `eRequest.action`.
- Valida parámetros y llama a los stored procedures.
- Devuelve siempre la estructura eResponse.

## 6. Vue.js Component
- Página independiente `/categorias`.
- Tabla con listado de categorías.
- Botón para agregar (abre modal).
- Botón para editar (abre modal con datos).
- Botón para eliminar (confirmación).
- Llama al endpoint `/api/execute` para todas las operaciones.
- Mensajes de éxito/error.

## 7. Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o session según la arquitectura global.
- Validar que sólo usuarios autorizados puedan crear/editar/eliminar.

## 8. Consideraciones de Migración
- El campo `categoria` es clave primaria (smallint).
- El campo `descripcion` es varchar(30), se almacena en mayúsculas.
- No hay referencias foráneas en este módulo, pero en producción validar integridad referencial.

## 9. Pruebas y Casos de Uso
- Ver sección de casos de uso y pruebas.

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar la estructura del endpoint.
- Los stored procedures pueden ser versionados y auditados en la base de datos.



## Casos de Uso

# Casos de Uso - Categoria

**Categoría:** Form

## Caso de Uso 1: Alta de nueva categoría

**Descripción:** Un usuario administrador desea agregar una nueva categoría de locales.

**Precondiciones:**
El usuario está autenticado y tiene permisos de administrador.

**Pasos a seguir:**
1. El usuario accede a la página de categorías.
2. Hace clic en 'Agregar Categoría'.
3. Ingresa el número de categoría (ej: 5) y la descripción (ej: 'ALIMENTOS').
4. Hace clic en 'Guardar'.
5. El sistema envía la petición a /api/execute con action 'categoria.create'.

**Resultado esperado:**
La categoría se agrega correctamente y aparece en el listado.

**Datos de prueba:**
{ "categoria": 5, "descripcion": "ALIMENTOS" }

---

## Caso de Uso 2: Edición de una categoría existente

**Descripción:** Un usuario desea modificar la descripción de una categoría existente.

**Precondiciones:**
Existe la categoría 5 en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de categorías.
2. Hace clic en 'Editar' sobre la categoría 5.
3. Cambia la descripción a 'ALIMENTOS Y BEBIDAS'.
4. Hace clic en 'Guardar'.
5. El sistema envía la petición a /api/execute con action 'categoria.update'.

**Resultado esperado:**
La descripción de la categoría se actualiza correctamente.

**Datos de prueba:**
{ "categoria": 5, "descripcion": "ALIMENTOS Y BEBIDAS" }

---

## Caso de Uso 3: Eliminación de una categoría

**Descripción:** Un usuario desea eliminar una categoría que ya no se utiliza.

**Precondiciones:**
Existe la categoría 5 en la base de datos y no está referenciada por otras tablas.

**Pasos a seguir:**
1. El usuario accede a la página de categorías.
2. Hace clic en 'Eliminar' sobre la categoría 5.
3. Confirma la eliminación.
4. El sistema envía la petición a /api/execute con action 'categoria.delete'.

**Resultado esperado:**
La categoría se elimina correctamente del sistema.

**Datos de prueba:**
{ "categoria": 5 }

---



## Casos de Prueba

# Casos de Prueba: Módulo Categoría

## 1. Alta de Categoría Exitosa
- **Input:** { "categoria": 10, "descripcion": "ELECTRÓNICA" }
- **Acción:** categoria.create
- **Resultado esperado:** success=true, message='Categoría creada correctamente', la categoría aparece en el listado.

## 2. Alta de Categoría Duplicada
- **Input:** { "categoria": 10, "descripcion": "ELECTRÓNICA" }
- **Acción:** categoria.create (cuando ya existe la categoría 10)
- **Resultado esperado:** success=false, message='La categoría ya existe'.

## 3. Edición de Categoría Exitosa
- **Input:** { "categoria": 10, "descripcion": "ELECTRODOMÉSTICOS" }
- **Acción:** categoria.update
- **Resultado esperado:** success=true, message='Categoría actualizada correctamente', la descripción se actualiza.

## 4. Edición de Categoría Inexistente
- **Input:** { "categoria": 99, "descripcion": "INEXISTENTE" }
- **Acción:** categoria.update
- **Resultado esperado:** success=false, message='La categoría no existe'.

## 5. Eliminación Exitosa
- **Input:** { "categoria": 10 }
- **Acción:** categoria.delete
- **Resultado esperado:** success=true, message='Categoría eliminada correctamente'.

## 6. Eliminación de Categoría Inexistente
- **Input:** { "categoria": 99 }
- **Acción:** categoria.delete
- **Resultado esperado:** success=false, message='La categoría no existe'.

## 7. Listado de Categorías
- **Input:** (sin parámetros)
- **Acción:** categoria.list
- **Resultado esperado:** success=true, data contiene todas las categorías ordenadas por número.



