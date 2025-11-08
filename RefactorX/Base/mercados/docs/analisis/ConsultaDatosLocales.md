# Documentación Técnica - ConsultaDatosLocales

## Descripción General
Este módulo permite consultar los datos generales de los locales comerciales registrados en el sistema. Permite filtrar por criterios como recaudadora, mercado, sección, local, letra, bloque o buscar por nombre. Además, permite consultar el detalle individual de un local.

## Arquitectura
- **Backend**: Laravel Controller con endpoint unificado `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend**: Componente Vue.js de página completa, sin tabs, con navegación y búsqueda.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Formato**: `{ action: 'nombreAccion', params: { ... } }`
- **Acciones soportadas**:
  - `getCatalogos`: Devuelve recaudadoras y secciones
  - `getMercadosPorOficina`: Devuelve mercados de una recaudadora
  - `buscarLocales`: Busca locales por filtros
  - `buscarPorNombre`: Busca locales por nombre
  - `getLocalIndividual`: Devuelve detalle de un local

## Stored Procedures
- Todos los queries están encapsulados en funciones PostgreSQL.
- Los procedimientos devuelven tablas (TABLE) para fácil consumo desde Laravel.

## Seguridad
- Validación de parámetros en el backend.
- Sanitización de entradas en el frontend.
- El endpoint puede ser protegido por middleware de autenticación Laravel.

## Flujo de Uso
1. El usuario accede a la página de consulta.
2. Selecciona "Local" o "Nombre" como criterio de búsqueda.
3. Si elige "Local", selecciona recaudadora, mercado, sección, etc.
4. Si elige "Nombre", ingresa el nombre o parte del nombre.
5. Al hacer clic en "Buscar", se envía la petición al endpoint unificado.
6. Se muestran los resultados en una tabla.
7. Puede consultar el detalle individual de un local.

## Consideraciones
- El frontend es completamente independiente y funcional como página.
- No se usan tabs ni componentes tabulares.
- El backend es desacoplado y puede ser reutilizado por otros clientes.

## Extensibilidad
- Se pueden agregar más filtros o columnas fácilmente.
- El endpoint puede crecer para soportar más acciones.

## Ejemplo de eRequest
```json
{
  "action": "buscarLocales",
  "params": {
    "oficina": 1,
    "num_mercado": 12,
    "categoria": 2,
    "seccion": "A",
    "local": 101,
    "letra_local": "B",
    "bloque": "C"
  }
}
```

## Ejemplo de eResponse
```json
{
  "success": true,
  "data": [
    { "id_local": 123, "oficina": 1, ... }
  ]
}
```
