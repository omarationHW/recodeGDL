# CuotasMdoMntto

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: CuotasMdoMntto (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo permite la administración de las cuotas de mercado por año (ta_11_cuo_locales), incluyendo alta, modificación, eliminación y consulta. Se implementa como una página Vue.js independiente, con backend en Laravel y lógica de negocio en stored procedures PostgreSQL. El API es unificado bajo el endpoint `/api/execute` usando el patrón eRequest/eResponse.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, página independiente, sin tabs.
- **Backend:** Laravel Controller único, endpoint `/api/execute`.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.
- **Comunicación:** JSON, patrón eRequest/eResponse.

## 3. API (Laravel Controller)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "list|create|update|delete|catalogs|get",
      "data": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```
- **Acciones soportadas:**
  - `list`: Listar todas las cuotas
  - `create`: Crear nueva cuota
  - `update`: Actualizar cuota existente
  - `delete`: Eliminar cuota
  - `catalogs`: Obtener catálogos auxiliares (categoría, sección, clave cuota)
  - `get`: Obtener detalle de una cuota

## 4. Stored Procedures
- Toda la lógica de negocio y validación de duplicados está en los SPs.
- Los SPs devuelven boolean para operaciones de escritura.
- El SP de listado devuelve tabla.

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Formulario para alta/modificación.
- Tabla de listado con acciones editar/eliminar.
- Validación en frontend y backend.
- Navegación breadcrumb.
- Mensajes de éxito/error.

## 6. Seguridad
- El id_usuario debe ser proporcionado por el frontend (en producción, tomar del usuario autenticado).
- Validación de datos en backend y frontend.

## 7. Consideraciones
- El endpoint es único y multipropósito.
- Los catálogos se obtienen vía acción `catalogs`.
- El frontend debe refrescar el listado tras cada operación.

## 8. Migración de SQL
- Todas las operaciones SQL directas se migran a SPs.
- El control de duplicados y validación de existencia se realiza en los SPs.

## 9. Pruebas
- Casos de uso y pruebas incluidas más abajo.



## Casos de Uso

# Casos de Uso - CuotasMdoMntto

**Categoría:** Form

## Caso de Uso 1: Alta de nueva cuota de mercado

**Descripción:** El usuario desea registrar una nueva cuota para el año 2024, categoría 1, sección 'A', clave de cuota 1001, importe 1234.56.

**Precondiciones:**
El usuario tiene permisos de escritura. No existe una cuota para la combinación año/categoría/sección/clave_cuota.

**Pasos a seguir:**
1. El usuario accede a la página de Cuotas de Mercado.
2. Hace clic en 'Crear'.
3. Llena el formulario con: Año=2024, Categoría=1, Sección='A', Clave de Cuota=1001, Importe=1234.56.
4. Hace clic en 'Crear'.
5. El sistema valida y llama al endpoint con acción 'create'.

**Resultado esperado:**
La cuota es registrada y aparece en el listado. Mensaje de éxito.

**Datos de prueba:**
{ "axo": 2024, "categoria": 1, "seccion": "A", "clave_cuota": 1001, "importe": 1234.56, "id_usuario": 1 }

---

## Caso de Uso 2: Modificación de cuota existente

**Descripción:** El usuario desea modificar el importe de una cuota existente (id_cuotas=5) a 1500.00.

**Precondiciones:**
Existe la cuota con id_cuotas=5.

**Pasos a seguir:**
1. El usuario localiza la cuota en el listado y hace clic en 'Editar'.
2. Cambia el importe a 1500.00.
3. Hace clic en 'Actualizar'.
4. El sistema valida y llama al endpoint con acción 'update'.

**Resultado esperado:**
El importe es actualizado. Mensaje de éxito.

**Datos de prueba:**
{ "id_cuotas": 5, "axo": 2024, "categoria": 1, "seccion": "A", "clave_cuota": 1001, "importe": 1500.00, "id_usuario": 1 }

---

## Caso de Uso 3: Eliminación de cuota

**Descripción:** El usuario desea eliminar una cuota existente (id_cuotas=7).

**Precondiciones:**
Existe la cuota con id_cuotas=7.

**Pasos a seguir:**
1. El usuario localiza la cuota en el listado y hace clic en 'Eliminar'.
2. Confirma la eliminación.
3. El sistema llama al endpoint con acción 'delete'.

**Resultado esperado:**
La cuota es eliminada del listado. Mensaje de éxito.

**Datos de prueba:**
{ "id_cuotas": 7 }

---



## Casos de Prueba

# Casos de Prueba: CuotasMdoMntto

## 1. Alta exitosa de cuota
- **Input:**
  - axo: 2024
  - categoria: 1
  - seccion: 'A'
  - clave_cuota: 1001
  - importe: 1234.56
  - id_usuario: 1
- **Acción:** create
- **Esperado:**
  - success: true
  - message: 'Registro creado correctamente'
  - La cuota aparece en el listado

## 2. Alta duplicada (misma combinación año/categoría/sección/clave_cuota)
- **Input:** (igual que el anterior)
- **Acción:** create
- **Esperado:**
  - success: false
  - message: 'Registro duplicado' o similar

## 3. Modificación exitosa
- **Input:**
  - id_cuotas: 5
  - axo: 2024
  - categoria: 1
  - seccion: 'A'
  - clave_cuota: 1001
  - importe: 1500.00
  - id_usuario: 1
- **Acción:** update
- **Esperado:**
  - success: true
  - message: 'Registro actualizado correctamente'
  - El importe se actualiza en el listado

## 4. Eliminación exitosa
- **Input:**
  - id_cuotas: 7
- **Acción:** delete
- **Esperado:**
  - success: true
  - message: 'Registro eliminado correctamente'
  - La cuota desaparece del listado

## 5. Eliminación de registro inexistente
- **Input:**
  - id_cuotas: 9999
- **Acción:** delete
- **Esperado:**
  - success: false
  - message: 'Error al eliminar registro' o similar

## 6. Validación de importe cero
- **Input:**
  - importe: 0
- **Acción:** create
- **Esperado:**
  - success: false
  - message: 'El campo importe debe ser mayor a cero' o similar

## 7. Listado de cuotas
- **Acción:** list
- **Esperado:**
  - success: true
  - data: array de cuotas

## 8. Consulta de catálogos
- **Acción:** catalogs
- **Esperado:**
  - success: true
  - data: { categorias, secciones, claves }



