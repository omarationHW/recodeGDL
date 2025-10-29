# Documentación Técnica: Catálogo de Mercados Municipales

## Descripción General
Este módulo permite la gestión completa del catálogo de mercados municipales, incluyendo alta, edición, eliminación, consulta y generación de reportes PDF. La solución está compuesta por:

- **Backend Laravel**: Un controlador con endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend Vue.js**: Página independiente para la administración del catálogo.
- **Stored Procedures PostgreSQL**: Toda la lógica de acceso y manipulación de datos se realiza mediante SPs.
- **API Unificada**: Todas las operaciones se realizan mediante el endpoint `/api/execute`.

## Arquitectura

- **API**: `/api/execute` (POST)
  - Recibe `{ action: string, params: object }`
  - Devuelve `{ success: bool, data: any, message: string }`
- **Acciones soportadas**:
  - `getCatalogoMercados`: Listado de mercados
  - `createCatalogoMercado`: Alta
  - `updateCatalogoMercado`: Edición
  - `deleteCatalogoMercado`: Eliminación
  - `getCatalogoMercadosReporte`: Generación de PDF

## Flujo de Datos
1. El usuario navega a la página de Catálogo de Mercados.
2. Vue.js solicita el listado vía `/api/execute` con `action: getCatalogoMercados`.
3. El backend ejecuta el SP correspondiente y retorna los datos.
4. Para crear/editar/eliminar, Vue.js envía los datos del formulario y la acción correspondiente.
5. Para reporte, Vue.js solicita la generación y obtiene la URL del PDF.

## Seguridad
- Todas las operaciones requieren autenticación (no incluida aquí, pero debe integrarse con Laravel Auth).
- Los SPs validan los parámetros y sólo permiten operaciones válidas.

## Integración de Reportes
- El SP `sp_reporte_catalogo_mercados` debe integrarse con una función de generación de PDF (puede ser una extensión en PostgreSQL, un microservicio, o lógica en Laravel que consuma los datos y genere el PDF).

## Consideraciones
- El frontend es una página independiente, sin tabs ni componentes tabulares.
- El endpoint `/api/execute` es único para todas las operaciones.
- El patrón eRequest/eResponse permite fácil integración con otros módulos.

## Estructura de la Tabla `ta_11_mercados`
- oficina (smallint)
- num_mercado_nvo (smallint)
- categoria (smallint)
- descripcion (varchar)
- cuenta_ingreso (integer)
- cuenta_energia (integer)
- id_zona (smallint)
- tipo_emision (varchar)
- id_usuario (integer)
- fecha_alta (timestamp)
- fecha_modificacion (timestamp)

## Ejemplo de Petición
```json
{
  "action": "createCatalogoMercado",
  "params": {
    "oficina": 1,
    "num_mercado_nvo": 10,
    "categoria": 2,
    "descripcion": "Mercado Juárez",
    "cuenta_ingreso": 44501,
    "cuenta_energia": 12345,
    "id_zona": 3,
    "tipo_emision": "M",
    "usuario_id": 5
  }
}
```

## Ejemplo de Respuesta
```json
{
  "success": true,
  "data": null,
  "message": ""
}
```

## Errores Comunes
- Parámetros faltantes o inválidos: el backend retorna `success: false` y un mensaje de error.
- Operación no soportada: mensaje de error.

## Extensibilidad
- Se pueden agregar nuevas acciones y SPs siguiendo el mismo patrón.
- El frontend puede ser extendido para incluir filtros, exportación, etc.
