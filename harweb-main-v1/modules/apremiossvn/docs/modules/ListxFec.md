# Documentación Técnica: Migración Formulario ListxFec (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario **ListxFec** permite generar listados de requerimientos filtrados por fechas, tipo de movimiento, vigencia, módulo (aplicación), recaudadora y ejecutor. El sistema original en Delphi se migra a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos y lógica de negocio en stored procedures).

## 2. Arquitectura
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel API, endpoint único `/api/execute` que recibe eRequest con acción y parámetros.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: `{ action: string, params: object }`
- **Salida**: `{ status: 'ok'|'error', data: any, message: string }`
- **Acciones soportadas**:
  - `getVigencias`: Catálogo de vigencias
  - `getRecaudadoras`: Catálogo de recaudadoras
  - `getEjecutores`: Ejecutores por recaudadora
  - `getReport`: Reporte principal filtrado

## 4. Stored Procedures
- **sp_listxFec_get_vigencias**: Devuelve las vigencias (claves tipo 5)
- **sp_listxFec_get_recaudadoras**: Devuelve recaudadoras
- **sp_listxFec_get_ejecutores**: Devuelve ejecutores por recaudadora
- **sp_listxFec_report**: Devuelve el reporte principal según filtros

## 5. Flujo de la Página Vue.js
1. Al cargar, obtiene vigencias y recaudadoras.
2. Al seleccionar recaudadora, obtiene ejecutores.
3. El usuario selecciona filtros y fechas.
4. Al enviar, llama a `getReport` y muestra resultados en tabla.

## 6. Seguridad
- Todas las llamadas pasan por autenticación Laravel (middleware auth/api).
- Los stored procedures validan parámetros y retornan solo datos permitidos.

## 7. Consideraciones de Migración
- Se respeta la lógica de Delphi, pero se moderniza la UI y la consulta SQL.
- El endpoint es genérico y puede ser extendido para otros formularios.
- El frontend es desacoplado y puede ser reutilizado en otras rutas.

## 8. Ejemplo de eRequest/eResponse
**Request:**
```json
{
  "action": "getReport",
  "params": {
    "rec": 2,
    "modulo": 11,
    "tipo_fecha": 2,
    "fecha1": "2024-01-01",
    "fecha2": "2024-01-31",
    "vigencia": "1",
    "ejecutor": "todos"
  }
}
```
**Response:**
```json
{
  "status": "ok",
  "data": [ ... ],
  "message": ""
}
```

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los stored procedures pueden ser versionados y auditados en la base de datos.

## 10. Pruebas y Validación
- Se recomienda pruebas unitarias de los SP y pruebas de integración de la API.
- El frontend puede ser probado con Cypress o Jest.

---
