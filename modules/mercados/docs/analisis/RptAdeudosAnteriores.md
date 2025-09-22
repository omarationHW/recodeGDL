# Documentación Técnica: Listado de Adeudos Anteriores (RptAdeudosAnteriores)

## Descripción General
Este módulo permite consultar y visualizar el listado de adeudos de años anteriores a 1996 para los mercados municipales, agrupando por local y año, mostrando información relevante como meses adeudados, renta, importe total, y datos del local.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente.
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures.
- **API**: Todas las operaciones se realizan mediante el endpoint `/api/execute`.

## Flujo de Datos
1. El usuario ingresa los parámetros (año, oficina, periodo) en el formulario Vue.
2. Vue envía un POST a `/api/execute` con `{ action: 'get_report', params: { axo, oficina, periodo } }`.
3. Laravel Controller recibe la petición, valida parámetros y ejecuta el stored procedure `rpt_adeudos_anteriores`.
4. El resultado se retorna como JSON y Vue lo muestra en una tabla.

## Endpoints
- **POST /api/execute**
  - **action**: `get_report` (para obtener el listado principal)
  - **params**: `{ axo, oficina, periodo }`
  - **action**: `get_mes_adeudo` (para obtener meses de adeudo de un local)
  - **params**: `{ id_local, axo }`

## Stored Procedures
- `rpt_adeudos_anteriores(axo, oficina, periodo)`
- `rpt_mes_adeudo_ant(id_local, axo)`

## Validaciones
- Todos los parámetros son obligatorios y deben ser numéricos.
- El año debe ser razonable (ej. 1992-1995).
- El periodo debe estar entre 1 y 12.
- La oficina debe existir en catálogo.

## Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel).
- Los parámetros deben validarse en backend.

## Manejo de Errores
- Si los parámetros son inválidos, se retorna `success: false` y un mensaje de error.
- Si ocurre un error en la base de datos, se retorna el mensaje de excepción.

## Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones relacionadas.
- Los stored procedures pueden ser reutilizados por otros reportes.

## Ejemplo de Request
```json
{
  "action": "get_report",
  "params": {
    "axo": 1994,
    "oficina": 2,
    "periodo": 7
  }
}
```

## Ejemplo de Response
```json
{
  "success": true,
  "data": [
    {
      "id_local": 123,
      "oficina": 2,
      "num_mercado": 5,
      "categoria": 1,
      "seccion": "A",
      "local": 10,
      "letra_local": "B",
      "bloque": "1",
      "nombre": "JUAN PEREZ",
      "axo": 1994,
      "totade": 1,
      "clave_cuota": 4,
      "adeudo": 1500.00,
      "recaudadora": "ZONA OLIMPICA",
      "descripcion": "MERCADO OLIMPICA",
      "renta": 150.00,
      "meses": "1,2,3,4,5,6,7",
      "datoslocal": "2 5 1 A 10 B 1"
    }
  ]
}
```

## Notas
- El frontend puede consultar los meses de adeudo de cada local usando el action `get_mes_adeudo`.
- El reporte puede ser exportado a Excel desde el frontend si se requiere.
