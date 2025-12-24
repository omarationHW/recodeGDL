# CategoriaMntto

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica - Migración Formulario CategoriaMntto (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend:** Laravel 10+, PostgreSQL 13+
- **Frontend:** Vue.js 2/3 SPA (Single Page Application)
- **API:** Unificada, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Base de datos:** PostgreSQL, lógica de negocio en stored procedures

## 2. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "categoria.create|categoria.update|categoria.delete|categoria.list",
    "data": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "message": "Mensaje de error o éxito",
    "data": [ ... ]
  }
  ```

## 3. Controlador Laravel
- Un solo método `execute(Request $request)`
- Ruteo por campo `action` (ej: `categoria.create`, `categoria.update`, etc)
- Validación de datos con `Validator`
- Llama a los stored procedures PostgreSQL vía `DB::select()`
- Devuelve respuesta JSON estándar

## 4. Stored Procedures PostgreSQL
- Toda la lógica de inserción, actualización, borrado y consulta está en SPs
- Cada SP retorna un registro con `success` y `message` para operaciones de escritura
- El SP de listado retorna un TABLE

## 5. Componente Vue.js
- Página independiente, sin tabs
- Formulario para alta/modificación de categoría
- Tabla de listado con acciones editar/eliminar
- Mensajes de error y éxito
- Navegación breadcrumb
- Lógica de edición y borrado inline
- Axios para llamadas a `/api/execute`

## 6. Seguridad
- Validación de datos en backend y frontend
- No se permite duplicidad de clave
- Descripción en mayúsculas (frontend y backend)

## 7. Consideraciones de Integración
- El endpoint `/api/execute` puede ser extendido para otros catálogos y procesos
- El frontend puede ser adaptado para otros catálogos con mínima modificación
- Los SPs pueden ser versionados y auditados en el esquema de la base de datos

## 8. Migración de Datos
- Para migrar datos existentes, usar scripts de ETL o migración directa a la tabla `ta_11_categoria`

## 9. Pruebas y Auditoría
- Todos los cambios quedan registrados en la base de datos
- Se recomienda auditar los cambios críticos en tablas de log si es necesario

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint
- Los SPs pueden ser reutilizados por otros sistemas


## Casos de Uso

# Casos de Uso - CategoriaMntto

**Categoría:** Form

## Caso de Uso 1: Alta de nueva categoría

**Descripción:** El usuario desea agregar una nueva categoría de mercado.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de administrador.

**Pasos a seguir:**
1. Ingresa a la página de Mantenimiento de Categorías.
2. Completa el campo 'Categoría' con el valor 5.
3. Completa el campo 'Descripción' con 'ALIMENTOS'.
4. Presiona el botón 'Agregar'.

**Resultado esperado:**
La categoría 5 con descripción 'ALIMENTOS' se agrega a la lista y aparece en la tabla.

**Datos de prueba:**
{ "categoria": 5, "descripcion": "ALIMENTOS" }

---

## Caso de Uso 2: Modificación de descripción de categoría existente

**Descripción:** El usuario desea modificar la descripción de una categoría existente.

**Precondiciones:**
La categoría 5 ya existe en la base de datos.

**Pasos a seguir:**
1. En la tabla, ubica la fila de la categoría 5.
2. Haz clic en 'Editar'.
3. Cambia la descripción a 'ALIMENTOS Y BEBIDAS'.
4. Presiona 'Actualizar'.

**Resultado esperado:**
La descripción de la categoría 5 se actualiza a 'ALIMENTOS Y BEBIDAS'.

**Datos de prueba:**
{ "categoria": 5, "descripcion": "ALIMENTOS Y BEBIDAS" }

---

## Caso de Uso 3: Eliminación de una categoría

**Descripción:** El usuario desea eliminar una categoría que no tiene dependencias.

**Precondiciones:**
La categoría 12 existe y no está referenciada por otras tablas.

**Pasos a seguir:**
1. En la tabla, ubica la fila de la categoría 12.
2. Haz clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
La categoría 12 es eliminada de la base de datos y desaparece de la tabla.

**Datos de prueba:**
{ "categoria": 12 }

---



## Casos de Prueba

# Casos de Prueba - CategoriaMntto

## 1. Alta de Categoría Válida
- **Entrada:** { "action": "categoria.create", "data": { "categoria": 3, "descripcion": "FRUTAS" } }
- **Esperado:** success=true, message='Categoría creada correctamente', la categoría aparece en el listado.

## 2. Alta de Categoría Duplicada
- **Entrada:** { "action": "categoria.create", "data": { "categoria": 3, "descripcion": "FRUTAS" } }
- **Esperado:** success=false, message='La categoría ya existe'.

## 3. Modificación de Categoría Existente
- **Entrada:** { "action": "categoria.update", "data": { "categoria": 3, "descripcion": "FRUTAS Y VERDURAS" } }
- **Esperado:** success=true, message='Categoría actualizada correctamente', la descripción se actualiza.

## 4. Modificación de Categoría Inexistente
- **Entrada:** { "action": "categoria.update", "data": { "categoria": 99, "descripcion": "NO EXISTE" } }
- **Esperado:** success=false, message='La categoría no existe'.

## 5. Eliminación de Categoría Existente
- **Entrada:** { "action": "categoria.delete", "data": { "categoria": 3 } }
- **Esperado:** success=true, message='Categoría eliminada correctamente'.

## 6. Eliminación de Categoría Inexistente
- **Entrada:** { "action": "categoria.delete", "data": { "categoria": 99 } }
- **Esperado:** success=false, message='La categoría no existe'.

## 7. Listado de Categorías
- **Entrada:** { "action": "categoria.list" }
- **Esperado:** success=true, data contiene arreglo de categorías existentes.

## 8. Validación de Campos Vacíos
- **Entrada:** { "action": "categoria.create", "data": { "categoria": "", "descripcion": "" } }
- **Esperado:** success=false, message de validación indicando campos obligatorios.



