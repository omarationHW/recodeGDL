# Documentación Técnica: Migración de GFacturacion (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend**: Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos**: PostgreSQL (stored procedures para lógica de negocio)
- **Patrón API**: eRequest/eResponse (todas las operaciones pasan por un solo endpoint)

## 2. Endpoint Unificado
- **Ruta**: `/api/execute`
- **Método**: POST
- **Entrada**: `{ eRequest: { operation: string, params: object } }`
- **Salida**: `{ eResponse: { success: bool, data: any, message: string } }`

## 3. Operaciones Soportadas
- `getTablas`: Catálogo de tablas de facturación
- `getEtiquetas`: Etiquetas de la tabla seleccionada
- `getFacturacion`: Consulta de facturación filtrada
- `getMeses`: Catálogo de meses (para UI)

## 4. Stored Procedures
- **sp_con34_gfact_02**: Consulta de facturación general (tabla, tipo, recargos, año, mes)
- **sp_get_tablas**: Catálogo de tablas
- **sp_get_etiquetas**: Catálogo de etiquetas

## 5. Flujo de la Página Vue.js
1. Al cargar, consulta las tablas (`getTablas`) y meses (`getMeses`)
2. Al seleccionar tabla, consulta etiquetas (`getEtiquetas`)
3. El usuario selecciona periodo, año, mes, tipo de consulta y recargos
4. Al hacer clic en "Consultar", llama a `getFacturacion` con los parámetros
5. Muestra resultados en tabla y suma total

## 6. Validaciones
- Año y mes requeridos si periodo es "otro"
- Tabla seleccionada obligatoria
- Si tipo es "Solo Pagados", no se permite recargos

## 7. Seguridad
- Todas las operaciones pasan por el endpoint unificado
- Validación de parámetros en el backend
- Uso de prepared statements en stored procedures

## 8. Extensibilidad
- Se pueden agregar nuevas operaciones en el controlador y SPs
- El frontend puede consumir cualquier operación agregada

## 9. Consideraciones de Migración
- Los combos y controles Delphi se migran a selects y campos Vue.js
- La lógica de Delphi para periodos, meses y validaciones se replica en JS
- El reporteador Delphi se reemplaza por tabla HTML y suma total
- El backend puede exportar a PDF/Excel si se requiere (no incluido en este ejemplo)

## 10. Ejemplo de eRequest/eResponse
### Request
```json
{
  "eRequest": {
    "operation": "getFacturacion",
    "params": {
      "par_Tab": "3",
      "par_Ade": "A",
      "Par_Rcgo": "S",
      "par_Axo": 2024,
      "par_Mes": 6
    }
  }
}
```
### Response
```json
{
  "eResponse": {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
}
```
