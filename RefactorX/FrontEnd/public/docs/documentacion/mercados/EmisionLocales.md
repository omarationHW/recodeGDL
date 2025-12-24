# EmisionLocales

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración Formulario Emisión de Recibos (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (API RESTful)
- **Frontend**: Vue.js 3 (SPA, cada formulario es una página independiente)
- **Base de Datos**: PostgreSQL (toda la lógica SQL en stored procedures)
- **API Unificada**: Un solo endpoint `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Patrón de Comunicación**: eRequest/eResponse (JSON)

## Flujo de Trabajo
1. **El usuario accede a la página de Emisión de Recibos** (ruta Vue.js).
2. **Carga de recaudadoras**: El frontend simula o consulta las recaudadoras disponibles.
3. **Al seleccionar una recaudadora**, el frontend llama a `/api/execute` con `action: listarMercados` para obtener los mercados activos.
4. **El usuario selecciona mercado, año y periodo**.
5. **Al presionar 'Emisión'**, el frontend llama a `/api/execute` con `action: emitirRecibos` y los parámetros.
6. **El backend ejecuta el stored procedure correspondiente y retorna los recibos generados**.
7. **El usuario puede grabar la emisión** (persistir en tabla de adeudos) o generar facturación.
8. **Toda la lógica de negocio y validación de reglas está en los stored procedures**.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Entrada**: `{ "eRequest": { "action": "...", ...parámetros... } }`
- **Salida**: `{ "eResponse": { ...resultado... } }`

## Stored Procedures
- Toda la lógica de negocio (emisión, grabado, facturación, detalle) está en SPs.
- Los SPs devuelven tablas o mensajes de estado.
- El controlador Laravel solo enruta y valida parámetros.

## Seguridad
- Se recomienda validar el usuario autenticado en el backend (middleware Laravel Auth).
- Validar que el usuario tenga permisos para la recaudadora/mercado seleccionado.

## Validaciones
- Año entre 2003 y 2999.
- Periodo entre 1 y 12.
- No se puede grabar emisión si ya existe adeudo para ese periodo/local.
- Solo se pueden emitir recibos de mercados activos.

## Extensibilidad
- Para agregar nuevas acciones, solo agregar el case en el controlador y el SP correspondiente.
- El frontend puede extenderse para otros formularios siguiendo el mismo patrón.

## Pruebas
- Se recomienda usar Postman para probar el endpoint `/api/execute` con diferentes acciones y parámetros.
- El frontend puede ser probado con Cypress o Jest.

## Notas
- El frontend NO usa tabs ni componentes tabulares: cada formulario es una página Vue.js independiente.
- El backend NO expone endpoints CRUD directos, solo el endpoint unificado.
- Los reportes y facturación pueden ser generados en el backend y enviados como PDF o datos tabulares.


## Casos de Uso

# Casos de Uso - EmisionLocales

**Categoría:** Form

## Caso de Uso 1: Emisión de Recibos para un Mercado

**Descripción:** El usuario emite los recibos de renta para todos los locales de un mercado en un periodo determinado.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos sobre la recaudadora y mercado.

**Pasos a seguir:**
1. El usuario accede a la página de Emisión de Recibos.
2. Selecciona la recaudadora y el mercado.
3. Selecciona el año y el periodo (mes).
4. Presiona el botón 'Emisión'.
5. El sistema muestra la lista de recibos generados.

**Resultado esperado:**
Se muestran los recibos generados para todos los locales del mercado seleccionado, con los importes correctos.

**Datos de prueba:**
{ oficina: 2, mercado: 15, axo: 2024, periodo: 6, usuario_id: 1 }

---

## Caso de Uso 2: Grabar Emisión de Recibos

**Descripción:** El usuario graba la emisión de recibos, persistiendo los adeudos en la base de datos.

**Precondiciones:**
Debe haberse realizado previamente la emisión de recibos para el mercado y periodo.

**Pasos a seguir:**
1. El usuario revisa la lista de recibos generados.
2. Presiona el botón 'Grabar'.
3. El sistema ejecuta el SP de grabado y retorna el estado de cada local.

**Resultado esperado:**
Los adeudos quedan registrados en la tabla ta_11_adeudo_local para cada local. Si ya existía, se indica 'ya_existe'.

**Datos de prueba:**
{ oficina: 2, mercado: 15, axo: 2024, periodo: 6, usuario_id: 1 }

---

## Caso de Uso 3: Generar Facturación del Mercado

**Descripción:** El usuario genera la facturación (listado para impresión) de los recibos emitidos.

**Precondiciones:**
Debe haberse realizado la emisión y grabado de recibos.

**Pasos a seguir:**
1. El usuario presiona el botón 'Facturación'.
2. El sistema ejecuta el SP de facturación y retorna los datos tabulares para impresión.

**Resultado esperado:**
Se genera el listado de facturación para el mercado y periodo seleccionado.

**Datos de prueba:**
{ oficina: 2, mercado: 15, axo: 2024, periodo: 6, solo_mercado: true }

---



## Casos de Prueba

# Casos de Prueba para Emisión de Recibos

## Caso 1: Emisión de Recibos Exitosa
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "emitirRecibos",
      "oficina": 2,
      "mercado": 15,
      "axo": 2024,
      "periodo": 6,
      "usuario_id": 1
    }
  }
  ```
- **Esperado**: Respuesta con lista de recibos generados (campos: id_local, local, nombre, descripcion_local, superficie, renta, subtotal, meses).

## Caso 2: Grabar Emisión con Locales ya Emitidos
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "grabarEmision",
      "oficina": 2,
      "mercado": 15,
      "axo": 2024,
      "periodo": 6,
      "usuario_id": 1
    }
  }
  ```
- **Esperado**: Respuesta con status 'ok', message 'Emisión grabada correctamente', y detalles por local (status 'insertado' o 'ya_existe').

## Caso 3: Facturación de Mercado Completa
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "facturacion",
      "oficina": 2,
      "mercado": 15,
      "axo": 2024,
      "periodo": 6,
      "solo_mercado": true
    }
  }
  ```
- **Esperado**: Respuesta con listado tabular de facturación (campos: id_local, nombre, descripcion_local, superficie, renta, subtotal).

## Caso 4: Error por Parámetros Inválidos
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "emitirRecibos",
      "oficina": null,
      "mercado": null,
      "axo": 2024,
      "periodo": 6,
      "usuario_id": 1
    }
  }
  ```
- **Esperado**: Respuesta con error indicando parámetros requeridos.

## Caso 5: Detalle de Local
- **Entrada**:
  ```json
  {
    "eRequest": {
      "action": "detalleLocal",
      "id_local": 12345
    }
  }
  ```
- **Esperado**: Respuesta con todos los campos del local solicitado.



