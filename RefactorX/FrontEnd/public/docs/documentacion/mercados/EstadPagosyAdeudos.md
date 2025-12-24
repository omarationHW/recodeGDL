# EstadPagosyAdeudos

## AnÃ¡lisis TÃ©cnico

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


## Casos de Uso

# Casos de Uso - EstadPagosyAdeudos

**Categoría:** Form

## Caso de Uso 1: Consulta de Estadística de Pagos y Adeudos por Recaudadora

**Descripción:** El usuario desea obtener la estadística consolidada de pagos, capturas y adeudos de todos los mercados de una recaudadora para un periodo y rango de fechas.

**Precondiciones:**
El usuario está autenticado y tiene permisos para consultar la recaudadora.

**Pasos a seguir:**
1. El usuario accede a la página de Estadística de Pagos y Adeudos.
2. Selecciona la recaudadora 'Zona Centro'.
3. Selecciona el año 2024 y mes 6.
4. Selecciona el rango de fechas del 2024-06-01 al 2024-06-30.
5. Presiona 'Consultar'.
6. El sistema muestra la tabla con los resultados por mercado.

**Resultado esperado:**
Se muestra la tabla con los mercados, locales pagados, importes, periodos, capturas y adeudos.

**Datos de prueba:**
rec: 1, axo: 2024, mes: 6, fecdsd: '2024-06-01', fechst: '2024-06-30'

---

## Caso de Uso 2: Exportación de Estadística a Excel

**Descripción:** El usuario desea exportar la estadística consultada a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una consulta y tiene resultados en pantalla.

**Pasos a seguir:**
1. El usuario presiona el botón 'Exportar'.
2. El sistema inicia la exportación (no implementado en este ejemplo).

**Resultado esperado:**
Se muestra un mensaje indicando que la exportación está en proceso o no implementada.

**Datos de prueba:**
N/A

---

## Caso de Uso 3: Detalle de Locales de un Mercado

**Descripción:** El usuario desea ver el detalle de pagos y adeudos de los locales de un mercado específico.

**Precondiciones:**
El usuario ya realizó una consulta y seleccionó un mercado.

**Pasos a seguir:**
1. El usuario selecciona el mercado 'Mercado Centro'.
2. El sistema llama a la acción 'getMercadoDetalle' con los parámetros correspondientes.
3. El sistema muestra el listado de locales, pagos y adeudos.

**Resultado esperado:**
Se muestra el detalle de locales con sus pagos y adeudos.

**Datos de prueba:**
rec: 1, mercado: 1

---



## Casos de Prueba

# Casos de Prueba: Estadística de Pagos y Adeudos

## Caso 1: Consulta exitosa
- **Entrada:** rec=1, axo=2024, mes=6, fecdsd='2024-06-01', fechst='2024-06-30'
- **Acción:** getEstadisticaPagosyAdeudos
- **Esperado:** status=ok, data es array con al menos un mercado, message='Estadística obtenida'

## Caso 2: Parámetros inválidos
- **Entrada:** rec='', axo='', mes='', fecdsd='', fechst=''
- **Acción:** getEstadisticaPagosyAdeudos
- **Esperado:** status=error, message indica parámetros inválidos

## Caso 3: Recaudadora sin mercados activos
- **Entrada:** rec=99, axo=2024, mes=6, fecdsd='2024-06-01', fechst='2024-06-30'
- **Acción:** getEstadisticaPagosyAdeudos
- **Esperado:** status=ok, data es array vacío, message='Estadística obtenida'

## Caso 4: Exportación no implementada
- **Entrada:** action=exportEstadisticaPagosyAdeudos
- **Esperado:** status=ok, message='Exportación en proceso (no implementado en este ejemplo)'

## Caso 5: Consulta de detalle de mercado
- **Entrada:** rec=1, mercado=1
- **Acción:** getMercadoDetalle
- **Esperado:** status=ok, data es array de locales, message='Detalle de mercado obtenido'



