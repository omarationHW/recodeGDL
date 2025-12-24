# Documentación Técnica: empresasfrm

## Análisis Técnico

# Documentación Técnica: Migración Formulario Empresas (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel (PHP 8+), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (sin tabs).
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.
- **Patrón API**: eRequest/eResponse, todas las operaciones pasan por `/api/execute`.

## 2. Backend (Laravel)
- **Controlador**: `EmpresasController`
  - Un solo método `execute(Request $request)` que recibe `{ action, params }`.
  - Cada acción (`list_empresas`, `get_empresa`, `create_empresa`, `update_empresa`, `delete_empresa`, `search_empresas`) llama a un stored procedure o consulta SQL.
  - Validación de parámetros con `Validator`.
  - Manejo de errores y respuesta unificada `{ success, data, message }`.
- **Rutas**: Definir en `routes/api.php`:
  ```php
  Route::post('/execute', [EmpresasController::class, 'execute']);
  ```
- **Seguridad**: Se recomienda agregar autenticación JWT o similar para producción.

## 3. Frontend (Vue.js)
- **Componente**: `EmpresasPage.vue`
  - Página completa, sin tabs.
  - Tabla de empresas, formulario de alta/edición, búsqueda.
  - Navegación breadcrumb.
  - Llama a `/api/execute` con `{ action, params }` para todas las operaciones.
  - Mensajes de error y éxito.
  - Validación básica en frontend.

## 4. Stored Procedures (PostgreSQL)
- Toda la lógica de inserción, actualización y borrado está en SPs:
  - `sp_empresas_create`: Inserta una empresa, retorna el registro.
  - `sp_empresas_update`: Actualiza una empresa, retorna el registro actualizado.
  - `sp_empresas_delete`: Borra una empresa, retorna la clave borrada.
- Los SPs usan parámetros nombrados y retornan tablas para fácil consumo desde Laravel.

## 5. API Unificada (eRequest/eResponse)
- Todas las operaciones pasan por `/api/execute`.
- El frontend envía `{ action: 'nombre_accion', params: { ... } }`.
- El backend responde `{ success, data, message }`.

## 6. Consideraciones de Migración
- Cada formulario Delphi se convierte en una página Vue.js independiente.
- No se usan tabs ni componentes tabulares.
- La navegación entre formularios es por rutas.
- Los reportes (impresión) deben migrarse a PDF en backend o usarse soluciones JS para impresión.
- El control de transacciones y validaciones críticas se realiza en los SPs.

## 7. Seguridad y Validación
- Validación de datos en backend y frontend.
- Manejo de errores y mensajes claros.
- Se recomienda agregar logs y auditoría en producción.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los SPs pueden evolucionar sin cambiar el frontend.

## 9. Pruebas y QA
- Casos de uso y pruebas incluidas para asegurar la funcionalidad.
- Se recomienda usar Postman y Cypress para pruebas automatizadas.

## Casos de Prueba



## Casos de Uso

# Casos de Uso - empresasfrm

**Categoría:** Form

## Caso de Uso 1: Alta de nueva empresa

**Descripción:** Un usuario administrativo da de alta una nueva empresa desde la página de Empresas.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para crear empresas.

**Pasos a seguir:**
- El usuario accede a la página de Empresas.
- Da clic en 'Nueva Empresa'.
- Llena los campos obligatorios: Propietario, RFC, Ubicación, No. ext., Colonia, Zona, Subzona.
- Da clic en 'Guardar'.

**Resultado esperado:**
La empresa se guarda en la base de datos y aparece en la lista. Se muestra mensaje de éxito.

**Datos de prueba:**
{
  "propietario": "Juan Pérez",
  "rfc": "PEJJ800101XXX",
  "ubicacion": "Av. Juárez 123",
  "numext_ubic": 123,
  "colonia_ubic": "Centro",
  "zona": 1,
  "subzona": 2
}

---

## Caso de Uso 2: Edición de empresa existente

**Descripción:** Un usuario edita los datos de una empresa ya registrada.

**Precondiciones:**
Existe al menos una empresa registrada.

**Pasos a seguir:**
- El usuario busca la empresa por nombre o RFC.
- Da clic en 'Editar'.
- Modifica el campo 'Correo electrónico'.
- Da clic en 'Guardar'.

**Resultado esperado:**
Los cambios se guardan y se reflejan en la lista. Se muestra mensaje de éxito.

**Datos de prueba:**
{
  "empresa": 1001,
  "email": "nuevo@email.com"
}

---

## Caso de Uso 3: Eliminación de empresa

**Descripción:** Un usuario elimina una empresa del sistema.

**Precondiciones:**
Existe al menos una empresa registrada.

**Pasos a seguir:**
- El usuario busca la empresa.
- Da clic en 'Eliminar'.
- Confirma la eliminación.

**Resultado esperado:**
La empresa desaparece de la lista y se muestra mensaje de éxito.

**Datos de prueba:**
{
  "empresa": 1001
}

---
