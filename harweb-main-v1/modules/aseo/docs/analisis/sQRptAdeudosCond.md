# Documentación Técnica: Migración de Formulario sQRptAdeudosCond (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al reporte de "Adeudos Condonados de Aseo Contratado". El sistema original en Delphi usaba QuickReport y consultas SQL directas. La migración implementa:
- Backend en Laravel (API REST unificada)
- Frontend en Vue.js (página independiente)
- Lógica SQL en stored procedure PostgreSQL
- API unificada con patrón eRequest/eResponse

## 2. Backend (Laravel)
- **Controlador:** `App\Http\Controllers\Api\ExecuteController`
- **Endpoint:** `POST /api/execute`
- **Patrón:** eRequest/eResponse
- **Método relevante:**
  - `getAdeudosCondonados`: Llama al stored procedure `rpt_adeudos_condonados` con parámetros `control_contrato` y `opcion`.
- **Respuesta:**
  - `success`: boolean
  - `data`: array de resultados
  - `error`: mensaje de error si aplica

## 3. Frontend (Vue.js)
- **Componente:** Página completa `AdeudosCondonadosPage`
- **Ruta:** Independiente (no tab)
- **Funcionalidad:**
  - Formulario para ingresar No. Contrato y opción de clasificación
  - Consulta al endpoint `/api/execute`
  - Renderizado de tabla de resultados y totales por contrato
  - Breadcrumb de navegación

## 4. Stored Procedure (PostgreSQL)
- **Nombre:** `rpt_adeudos_condonados`
- **Parámetros:**
  - `p_control_contrato` (integer)
  - `p_opcion` (smallint): 1=Periodo de Pago, 2=Operación
- **Retorna:** Tabla con todos los campos requeridos para el reporte
- **Lógica:**
  - Realiza los JOINs y filtros equivalentes al SQL Delphi
  - Ordena según la opción seleccionada

## 5. API Unificada
- **Patrón:** eRequest/eResponse
- **Endpoint único:** `/api/execute`
- **Payload ejemplo:**
```json
{
  "eRequest": "getAdeudosCondonados",
  "params": {
    "control_contrato": 1228,
    "opcion": 1
  }
}
```
- **Respuesta:**
```json
{
  "success": true,
  "data": [ ... ],
  "error": null
}
```

## 6. Seguridad
- Validar que el parámetro `control_contrato` sea obligatorio y numérico
- Manejar errores y excepciones en el controlador

## 7. Pruebas
- Casos de uso y pruebas incluidas más abajo

## 8. Consideraciones
- El frontend calcula los totales por contrato de manera similar al reporte original
- El stored procedure puede ser extendido para incluir más lógica de agregados si se requiere

## 9. Extensibilidad
- Se pueden agregar nuevos eRequest fácilmente en el controlador
- El frontend puede ser adaptado para exportar a PDF/Excel si se requiere
