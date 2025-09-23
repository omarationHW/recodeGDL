# Documentación Técnica: Migración ReportAutor Delphi a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend**: Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos**: PostgreSQL (todas las consultas y lógica SQL migradas a stored procedures)
- **Patrón API**: eRequest/eResponse (un solo endpoint, acción y parámetros)

## Flujo de Datos
1. **El usuario accede a la página de Reporte de Descuentos Autorizados**
2. **El frontend Vue.js** solicita la lista de recaudadoras vía `/api/execute` con acción `getRecInfo`.
3. El usuario selecciona la recaudadora y el rango de fechas.
4. Al enviar el formulario, Vue.js hace un POST a `/api/execute` con acción `getReport` y los parámetros.
5. **Laravel Controller** recibe la acción, valida los parámetros y llama al stored procedure correspondiente.
6. El resultado se regresa en formato JSON y se muestra en la tabla de resultados.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**: `{ action: string, params: object }`
- **Salida**: `{ status: 'success'|'error', data: any, message: string }`

### Acciones soportadas
- `getReport`: Obtiene el reporte de descuentos autorizados
- `getRecInfo`: Obtiene información de recaudadora/zona
- `cancelAutorizados`: Cancela autorizados vigentes
- `set100Porciento`: Actualiza porcentaje de multa a 100%

## Stored Procedures
- Toda la lógica SQL se encapsula en stored procedures PostgreSQL.
- Los procedimientos devuelven resultados en formato tabla para fácil consumo desde Laravel.

## Seguridad
- Validación de parámetros en backend (Laravel Validator)
- El endpoint requiere autenticación (middleware Laravel, no mostrado aquí)

## Frontend (Vue.js)
- Página independiente, sin tabs ni componentes tabulares.
- Navegación breadcrumb.
- Formulario reactivo con validación básica.
- Tabla de resultados con scroll horizontal si es necesario.
- Filtros y formatos para moneda y fechas.

## Consideraciones de Migración
- Los campos calculados Delphi se implementan en el stored procedure.
- Las relaciones a otras tablas (Mercados, Aseo, etc.) se resuelven vía subconsultas en el SP.
- El reporte se puede exportar desde el frontend usando librerías JS si se requiere.

## Extensibilidad
- Se pueden agregar nuevas acciones al endpoint `/api/execute` siguiendo el patrón.
- Los stored procedures pueden evolucionar sin afectar el frontend.

# Esquema de Base de Datos
- Tablas principales: `ta_15_autorizados`, `ta_15_apremios`, `ta_11_locales`, `ta_16_contratos`, `ta_16_empresas`, `ta_12_recaudadoras`, `ta_12_zonas`, `ta_12_nombrerec`, `ta_15_quienautor`, `ta_12_passwords`, `ta_12_ingreso`.

# Ejemplo de Llamada API
```json
{
  "action": "getReport",
  "params": {
    "rec": 1,
    "fecha1": "2024-01-01",
    "fecha2": "2024-01-31"
  }
}
```

# Manejo de Errores
- Si la acción no existe: status error, message descriptivo
- Si los parámetros son inválidos: status error, message de validación
- Si ocurre error SQL: status error, message de excepción

# Pruebas y Validación
- Se recomienda pruebas unitarias de los SP y pruebas de integración del endpoint.
- El frontend debe manejar errores de red y mostrar mensajes claros al usuario.
