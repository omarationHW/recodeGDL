# Documentación Técnica: Migración de Formulario Unit1 (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario "Unit1" de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El formulario genera un reporte de folios de estacionamiento para una fecha/hora específica.

## 2. Arquitectura
- **Backend**: Laravel, expone un endpoint unificado `/api/execute` que recibe peticiones con el patrón `eRequest`/`eResponse`.
- **Frontend**: Componente Vue.js como página independiente, permite seleccionar fecha/hora y muestra el reporte en tabla.
- **Base de Datos**: PostgreSQL, la lógica SQL se encapsula en un stored procedure (`report_unit1`).

## 3. API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Request**:
  - `eRequest`: Identificador de la operación (ej: `unit1_report`)
  - `params`: Parámetros requeridos (ej: `{ fechora: '2024-06-01T10:00' }`)
- **Response**:
  - `eResponse.success`: true/false
  - `eResponse.data`: Datos del reporte (array de objetos)
  - `eResponse.error`: Mensaje de error si aplica

## 4. Stored Procedure
- **Nombre**: `report_unit1`
- **Parámetro**: `fechora` (timestamp)
- **Retorna**: Tabla con columnas `aso`, `folio`, `placa`, `fecha_hora`, `estado`, `clave`, `importe`.
- **Lógica**: Une las tablas `ta_14_folios` y `ta_14_cve_importe` por `aso` y `clave`, filtra por fecha/hora y fecha_baja igual a parámetro.

## 5. Frontend (Vue.js)
- Página independiente con ruta propia.
- Formulario para seleccionar fecha/hora.
- Botón para generar reporte.
- Tabla de resultados.
- Mensajes de error y estados de carga.

## 6. Seguridad
- Validación de parámetros en backend.
- Manejo de errores y logs.
- No expone SQL ni detalles internos al frontend.

## 7. Extensibilidad
- El endpoint `/api/execute` puede manejar múltiples operaciones agregando nuevos casos en el controlador.
- El patrón eRequest/eResponse permite desacoplar frontend y backend.

## 8. Consideraciones
- El stored procedure asume que los campos y tablas existen y tienen los tipos correctos.
- El frontend espera los datos en el formato retornado por el SP.

---

# Esquema de Tablas (Referencia)
- **ta_14_folios**: aso, folio, placa, fecha_hora, estado, clave, fecha_baja
- **ta_14_cve_importe**: aso, num_clave, importe

---

# Flujo de Datos
1. Usuario selecciona fecha/hora y envía formulario.
2. Vue.js hace POST a `/api/execute` con `{ eRequest: 'unit1_report', params: { fechora } }`.
3. Laravel recibe, valida, llama a `report_unit1(fechora)` en PostgreSQL.
4. El SP retorna los datos, Laravel los empaqueta en `eResponse` y responde.
5. Vue.js muestra los resultados en tabla.
