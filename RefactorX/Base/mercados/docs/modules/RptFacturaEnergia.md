# Documentación Técnica: Migración RptFacturaEnergia Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el formulario de reporte de factura de energía eléctrica (RptFacturaEnergia) migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). Toda la lógica de consulta y presentación se ha adaptado para cumplir con el patrón eRequest/eResponse y un endpoint API unificado.

## 2. Arquitectura
- **Backend:** Laravel Controller (ExecuteController) con endpoint único `/api/execute`.
- **Frontend:** Componente Vue.js de página completa, independiente, sin tabs.
- **Base de Datos:** Stored Procedure PostgreSQL para encapsular la lógica SQL del reporte.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  - `eRequest`: Nombre de la operación (ej: `RptFacturaEnergia.getReport`)
  - `eParams`: Objeto con parámetros requeridos
- **Salida:**
  - `success`: true/false
  - `data`: Datos solicitados
  - `message`: Mensaje de error o información

### Ejemplo de Request
```json
{
  "eRequest": "RptFacturaEnergia.getReport",
  "eParams": {
    "oficina": 1,
    "axo": 2024,
    "periodo": 6,
    "mercado": 2
  }
}
```

## 4. Stored Procedure
- **Nombre:** `rpt_factura_energia`
- **Parámetros:**
  - `p_oficina` (int)
  - `p_axo` (int)
  - `p_periodo` (int)
  - `p_mercado` (int)
- **Retorna:** Tabla con los campos requeridos para el reporte.
- **Ventajas:**
  - Encapsula la lógica SQL compleja.
  - Facilita el mantenimiento y pruebas.

## 5. Frontend (Vue.js)
- Página independiente `/factura-energia`.
- Formulario para capturar parámetros.
- Consulta asincrónica al API.
- Presentación tabular y totales.
- Breadcrumb de navegación.

## 6. Controlador Laravel
- Centraliza todas las operaciones bajo `/api/execute`.
- Implementa lógica de ruteo por `eRequest`.
- Maneja errores y validaciones.

## 7. Seguridad
- Validación de parámetros en backend.
- El stored procedure sólo expone los datos requeridos.
- Se recomienda proteger el endpoint con autenticación JWT o similar en producción.

## 8. Pruebas y Casos de Uso
- Incluye casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez del módulo.

## 9. Extensibilidad
- Para agregar nuevos reportes o formularios, basta con:
  - Crear el stored procedure correspondiente.
  - Agregar el caso en el controlador.
  - Crear el componente Vue.js de página.

## 10. Notas de Migración
- Los nombres de campos y lógica de periodos se han respetado.
- La lógica de etiquetas de periodo se implementa en backend y frontend.
- El reporte es completamente funcional y puede exportarse a PDF/Excel desde el frontend si se requiere.
