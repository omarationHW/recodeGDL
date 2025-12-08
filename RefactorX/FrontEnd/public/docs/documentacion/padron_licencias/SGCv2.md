# Documentación Técnica: SGCv2

## Análisis Técnico

# Documentación Técnica SGCv2 - Migración Delphi a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente (NO tabs).
- **Base de Datos**: PostgreSQL, toda la lógica de negocio SQL en stored procedures (SPs).
- **Comunicación**: Patrón eRequest/eResponse, todos los requests van a `/api/execute` con `{ eRequest: { action, params } }`.

## Flujo de Datos
1. **Frontend**: El usuario navega a una página (ej. Alta de Licencia), llena el formulario y envía.
2. **Vue.js**: El componente construye un `eRequest` con la acción y los parámetros y lo envía vía POST a `/api/execute`.
3. **Laravel Controller**: Recibe el request, despacha según la acción, llama el SP correspondiente y retorna el resultado como `eResponse`.
4. **PostgreSQL**: Ejecuta el SP, realiza la lógica, retorna el resultado (JSON o tabla).
5. **Frontend**: Recibe el `eResponse` y muestra el resultado.

## Ejemplo de Request/Response
**Request:**
```json
{
  "eRequest": {
    "action": "altaTramiteLicencia",
    "params": {
      "tipo_tramite": 1,
      "id_giro": 123,
      "propietario": "Juan Perez",
      "rfc": "PEJJ800101XXX",
      ...
    }
  }
}
```
**Response:**
```json
{
  "eResponse": {
    "id_tramite": 456,
    "status": "ok"
  }
}
```

## Seguridad
- Autenticación JWT recomendada (no incluida en este ejemplo).
- Validación de parámetros en el frontend y backend.
- Todos los accesos a datos pasan por SPs, no hay SQL directo en el backend.

## Estructura de SPs
- Todos los SPs devuelven JSON o TABLE.
- Los SPs de proceso (alta, baja, bloqueo) devuelven `{ status, id, ... }`.
- Los SPs de consulta devuelven JSON con los datos solicitados.

## Frontend
- Cada formulario es un componente Vue independiente.
- Navegación por rutas (`/licencia/alta`, `/licencia/consulta`, etc.).
- No hay tabs, cada formulario es una página.
- Breadcrumbs opcionales.
- Validación de campos en el frontend.
- Llamadas a `/api/execute` con la acción y parámetros.

## Backend
- Un solo controlador (`SGCv2Controller`) maneja todas las acciones.
- Cada acción llama un SP específico.
- Manejo de errores centralizado.

## Base de Datos
- Todas las operaciones de negocio están en SPs.
- No se permite acceso directo a tablas desde el backend.
- Los SPs pueden recibir parámetros simples o JSON.

## Extensibilidad
- Para agregar una nueva acción, crear el SP y agregar el case en el controlador.
- Para agregar una nueva página, crear el componente Vue y la ruta.

## Ejemplo de Extensión
- Para agregar "Reactivar Licencia":
  - Crear `sp_reactivar_licencia` en PostgreSQL.
  - Agregar método `reactivarLicencia` en el controlador.
  - Crear página Vue `ReactivarLicencia.vue`.

## Pruebas
- Todos los casos de uso y pruebas deben ejecutarse vía `/api/execute`.

## Notas
- El sistema es desacoplado: el frontend no conoce la estructura de la base de datos.
- El backend sólo despacha acciones y valida parámetros.
- La lógica de negocio y reglas están en los SPs.

## Casos de Prueba

## Casos de Prueba SGCv2

### Caso 1: Alta de Trámite de Licencia
- **Entrada:**
  - action: altaTramiteLicencia
  - params: { tipo_tramite: 1, id_giro: 123, propietario: "Juan Perez", rfc: "PEJJ800101XXX", ... }
- **Esperado:**
  - eResponse: { id_tramite: <int>, status: "ok" }

### Caso 2: Bloqueo de Licencia
- **Entrada:**
  - action: bloquearLicencia
  - params: { licencia: 456, motivo: "Falta de pago", usuario: "admin" }
- **Esperado:**
  - eResponse: { licencia: 456, status: "bloqueada" }

### Caso 3: Consulta de Licencia
- **Entrada:**
  - action: consultaLicencia
  - params: { licencia: 456 }
- **Esperado:**
  - eResponse: { ...datos de la licencia... }

### Caso 4: Baja de Licencia
- **Entrada:**
  - action: bajaLicencia
  - params: { licencia: 456, motivo: "Cierre definitivo", usuario: "admin" }
- **Esperado:**
  - eResponse: { licencia: 456, status: "baja" }

### Caso 5: Consulta de Trámite
- **Entrada:**
  - action: consultaTramite
  - params: { tramite: 789 }
- **Esperado:**
  - eResponse: { ...datos del trámite... }

## Casos de Uso

# Casos de Uso - SGCv2

**Categoría:** Form

## Caso de Uso 1: Alta de Trámite de Licencia

**Descripción:** El usuario da de alta un trámite de licencia nueva, ingresando todos los datos requeridos.

**Precondiciones:**
El usuario está autenticado y tiene permisos para alta de trámites.

**Pasos a seguir:**
[
  "El usuario navega a la página de Alta de Licencia.",
  "Llena el formulario con los datos del propietario, giro, domicilio, etc.",
  "Presiona 'Guardar'.",
  "El frontend envía un eRequest con acción 'altaTramiteLicencia' y los datos.",
  "El backend ejecuta el SP correspondiente.",
  "El sistema retorna el id_tramite generado y status 'ok'."
]

**Resultado esperado:**
El trámite se registra correctamente y se muestra el número de folio generado.

**Datos de prueba:**
{
  "tipo_tramite": 1,
  "id_giro": 123,
  "propietario": "Juan Perez",
  "rfc": "PEJJ800101XXX",
  "curp": "PEJJ800101HJCXXX01",
  "domicilio": "Av. Juarez 123",
  "telefono_prop": "3331234567",
  "email": "juan.perez@email.com"
}

---

## Caso de Uso 2: Bloqueo de Licencia

**Descripción:** El usuario bloquea una licencia por motivo administrativo.

**Precondiciones:**
El usuario tiene permisos de bloqueo.

**Pasos a seguir:**
[
  "El usuario navega a la página de Bloqueo de Licencia.",
  "Ingresa el número de licencia y el motivo.",
  "Presiona 'Bloquear'.",
  "El frontend envía un eRequest con acción 'bloquearLicencia'.",
  "El backend ejecuta el SP de bloqueo.",
  "El sistema retorna status 'bloqueada'."
]

**Resultado esperado:**
La licencia queda bloqueada y se registra el motivo.

**Datos de prueba:**
{
  "licencia": 456,
  "motivo": "Falta de pago",
  "usuario": "admin"
}

---

## Caso de Uso 3: Consulta de Licencia

**Descripción:** El usuario consulta los datos de una licencia existente.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
[
  "El usuario navega a la página de Consulta de Licencia.",
  "Ingresa el número de licencia.",
  "Presiona 'Buscar'.",
  "El frontend envía un eRequest con acción 'consultaLicencia'.",
  "El backend ejecuta el SP de consulta.",
  "El sistema retorna los datos de la licencia."
]

**Resultado esperado:**
Se muestran todos los datos de la licencia consultada.

**Datos de prueba:**
{
  "licencia": 456
}

---


