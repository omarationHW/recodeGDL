# Documentación Técnica: consultaLicenciafrm

## Análisis Técnico

# Documentación Técnica: Migración de consultaLicenciafrm (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), PostgreSQL 13+, API RESTful
- **Frontend**: Vue.js 3 SPA (Single Page Application)
- **Base de datos**: PostgreSQL, lógica de negocio crítica en stored procedures
- **API Unificada**: Un solo endpoint `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`
- **Patrón de integración**: El frontend nunca accede directamente a la base de datos, siempre a través del endpoint Laravel

## API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: `{ eRequest: { operation: string, params: object } }`
- **Salida**: `{ eResponse: { result: any, error: string|null } }`
- **Operaciones soportadas**:
  - `search_by_licencia`: Búsqueda por número de licencia
  - `search_by_ubicacion`: Búsqueda por ubicación
  - `search_by_contribuyente`: Búsqueda por nombre de propietario
  - `search_by_tramite`: Búsqueda por número de trámite
  - `get_adeudos`: Consulta de adeudos de licencia
  - `get_pagos`: Consulta de pagos de licencia
  - `bloquear_licencia`: Bloqueo de licencia
  - `desbloquear_licencia`: Desbloqueo de licencia
  - `exportar_excel`: Exportación de resultados a Excel

## Backend (Laravel)
- **Controlador**: `ConsultaLicenciaController`
- **Método principal**: `execute(Request $request)`
- **Lógica**: Cada operación del frontend se mapea a una función SQL o stored procedure. El controlador valida la operación, ejecuta la consulta/procedimiento y retorna el resultado o error.
- **Seguridad**: Se recomienda agregar autenticación JWT y validación de permisos por usuario.

## Frontend (Vue.js)
- **Componente**: `ConsultaLicenciaPage.vue`
- **Estructura**: Página completa, sin tabs. Cada formulario es una página independiente.
- **Flujo**:
  - El usuario llena uno de los criterios de búsqueda y presiona el botón correspondiente.
  - Se hace una llamada a `/api/execute` con la operación y parámetros.
  - Los resultados se muestran en una tabla. Cada fila tiene acciones para ver detalle, pagos, adeudos, bloquear/desbloquear, exportar.
  - Los detalles, pagos y adeudos se muestran en secciones independientes.
- **UX**: Mensajes de carga, error, y confirmación. Navegación breadcrumb.

## Stored Procedures
- Toda la lógica de negocio SQL se implementa en stored procedures para garantizar atomicidad y portabilidad.
- Los procedimientos deben ser idempotentes y seguros ante SQL Injection (usar parámetros).
- Los procedimientos de bloqueo/desbloqueo deben registrar bitácora de usuario y fecha.

## Exportación a Excel
- El backend puede generar el archivo y devolver una URL temporal para descarga, o devolver los datos en base64 para descarga directa.

## Seguridad y Validaciones
- Validar que los parámetros requeridos estén presentes antes de ejecutar cualquier operación.
- Validar que el usuario tenga permisos para bloquear/desbloquear/exportar.
- Manejar errores de base de datos y devolver mensajes claros al frontend.

## Pruebas y Casos de Uso
- Se deben cubrir búsquedas, bloqueos, desbloqueos, exportación y visualización de pagos/adeudos.
- Los casos de prueba deben incluir escenarios de error y edge cases.

## Migración de Datos
- Se recomienda migrar los datos de licencias, bloqueos, pagos, etc. a PostgreSQL usando scripts ETL o herramientas como pgloader.

## Notas
- El frontend debe ser desacoplado y reutilizable para otros módulos de consulta.
- El endpoint `/api/execute` puede ser extendido para otras operaciones futuras.

## Casos de Prueba

# Casos de Prueba para ConsultaLicenciafrm

## 1. Consulta por Número de Licencia
- **Entrada**: licencia = '123456'
- **Acción**: Buscar
- **Esperado**: Se muestra la licencia 123456 con todos sus datos.

## 2. Consulta por Ubicación
- **Entrada**: ubicacion = 'AV. JUAREZ'
- **Acción**: Buscar
- **Esperado**: Se muestran todas las licencias con ubicación que contiene 'AV. JUAREZ'.

