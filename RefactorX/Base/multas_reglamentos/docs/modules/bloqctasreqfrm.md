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
