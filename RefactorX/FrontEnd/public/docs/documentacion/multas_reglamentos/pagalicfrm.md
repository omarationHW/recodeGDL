# Documentación: pagalicfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario pagalicfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo permite marcar licencias o anuncios como pagados, actualizando los adeudos correspondientes y recalculando los saldos mediante procedimientos almacenados. La migración incluye:
- Un endpoint API unificado (`/api/execute`) bajo el patrón eRequest/eResponse.
- Un controlador Laravel que maneja toda la lógica de negocio y acceso a datos.
- Un componente Vue.js que representa la página completa del formulario.
- Procedimientos almacenados en PostgreSQL para el recálculo de saldos.

## Arquitectura
- **Backend:** Laravel 10+, PostgreSQL
- **Frontend:** Vue.js 3+, Bootstrap 5 (opcional para estilos)
- **API:** Endpoint único `/api/execute` que recibe `{action, params}` y responde `{success, data, message}`

## Flujo de Trabajo
1. El usuario selecciona si desea trabajar con Licencia o Anuncio.
2. Ingresa el número y año, y presiona Buscar.
3. El sistema consulta la existencia y adeudos pendientes.
4. Si existen adeudos, se muestran en una tabla.
5. El usuario puede marcar como pagado, lo que actualiza los registros y ejecuta el procedimiento almacenado de recálculo.

## Detalle de Acciones API
- **buscar_licencia**: Busca una licencia vigente y sus adeudos pendientes para el año dado.
- **buscar_anuncio**: Busca un anuncio vigente y sus adeudos pendientes para el año dado.
- **marcar_pagado**: Marca los adeudos como pagados (cvepago=999999999) y ejecuta el procedimiento almacenado de recálculo.

## Seguridad
- Se recomienda proteger el endpoint con autenticación y autorización según el contexto de la aplicación.
- Validar siempre los parámetros recibidos.

## Consideraciones de Migración
- Los nombres de tablas y campos deben coincidir con los de la base de datos destino.
- Los procedimientos almacenados deben adaptarse a la lógica de negocio real.
- El frontend es una página independiente, sin tabs ni componentes compartidos.

## Ejemplo de Request/Response
### Buscar Licencia
```json
POST /api/execute
{
  "action": "buscar_licencia",
  "params": {
    "numero": 1234,
    "axo": 2024
  }
}
```

### Marcar como Pagado
```json
POST /api/execute
{
  "action": "marcar_pagado",
  "params": {
    "tipo": "licencia",
    "numero": 1234,
    "axo": 2024
  }
}
```

## Manejo de Errores
- Si no existe el número, se retorna `success: false` y un mensaje descriptivo.
- Si no hay adeudos, se informa al usuario.
- Si ocurre un error de base de datos, se retorna el mensaje de error.

## Pruebas
- Ver sección de Casos de Uso y Casos de Prueba.

## Casos de Uso

# Casos de Uso - pagalicfrm

**Categoría:** Form

## Caso de Uso 1: Marcar una Licencia como Pagada

**Descripción:** El usuario desea marcar como pagada una licencia con adeudos pendientes para un año específico.

**Precondiciones:**
La licencia existe, está vigente y tiene adeudos pendientes para el año seleccionado.

**Pasos a seguir:**
1. El usuario selecciona 'Licencia'.
2. Ingresa el número de licencia y el año.
3. Presiona 'Buscar'.
4. El sistema muestra los datos de la licencia y los adeudos.
5. El usuario presiona 'Marcar como Pagado'.
6. El sistema actualiza los registros y recalcula los saldos.

**Resultado esperado:**
La licencia es marcada como pagada, los adeudos desaparecen y se muestra un mensaje de éxito.

**Datos de prueba:**
numero: 1234, axo: 2024 (licencia vigente con adeudos)

---

## Caso de Uso 2: Intentar Marcar una Licencia Inexistente

**Descripción:** El usuario intenta buscar una licencia que no existe.

**Precondiciones:**
El número de licencia no existe en la base de datos.

**Pasos a seguir:**
1. El usuario selecciona 'Licencia'.
2. Ingresa un número de licencia inexistente y el año.
3. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no existe ese número de licencia.

**Datos de prueba:**
numero: 999999, axo: 2024

---

## Caso de Uso 3: Marcar un Anuncio como Pagado

**Descripción:** El usuario marca como pagado un anuncio con adeudos pendientes.

**Precondiciones:**
El anuncio existe, está vigente y tiene adeudos pendientes para el año seleccionado.

**Pasos a seguir:**
1. El usuario selecciona 'Anuncio'.
2. Ingresa el número de anuncio y el año.
3. Presiona 'Buscar'.
4. El sistema muestra los datos del anuncio y los adeudos.
5. El usuario presiona 'Marcar como Pagado'.
6. El sistema actualiza los registros y recalcula los saldos.

**Resultado esperado:**
El anuncio es marcado como pagado, los adeudos desaparecen y se muestra un mensaje de éxito.

**Datos de prueba:**
numero: 5678, axo: 2024 (anuncio vigente con adeudos)

---

## Casos de Prueba

# Casos de Prueba para Formulario pagalicfrm

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Buscar licencia existente con adeudos | tipo: licencia, numero: 1234, axo: 2024 | Se muestran los datos de la licencia y los adeudos pendientes |
| TC02 | Buscar licencia inexistente | tipo: licencia, numero: 999999, axo: 2024 | Mensaje de error: 'NO existe este numero de licencia' |
| TC03 | Buscar licencia sin adeudos | tipo: licencia, numero: 1234, axo: 2020 (sin adeudos) | Mensaje de error: 'NO existen adeudos para esta Licencia/Anuncio' |
| TC04 | Marcar licencia como pagada | tipo: licencia, numero: 1234, axo: 2024 | Mensaje de éxito: 'Licencia marcada como pagada correctamente.' y los adeudos desaparecen |
| TC05 | Buscar anuncio existente con adeudos | tipo: anuncio, numero: 5678, axo: 2024 | Se muestran los datos del anuncio y los adeudos pendientes |
| TC06 | Marcar anuncio como pagado | tipo: anuncio, numero: 5678, axo: 2024 | Mensaje de éxito: 'Anuncio marcado como pagado correctamente.' y los adeudos desaparecen |
| TC07 | Buscar anuncio inexistente | tipo: anuncio, numero: 888888, axo: 2024 | Mensaje de error: 'NO existe este numero de anuncio' |
| TC08 | Buscar anuncio sin adeudos | tipo: anuncio, numero: 5678, axo: 2020 (sin adeudos) | Mensaje de error: 'NO existen adeudos para esta Licencia/Anuncio' |

## Integración con Backend

> ⚠️ Pendiente de documentar

