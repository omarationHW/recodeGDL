# Documentación: Ubicodifica

## Análisis Técnico

# Documentación Técnica: Migración de Formulario Ubicodifica (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario "Ubicodifica" del sistema Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad de consulta, alta, actualización, cancelación y listado de codificaciones de ubicación catastral, centralizando la lógica de negocio en stored procedures y exponiendo la funcionalidad a través de un endpoint API unificado.

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3, componente de página independiente, sin tabs.
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón API:** eRequest/eResponse (un solo endpoint, acción y parámetros).

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  - `action`: Nombre de la acción (string)
  - `params`: Objeto de parámetros
- **Response:**
  - JSON con datos o error

### Acciones soportadas
- `get_ubicodifica_data`: Consulta datos de cuenta y codificación
- `alta_ubicodifica`: Alta de codificación
- `actualiza_ubicodifica`: Actualiza/reactiva codificación
- `cancela_ubicodifica`: Cancela codificación
- `listado_ubicodifica`: Listado de cuentas sin zona/subzona

## 4. Stored Procedures
Toda la lógica de negocio y reportes se implementa en funciones/stored procedures PostgreSQL, asegurando atomicidad y portabilidad. Los procedimientos están documentados en la sección correspondiente.

## 5. Seguridad
- Autenticación JWT (Laravel Sanctum o Passport recomendado)
- Validación de parámetros en backend
- Control de acceso por usuario en los procedimientos de alta/actualización/cancelación

## 6. Frontend (Vue.js)
- Página independiente para Ubicodifica
- Formulario para búsqueda y gestión de codificación
- Acciones de alta, actualización, cancelación
- Listado de cuentas sin zona/subzona
- Manejo de estados y mensajes de error
- No se usan tabs ni componentes tabulares; cada formulario es una página

## 7. Integración
- El frontend se comunica exclusivamente con `/api/execute` usando eRequest/eResponse
- El backend enruta la acción al procedimiento correspondiente
- Los stored procedures devuelven datos en formato tabular o de éxito/error

## 8. Migración de Lógica Delphi
- Los métodos y eventos Delphi se migran a métodos del controlador y stored procedures
- La lógica de habilitación/deshabilitación de botones se traslada a la lógica de estado en Vue.js
- Los reportes se migran a consultas SQL y pueden ser exportados desde el frontend si se requiere

## 9. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para validar la migración

## 10. Consideraciones
- El endpoint `/api/execute` puede ser extendido para otras acciones del sistema
- Se recomienda versionar los stored procedures y documentar cambios
- El frontend puede ser extendido para incluir breadcrumbs y navegación contextual

## Casos de Uso

# Casos de Uso - Ubicodifica

**Categoría:** Form

## Caso de Uso 1: Alta de Codificación de Ubicación para una Cuenta Nueva

**Descripción:** El usuario desea dar de alta la codificación de ubicación para una cuenta catastral que no tiene registro previo en la tabla de codificación.

**Precondiciones:**
El usuario está autenticado y tiene permisos de alta. La cuenta catastral existe y no tiene registro en ubicacion_req.

**Pasos a seguir:**
1. El usuario ingresa el número de cuenta en el formulario.
2. El sistema consulta los datos de la cuenta y muestra la información del contribuyente.
3. El usuario presiona el botón 'Dar de Alta'.
4. El sistema envía la acción 'alta_ubicodifica' al endpoint API.
5. El backend ejecuta el stored procedure de alta y retorna éxito.

**Resultado esperado:**
La codificación se da de alta correctamente, el usuario ve los datos de codificación y el estado cambia a 'Vigente'.

**Datos de prueba:**
{ "cvecuenta": 123456 }

---

## Caso de Uso 2: Cancelación de Codificación de Ubicación

**Descripción:** El usuario desea cancelar (dar de baja lógica) la codificación de ubicación de una cuenta existente.

**Precondiciones:**
La cuenta tiene un registro vigente en ubicacion_req. El usuario tiene permisos de cancelación.

**Pasos a seguir:**
1. El usuario busca la cuenta y visualiza la codificación vigente.
2. El usuario presiona el botón 'Cancelar'.
3. El sistema envía la acción 'cancela_ubicodifica' al endpoint API.
4. El backend ejecuta el stored procedure de cancelación y retorna éxito.

**Resultado esperado:**
La codificación cambia a estado 'Cancelada', se registra la fecha de baja y usuario.

**Datos de prueba:**
{ "cvecuenta": 123456 }

---

## Caso de Uso 3: Listado de Cuentas sin Zona/Subzona

**Descripción:** El usuario desea obtener un listado de cuentas que no tienen zona/subzona asignada en un rango de cuentas.

**Precondiciones:**
El usuario está autenticado. Existen cuentas en el rango solicitado sin zona/subzona.

**Pasos a seguir:**
1. El usuario ingresa los parámetros de recaudadora, cuenta inicial y cuenta final.
2. El usuario presiona 'Buscar'.
3. El sistema envía la acción 'listado_ubicodifica' al endpoint API.
4. El backend ejecuta el stored procedure de listado y retorna los resultados.

**Resultado esperado:**
El usuario visualiza una tabla con las cuentas sin zona/subzona en el rango solicitado.

**Datos de prueba:**
{ "reca": 1, "ctaini": 1000, "ctafin": 2000 }

---

## Casos de Prueba

# Casos de Prueba para Ubicodifica

## 1. Alta de Codificación Exitosa
- **Entrada:** cvecuenta válida sin codificación previa
- **Acción:** alta_ubicodifica
- **Resultado esperado:** Registro creado, estado 'Vigente', usuario y fecha correctos

## 2. Alta de Codificación Duplicada
- **Entrada:** cvecuenta ya existente en ubicacion_req
- **Acción:** alta_ubicodifica
- **Resultado esperado:** Error 409, mensaje 'Ya existe codificación para esta cuenta'

## 3. Actualización de Codificación Exitosa
- **Entrada:** cvecuenta existente, estado 'Cancelada'
- **Acción:** actualiza_ubicodifica
- **Resultado esperado:** Estado cambia a 'Vigente', fechas y usuario actualizados

## 4. Cancelación Exitosa
- **Entrada:** cvecuenta existente, estado 'Vigente'
- **Acción:** cancela_ubicodifica
- **Resultado esperado:** Estado cambia a 'Cancelada', fecha de baja y usuario registrados

## 5. Cancelación de Registro ya Cancelado
- **Entrada:** cvecuenta existente, estado 'Cancelada'
- **Acción:** cancela_ubicodifica
- **Resultado esperado:** Error 409, mensaje 'Ubicación ya está cancelada'

## 6. Listado de Cuentas sin Zona/Subzona
- **Entrada:** recaudadora, cuenta inicial y final válidos
- **Acción:** listado_ubicodifica
- **Resultado esperado:** Tabla con cuentas sin zona/subzona

## 7. Consulta de Datos de Cuenta Inexistente
- **Entrada:** cvecuenta inexistente
- **Acción:** get_ubicodifica_data
- **Resultado esperado:** Error 400 o 404, mensaje adecuado

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

