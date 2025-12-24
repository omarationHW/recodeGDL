# DatosConvenio

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Módulo DatosConvenio

## Descripción General
El módulo **DatosConvenio** permite consultar y visualizar la información detallada de un convenio de local conveniado, incluyendo sus datos generales, periodos, parcialidades y estado. La migración Delphi → Laravel + Vue.js + PostgreSQL se implementa bajo un patrón API unificada (eRequest/eResponse) y stored procedures para lógica de negocio.

## Arquitectura
- **Backend**: Laravel Controller (DatosConvenioController) expone un endpoint único `/api/execute` que recibe acciones y parámetros.
- **Frontend**: Componente Vue.js de página completa, sin tabs, con navegación breadcrumb y tabla de parcialidades.
- **Base de Datos**: Toda la lógica SQL se encapsula en stored procedures PostgreSQL.
- **API**: Comunicación por JSON, patrón eRequest/eResponse.

## Flujo de Datos
1. El frontend solicita `/api/execute` con acción `getConvenioById` y el id del convenio.
2. El backend ejecuta el stored procedure `sp_get_datos_convenio` y retorna los datos generales.
3. El frontend solicita `/api/execute` con acción `getConvenioParciales` para obtener la tabla de parcialidades.
4. El backend ejecuta el stored procedure `sp_get_convenio_parciales` y retorna la lista.

## Endpoints
- **POST /api/execute**
  - **Body:**
    ```json
    {
      "action": "getConvenioById", // o getConvenioParciales, getConvenioResumen
      "params": { "id_conv": 123 }
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
- **sp_get_datos_convenio**: Devuelve todos los campos del convenio, más campos calculados (estado, tipodesc, periodos, peradeudos, convenio).
- **sp_get_convenio_parciales**: Devuelve la lista de pagos parciales con descripción, importe, periodos y datos de pago.
- **sp_get_convenio_resumen**: Devuelve resumen de estado, tipo, periodos, etc.

## Seguridad
- El endpoint requiere autenticación JWT (recomendado, no incluido en este ejemplo).
- Validación de parámetros en el controlador.

## Consideraciones de Migración
- Todos los cálculos de campos (estado, tipodesc, periodos, etc.) se trasladan a los stored procedures.
- El frontend es reactivo y desacoplado, cada página es independiente.
- No se usan tabs ni componentes tabulares.

## Extensibilidad
- Se pueden agregar nuevas acciones en el controlador y nuevos stored procedures para otras vistas o reportes.

## Dependencias
- Laravel 9+
- Vue.js 2/3 + Element UI (o similar)
- PostgreSQL 12+

## Ejemplo de Uso
1. El usuario navega a `/convenios/123`.
2. El componente Vue carga los datos generales y las parcialidades del convenio 123.
3. El usuario puede ver todos los detalles y parcialidades en una sola página.



## Casos de Uso

# Casos de Uso - DatosConvenio

**Categoría:** Form

## Caso de Uso 1: Consulta de Convenio Existente

**Descripción:** El usuario consulta el detalle de un convenio existente desde la página de convenios.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta. Existe un convenio con id_conv=123.

**Pasos a seguir:**
1. El usuario navega a /convenios/123
2. El frontend solicita /api/execute con action=getConvenioById y id_conv=123
3. El backend retorna los datos generales del convenio
4. El frontend solicita /api/execute con action=getConvenioParciales y id_conv=123
5. El backend retorna la lista de parcialidades
6. El usuario visualiza toda la información en la página

**Resultado esperado:**
Se muestran todos los datos del convenio y la tabla de parcialidades correctamente.

**Datos de prueba:**
{ "id_conv": 123 }

---

## Caso de Uso 2: Consulta de Convenio Inexistente

**Descripción:** El usuario intenta consultar un convenio que no existe.

**Precondiciones:**
El usuario está autenticado. No existe un convenio con id_conv=9999.

**Pasos a seguir:**
1. El usuario navega a /convenios/9999
2. El frontend solicita /api/execute con action=getConvenioById y id_conv=9999
3. El backend retorna null o error
4. El frontend muestra mensaje de error

**Resultado esperado:**
Se muestra un mensaje de 'Convenio no encontrado' o similar.

**Datos de prueba:**
{ "id_conv": 9999 }

---

## Caso de Uso 3: Visualización de Estado y Periodos Calculados

**Descripción:** El usuario verifica que los campos calculados (estado, tipodesc, periodos, peradeudos, convenio) se muestran correctamente según los datos.

**Precondiciones:**
El usuario está autenticado. El convenio tiene diferentes valores de vigencia y tipo_pago.

**Pasos a seguir:**
1. El usuario navega a /convenios/124
2. El frontend solicita /api/execute con action=getConvenioById y id_conv=124
3. El backend retorna los datos con campos calculados
4. El usuario verifica los valores en la interfaz

**Resultado esperado:**
Los campos calculados muestran los valores correctos según la lógica de negocio.

**Datos de prueba:**
{ "id_conv": 124 }

---



## Casos de Prueba

# Casos de Prueba: DatosConvenio

## 1. Consulta de Convenio Existente
- **Entrada:** id_conv=123
- **Acción:** POST /api/execute { action: 'getConvenioById', params: { id_conv: 123 } }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: objeto con todos los campos del convenio
  - Los campos calculados (estado, tipodesc, periodos, peradeudos, convenio) son correctos

## 2. Consulta de Parcialidades
- **Entrada:** id_conv=123
- **Acción:** POST /api/execute { action: 'getConvenioParciales', params: { id_conv: 123 } }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: array de parcialidades con campos: pago_parcial_1, descparc, importe, peradeudos, fecha_pago, oficina_pago, caja_pago, operacion_pago

## 3. Consulta de Convenio Inexistente
- **Entrada:** id_conv=9999
- **Acción:** POST /api/execute { action: 'getConvenioById', params: { id_conv: 9999 } }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: null
  - message: '' o 'No encontrado'

## 4. Validación de Campos Calculados
- **Entrada:** id_conv=124 (vigencia='B', tipo_pago='Q', etc)
- **Acción:** POST /api/execute { action: 'getConvenioById', params: { id_conv: 124 } }
- **Resultado esperado:**
  - Los campos calculados muestran los valores correctos:
    - estado: 'BAJA'
    - tipodesc: 'QUINCENAL'
    - periodos: 'mes_desde/axo_desde - mes_hasta/axo_hasta'
    - peradeudos: 'mes_desde_1/axo_desde_1 - mes_hasta_1/axo_hasta_1'
    - convenio: 'letras_exp/numero_exp/axo_exp'

## 5. Seguridad: Acceso sin Autenticación
- **Entrada:** Sin token JWT
- **Acción:** POST /api/execute { action: 'getConvenioById', params: { id_conv: 123 } }
- **Resultado esperado:**
  - HTTP 401 Unauthorized (si la autenticación está implementada)



