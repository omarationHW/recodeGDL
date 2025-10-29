# Documentación Técnica: Migración Formulario RptEmisionRbosAbastos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario de emisión de recibos de abastos (RptEmisionRbosAbastos) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos y lógica de negocio en stored procedures). El objetivo es mantener la lógica de negocio, cálculos y reportes, pero modernizando la interfaz y la integración.

## 2. Arquitectura
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel, con endpoint único `/api/execute` que recibe eRequest/eResponse.
- **Base de Datos**: PostgreSQL, toda la lógica SQL y de negocio reside en stored procedures.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**: `{ action: 'nombreAccion', params: { ... } }`
- **Respuesta**: `{ success: bool, data: ..., message: '' }`

### Acciones soportadas para este formulario:
- `getReportData`: Obtiene el reporte principal de emisión de recibos de abastos.
- `getRequerimientos`: Obtiene los requerimientos (apremios) asociados a un local.
- `getRecargosMes`: Obtiene los recargos del mes para un año y periodo.

## 4. Stored Procedures
Toda la lógica de negocio y cálculos reside en stored procedures PostgreSQL:
- `sp_rpt_emision_rbos_abastos`: Genera el reporte principal.
- `sp_get_requerimientos_abastos`: Devuelve los requerimientos de un local.
- `sp_get_recargos_mes_abastos`: Devuelve los recargos del mes.

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Formulario para seleccionar oficina, mercado, año y periodo.
- Tabla de resultados con totales calculados en frontend.
- Modal para ver requerimientos de cada local.
- Navegación breadcrumb.
- Validaciones y mensajes de error.

## 6. Backend (Laravel)
- Controlador único con método `execute`.
- Cada acción del frontend se mapea a una función privada que llama al stored procedure correspondiente.
- Manejo de errores y logging.

## 7. Seguridad
- Validación de parámetros en backend.
- (Opcional) Autenticación JWT o session para restringir acceso.

## 8. Consideraciones de Migración
- Todos los cálculos de campos calculados (renta, rentaaxos, meses, subtotal, etc.) se realizan en el stored procedure.
- El frontend sólo muestra los datos y realiza sumatorias para totales.
- El reporte puede ser exportado a Excel desde el frontend (no incluido en este ejemplo, pero fácilmente integrable).

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar la estructura del endpoint.
- Los stored procedures pueden ser versionados y optimizados sin afectar el frontend.

## 10. Pruebas
- Se recomienda usar Postman para probar el endpoint `/api/execute` con diferentes acciones y parámetros.
- El frontend puede ser probado con datos reales y de prueba.

---
