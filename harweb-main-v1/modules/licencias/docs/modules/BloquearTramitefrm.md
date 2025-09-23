# Documentación Técnica: Migración de BloquearTramitefrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General

- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel API, endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Base de Datos**: PostgreSQL, toda la lógica de negocio y acceso a datos encapsulada en stored procedures.

## 2. API Unificada

- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**: `{ eRequest: { action: string, params: object } }`
- **Response**: `{ eResponse: { success: boolean, data: any, message: string } }`

### Acciones soportadas:
- `getTramite`: Obtiene los datos de un trámite por ID.
- `getBloqueos`: Obtiene el historial de bloqueos/desbloqueos de un trámite.
- `getGiroDescripcion`: Obtiene la descripción del giro asociado al trámite.
- `bloquearTramite`: Bloquea el trámite, cancela el último bloqueo vigente y registra el nuevo bloqueo.
- `desbloquearTramite`: Desbloquea el trámite, cancela el último bloqueo vigente y registra el desbloqueo.

## 3. Stored Procedures

Toda la lógica de acceso y manipulación de datos se realiza mediante funciones almacenadas en PostgreSQL:
- **get_tramite**: Devuelve todos los campos del trámite.
- **get_bloqueos**: Devuelve el historial de bloqueos/desbloqueos, calculando el estado textual.
- **get_giro_descripcion**: Devuelve la descripción del giro.
- **bloquear_tramite**: Realiza el proceso de bloqueo (actualiza campo, cancela vigentes, inserta nuevo registro).
- **desbloquear_tramite**: Realiza el proceso de desbloqueo (igual que bloqueo, pero con valor 0).

## 4. Frontend (Vue.js)

- Página independiente con ruta propia.
- Formulario para ingresar el número de trámite.
- Visualización de datos del trámite y su historial de bloqueos.
- Botones para bloquear/desbloquear según estado actual.
- Prompts para capturar observaciones.
- Mensajes de éxito/error.

## 5. Backend (Laravel)

- Controlador único (`ExecuteController`) que enruta la acción a la función almacenada correspondiente.
- Manejo de errores y respuesta unificada.

## 6. Seguridad

- Validación de parámetros en el frontend y backend.
- Uso de funciones almacenadas para evitar SQL Injection.
- El campo `capturista` debe ser provisto por el frontend (puede integrarse con autenticación en producción).

## 7. Consideraciones de Migración

- Todos los nombres de campos y lógica se mantienen fieles al formulario original.
- El cálculo de propietario nuevo (`propietarionvo`) se realiza en el frontend.
- El historial de bloqueos muestra el estado textual calculado en el SP.

## 8. Extensibilidad

- Se pueden agregar nuevas acciones al endpoint unificado simplemente agregando nuevos casos en el controlador y nuevos SPs.

## 9. Pruebas

- Casos de uso y pruebas detalladas incluidas para asegurar la funcionalidad y robustez del sistema.
