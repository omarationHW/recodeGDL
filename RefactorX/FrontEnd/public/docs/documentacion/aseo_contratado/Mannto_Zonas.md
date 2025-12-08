# Documentación Técnica: Mannto_Zonas

## Análisis

# Documentación Técnica: Migración de Formulario Mannto_Zonas (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs)
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures
- **Seguridad:** Validación de datos en backend y frontend, manejo de errores unificado

## 2. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "ZONAS_CREATE", // o ZONAS_LIST, ZONAS_UPDATE, ZONAS_DELETE, ZONAS_GET
    "payload": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "data": [ ... ],
    "message": "Mensaje de error o éxito"
  }
  ```

## 3. Métodos soportados
- `ZONAS_LIST`: Listar todas las zonas
- `ZONAS_GET`: Obtener una zona específica (por zona y sub_zona)
- `ZONAS_CREATE`: Alta de zona
- `ZONAS_UPDATE`: Modificación de zona
- `ZONAS_DELETE`: Baja de zona (solo si no tiene empresas dependientes)
- `ZONAS_EMPRESA_DEPENDENCY`: Consulta de empresas dependientes de una zona

## 4. Validaciones
- **Zona y Sub-Zona**: Requeridos, numéricos, únicos en combinación
- **Descripción**: Requerida, máximo 80 caracteres
- **No se puede eliminar una zona si existen empresas con esa zona**

## 5. Stored Procedures
- Toda la lógica de inserción, actualización y borrado está en stored procedures PostgreSQL:
  - `sp_zonas_create(zona, sub_zona, descripcion)`
  - `sp_zonas_update(zona, sub_zona, descripcion)`
  - `sp_zonas_delete(ctrol_zona)`

## 6. Frontend (Vue.js)
- Página independiente `/catalogo/zonas`
- Tabla de zonas con acciones de editar y eliminar
- Formulario modal para alta/edición
- Confirmación modal para eliminación
- Mensajes de error y éxito
- Navegación breadcrumb

## 7. Seguridad y Manejo de Errores
- Validación en backend y frontend
- Mensajes claros en caso de error (por ejemplo, si la zona ya existe o tiene dependencias)
- Todas las operaciones son transaccionales

## 8. Pruebas y Casos de Uso
- Casos de uso y pruebas detalladas para alta, edición, eliminación y validación de dependencias

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente
- Los stored procedures pueden ser versionados y auditados

## 10. Consideraciones de Migración
- El campo `ctrol_zona` es autoincremental (serial) en PostgreSQL
- Las validaciones de negocio (existencia, dependencias) se trasladan a los stored procedures
- El frontend no usa tabs ni componentes tabulares: cada formulario es una página


## Casos de Uso

# Casos de Uso - Mannto_Zonas

**Categoría:** Form

## Caso de Uso 1: Alta de Zona Nueva

**Descripción:** El usuario desea registrar una nueva zona y sub-zona en el catálogo.

**Precondiciones:**
El usuario tiene permisos de acceso y la combinación zona/sub-zona no existe.

**Pasos a seguir:**
1. El usuario accede a la página de Catálogo de Zonas.
2. Hace clic en 'Nueva Zona'.
3. Ingresa los valores: Zona=10, Sub-Zona=1, Descripción='Zona Industrial Norte'.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La zona se crea correctamente y aparece en la lista. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "zona": 10, "sub_zona": 1, "descripcion": "Zona Industrial Norte" }

---

## Caso de Uso 2: Intento de Alta Duplicada

**Descripción:** El usuario intenta registrar una zona/sub-zona que ya existe.

**Precondiciones:**
Ya existe una zona con Zona=10 y Sub-Zona=1.

**Pasos a seguir:**
1. El usuario accede a la página de Catálogo de Zonas.
2. Hace clic en 'Nueva Zona'.
3. Ingresa los valores: Zona=10, Sub-Zona=1, Descripción='Zona Industrial Norte'.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la zona/sub-zona ya existe.

**Datos de prueba:**
{ "zona": 10, "sub_zona": 1, "descripcion": "Zona Industrial Norte" }

---

## Caso de Uso 3: Eliminación de Zona con Dependencias

**Descripción:** El usuario intenta eliminar una zona que tiene empresas asociadas.

**Precondiciones:**
Existe una zona con ctrol_zona=5 y al menos una empresa con ctrol_zona=5.

**Pasos a seguir:**
1. El usuario accede a la página de Catálogo de Zonas.
2. Hace clic en 'Eliminar' en la fila de la zona con ctrol_zona=5.
3. Confirma la eliminación.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que existen empresas con esta zona y no se puede borrar.

**Datos de prueba:**
{ "ctrol_zona": 5 }

---



## Casos de Prueba

# Casos de Prueba para Catálogo de Zonas

## 1. Alta de Zona Nueva
- **Entrada:** zona=20, sub_zona=2, descripcion='Zona Comercial Sur'
- **Acción:** ZONAS_CREATE
- **Esperado:** success=true, message='Zona creada correctamente', la zona aparece en la lista

## 2. Alta de Zona Duplicada
- **Entrada:** zona=20, sub_zona=2, descripcion='Zona Comercial Sur'
- **Acción:** ZONAS_CREATE
- **Esperado:** success=false, message='Ya existe la zona/sub-zona'

## 3. Edición de Zona
- **Entrada:** zona=20, sub_zona=2, descripcion='Zona Comercial Sur Actualizada'
- **Acción:** ZONAS_UPDATE
- **Esperado:** success=true, message='Zona actualizada correctamente', la descripción se actualiza

## 4. Eliminación de Zona sin Dependencias
- **Entrada:** ctrol_zona=8
- **Acción:** ZONAS_DELETE
- **Esperado:** success=true, message='Zona eliminada correctamente', la zona desaparece de la lista

## 5. Eliminación de Zona con Dependencias
- **Entrada:** ctrol_zona=5 (tiene empresas asociadas)
- **Acción:** ZONAS_DELETE
- **Esperado:** success=false, message='Existen empresas con esta zona. No se puede borrar.'

## 6. Validación de Campos Vacíos
- **Entrada:** zona='', sub_zona='', descripcion=''
- **Acción:** ZONAS_CREATE
- **Esperado:** success=false, message de validación indicando campos requeridos

## 7. Consulta de Empresas Dependientes
- **Entrada:** ctrol_zona=5
- **Acción:** ZONAS_EMPRESA_DEPENDENCY
- **Esperado:** success=true, data contiene lista de empresas con ctrol_zona=5


