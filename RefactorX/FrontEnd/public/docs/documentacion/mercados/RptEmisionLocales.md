# RptEmisionLocales

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: RptEmisionLocales (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## Descripción General
Este módulo corresponde a la emisión de recibos de locales de mercados municipales. Permite:
- Previsualizar la emisión de recibos para un mercado/oficina/año/mes.
- Grabar (emitir) los recibos, generando los adeudos correspondientes.
- Consultar mercados disponibles por oficina.

Toda la lógica de negocio y cálculos (renta, recargos, meses adeudados) se realiza en stored procedures PostgreSQL.

## Arquitectura
- **Frontend**: Vue.js SPA, página independiente `/emision-locales`.
- **Backend**: Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Base de Datos**: PostgreSQL, lógica en stored procedures.

## API (Patrón eRequest/eResponse)
- **Endpoint**: `/api/execute` (POST)
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "get|emit|preview|get-mercados",
      "params": { ... }
    }
  }
  ```
- **Salida**:
  ```json
  {
    "eResponse": { ... }
  }
  ```

### Acciones soportadas
- `get`: Previsualización de emisión (no graba nada)
- `emit`: Graba la emisión (genera adeudos)
- `preview`: Alias de `get`
- `get-mercados`: Devuelve mercados de una oficina

## Stored Procedures
- `sp_rpt_emision_locales_get`: Devuelve la previsualización de la emisión (cálculos de renta, recargos, meses adeudados)
- `sp_rpt_emision_locales_emit`: Graba los adeudos del periodo/mercado/oficina/año

## Seguridad
- El endpoint requiere autenticación (token JWT o sesión Laravel).
- El parámetro `usuario_id` debe ser validado contra el usuario autenticado.

## Validaciones
- Todos los parámetros son obligatorios.
- No se permite emitir dos veces el mismo periodo/local.
- Solo mercados con `tipo_emision = 'M'` pueden ser emitidos.

## Errores comunes
- Si ya existe el adeudo para el periodo/local, no se duplica.
- Si faltan parámetros, se devuelve error de validación.

## Frontend
- Página Vue.js independiente, sin tabs.
- Navegación breadcrumb.
- Botón de previsualización y emisión.
- Tabla de previsualización con todos los datos relevantes.

## Backend
- Controlador Laravel centraliza todas las acciones.
- Toda la lógica de negocio está en los stored procedures.

## Base de Datos
- Tablas principales: `ta_11_locales`, `ta_11_cuo_locales`, `ta_11_adeudo_local`, `ta_12_recargos`, `ta_11_mercados`.

# Diagrama de Flujo
1. Usuario selecciona oficina, año, mes, mercado.
2. Frontend llama a `/api/execute` con acción `get`.
3. Backend ejecuta `sp_rpt_emision_locales_get` y devuelve la previsualización.
4. Usuario revisa y confirma emisión.
5. Frontend llama a `/api/execute` con acción `emit`.
6. Backend ejecuta `sp_rpt_emision_locales_emit` y graba los adeudos.

# Notas de Migración
- Todos los cálculos de Delphi (renta, recargos, meses) están migrados a SQL.
- El frontend es una página independiente, no usa tabs.
- El endpoint es único y flexible para futuras extensiones.


## Casos de Uso

# Casos de Uso - RptEmisionLocales

**Categoría:** Form

## Caso de Uso 1: Previsualizar emisión de recibos de locales

**Descripción:** El usuario desea ver la previsualización de los recibos a emitir para un mercado específico antes de grabar la emisión.

**Precondiciones:**
El usuario está autenticado y tiene permisos para emitir recibos.

**Pasos a seguir:**
1. El usuario accede a la página de Emisión de Recibos de Locales.
2. Selecciona la oficina, año, mes y mercado.
3. Presiona el botón 'Previsualizar'.
4. El sistema muestra la tabla con los locales, rentas, adeudos, recargos y meses adeudados.

**Resultado esperado:**
Se muestra una tabla con los datos de emisión calculados correctamente, sin grabar nada en la base de datos.

**Datos de prueba:**
{ oficina: 2, axo: 2024, periodo: 6, mercado: 5 }

---

## Caso de Uso 2: Emitir (grabar) la emisión de recibos de locales

**Descripción:** El usuario confirma la emisión y graba los adeudos correspondientes para el periodo/mercado/oficina/año seleccionados.

**Precondiciones:**
El usuario está autenticado y ha previsualizado la emisión.

**Pasos a seguir:**
1. El usuario revisa la previsualización.
2. Presiona el botón 'Emitir Recibos'.
3. El sistema ejecuta el proceso de grabado.
4. Se graban los adeudos para cada local que no tenga ya adeudo en ese periodo.

**Resultado esperado:**
Se graban los adeudos correctamente. Si algún local ya tenía adeudo, no se duplica.

**Datos de prueba:**
{ oficina: 2, axo: 2024, periodo: 6, mercado: 5, usuario_id: 10 }

---

## Caso de Uso 3: Consultar mercados disponibles para una oficina

**Descripción:** El usuario necesita seleccionar el mercado correcto para emitir recibos.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario selecciona una oficina.
2. El sistema consulta los mercados disponibles para esa oficina.
3. El usuario selecciona el mercado deseado.

**Resultado esperado:**
Se muestra la lista de mercados con tipo_emision = 'M' para la oficina seleccionada.

**Datos de prueba:**
{ oficina: 2 }

---



## Casos de Prueba

# Casos de Prueba para RptEmisionLocales

## Caso 1: Previsualización exitosa
- **Entrada:**
  ```json
  { "eRequest": { "action": "get", "params": { "oficina": 2, "axo": 2024, "periodo": 6, "mercado": 5 } } }
  ```
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array con al menos un local
  - Cada local tiene campos: id_local, renta, adeudo, recargos, subtotal, meses

## Caso 2: Emisión exitosa
- **Entrada:**
  ```json
  { "eRequest": { "action": "emit", "params": { "oficina": 2, "axo": 2024, "periodo": 6, "mercado": 5, "usuario_id": 10 } } }
  ```
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.message contiene 'Emisión realizada correctamente'
  - eResponse.data es un array con status 'inserted' o 'exists' por local

## Caso 3: Error por parámetros faltantes
- **Entrada:**
  ```json
  { "eRequest": { "action": "emit", "params": { "oficina": 2, "axo": 2024, "periodo": 6 } } }
  ```
- **Esperado:**
  - HTTP 200
  - eResponse.success = false
  - eResponse.errors contiene los campos faltantes

## Caso 4: Consulta de mercados
- **Entrada:**
  ```json
  { "eRequest": { "action": "get-mercados", "params": { "oficina": 2 } } }
  ```
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array de mercados con campos id, descripcion

## Caso 5: Emisión duplicada (ya existe adeudo)
- **Entrada:**
  ```json
  { "eRequest": { "action": "emit", "params": { "oficina": 2, "axo": 2024, "periodo": 6, "mercado": 5, "usuario_id": 10 } } }
  ```
- **Precondición:** Ya se ejecutó la emisión para ese periodo/mercado/oficina.
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data contiene status 'exists' para los locales ya emitidos



