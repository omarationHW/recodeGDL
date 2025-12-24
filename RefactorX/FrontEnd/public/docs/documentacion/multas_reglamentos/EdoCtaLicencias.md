# Documentación: EdoCtaLicencias

## Análisis Técnico

# Documentación Técnica: Migración EdoCtaLicencias Delphi a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8.1+) usando un único endpoint `/api/execute` para todas las operaciones (patrón eRequest/eResponse).
- **Frontend:** Vue.js 3 SPA. Cada formulario es una página independiente, sin tabs.
- **Base de Datos:** PostgreSQL. Toda la lógica SQL se encapsula en stored procedures y vistas.
- **Comunicación:** El frontend envía peticiones JSON a `/api/execute` con la acción y parámetros. El backend responde con JSON.

## 2. Endpoints y Flujo
- **POST /api/execute**
  - Entrada: `{ eRequest: { action: 'search'|'totals'|'print'|'cancel'|..., params: { ... } } }`
  - Salida: `{ eResponse: { ... } }`

## 3. Controlador Laravel
- Un solo controlador maneja todas las acciones.
- Cada acción (search, totals, print, cancel, etc.) llama a un método privado que ejecuta el SP correspondiente o lógica de negocio.
- Los errores se devuelven en `eResponse.error`.

## 4. Componente Vue.js
- Página independiente para EdoCtaLicencias.
- Formulario de búsqueda por tipo y folio.
- Botones para ver totales, imprimir y cancelar descuento.
- Muestra resultados y mensajes de error.

## 5. Stored Procedures
- Toda la lógica de consulta y cálculo se implementa en SPs de PostgreSQL.
- Ejemplo: `spget_lic_grales`, `spget_lic_adeudos`, `spget_lic_totales`, `odoo_adeudos_detalle_12`.
- Las vistas `v_lic_grales`, `v_lic_adeudos`, etc. deben existir y mapear la lógica de negocio.

## 6. Seguridad
- Validación de parámetros en backend.
- Control de permisos en SPs y/o middleware Laravel.

## 7. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad.

## 8. Consideraciones de Migración
- Los tabs Delphi se migran a páginas independientes en Vue.
- Los reportes Delphi (QuickReport) se migran a generación de PDF en backend o frontend.
- Los stored procedures Delphi se convierten a funciones y procedimientos PostgreSQL.
- El endpoint `/api/execute` es el único punto de entrada para el frontend.

## 9. Ejemplo de Petición
```json
{
  "eRequest": {
    "action": "search",
    "params": {
      "tipo": "L",
      "folio": 12345
    }
  }
}
```

## 10. Ejemplo de Respuesta
```json
{
  "eResponse": {
    "data": [ { ... } ]
  }
}
```

## 11. Extensibilidad
- Para agregar nuevas acciones, basta con añadir un nuevo método en el controlador y mapearlo en el switch.
- Los formularios adicionales se implementan como páginas Vue independientes.

## 12. Notas
- El frontend puede usar breadcrumbs para navegación.
- El backend puede generar PDFs usando librerías Laravel (dompdf, snappy, etc.) si se requiere impresión real.
- Los stored procedures pueden ser adaptados para lógica adicional según reglas de negocio.

## Casos de Uso

> ⚠️ Pendiente de documentar

## Casos de Prueba

> ⚠️ Pendiente de documentar

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

