# Documentación Técnica: Migración de Formulario sfolios_alta (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este documento describe la migración del formulario `sfolios_alta` de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). Se implementa una API unificada bajo el endpoint `/api/execute` usando el patrón eRequest/eResponse.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel, controlador único para todas las operaciones (`ExecuteController`).
- **Base de Datos:** PostgreSQL, lógica de inserción encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  - `eRequest`: Identificador de la operación (ej: `get_infracciones`, `insert_folio_adeudo`)
  - `params`: Parámetros requeridos para la operación
- **Salida:**
  - `eResponse`: Objeto con `success`, `data`, `message`

## 4. Operaciones Disponibles
- `get_infracciones`: Catálogo de infracciones
- `get_estados`: Catálogo de estados
- `get_vigilantes`: Catálogo de vigilantes
- `get_axo_captura`: Año de captura
- `get_folio_adeudo`: Consulta folio vigente
- `get_folio_histo`: Consulta folio en histórico
- `get_calcomania`: Consulta calcomanía vigente por placa y fecha
- `get_padron_vehiculo`: Consulta datos de vehículo por placa
- `insert_folio_adeudo`: Inserta nuevo folio (usa stored procedure)

## 5. Stored Procedures
- **sp_insert_folio_adeudo:** Inserta un registro en `ta14_folios_adeudo` y retorna 'OK' o mensaje de error.

## 6. Validaciones
- Validaciones de parámetros en backend (Laravel Validator)
- Validaciones de negocio en frontend (folio único, placa válida, etc.)

## 7. Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o session según la política del sistema.

## 8. Flujo de Alta de Folio
1. El usuario ingresa los datos requeridos en la página Vue.
2. El frontend valida el folio y la placa (existencia, vigencia, etc.)
3. Al grabar, se envía la petición `insert_folio_adeudo` a la API.
4. El backend ejecuta el stored procedure y retorna el resultado.

## 9. Consideraciones
- El frontend es completamente independiente y no usa tabs.
- El backend centraliza toda la lógica de negocio y acceso a datos.
- El stored procedure encapsula la lógica de inserción para facilitar mantenibilidad y auditoría.

## 10. Extensibilidad
- Para agregar nuevas operaciones, basta con añadir un nuevo case en el controlador y, si es necesario, un nuevo stored procedure.

