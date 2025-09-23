# Documentación Técnica - Migración Formulario Prepago (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel API con endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (sin tabs), navegación por rutas.
- **Base de Datos**: PostgreSQL, toda la lógica de negocio SQL encapsulada en stored procedures.

## 2. API Unificada
- **Endpoint**: `POST /api/execute`
- **Entrada**: `{ "eRequest": { "operation": "string", "params": { ... } } }`
- **Salida**: `{ "eResponse": { ... } }`
- **Operaciones soportadas**:
  - `getResumen`: Resumen de contribuyente y predio
  - `getPeriodos`: Periodos de adeudo
  - `getUltimoRequerimiento`: Último requerimiento practicado
  - `getDescuentos`: Descuentos aplicados
  - `liquidacionParcial`: Liquidación parcial para periodo dado
  - `calculaMultaVirtual`: Cálculo de multa virtual

## 3. Controlador Laravel
- Un solo controlador (`PrePagoController`) maneja todas las operaciones.
- Cada operación llama a un stored procedure correspondiente.
- Validación de parámetros y manejo de errores centralizado.

## 4. Vue.js Component
- Página independiente `/prepago/:cvecuenta`.
- Carga toda la información relevante al cargar la página.
- Permite mostrar descuentos, ver último requerimiento, y simular liquidación parcial.
- Usa fetch API para comunicarse con `/api/execute`.
- No usa tabs, cada formulario es una página.

## 5. Stored Procedures PostgreSQL
- Toda la lógica SQL y de negocio está en SPs.
- Los SPs devuelven tablas (RETURNS TABLE) para facilitar el consumo desde Laravel.
- Los cálculos de multas virtuales, descuentos, periodos, etc., están encapsulados.

## 6. Seguridad y Validación
- El endpoint valida que los parámetros requeridos estén presentes.
- Los SPs validan la existencia de la cuenta y retornan datos consistentes.
- El frontend valida los campos de entrada antes de enviar solicitudes.

## 7. Extensibilidad
- Para agregar nuevas operaciones, basta con agregar un nuevo case en el controlador y un SP correspondiente.
- El frontend puede consumir cualquier operación definida en el backend.

## 8. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.

## 9. Notas de Migración
- Los nombres de los SPs y parámetros siguen el estándar snake_case.
- Los nombres de campos y tablas se adaptan a la convención PostgreSQL.
- El frontend asume que los nombres de campos devueltos por los SPs coinciden con los usados en la UI.

---
