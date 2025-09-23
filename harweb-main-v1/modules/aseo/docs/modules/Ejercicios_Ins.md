# Documentación Técnica: Ejercicios_Ins

## Descripción General
El módulo **Ejercicios_Ins** permite la gestión de los ejercicios fiscales/años en el sistema. Permite visualizar los ejercicios existentes y agregar uno nuevo, asegurando que no se dupliquen.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js de página completa, independiente, sin tabs.
- **Base de Datos:** PostgreSQL, lógica de inserción encapsulada en stored procedure `sp_create_ejercicio`.

## API
### Endpoint
`POST /api/execute`

#### Request Body
```json
{
  "action": "get_ejercicios"
}
```

```json
{
  "action": "create_ejercicio",
  "params": { "ejercicio": 2024 }
}
```

#### Response
```json
{
  "success": true,
  "data": [...],
  "message": "Ejercicio creado correctamente"
}
```

## Stored Procedure
- **sp_create_ejercicio(p_ejercicio INTEGER):**
  - Verifica si el ejercicio ya existe.
  - Si no existe, lo inserta con la fecha actual.
  - Devuelve 'OK' o mensaje de error.

## Validaciones
- El año debe ser numérico, entre 1900 y 2100.
- No se permite duplicidad de ejercicios.

## Seguridad
- Todas las operaciones pasan por validación de parámetros en el backend.
- El endpoint está protegido por autenticación Laravel (middleware estándar).

## Flujo de Usuario
1. El usuario ve la lista de ejercicios.
2. Ingresa un nuevo año y presiona "Aceptar".
3. El sistema valida y, si es correcto, lo agrega y actualiza la lista.

## Errores Comunes
- Intentar agregar un año existente: muestra mensaje "YA EXISTE EL EJERCICIO".
- Año fuera de rango: validación frontend y backend.

## Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones relacionadas.
- El stored procedure puede ser modificado para agregar más lógica si se requiere.
