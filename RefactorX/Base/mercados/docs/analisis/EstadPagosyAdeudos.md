# Documentación Técnica: Estadística de Pagos y Adeudos

## Descripción General
Este módulo permite consultar la estadística de pagos, capturas y adeudos de locales por mercado y recaudadora, para un periodo y rango de fechas determinado. Incluye:
- Consulta de recaudadoras y mercados activos
- Consulta de estadística consolidada por mercado
- Consulta de detalle de locales por mercado
- Exportación (Excel/PDF) de los resultados (a implementar)

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` que recibe un objeto `eRequest` con acción y parámetros, y responde con `eResponse`.
- **Frontend**: Componente Vue.js de página completa, sin tabs, con formulario y tabla de resultados.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**: `{ eRequest: { action: string, params: object } }`
- **Salida**: `{ eResponse: { status: 'ok'|'error', data: any, message: string } }`

### Acciones soportadas
- `getRecaudadoras`: Lista de recaudadoras
- `getMercadosByRecaudadora`: Mercados activos de una recaudadora
- `getEstadisticaPagosyAdeudos`: Estadística consolidada por mercado
- `getMercadoDetalle`: Detalle de locales de un mercado
- `exportEstadisticaPagosyAdeudos`: Exportación (no implementado)

## Stored Procedures
- `get_recaudadoras()`: Catálogo de recaudadoras
- `get_mercados_by_recaudadora(p_rec)`: Mercados activos de una recaudadora
- `get_estadistica_pagosyadeudos(p_rec, p_axo, p_mes, p_fecdsd, p_fechst)`: Estadística consolidada
- `get_mercado_detalle(p_rec, p_mercado)`: Detalle de locales de un mercado

## Validaciones
- Todos los parámetros son requeridos y validados en el frontend y backend.
- Fechas deben ser válidas y el rango correcto.
- El usuario debe tener permisos para consultar la recaudadora.

## Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel).
- Los procedimientos almacenados no permiten SQL injection (parámetros tipados).

## Exportación
- La exportación a Excel/PDF debe implementarse como un job o endpoint adicional, reutilizando los SPs.

## Errores
- Todos los errores se devuelven en el campo `message` de `eResponse`.

## Frontend
- Página Vue.js independiente, sin tabs.
- Formulario con selección de recaudadora, año, mes, fechas.
- Tabla de resultados con totales por mercado.
- Botón de exportar (no implementado).

## Backend
- Controlador Laravel único, con switch de acciones.
- Llama a los SPs usando DB::select.
- Devuelve eResponse siempre.

## Base de Datos
- Todas las consultas y cálculos se hacen en los SPs.
- No se permite lógica SQL en el controlador.

# Ejemplo de eRequest/eResponse

**Request:**
```json
{
  "eRequest": {
    "action": "getEstadisticaPagosyAdeudos",
    "params": {
      "rec": 1,
      "axo": 2024,
      "mes": 6,
      "fecdsd": "2024-06-01",
      "fechst": "2024-06-30"
    }
  }
}
```

**Response:**
```json
{
  "eResponse": {
    "status": "ok",
    "data": [
      {
        "num_mercado_nvo": 1,
        "descripcion": "Mercado Centro",
        "localpag": 120,
        "pagospag": 50000.00,
        "periodospag": 130,
        "localcap": 110,
        "pagoscap": 48000.00,
        "periodoscap": 120,
        "localade": 10,
        "pagosade": 2000.00,
        "periodosade": 12
      }
    ],
    "message": "Estadística obtenida"
  }
}
```
