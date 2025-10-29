# Documentación Técnica: Migración Formulario Propuestatab (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend**: Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos**: PostgreSQL 13+ (toda la lógica SQL en stored procedures)
- **Comunicación**: Patrón eRequest/eResponse (entrada/salida JSON)

## Flujo de Datos
1. El usuario accede a la página de consulta histórica de cuenta (`/propuestatab`)
2. Ingresa el número de cuenta catastral y envía la búsqueda
3. El componente Vue hace una petición POST a `/api/execute` con `{ eRequest: { action: 'list', params: { cvecuenta } } }`
4. El controlador Laravel recibe la petición, despacha la acción al stored procedure correspondiente y retorna el resultado en `eResponse`
5. El componente Vue muestra los datos y realiza peticiones adicionales para régimen, diferencias, observaciones y condominio

## API Backend
- **Endpoint único**: `/api/execute`
- **Método**: POST
- **Entrada**: `{ eRequest: { action: string, params: object } }`
- **Salida**: `{ eResponse: any }`
- **Acciones soportadas**:
  - `list`: Datos principales de la cuenta
  - `regimen`: Régimen de propiedad
  - `diferencias`: Diferencias históricas
  - `obs400`: Observaciones AS-400
  - `condominio`: Datos de condominio
  - (y otras según necesidades)

## Stored Procedures
- Toda la lógica de consulta y reporte se implementa en funciones SQL de PostgreSQL
- Cada función recibe parámetros y retorna un conjunto de resultados (TABLE)
- Se recomienda usar transacciones para operaciones de escritura

## Frontend Vue.js
- Cada formulario es una página independiente (NO TABS)
- Navegación por rutas (ej: `/propuestatab`)
- Uso de breadcrumbs para navegación
- Cada página es funcional por sí sola y puede ser accedida directamente
- Manejo de estado local para loading, error, y datos
- Uso de Axios para llamadas API

## Seguridad
- Validación de entrada en backend y frontend
- Manejo de errores y mensajes claros al usuario
- (Opcional) Autenticación JWT para proteger el endpoint

## Ejemplo de Petición
```json
POST /api/execute
{
  "eRequest": {
    "action": "list",
    "params": { "cvecuenta": 123456 }
  }
}
```

## Ejemplo de Respuesta
```json
{
  "eResponse": [
    {
      "cvecuenta": 123456,
      "cvecatnva": "A123456789",
      ...
    }
  ]
}
```

## Consideraciones de Migración
- Todos los queries Delphi se migran a stored procedures
- La lógica de tabs/pestañas se elimina: cada sección es una página
- Los datos relacionados (régimen, diferencias, obs400, condominio) se consultan por separado
- El endpoint es genérico y puede ser extendido para otras acciones

## Estructura de Carpetas
- `app/Http/Controllers/PropuestatabController.php`
- `resources/js/pages/PropuestatabPage.vue`
- `database/migrations/` (tablas)
- `database/functions/` (stored procedures)

## Pruebas y Validación
- Se recomienda usar Postman para probar el endpoint
- El frontend debe manejar todos los errores y mostrar mensajes claros