## 3. Consulta por Contribuyente
- **Entrada**: propietario = 'JUAN PEREZ'
- **Acción**: Buscar
- **Esperado**: Se muestran todas las licencias cuyo propietario contiene 'JUAN PEREZ'.

## 4. Consulta por Trámite
- **Entrada**: id_tramite = '7890'
- **Acción**: Buscar
- **Esperado**: Se muestran las licencias asociadas al trámite 7890.

## 5. Visualización de Pagos
- **Entrada**: Seleccionar licencia 123456
- **Acción**: Ver Pagos
- **Esperado**: Se muestran los pagos asociados a la licencia.

## 6. Visualización de Adeudos
- **Entrada**: Seleccionar licencia 123456
- **Acción**: Ver Adeudos
- **Esperado**: Se muestran los adeudos por año de la licencia.

## 7. Bloqueo de Licencia
- **Entrada**: Seleccionar licencia 123456
- **Acción**: Bloquear (motivo: 'Prueba')
- **Esperado**: La licencia aparece como bloqueada.

## 8. Desbloqueo de Licencia
- **Entrada**: Seleccionar licencia 123456
- **Acción**: Desbloquear (motivo: 'Prueba')
- **Esperado**: La licencia aparece como no bloqueada.

## 9. Exportación a Excel
- **Entrada**: Realizar búsqueda por ubicación 'AV. JUAREZ'
- **Acción**: Exportar a Excel
- **Esperado**: Se descarga un archivo Excel con los resultados.

## 10. Error por Faltante de Parámetro
- **Entrada**: Buscar sin ingresar ningún campo
- **Acción**: Buscar
- **Esperado**: Se muestra un mensaje de error indicando que falta un parámetro.

## Casos de Uso

# Casos de Uso - consultaLicenciafrm

**Categoría:** Form

## Caso de Uso 1: Consulta de Licencia por Número

**Descripción:** El usuario busca una licencia por su número y visualiza los detalles, pagos y adeudos.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de consulta.

**Pasos a seguir:**
[
  "El usuario ingresa el número de licencia en el campo correspondiente.",
  "Presiona el botón 'Buscar'.",
  "El sistema consulta la API con operación 'search_by_licencia'.",
  "Se muestran los resultados en la tabla.",
  "El usuario selecciona una licencia y presiona 'Detalle'.",
  "El sistema muestra los detalles completos de la licencia.",
  "El usuario puede ver pagos y adeudos asociados."
]

**Resultado esperado:**
Se muestra la información completa de la licencia, incluyendo pagos y adeudos.

**Datos de prueba:**
{
  "licencia": "123456"
}

---

## Caso de Uso 2: Bloqueo y Desbloqueo de Licencia

**Descripción:** Un usuario con permisos bloquea y luego desbloquea una licencia.

**Precondiciones:**
El usuario tiene permisos de bloqueo/desbloqueo.

**Pasos a seguir:**
[
  "El usuario busca una licencia vigente.",
  "Presiona el botón 'Bloquear'.",
  "Ingresa el motivo del bloqueo.",
  "El sistema ejecuta el stored procedure de bloqueo.",
  "La licencia aparece como bloqueada.",
  "El usuario presiona 'Desbloquear'.",
  "Ingresa el motivo del desbloqueo.",
  "El sistema ejecuta el stored procedure de desbloqueo.",
  "La licencia aparece como no bloqueada."
]

**Resultado esperado:**
La licencia cambia de estado correctamente y se registran los motivos.

**Datos de prueba:**
{
  "id_licencia": 123456,
  "tipo_bloqueo": 1,
  "motivo": "Prueba de bloqueo"
}

---

## Caso de Uso 3: Exportación de Resultados a Excel

**Descripción:** El usuario exporta los resultados de una búsqueda a un archivo Excel.

**Precondiciones:**
El usuario tiene permisos de exportación.

**Pasos a seguir:**
[
  "El usuario realiza una búsqueda de licencias.",
  "Presiona el botón 'Exportar a Excel'.",
  "El sistema genera el archivo y devuelve una URL de descarga.",
  "El usuario descarga el archivo y lo abre en Excel."
]

**Resultado esperado:**
El archivo contiene los datos de la búsqueda en formato Excel.

**Datos de prueba:**
{
  "filtros": {
    "licencia": "",
    "ubicacion": "AV. JUAREZ",
    "propietario": "",
    "id_tramite": ""
  }
}

---
