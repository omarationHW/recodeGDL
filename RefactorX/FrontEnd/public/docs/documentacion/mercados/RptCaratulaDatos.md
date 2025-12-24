# RptCaratulaDatos

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: RptCaratulaDatos

## Descripción General
Este módulo corresponde a la migración del formulario "Carátula de Locales" (RptCaratulaDatos) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos). El objetivo es ofrecer una consulta detallada de los datos de un local, incluyendo sus adeudos, recargos, y estado financiero, con lógica de negocio centralizada en stored procedures y un endpoint API unificado.

## Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "getRptCaratulaDatos",
    "params": {
      "id_local": 123,
      "renta": 1000.00,
      "adeudo": 500.00,
      "recargos": 50.00,
      "gastos": 10.00,
      "multa": 0.00,
      "total": 560.00,
      "folios": "1234,1235,",
      "leyenda": "Desc. pronto pago"
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": { ... },
    "message": ""
  }
  ```

## Stored Procedures
Toda la lógica de negocio y cálculos (recargos, descuentos, leyendas, etc.) se implementa en stored procedures PostgreSQL. El controlador Laravel solo invoca estos procedimientos y retorna el resultado.

## Seguridad
- Autenticación JWT recomendada para el endpoint
- Validación de parámetros en el backend

## Frontend
- Página Vue.js independiente, sin tabs
- Formulario para ingresar parámetros y consultar la carátula
- Renderizado de los datos y detalle de adeudos

## Navegación
- Breadcrumb simple: Inicio / Carátula de Locales
- Cada formulario es una ruta independiente

## Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones relacionadas
- Los stored procedures pueden ser reutilizados por otros módulos

## Pruebas
- Casos de uso y escenarios de prueba incluidos en este documento

# Esquema de Base de Datos (relevante)
- ta_11_locales
- ta_11_adeudo_local
- ta_11_mercados
- ta_12_recargos
- ta_11_fecha_desc
- ta_12_passwords

# Notas de Migración
- Los cálculos de recargos y descuentos se centralizan en SPs
- El frontend no realiza lógica de negocio, solo presenta los datos
- El endpoint es agnóstico de la acción, todo se resuelve por el parámetro `action`


## Casos de Uso

# Casos de Uso - RptCaratulaDatos

**Categoría:** Form

## Caso de Uso 1: Consulta de Carátula de Local con Adeudo Vigente

**Descripción:** El usuario consulta la carátula de un local con adeudos y recargos vigentes.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta. El local existe y tiene adeudos registrados.

**Pasos a seguir:**
1. El usuario accede a la página 'Carátula de Locales'.
2. Ingresa el ID del local y los importes de renta, adeudo, recargos, gastos, multa y total.
3. Presiona 'Consultar Carátula'.
4. El sistema consulta el backend vía /api/execute con action 'getRptCaratulaDatos'.
5. El backend ejecuta el stored procedure y retorna los datos completos del local y sus adeudos.

**Resultado esperado:**
Se muestra la información completa del local, incluyendo datos generales, adeudos por periodo, recargos calculados y leyenda de descuento si aplica.

**Datos de prueba:**
{ "id_local": 1001, "renta": 1200.00, "adeudo": 600.00, "recargos": 60.00, "gastos": 20.00, "multa": 0.00, "total": 680.00, "folios": "1234,1235,", "leyenda": "Desc. pronto pago" }

---

## Caso de Uso 2: Consulta de Local sin Adeudos

**Descripción:** El usuario consulta la carátula de un local que está al corriente de pagos.

**Precondiciones:**
El usuario está autenticado. El local existe y no tiene adeudos.

**Pasos a seguir:**
1. El usuario accede a la página 'Carátula de Locales'.
2. Ingresa el ID del local y deja los importes de adeudo, recargos, gastos y multa en cero.
3. Presiona 'Consultar Carátula'.
4. El sistema consulta el backend vía /api/execute.
5. El backend retorna los datos del local y un arreglo vacío de adeudos.

**Resultado esperado:**
Se muestra la información del local y un mensaje o tabla vacía indicando que no existen adeudos.

**Datos de prueba:**
{ "id_local": 2002, "renta": 900.00, "adeudo": 0.00, "recargos": 0.00, "gastos": 0.00, "multa": 0.00, "total": 900.00, "folios": "", "leyenda": "" }

---

## Caso de Uso 3: Consulta con Error de Parámetros

**Descripción:** El usuario intenta consultar la carátula sin ingresar el ID del local.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página 'Carátula de Locales'.
2. Deja el campo ID Local vacío y presiona 'Consultar Carátula'.
3. El frontend valida y muestra un mensaje de error.

**Resultado esperado:**
El sistema no realiza la consulta y muestra un mensaje de error indicando que el ID Local es requerido.

**Datos de prueba:**
{ "id_local": "", "renta": 0, "adeudo": 0, "recargos": 0, "gastos": 0, "multa": 0, "total": 0, "folios": "", "leyenda": "" }

---



## Casos de Prueba

# Casos de Prueba para RptCaratulaDatos

## Caso 1: Consulta exitosa de carátula con adeudos
- **Entrada:** id_local=1001, renta=1200.00, adeudo=600.00, recargos=60.00, gastos=20.00, multa=0.00, total=680.00, folios="1234,1235,", leyenda="Desc. pronto pago"
- **Acción:** POST /api/execute { action: 'getRptCaratulaDatos', params: ... }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: objeto con datos del local y arreglo de adeudos
  - Los recargos y leyenda calculados correctamente

## Caso 2: Consulta de local sin adeudos
- **Entrada:** id_local=2002, renta=900.00, adeudo=0.00, recargos=0.00, gastos=0.00, multa=0.00, total=900.00, folios="", leyenda=""
- **Acción:** POST /api/execute { action: 'getRptCaratulaDatos', params: ... }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: objeto con datos del local y arreglo de adeudos vacío

## Caso 3: Error por parámetro faltante
- **Entrada:** id_local=""
- **Acción:** POST /api/execute { action: 'getRptCaratulaDatos', params: ... }
- **Resultado esperado:**
  - HTTP 200
  - success: false
  - message: "ID Local es requerido" o mensaje similar

## Caso 4: Error de base de datos
- **Simulación:** Forzar error en SP (por ejemplo, id_local inexistente)
- **Resultado esperado:**
  - HTTP 200
  - success: false
  - message: error SQL o mensaje amigable



