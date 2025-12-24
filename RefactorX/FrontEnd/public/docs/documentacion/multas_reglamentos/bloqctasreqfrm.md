# Documentación: bloqctasreqfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario BloqCtasReq (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite bloquear y desbloquear cuentas para requerimientos fiscales, así como consultar el historial de bloqueos y realizar envíos a Catastro/Inconformidades. La migración incluye:
- Backend: Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- Frontend: Componente Vue.js como página independiente
- Base de datos: PostgreSQL con stored procedures para lógica de negocio

## 2. Arquitectura
- **API Unificada**: Todas las acciones se realizan vía POST `/api/execute` con un objeto `eRequest` que indica la acción y los parámetros.
- **Acciones soportadas**:
  - `listar`: Listar cuentas bloqueadas/desbloqueadas/por Catastro
  - `consultar`: Consultar cuenta y su historial
  - `bloquear`: Bloquear una cuenta
  - `desbloquear`: Desbloquear una cuenta
  - `historial`: Obtener historial de bloqueos
  - `enviar_catastro`: Enviar cuentas bloqueadas a Catastro/Inconformidades
  - `desbloqueo_masivo`: Desbloqueo masivo de cuentas

## 3. Backend (Laravel)
- Controlador: `BloqCtasReqController`
- Todas las acciones se resuelven en el método `execute()`
- Validaciones y lógica de negocio se delegan a stored procedures en PostgreSQL
- El controlador retorna siempre `{ "eResponse": { ... } }`

## 4. Frontend (Vue.js)
- Componente de página independiente (no tabs)
- Permite buscar cuenta, mostrar datos, bloquear/desbloquear, ver historial
- Usa fetch API para comunicarse con `/api/execute`
- Maneja mensajes de error y éxito

## 5. Base de Datos (PostgreSQL)
- Tablas principales: `norequeribles`, `h_norequeribles`, `convcta`, etc.
- Stored procedures para bloquear, desbloquear, enviar a Catastro y desbloqueo masivo
- Todas las operaciones de inserción/actualización usan SPs

## 6. Seguridad
- El usuario debe ser autenticado (el frontend debe pasar el usuario en cada acción)
- Validaciones de datos en backend y frontend

## 7. Ejemplo de eRequest/eResponse
### Solicitud:
```json
{
  "eRequest": {
    "action": "bloquear",
    "recaud": 1,
    "urbrus": "U",
    "cuenta": 12345,
    "motivo": "Cuenta con inconsistencias",
    "fecha_desbloqueo": "2024-06-30",
    "usuario": "admin"
  }
}
```
### Respuesta:
```json
{
  "eResponse": {
    "success": true,
    "message": "Cuenta bloqueada correctamente",
    "data": { "id": 123 }
  }
}
```

## 8. Flujo de Uso
1. Usuario busca cuenta (por recaudadora, urbrus y cuenta)
2. El sistema muestra datos y estado (bloqueada/desbloqueada)
3. Usuario puede bloquear/desbloquear, indicando motivo y fecha
4. El historial muestra todos los movimientos
5. Puede enviar bloqueos a Catastro o realizar desbloqueo masivo

## 9. Consideraciones
- El frontend debe manejar los estados y mensajes de error
- El backend debe validar que no se bloquee dos veces la misma cuenta
- El historial se obtiene de la tabla `h_norequeribles`

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente
- Los stored procedures pueden ser extendidos para nuevas reglas de negocio

## Casos de Uso

# Casos de Uso - bloqctasreqfrm

**Categoría:** Form

## Caso de Uso 1: Bloquear una cuenta para requerir

**Descripción:** El usuario bloquea una cuenta para que no sea requerida fiscalmente.

**Precondiciones:**
El usuario está autenticado y conoce los datos de la cuenta.

**Pasos a seguir:**
1. El usuario ingresa recaudadora, urbrus y cuenta.
2. El usuario da clic en 'Buscar'.
3. El sistema muestra los datos de la cuenta y su estado.
4. El usuario ingresa el motivo y la fecha de desbloqueo.
5. El usuario da clic en 'Bloquear'.
6. El sistema ejecuta el bloqueo y muestra mensaje de éxito.

**Resultado esperado:**
La cuenta queda bloqueada y aparece en el historial.

**Datos de prueba:**
{ "recaud": 1, "urbrus": "U", "cuenta": 12345, "motivo": "Cuenta con inconsistencias", "fecha_desbloqueo": "2024-06-30", "usuario": "admin" }

---

## Caso de Uso 2: Desbloquear una cuenta previamente bloqueada

**Descripción:** El usuario desbloquea una cuenta para que pueda ser requerida nuevamente.

**Precondiciones:**
La cuenta está bloqueada y el usuario está autenticado.

**Pasos a seguir:**
1. El usuario busca la cuenta bloqueada.
2. El sistema muestra el estado 'Bloqueada'.
3. El usuario ingresa el motivo de desbloqueo y la fecha.
4. El usuario da clic en 'Desbloquear'.
5. El sistema actualiza el registro y muestra mensaje de éxito.

**Resultado esperado:**
La cuenta queda desbloqueada y el movimiento aparece en el historial.

**Datos de prueba:**
{ "recaud": 1, "urbrus": "U", "cuenta": 12345, "motivo": "Cuenta regularizada", "fecha_desbloqueo": "2024-07-01", "usuario": "admin" }

---

## Caso de Uso 3: Enviar cuentas bloqueadas a Catastro/Inconformidades

**Descripción:** El usuario envía todas las cuentas bloqueadas de una recaudadora a Catastro.

**Precondiciones:**
El usuario tiene permisos y existen cuentas bloqueadas sin enviar.

**Pasos a seguir:**
1. El usuario selecciona la recaudadora.
2. El usuario da clic en 'Enviar a Catastro'.
3. El sistema ejecuta el stored procedure y muestra cuántas cuentas fueron enviadas.

**Resultado esperado:**
Las cuentas quedan marcadas con lote_envio y fecha_envio.

**Datos de prueba:**
{ "usuario": "admin", "recaud": 1 }

---

## Casos de Prueba

# Casos de Prueba para BloqCtasReq

## Caso 1: Bloquear cuenta válida
- Ingresar recaudadora=1, urbrus=U, cuenta=12345, motivo='Prueba bloqueo', fecha_desbloqueo='2024-06-30', usuario='admin'.
- Esperar mensaje de éxito y ver la cuenta bloqueada en el historial.

## Caso 2: Intentar bloquear cuenta ya bloqueada
- Repetir el caso 1.
- Esperar mensaje de error 'La cuenta ya está bloqueada'.

## Caso 3: Desbloquear cuenta
- Buscar la cuenta bloqueada.
- Ingresar motivo='Regularización', fecha_desbloqueo='2024-07-01', usuario='admin'.
- Esperar mensaje de éxito y ver el movimiento en el historial.

## Caso 4: Consultar historial de bloqueos
- Buscar la cuenta y verificar que el historial muestra todos los movimientos.

## Caso 5: Enviar cuentas bloqueadas a Catastro
- Ejecutar acción 'enviar_catastro' con recaud=1, usuario='admin'.
- Esperar mensaje de éxito y número de cuentas enviadas.

## Caso 6: Desbloqueo masivo
- Ejecutar acción 'desbloqueo_masivo' con usuario='admin'.
- Esperar mensaje de éxito y número de cuentas desbloqueadas.

## Caso 7: Validación de campos obligatorios
- Omitir algún campo requerido y esperar mensaje de error de validación.

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

