# Documentación Técnica: Ejercicios_Ins

## Análisis

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


## Casos de Uso

# Casos de Uso - Ejercicios_Ins

**Categoría:** Form

## Caso de Uso 1: Agregar un nuevo ejercicio fiscal

**Descripción:** El usuario desea agregar el ejercicio 2025 al sistema.

**Precondiciones:**
El usuario tiene permisos de administrador y el año 2025 no existe en la tabla.

**Pasos a seguir:**
1. El usuario accede a la página de Ejercicios.
2. Ingresa '2025' en el campo de nuevo ejercicio.
3. Presiona el botón 'Aceptar'.

**Resultado esperado:**
El sistema muestra mensaje de éxito y el año 2025 aparece en la lista.

**Datos de prueba:**
nuevoEjercicio = 2025

---

## Caso de Uso 2: Intentar agregar un ejercicio existente

**Descripción:** El usuario intenta agregar el año 2023, que ya existe.

**Precondiciones:**
El año 2023 ya está en la tabla ta_16_ejercicios.

**Pasos a seguir:**
1. El usuario accede a la página de Ejercicios.
2. Ingresa '2023' en el campo de nuevo ejercicio.
3. Presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra mensaje de error 'YA EXISTE EL EJERCICIO' y no agrega nada.

**Datos de prueba:**
nuevoEjercicio = 2023

---

## Caso de Uso 3: Validación de año fuera de rango

**Descripción:** El usuario intenta agregar el año 1800.

**Precondiciones:**
El usuario tiene acceso al formulario.

**Pasos a seguir:**
1. El usuario accede a la página de Ejercicios.
2. Ingresa '1800' en el campo de nuevo ejercicio.
3. Presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra mensaje de error de validación y no realiza ninguna acción.

**Datos de prueba:**
nuevoEjercicio = 1800

---



## Casos de Prueba

# Casos de Prueba: Ejercicios_Ins

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|-------------------|
| 1 | Agregar ejercicio válido | 2026 | Mensaje de éxito, aparece en lista |
| 2 | Agregar ejercicio duplicado | 2024 (ya existe) | Mensaje de error 'YA EXISTE EL EJERCICIO' |
| 3 | Año fuera de rango | 1899 | Mensaje de error de validación |
| 4 | Año no numérico | 'abcd' | Mensaje de error de validación |
| 5 | Listar ejercicios | - | Lista completa de ejercicios |


