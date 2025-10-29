# Documentación Técnica: Migración IndividualPredios Delphi a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs)
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures
- **Comunicación:** El frontend consume el endpoint `/api/execute` enviando `{ eRequest: { action, params } }` y recibe `{ eResponse: { success, data, message } }`

## 2. Descripción del Módulo IndividualPredios
- Consulta y muestra los datos de un convenio/predio específico
- Muestra el estado de cuenta: total pagado, adeudos vencidos, recargos, total vencido
- Lista las parcialidades vencidas con sus recargos
- Permite navegar al detalle de pagos del convenio

## 3. Backend (Laravel Controller)
- **Método principal:** `execute(Request $request)`
- **Acciones soportadas:**
  - `getPredioById`: Devuelve los datos completos del predio/convenio
  - `getAdeudosByPredio`: Devuelve los adeudos vencidos y calcula recargos
  - `getTotPagadoByPredio`: Devuelve el total pagado
  - `getRecargosByAdeudo`: Calcula recargos para un adeudo específico
  - `getDiaVencimiento`: Devuelve el día de vencimiento para el predio
  - `getDiasInhabiles`: Devuelve los días inhábiles para una fecha
- **Validación:** Si faltan parámetros, retorna error en `eResponse.message`
- **Lógica de negocio:** Toda la lógica de cálculo de recargos y queries complejas se delega a stored procedures en PostgreSQL

## 4. Frontend (Vue.js Component)
- **Página independiente**: No usa tabs, es una vista completa
- **Props:** `id_conv_predio` (ID del convenio/predio a consultar)
- **Carga de datos:**
  - Al montar, llama a `/api/execute` para obtener los datos del predio, adeudos y pagos
  - Muestra los totales y la tabla de parcialidades vencidas
- **Acciones:**
  - Botón para ver detalle de pagos (navega a otra página)
  - Botón para regresar
- **Filtros:** Formatea moneda

## 5. Stored Procedures PostgreSQL
- Toda la lógica de negocio (queries, cálculos de recargos) está en SPs
- Los SPs devuelven tablas o valores escalares según corresponda
- Los SPs pueden ser llamados desde Laravel usando DB::select

## 6. API Unificada
- **Endpoint:** `/api/execute`
- **Entrada:** `{ eRequest: { action: string, params: object } }`
- **Salida:** `{ eResponse: { success: bool, data: any, message: string } }`
- **Ventajas:**
  - Permite desacoplar el frontend del backend
  - Facilita la integración de nuevos formularios y acciones

## 7. Seguridad
- Validación de parámetros en el backend
- Uso de parámetros en SPs para evitar SQL Injection
- Se recomienda agregar autenticación JWT o similar (no incluido aquí)

## 8. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad

## 9. Extensibilidad
- Para agregar nuevas acciones, basta con implementar el SP y agregar el case en el controlador
- El frontend puede consumir nuevas acciones sin cambios estructurales

## 10. Consideraciones de Migración
- Los nombres de tablas y campos deben coincidir con la estructura original
- Los SPs pueden ser adaptados para lógica adicional según necesidades del negocio

