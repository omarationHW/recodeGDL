# CuotasMdo

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario CuotasMdo (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8+), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.
- **Patrón API:** eRequest/eResponse (acción + parámetros).

## 2. Endpoint API Unificado
- **Ruta:** `/api/execute` (POST)
- **Request:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "data": [...],
    "message": "..."
  }
  ```

## 3. Controlador Laravel
- Un solo método `execute` que despacha según `action`.
- Validación de parámetros con `Validator`.
- Llama a stored procedures vía DB::select/DB::statement.
- Maneja errores y devuelve mensajes claros.

## 4. Stored Procedures PostgreSQL
- Toda la lógica de CRUD y catálogos está en stored procedures.
- Ejemplo: `sp_cuotasmdo_list`, `sp_cuotasmdo_create`, etc.
- Cada SP retorna datos en formato tabla o VOID según corresponda.

## 5. Componente Vue.js
- Página independiente para CuotasMdo.
- Tabla con listado, botones para agregar/editar/eliminar.
- Modal para crear/editar.
- Usa axios para consumir `/api/execute`.
- Filtros para moneda y fecha.
- Breadcrumb para navegación.

## 6. Seguridad
- Validación de usuario (`id_usuario`) en cada operación.
- Los stored procedures pueden ser extendidos para validar permisos si es necesario.

## 7. Extensibilidad
- El endpoint `/api/execute` puede despachar cualquier acción del sistema.
- Los catálogos (categorías, secciones, claves de cuota) se obtienen vía SPs.

## 8. Manejo de Errores
- El backend devuelve `success: false` y un mensaje en caso de error.
- El frontend muestra alertas en caso de error.

## 9. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para QA y UAT.

## 10. Notas de Migración
- Los nombres de tablas y campos se mantienen fieles al modelo Delphi.
- Los triggers y lógica de negocio compleja deben migrarse a SPs.
- El frontend NO usa tabs, cada formulario es una página.

---


## Casos de Uso

# Casos de Uso - CuotasMdo

**Categoría:** Form

## Caso de Uso 1: Alta de nueva cuota de mercado

**Descripción:** Un usuario autorizado desea agregar una nueva cuota de mercado para el año actual.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos para crear cuotas.

**Pasos a seguir:**
1. El usuario accede a la página 'Cuotas de Mercados'.
2. Hace clic en 'Agregar'.
3. Llena el formulario con año, categoría, sección, clave de cuota, importe y su ID de usuario.
4. Hace clic en 'Guardar'.
5. El sistema valida y envía la petición al backend.

**Resultado esperado:**
La cuota se agrega correctamente y aparece en el listado.

**Datos de prueba:**
{ "axo": 2024, "categoria": 1, "seccion": "A1", "clave_cuota": 2, "importe_cuota": 1500.00, "id_usuario": 5 }

---

## Caso de Uso 2: Edición de cuota existente

**Descripción:** Un usuario necesita modificar el importe de una cuota ya existente.

**Precondiciones:**
Debe existir al menos una cuota en el sistema.

**Pasos a seguir:**
1. El usuario accede a la página 'Cuotas de Mercados'.
2. Ubica la cuota a editar y hace clic en 'Editar'.
3. Modifica el campo 'Importe'.
4. Hace clic en 'Actualizar'.

**Resultado esperado:**
El importe de la cuota se actualiza y se refleja en el listado.

**Datos de prueba:**
{ "id_cuotas": 10, "axo": 2024, "categoria": 1, "seccion": "A1", "clave_cuota": 2, "importe_cuota": 1800.00, "id_usuario": 5 }

---

## Caso de Uso 3: Eliminación de cuota

**Descripción:** Un usuario elimina una cuota de mercado que ya no es válida.

**Precondiciones:**
Debe existir la cuota a eliminar.

**Pasos a seguir:**
1. El usuario accede a la página 'Cuotas de Mercados'.
2. Hace clic en 'Eliminar' en la cuota deseada.
3. Confirma la eliminación.

**Resultado esperado:**
La cuota desaparece del listado y no puede ser utilizada en operaciones futuras.

**Datos de prueba:**
{ "id_cuotas": 10 }

---



## Casos de Prueba

# Casos de Prueba para CuotasMdo

## 1. Alta de cuota válida
- **Entrada:** Todos los campos requeridos completos y válidos.
- **Acción:** Enviar acción `create_cuota`.
- **Esperado:** Respuesta `success: true`, la cuota aparece en el listado.

## 2. Alta de cuota con importe cero
- **Entrada:** Importe = 0
- **Acción:** Enviar acción `create_cuota`.
- **Esperado:** Respuesta `success: false`, mensaje de error de validación.

## 3. Edición de cuota existente
- **Entrada:** Modificar importe de cuota existente.
- **Acción:** Enviar acción `update_cuota`.
- **Esperado:** Respuesta `success: true`, importe actualizado en el listado.

## 4. Eliminación de cuota
- **Entrada:** ID de cuota existente.
- **Acción:** Enviar acción `delete_cuota`.
- **Esperado:** Respuesta `success: true`, cuota ya no aparece en el listado.

## 5. Listado de cuotas por año
- **Entrada:** Año específico.
- **Acción:** Enviar acción `list_cuotas`.
- **Esperado:** Respuesta `success: true`, lista de cuotas del año solicitado.

## 6. Listado de catálogos
- **Entrada:** Ninguna.
- **Acción:** Enviar acción `get_categorias`, `get_secciones`, `get_claves_cuota`.
- **Esperado:** Respuesta `success: true`, datos de catálogo correspondientes.

## 7. Error de parámetros faltantes
- **Entrada:** Falta campo requerido (ej: sin 'categoria').
- **Acción:** Enviar acción `create_cuota`.
- **Esperado:** Respuesta `success: false`, mensaje de error de validación.



