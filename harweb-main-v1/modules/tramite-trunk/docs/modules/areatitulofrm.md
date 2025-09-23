# Documentación Técnica: Área según Título (areatitulofrm)

## Descripción General
Este módulo permite consultar y actualizar el campo "área según título" de una cuenta catastral, registrando observaciones y validando que el área no difiera más de un 10% respecto a la superficie de terreno registrada en el avalúo. Incluye lógica de comprobante y registro de auditoría.

## Arquitectura
- **Backend:** Laravel Controller (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (componente de página independiente)
- **Base de datos:** PostgreSQL (stored procedures para lógica de negocio)
- **Patrón API:** eRequest/eResponse

## Flujo de Datos
1. El usuario accede a la página de "Área según título" e ingresa el número de cuenta catastral.
2. El frontend consulta los datos actuales vía `/api/execute` con acción `get`.
3. El usuario edita el área y observaciones, y presiona "Actualizar".
4. El frontend envía la petición con acción `update`.
5. El backend valida:
   - Si el subpredio > 0, solo actualiza.
   - Si no, valida que el área no difiera más de 10% respecto al avalúo.
   - Si la validación pasa, ejecuta el stored procedure para actualizar.
6. El frontend muestra mensajes de éxito o error.

## Validaciones
- El área según título debe ser mayor a 0.
- Si el subpredio es 0, la diferencia porcentual entre el área del avalúo y el área según título no debe exceder el 10%.
- Si no existe avalúo o la superficie es 0, se rechaza la operación.

## Seguridad
- El endpoint requiere autenticación (middleware Laravel `auth:api` recomendado).
- El usuario que realiza la operación se registra como capturista.

## API
### Endpoint
`POST /api/execute`

#### Entrada (eRequest)
- `action`: `get` | `update` | `cancel`
- `cvecuenta`: int
- `areatitulo`: float (solo para update)
- `observacion`: string (opcional)

#### Salida (eResponse)
- `success`: bool
- `message`: string
- `data`: objeto con los datos de la cuenta (para get)

## Stored Procedure
- `sp_update_area_titulo`: Actualiza el área y observación, incrementa el asiento, registra capturista y fecha.

## Frontend
- Página Vue.js independiente, sin tabs.
- Navegación breadcrumb.
- Formulario reactivo, validación en cliente y servidor.
- Mensajes de error y éxito.

## Auditoría
- Cada actualización incrementa el campo `asiento`.
- Se recomienda registrar cambios en tabla histórica si aplica.

## Extensibilidad
- El endpoint puede ser extendido para soportar otras acciones (delete, history, etc.)
- El componente Vue puede integrarse en un router SPA.
