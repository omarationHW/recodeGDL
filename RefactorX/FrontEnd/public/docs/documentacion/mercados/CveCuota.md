# CveCuota

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Catálogo de Claves de Cuota (CveCuota)

## Descripción General
Este módulo permite la administración del catálogo de claves de cuota, incluyendo la consulta, alta, modificación y eliminación de claves. La solución está compuesta por:
- Un controlador Laravel que expone un endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.
- Un componente Vue.js que implementa la interfaz de usuario como página independiente.
- Stored procedures en PostgreSQL para encapsular la lógica de negocio y acceso a datos.

## Arquitectura
- **Backend**: Laravel 10+, PostgreSQL 13+, API RESTful.
- **Frontend**: Vue.js 3+, SPA, rutas independientes por formulario.
- **Base de Datos**: Tabla `ta_11_cve_cuota` con campos `clave_cuota` (smallint, PK) y `descripcion` (varchar).

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": {
      "action": "listCveCuota|createCveCuota|updateCveCuota|deleteCveCuota|getCveCuota",
      "params": { ... }
    }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "Mensaje de resultado",
      "data": [ ... ]
    }
  }
  ```

## Stored Procedures
- Toda la lógica de acceso y manipulación de datos se realiza mediante stored procedures en PostgreSQL.
- Los procedimientos están versionados y documentados.

## Seguridad
- Validación de parámetros en el controlador Laravel.
- Uso de transacciones en operaciones de escritura.
- El frontend no expone directamente los procedimientos ni la estructura de la base de datos.

## Frontend
- El componente Vue.js es una página completa, no usa tabs ni subcomponentes tabulares.
- Incluye navegación breadcrumb.
- Permite agregar, editar y listar claves de cuota.
- Mensajes de error y éxito amigables.

## Backend
- El controlador Laravel recibe todas las peticiones por el endpoint `/api/execute`.
- Cada acción del frontend se traduce en una llamada a un stored procedure.
- El patrón eRequest/eResponse permite desacoplar la lógica de negocio del transporte HTTP.

## Pruebas
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez del módulo.

# Tabla de Base de Datos
```sql
CREATE TABLE ta_11_cve_cuota (
  clave_cuota smallint PRIMARY KEY,
  descripcion varchar(50) NOT NULL
);
```

# Ejemplo de Request/Response
## Listar claves de cuota
**Request:**
```json
{
  "eRequest": { "action": "listCveCuota" }
}
```
**Response:**
```json
{
  "eResponse": {
    "success": true,
    "data": [
      { "clave_cuota": 1, "descripcion": "MENSUAL" },
      { "clave_cuota": 2, "descripcion": "BIMESTRAL" }
    ]
  }
}
```

# Notas de Migración
- El formulario Delphi se ha migrado a una arquitectura web moderna.
- Todas las operaciones de negocio se encapsulan en stored procedures para facilitar el mantenimiento y la auditoría.
- El frontend es desacoplado y puede evolucionar independientemente del backend.


## Casos de Uso

# Casos de Uso - CveCuota

**Categoría:** Form

## Caso de Uso 1: Alta de nueva clave de cuota

**Descripción:** El usuario desea agregar una nueva clave de cuota al catálogo.

**Precondiciones:**
El usuario tiene permisos de administrador y la clave no existe.

**Pasos a seguir:**
1. El usuario accede a la página de Claves de Cuota.
2. Hace clic en 'Agregar'.
3. Ingresa el número de clave (ej: 5) y la descripción (ej: 'TRIMESTRAL').
4. Presiona 'Guardar'.

**Resultado esperado:**
La clave de cuota se agrega correctamente y aparece en la lista.

**Datos de prueba:**
{ "clave_cuota": 5, "descripcion": "TRIMESTRAL" }

---

## Caso de Uso 2: Modificación de descripción de clave de cuota

**Descripción:** El usuario edita la descripción de una clave de cuota existente.

**Precondiciones:**
La clave de cuota existe.

**Pasos a seguir:**
1. El usuario accede a la página de Claves de Cuota.
2. Hace clic en 'Editar' sobre la clave 2.
3. Cambia la descripción a 'BIMESTRAL ACTUALIZADO'.
4. Presiona 'Guardar'.

**Resultado esperado:**
La descripción de la clave de cuota se actualiza correctamente.

**Datos de prueba:**
{ "clave_cuota": 2, "descripcion": "BIMESTRAL ACTUALIZADO" }

---

## Caso de Uso 3: Consulta de claves de cuota

**Descripción:** El usuario consulta el listado de claves de cuota.

**Precondiciones:**
Existen registros en la tabla ta_11_cve_cuota.

**Pasos a seguir:**
1. El usuario accede a la página de Claves de Cuota.
2. El sistema muestra la lista de claves y descripciones.

**Resultado esperado:**
Se visualizan todas las claves de cuota existentes.

**Datos de prueba:**
N/A

---



## Casos de Prueba

# Casos de Prueba: Catálogo de Claves de Cuota

## 1. Alta de clave de cuota válida
- **Input:** clave_cuota=10, descripcion="ANUAL"
- **Acción:** createCveCuota
- **Resultado esperado:** Clave agregada, success=true

## 2. Alta de clave de cuota duplicada
- **Input:** clave_cuota=1, descripcion="DUPLICADO"
- **Acción:** createCveCuota
- **Resultado esperado:** Error de clave duplicada, success=false

## 3. Modificación de descripción
- **Input:** clave_cuota=1, descripcion="MENSUAL ACTUALIZADO"
- **Acción:** updateCveCuota
- **Resultado esperado:** Descripción actualizada, success=true

## 4. Eliminación de clave existente
- **Input:** clave_cuota=10
- **Acción:** deleteCveCuota
- **Resultado esperado:** Clave eliminada, success=true

## 5. Consulta de clave específica
- **Input:** clave_cuota=2
- **Acción:** getCveCuota
- **Resultado esperado:** Devuelve registro con clave_cuota=2

## 6. Consulta de todas las claves
- **Input:** (sin parámetros)
- **Acción:** listCveCuota
- **Resultado esperado:** Lista completa de claves de cuota

## 7. Validación de campos obligatorios
- **Input:** clave_cuota=null, descripcion=""
- **Acción:** createCveCuota
- **Resultado esperado:** Error de validación, success=false



