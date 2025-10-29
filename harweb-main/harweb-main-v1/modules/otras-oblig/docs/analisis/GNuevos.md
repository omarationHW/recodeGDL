# Documentación Técnica: Migración Formulario GNuevos (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel API, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.

## API Unificada
- **Endpoint**: `POST /api/execute`
- **Request**:
  - `action`: string, nombre de la acción (ej: `GNuevos.create`)
  - `params`: objeto, parámetros requeridos por la acción
- **Response**:
  - `success`: boolean
  - `data`: objeto con resultado o error

### Ejemplo de Request
```json
{
  "action": "GNuevos.create",
  "params": {
    "par_tabla": 3,
    "par_control": "123-AB",
    "par_conces": "JUAN PEREZ",
    "par_ubica": "MERCADO CENTRAL",
    "par_sup": 10.5,
    "par_Axo_Ini": 2024,
    "par_Mes_Ini": 6,
    "par_ofna": 1,
    "par_sector": "A",
    "par_zona": 2,
    "par_lic": 123456,
    "par_Descrip": "INTERNO",
    "par_NomCom": "TIENDA JUAN",
    "par_Lugar": "LOCAL 5",
    "par_Obs": "NINGUNA",
    "par_usuario": "admin"
  }
}
```

## Stored Procedures
- Toda la lógica de negocio (validaciones, inserciones, reglas) está en SPs.
- El SP `sp_gnuevos_alta` realiza validaciones y alta de registro.

## Vue.js
- Cada formulario es una página Vue independiente.
- No se usan tabs ni componentes tabulares.
- Navegación y breadcrumbs opcionales.
- Validaciones en frontend y backend.

## Laravel Controller
- Un solo controlador (`ExecuteController`) maneja todas las acciones.
- Cada acción se mapea a un método privado.
- Todas las respuestas siguen el patrón eRequest/eResponse.

## Seguridad
- Validación de parámetros en backend.
- Validación de usuario/autenticación recomendada (no incluida en este ejemplo).

## Extensibilidad
- Para agregar nuevas acciones, implementar el método en el controlador y el SP correspondiente.

## Errores
- Los errores se devuelven en el campo `error` del JSON.
- Los mensajes de validación y negocio se devuelven desde el SP.

## Pruebas
- Casos de uso y pruebas incluidas al final de este documento.
