# Documentación Técnica: Migración Formulario ConIndividual (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel API con endpoint único `/api/execute` que recibe un objeto `eRequest` con el nombre del procedimiento y parámetros. Devuelve `eResponse` con los datos o error.
- **Frontend**: Vue.js SPA. Cada sección/tab del formulario Delphi es una página Vue independiente, con navegación por rutas y breadcrumbs.
- **Base de Datos**: PostgreSQL. Toda la lógica SQL se encapsula en stored procedures (SPs) que reciben parámetros y devuelven resultados.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**:
  ```json
  {
    "eRequest": {
      "procedure": "sp_get_datosrcm",
      "params": { "fol": 1234 }
    }
  }
  ```
- **Salida**:
  ```json
  {
    "eResponse": [ { ...datos... } ]
  }
  ```
- **Errores**: Devueltos en `eResponse.error`.

## Stored Procedures
- Cada consulta SQL del Delphi se convierte en un SP en PostgreSQL.
- Los SPs reciben parámetros y devuelven resultados con `SELECT`.
- Los nombres de los SPs siguen el patrón `sp_get_*`.

## Frontend (Vue.js)
- Cada página Vue corresponde a una sección del formulario original.
- El componente principal permite buscar por folio y muestra los datos generales.
- Navegación a otras páginas (Pagos, Adeudos, Descuentos, etc.) mediante rutas.
- Cada página Vue consulta su SP correspondiente usando el endpoint `/api/execute`.

## Backend (Laravel)
- Un solo controlador maneja todas las peticiones a `/api/execute`.
- Valida el nombre del SP y los parámetros.
- Ejecuta el SP usando DB::select y devuelve el resultado.
- Maneja errores y excepciones.

## Seguridad
- Solo se permite ejecutar SPs listados explícitamente.
- No se permite ejecución arbitraria de SQL.

## Extensibilidad
- Para agregar nuevas consultas, crear el SP en PostgreSQL y agregar el nombre al array `$allowedProcedures` en el controlador.

## Ejemplo de flujo
1. Usuario ingresa folio y presiona Buscar.
2. Vue llama a `/api/execute` con `sp_get_datosrcm` y el folio.
3. Laravel ejecuta el SP y devuelve los datos.
4. Vue muestra los datos y permite navegar a otras páginas.

## Notas
- Todos los SPs deben devolver los campos esperados por el frontend.
- Los nombres de campos deben coincidir entre SP y frontend.
- Para reportes o cálculos complejos, encapsular toda la lógica en el SP.
