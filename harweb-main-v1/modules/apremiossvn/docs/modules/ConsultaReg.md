# Documentación Técnica: ConsultaReg (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
El módulo **ConsultaReg** permite consultar información detallada de registros requeridos en diferentes aplicaciones (Mercados, Aseo, Estacionamientos Públicos/Exclusivos, Estacionómetros, Cementerios). La migración implementa una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos y lógica de negocio).

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, componente de página independiente para ConsultaReg
- **Base de Datos:** PostgreSQL 13+, lógica encapsulada en stored procedures

## 3. API Unificada
### Endpoint
- **POST** `/api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "buscar|detalle|otro",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": { ... }
  }
  ```

### Acciones soportadas
- `buscar`: Busca un registro según el tipo de aplicación y parámetros.
- `detalle`: Obtiene el detalle de requerimientos para un registro.
- `otro`: Resetea el formulario (simula "Otro Registro").

## 4. Stored Procedures
Toda la lógica SQL se encapsula en stored procedures (ver sección `stored_procedures`).
- Cada tipo de aplicación tiene un SP de búsqueda.
- El detalle de requerimientos se obtiene con `sp_consultareg_detalle`.

## 5. Controlador Laravel
- Controlador: `ConsultaRegController`
- Método principal: `execute(Request $request)`
- Llama a los SPs según la acción y parámetros recibidos.
- Maneja errores y respuestas unificadas.

## 6. Componente Vue.js
- Página independiente: `ConsultaRegPage.vue`
- Formulario reactivo según tipo de aplicación
- Llama al endpoint `/api/execute` con la acción y parámetros
- Muestra resultados y detalle en tabla
- Permite limpiar formulario y consultar otro registro

## 7. Seguridad
- El endpoint debe protegerse con autenticación JWT o session según la política de la aplicación.
- Validar y sanear todos los parámetros recibidos antes de pasarlos a los SPs.

## 8. Extensibilidad
- Para agregar nuevas aplicaciones, crear un nuevo SP y agregar el caso en el controlador y frontend.

## 9. Pruebas
- Ver sección `use_cases` y `test_cases` para escenarios y datos de prueba.

## 10. Notas de Migración
- Los nombres de campos y tablas se han adaptado a convención snake_case y PostgreSQL.
- Los SPs devuelven siempre un solo registro (o vacío) para búsquedas.
- El frontend es completamente desacoplado y no usa tabs ni componentes tabulares.

---
