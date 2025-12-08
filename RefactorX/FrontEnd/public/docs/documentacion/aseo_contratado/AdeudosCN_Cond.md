# DocumentaciÃ³n TÃ©cnica: AdeudosCN_Cond

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Condonación de Adeudos (AdeudosCN_Cond)

## Descripción General
Este módulo permite condonar (marcar como condonado) un adeudo de exedencia vigente para un contrato, periodo y tipo de operación. La migración se realizó desde Delphi a Laravel + Vue.js + PostgreSQL, usando un endpoint API unificado y stored procedures para la lógica de negocio.

## Arquitectura
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel, controlador único para /api/execute, patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, lógica crítica en stored procedures.

## Flujo de Proceso
1. El usuario ingresa los datos del contrato, tipo de aseo, año, mes, tipo de movimiento y oficio.
2. El frontend consulta los catálogos necesarios (tipos de aseo y operación).
3. El frontend valida la existencia del contrato y la exedencia vigente para el periodo y operación.
4. Si existe, ejecuta la stored procedure para condonar el adeudo.
5. El backend responde con éxito o error y el frontend muestra el mensaje correspondiente.

## API
- **Endpoint**: POST /api/execute
- **Patrón**: { action: string, params: object }
- **Acciones soportadas**:
    - getCatalogs
    - getContratoInfo
    - checkExedenciaVigente
    - condonarAdeudo

## Stored Procedure
- **sp16_condona_adeudo**: Encapsula la lógica de condonación, validando existencia y estado del adeudo antes de actualizarlo.

## Validaciones
- Todos los campos son obligatorios.
- El contrato debe existir.
- Debe existir un adeudo vigente para el periodo y tipo de operación.
- El usuario debe estar autenticado (para registrar el usuario que realiza la condonación).

## Seguridad
- El endpoint requiere autenticación (Laravel middleware auth:api recomendado).
- El usuario que ejecuta la condonación queda registrado en la tabla de pagos.

## Manejo de Errores
- Todos los errores se devuelven en formato { success: false, message: '...' }.
- Errores de validación y de base de datos se manejan y reportan al usuario.

## Consideraciones
- El frontend no permite tabs ni componentes tabulares, cada formulario es una página.
- El endpoint es único y multipropósito, siguiendo el patrón eRequest/eResponse.
- Toda la lógica de negocio crítica reside en stored procedures para facilitar auditoría y portabilidad.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los catálogos pueden ser cacheados en frontend para mejorar rendimiento.



## Casos de Prueba

## Casos de Prueba: Condonación de Adeudos

### Caso 1: Condonar un adeudo exitosamente
- **Entrada:** num_contrato=12345, ctrol_aseo=9, aso=2024, mes=06, ctrol_operacion=8, oficio=OF-2024-001
- **Acción:** Ejecutar condonación
- **Esperado:** Respuesta success=true, mensaje de éxito, registro actualizado en ta_16_pagos

### Caso 2: Intentar condonar un adeudo inexistente
- **Entrada:** num_contrato=12345, ctrol_aseo=9, aso=2023, mes=01, ctrol_operacion=8, oficio=OF-2023-002
- **Acción:** Ejecutar condonación
- **Esperado:** Respuesta success=false, mensaje de error, sin cambios en la base de datos

### Caso 3: Validación de campos obligatorios
- **Entrada:** num_contrato vacío, ctrol_aseo vacío, aso=2024, mes=06, ctrol_operacion vacío, oficio vacío
- **Acción:** Ejecutar condonación
- **Esperado:** Mensaje de error en frontend, sin llamada a backend

### Caso 4: Error de base de datos (simulado)
- **Entrada:** Datos válidos pero la base de datos falla
- **Acción:** Ejecutar condonación
- **Esperado:** Respuesta success=false, mensaje de error técnico, sin cambios en la base de datos

### Caso 5: Usuario no autenticado
- **Entrada:** Cualquier
- **Acción:** Ejecutar condonación sin autenticación
- **Esperado:** Respuesta HTTP 401 Unauthorized


## Casos de Uso

# Casos de Uso - AdeudosCN_Cond

**Categoría:** Form

## Caso de Uso 1: Condonar un adeudo de exedencia vigente

**Descripción:** El usuario condona un adeudo de exedencia vigente para un contrato y periodo específico.

**Precondiciones:**
El contrato y el adeudo de exedencia existen y están vigentes. El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de condonación de adeudos.
2. Ingresa el número de contrato, selecciona el tipo de aseo, año, mes, tipo de movimiento y oficio.
3. Presiona 'Ejecutar'.
4. El sistema valida la existencia del contrato y del adeudo vigente.
5. El sistema ejecuta la condonación.
6. El usuario recibe un mensaje de éxito.

**Resultado esperado:**
El adeudo es marcado como condonado (status_vigencia = 'S'), se registra la fecha, usuario y oficio.

**Datos de prueba:**
{
  "num_contrato": "12345",
  "ctrol_aseo": 9,
  "aso": "2024",
  "mes": "06",
  "ctrol_operacion": 8,
  "oficio": "OF-2024-001"
}

---

## Caso de Uso 2: Intentar condonar un adeudo inexistente

**Descripción:** El usuario intenta condonar un adeudo que no existe o no está vigente.

**Precondiciones:**
El contrato existe pero no hay adeudo vigente para el periodo y operación seleccionados.

**Pasos a seguir:**
1. El usuario accede a la página de condonación de adeudos.
2. Ingresa los datos de un contrato y periodo sin adeudo vigente.
3. Presiona 'Ejecutar'.
4. El sistema valida y detecta que no existe adeudo vigente.
5. El usuario recibe un mensaje de error.

**Resultado esperado:**
El sistema muestra un mensaje de error y no realiza ningún cambio.

**Datos de prueba:**
{
  "num_contrato": "12345",
  "ctrol_aseo": 9,
  "aso": "2023",
  "mes": "01",
  "ctrol_operacion": 8,
  "oficio": "OF-2023-002"
}

---

## Caso de Uso 3: Validación de campos obligatorios

**Descripción:** El usuario intenta ejecutar la condonación dejando campos obligatorios vacíos.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de condonación de adeudos.
2. Deja uno o más campos obligatorios vacíos.
3. Presiona 'Ejecutar'.
4. El sistema valida los campos y detecta la omisión.
5. El usuario recibe un mensaje de error.

**Resultado esperado:**
El sistema no ejecuta la condonación y muestra un mensaje de error indicando los campos faltantes.

**Datos de prueba:**
{
  "num_contrato": "",
  "ctrol_aseo": "",
  "aso": "2024",
  "mes": "06",
  "ctrol_operacion": "",
  "oficio": ""
}

---



---
**Componente:** `AdeudosCN_Cond.vue`
**MÃ³dulo:** `aseo_contratado`

