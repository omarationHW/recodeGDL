# Documentación Técnica: Migración Formulario Gastos Cobrados (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo permite consultar, visualizar y exportar los pagos de gastos de cobranza realizados en un rango de fechas y por recaudadora. Incluye la migración de la lógica Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos y stored procedures).

## 2. Arquitectura
- **Backend:** Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js 3 SPA (componente de página independiente)
- **Base de Datos:** PostgreSQL 13+ (stored procedures para lógica de negocio y reportes)

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada (eRequest):**
  - `action`: Acción a ejecutar (`getRecaudadoras`, `getPagosGastosCob`, `getPagosGastosCobPorRecaudadora`, `exportPagosGastosCob`)
  - `params`: Parámetros específicos de la acción
  - `user`: (opcional) Usuario autenticado
- **Salida (eResponse):**
  - `status`: `success` | `error`
  - `data`: Datos de respuesta (array, objeto, etc.)
  - `message`: Mensaje de estado

## 4. Stored Procedures
- **spd_12_gastoscob:** Devuelve los pagos de gastos de cobranza en un rango de fechas y recaudadora.
- **spd_12_gastoscobxrec:** Devuelve los pagos de gastos de cobranza por recaudadora en un rango de fechas.

Ambos SPs devuelven los datos listos para ser mostrados en la tabla y exportados a Excel.

## 5. Frontend (Vue.js)
- Página independiente `/gastos-cobrados`.
- Formulario de filtros: recaudadora, fecha desde, fecha hasta, tipo de consulta.
- Tabla de resultados con totales.
- Botón de exportar a Excel (CSV).
- Manejo de loading y errores.

## 6. Backend (Laravel)
- Controlador único `GastosCobController` con método `execute`.
- Validación de parámetros.
- Llamada a stored procedures vía DB::select.
- Respuesta unificada eRequest/eResponse.

## 7. Seguridad
- Validación de parámetros en backend.
- (Opcional) Middleware de autenticación para restringir acceso.

## 8. Exportación
- Exportación a Excel/CSV se realiza en frontend (JS) para simplicidad, pero puede implementarse en backend si se requiere.

## 9. Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden ser extendidos para incluir más columnas o lógica.

## 10. Consideraciones de Migración
- Los nombres de campos y lógica de joins se adaptaron a la estructura PostgreSQL.
- Se recomienda revisar los tipos de datos y optimizar los índices en las tablas involucradas.

# Diagrama de Flujo
1. Usuario accede a `/gastos-cobrados`.
2. Vue carga recaudadoras vía `/api/execute?action=getRecaudadoras`.
3. Usuario selecciona filtros y envía formulario.
4. Vue envía `/api/execute?action=getPagosGastosCob` (o `getPagosGastosCobPorRecaudadora`) con parámetros.
5. Laravel ejecuta el SP correspondiente y retorna los datos.
6. Vue muestra la tabla y permite exportar a Excel.

# Ejemplo de eRequest/eResponse
**eRequest:**
```json
{
  "action": "getPagosGastosCob",
  "params": {
    "fecha_desde": "2024-01-01",
    "fecha_hasta": "2024-01-31",
    "id_rec": 1
  }
}
```
**eResponse:**
```json
{
  "status": "success",
  "data": [
    { "r_fecp": "2024-01-02", "r_rec": 1, ... },
    ...
  ],
  "message": "Pagos de gastos de cobranza obtenidos."
}
```

# Notas
- El frontend es completamente independiente y no usa tabs.
- El backend es desacoplado y puede ser consumido por otros sistemas.
- Los stored procedures están optimizados para reporting.
