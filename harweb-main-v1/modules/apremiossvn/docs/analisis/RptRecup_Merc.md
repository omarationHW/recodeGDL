# Documentación Técnica: Migración RptRecup_Merc Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario de "Orden de Requerimiento de Pago y Embargo (Mercados)" originalmente en Delphi, ahora implementado como:
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (componente de página independiente)
- **Base de Datos:** PostgreSQL (con stored procedures para lógica de negocio y reportes)

## 2. Arquitectura
- **API Unificada:** Todas las operaciones se realizan mediante un endpoint único `/api/execute` usando el patrón `eRequest`/`eResponse`.
- **Stored Procedures:** Toda la lógica SQL y de reportes se encapsula en funciones de PostgreSQL.
- **Frontend:** Cada formulario es una página Vue.js independiente, sin tabs ni componentes compartidos.

## 3. Endpoints y Contratos
### Endpoint Único
- **POST** `/api/execute`
- **Body:**
```json
{
  "eRequest": "RptRecup_Merc.getReport", // o RptRecup_Merc.getRecaudadora, etc
  "params": { ... } // parámetros según operación
}
```
- **Response:**
```json
{
  "eResponse": {
    "success": true|false,
    "data": [ ... ], // o string, según operación
    "message": ""
  }
}
```

### eRequest soportados
- `RptRecup_Merc.getReport` (params: ofna, folio1, folio2)
- `RptRecup_Merc.getRecaudadora` (params: reca)
- `RptRecup_Merc.fechaAletras` (params: fecha)

## 4. Stored Procedures
- **rptrecup_merc_report:** Devuelve el reporte principal de adeudos de mercados.
- **rptrecup_merc_recaudadora:** Devuelve los datos de la recaudadora y zona.
- **fecha_aletras:** Convierte una fecha a letras en español.

## 5. Seguridad
- Se recomienda proteger el endpoint `/api/execute` con autenticación JWT o session según la política de la aplicación.
- Validar siempre los parámetros recibidos.

## 6. Frontend
- El componente Vue.js es una página completa, con formulario de consulta, tabla de resultados y opción de impresión.
- No utiliza tabs ni componentes compartidos con otros formularios.
- Incluye breadcrumbs para navegación.

## 7. Consideraciones de Migración
- Los cálculos de totales y periodos se realizan en el frontend o pueden extenderse en el stored procedure si se requiere.
- Los textos legales y plantillas de impresión pueden ser adaptados en el frontend según el diseño original.

## 8. Pruebas
- Se deben probar los casos de uso principales: consulta de reporte, consulta de recaudadora, conversión de fecha a letras.
- Verificar que los resultados coincidan con los obtenidos en el sistema Delphi original.

## 9. Extensibilidad
- Para agregar nuevos formularios, crear nuevos eRequest y stored procedures siguiendo el mismo patrón.

## 10. Mantenimiento
- Toda la lógica SQL debe mantenerse en los stored procedures para facilitar cambios futuros.
- El frontend puede ser extendido para exportar a PDF, Excel, etc., si se requiere.
