# Documentación Técnica: Migración Formulario Rep_Contratos (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos**: PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón API**: eRequest/eResponse, todas las acciones pasan por un solo endpoint.

## Flujo de Datos
1. **Frontend** solicita datos (empresas, tipos de aseo, recaudadoras) vía `/api/execute` con acción específica.
2. **Backend** recibe la acción, despacha a la función/stored procedure correspondiente.
3. **Stored Procedures** devuelven los datos filtrados y ordenados según los parámetros.
4. **Frontend** muestra los resultados en tablas, permite búsqueda y selección.

## Endpoints y Acciones
- `/api/execute` (POST)
  - Entrada: `{ eRequest: { action: ..., ...params } }`
  - Salida: `{ eResponse: { ... } }`

### Acciones Soportadas
- `listar_empresas`: Lista todas las empresas.
- `listar_tipo_aseo`: Lista todos los tipos de aseo.
- `listar_recaudadoras`: Lista todas las recaudadoras.
- `buscar_empresas`: Busca empresas por nombre.
- `buscar_contratos`: Busca contratos por filtros.
- `reporte_empresa_contratos`: Reporte empresa-contratos (cabecera/detalle).
- `reporte_contratos`: Reporte solo contratos.

## Seguridad
- Se recomienda implementar autenticación JWT o session-based.
- Validar y sanitizar todos los parámetros recibidos.

## Manejo de Errores
- Todos los errores se devuelven en `eResponse.error`.
- El frontend muestra mensajes de error amigables.

## Consideraciones de Migración
- Los combos y listas Delphi se migran a selects Vue.js.
- Los reportes Delphi (QuickReport) se migran a tablas HTML y pueden exportarse a PDF/Excel desde el frontend.
- El ordenamiento y filtrado se realiza en el backend vía stored procedures.
- El frontend es completamente desacoplado y no usa tabs.

## Estructura de Stored Procedures
- Todos los SPs devuelven TABLE (PostgreSQL setof record).
- Los parámetros pueden ser NULL para indicar "todos".
- El ordenamiento se parametriza vía string (ejemplo: 'ctrol_emp,num_empresa').

## Ejemplo de Llamada API
```json
{
  "eRequest": {
    "action": "reporte_contratos",
    "empresa_id": 123,
    "tipo_aseo_id": 4,
    "vigencia": "V",
    "recaudadora_id": 2,
    "orden": "ctrol_aseo,num_contrato"
  }
}
```

## Ejemplo de Respuesta
```json
{
  "eResponse": {
    "reporte": [
      { "num_contrato": 1, "ctrol_aseo": 4, ... },
      ...
    ]
  }
}
```

## Notas de Implementación
- El frontend puede paginar los resultados si el reporte es muy grande.
- El backend puede agregar paginación en los SPs si es necesario.
- El endpoint es extensible para futuras acciones.

# Migración de Lógica Delphi
- Los métodos de inicialización de combos se migran a llamadas a los SPs de catálogo.
- La lógica de armado de queries Delphi se traslada a los SPs de reporte.
- El filtro por empresa, tipo de aseo, vigencia y recaudadora se parametriza en los SPs.
- El frontend permite búsqueda por nombre de empresa mediante un modal.

# Pruebas y Validación
- Se recomienda probar todos los filtros combinados.
- Validar que los reportes coincidan con los resultados del sistema original.
- Probar casos de error (empresa inexistente, sin contratos, etc).
