# Documentación Técnica: Migración Formulario Facturación (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend**: Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos**: PostgreSQL (toda la lógica SQL en stored procedures)
- **Patrón API**: eRequest/eResponse (un solo endpoint, acción por parámetro)

## Flujo de Trabajo
1. **El usuario accede a la página de Facturación** (ruta Vue.js `/facturacion`)
2. **El frontend solicita el catálogo de recaudadoras** usando `action: getRecaudadoras`.
3. **El usuario selecciona la aplicación (módulo), recaudadora y rango de folios**.
4. **Al enviar el formulario**, Vue.js hace POST a `/api/execute` con `action: facturacionList` y los parámetros.
5. **Laravel recibe la petición**, valida los parámetros y llama al stored procedure correspondiente.
6. **El resultado se devuelve como JSON** y se muestra en la tabla de resultados.
7. **Exportación a Excel**: El frontend puede implementar exportación usando librerías JS (no incluido en este ejemplo).

## API: Endpoint Unificado
- **URL**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "action": "facturacionList",
    "params": {
      "modulo": 11,
      "rec": 1,
      "fol1": 100,
      "fol2": 200
    }
  }
  ```
- **Acciones soportadas**:
  - `getRecaudadoras`: Devuelve catálogo de recaudadoras
  - `facturacionList`: Devuelve listado de facturación
  - `facturacionReport`: Devuelve datos para reporte (PDF/Excel)

## Stored Procedures
- Toda la lógica de consulta/reportes está en SPs de PostgreSQL.
- Los SPs devuelven tablas (RETURNS TABLE) para fácil consumo desde Laravel.

## Seguridad
- El endpoint puede protegerse con middleware de autenticación Laravel (ej. Sanctum, JWT).
- Validación de parámetros en el controlador.

## Frontend
- Cada formulario es una página Vue.js independiente (NO tabs).
- Navegación por rutas (`/facturacion`)
- Uso de Bootstrap para estilos (opcional)
- Exportación a Excel sugerida con SheetJS o similar.

## Consideraciones
- El SP puede adaptarse para incluir más campos según el módulo seleccionado.
- El frontend puede mostrar/ocultar columnas según el módulo.
- El endpoint `/api/execute` puede ser extendido para otras acciones de otros formularios.

## Ejemplo de Respuesta
```json
{
  "success": true,
  "data": [
    {
      "folio": 101,
      "nombre": "Juan Pérez",
      "importe_global": 1234.56,
      "importe_multa": 0.00,
      "importe_recargo": 0.00,
      "importe_gastos": 0.00,
      "fecha_emision": "2024-06-01",
      "vigencia": "1"
    },
    ...
  ]
}
```

## Extensión
- Para generación de reportes PDF/Excel, se recomienda usar Laravel Excel o DomPDF, llamando al SP y generando el archivo en backend.
- El frontend puede descargar el archivo generado por un endpoint específico.

# Estructura de la Base de Datos
- **ta_15_apremios**: Tabla principal de folios/facturación
- **ta_15_ejecutores**: Catálogo de ejecutores
- **ta_12_recaudadoras**: Catálogo de recaudadoras

# Validaciones
- El rango de folios debe ser válido (`fol1 <= fol2`)
- El usuario debe tener permisos para la recaudadora seleccionada (si aplica)

# Escalabilidad
- El patrón eRequest/eResponse permite agregar más acciones sin crear múltiples endpoints.
- Los SPs pueden ser versionados y optimizados para performance.

# Pruebas
- Se recomienda usar Postman para pruebas de API y Cypress/Jest para frontend.
