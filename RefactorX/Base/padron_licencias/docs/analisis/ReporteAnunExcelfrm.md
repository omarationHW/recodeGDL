# Documentación Técnica: Migración Formulario ReporteAnunExcel (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel API, endpoint único `/api/execute` (POST)
- **Frontend**: Vue.js SPA, página independiente para el formulario
- **Base de Datos**: PostgreSQL, lógica de reportes en stored procedures
- **Comunicación**: eRequest/eResponse (action, params)

## 2. API Backend
- **Controlador**: `ReporteAnunExcelController`
- **Métodos principales**:
  - `getGruposAnun`: Devuelve lista de grupos de anuncios
  - `getReporteAnuncios`: Ejecuta el SP de reporte con filtros
  - `exportReporteAnuncios`: Genera archivo Excel y devuelve URL
- **Endpoint único**: `/api/execute` (POST)
  - Entrada: `{ action: string, params: object }`
  - Salida: `{ status: 'success'|'error', data: any, message: string }`

## 3. Frontend Vue.js
- **Componente**: `ReporteAnunExcelPage.vue`
- **Características**:
  - Formulario con todos los filtros (vigencia, tipo reporte, fechas, adeudo, grupo)
  - Botón para consultar y exportar a Excel
  - Tabla de resultados dinámica
  - Descarga de Excel vía URL
  - Sin tabs, es página completa

## 4. Stored Procedure PostgreSQL
- **Nombre**: `sp_reporte_anuncios_excel`
- **Entradas**: Filtros del formulario (vigencia, tipo reporte, fechas, adeudo, grupo, etc)
- **Salida**: Tabla con columnas del reporte
- **Lógica**: Construcción dinámica del SQL según filtros, agrupaciones y joins

## 5. Flujo de Datos
1. Usuario accede a la página `/reporte-anuncios`
2. Vue.js carga grupos de anuncios vía `getGruposAnun`
3. Usuario llena filtros y presiona "Consultar"
4. Vue.js envía eRequest a `/api/execute` con action `getReporteAnuncios`
5. Laravel llama el SP y devuelve resultados
6. Usuario puede exportar a Excel (action `exportReporteAnuncios`)

## 6. Seguridad
- Validación de parámetros en backend
- Solo lectura (no hay escritura en este formulario)
- Exportación de Excel solo para usuarios autenticados

## 7. Consideraciones
- El SP puede ser optimizado para índices y performance
- El endpoint `/api/execute` puede ser usado por otros formularios
- El frontend es desacoplado, puede integrarse en cualquier SPA

## 8. Extensibilidad
- Se pueden agregar más filtros en el SP y el formulario
- El patrón eRequest/eResponse permite versionar acciones fácilmente

## 9. Ejemplo de eRequest/eResponse
```json
{
  "action": "getReporteAnuncios",
  "params": {
    "vigencia": 1,
    "tipoRep": 0,
    "fechaCons": "2024-06-01",
    "adeudo": 2,
    "axoIni": 2023,
    "grupoAnunId": 5
  }
}
```

## 10. Integración
- El endpoint `/api/execute` debe estar registrado en `routes/api.php` y apuntar al método `execute` del controlador.
- El frontend debe importar el componente y agregar la ruta correspondiente en el router de Vue.js.

---
