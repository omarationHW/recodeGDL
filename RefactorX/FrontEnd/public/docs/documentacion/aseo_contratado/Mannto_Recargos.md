# Documentación Técnica: Mannto_Recargos

## Análisis

# Documentación Técnica: Mantenimiento de Recargos (ta_16_recargos)

## Descripción General
Este módulo permite la administración de los recargos y multas mensuales asociados a periodos fiscales. Incluye la consulta, alta, modificación y eliminación de registros de recargos para cada mes de un año fiscal.

## Arquitectura
- **Backend:** Laravel Controller expone un endpoint único `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente, sin tabs, con navegación y formularios completos.
- **Base de Datos:** Toda la lógica de negocio y validación reside en stored procedures PostgreSQL.
- **API:** El endpoint `/api/execute` recibe `{ action, params }` y responde con `{ success, data, message }`.

## API eRequest/eResponse
- **Endpoint:** `POST /api/execute`
- **Body:**
  ```json
  {
    "action": "recargos.list|recargos.create|recargos.update|recargos.delete",
    "params": { ... }
  }
  ```
- **Acciones:**
  - `recargos.list`: Listar recargos de un año `{ year }`
  - `recargos.create`: Crear recargo `{ year, month, porc_recargo, porc_multa }`
  - `recargos.update`: Actualizar recargo `{ year, month, porc_recargo, porc_multa }`
  - `recargos.delete`: Eliminar recargo `{ year, month }`
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": [...],
    "message": "..."
  }
  ```

## Validaciones
- No se permite duplicar recargos para el mismo año-mes.
- No se permite eliminar o actualizar un recargo inexistente.
- Todos los campos son obligatorios y deben ser numéricos positivos.

## Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o Laravel Sanctum.
- Validar roles/privilegios para acceso a operaciones de escritura.

## Integración Vue.js
- El componente Vue.js consume el endpoint `/api/execute` usando fetch/AJAX.
- El formulario de alta y edición valida los campos antes de enviar.
- El listado se actualiza automáticamente tras operaciones exitosas.

## Navegación
- Cada formulario es una página independiente, sin tabs.
- Breadcrumbs opcionales para navegación.

## Errores y Mensajes
- Todos los errores de validación y de base de datos se devuelven en el campo `message`.
- El frontend muestra los mensajes de error o éxito en alertas visibles.

## Ejemplo de llamada
```json
{
  "action": "recargos.create",
  "params": {
    "year": 2024,
    "month": 6,
    "porc_recargo": 2.5,
    "porc_multa": 1.5
  }
}
```

## Ejemplo de respuesta
```json
{
  "success": true,
  "message": "Recargo creado correctamente"
}
```

# Base de Datos
- Tabla: `ta_16_recargos`
  - `aso_mes_recargo` DATE (PK)
  - `porc_recargo` NUMERIC
  - `porc_multa` NUMERIC

# Stored Procedures
- `sp_recargos_list(year)`
- `sp_recargos_create(year, month, porc_recargo, porc_multa)`
- `sp_recargos_update(year, month, porc_recargo, porc_multa)`
- `sp_recargos_delete(year, month)`

# Frontend
- Página Vue.js independiente
- Listado, alta, edición y eliminación de recargos
- Validación de campos y mensajes de error

# Backend
- Controlador Laravel único para todas las acciones
- Uso de validaciones y manejo de errores
- Llamadas a stored procedures PostgreSQL

# Pruebas
- Casos de uso y pruebas unitarias incluidas


## Casos de Uso

# Casos de Uso - Mannto_Recargos

**Categoría:** Form

## Caso de Uso 1: Alta de Recargo Mensual

**Descripción:** El usuario desea registrar el recargo y multa para el mes de junio de 2024.

**Precondiciones:**
El usuario tiene permisos de administrador. No existe recargo para junio 2024.

**Pasos a seguir:**
1. Accede a la página de Recargos.
2. Da clic en 'Nuevo Recargo'.
3. Ingresa Año: 2024, Mes: 6, % Recargo: 2.5, % Multa: 1.5.
4. Da clic en 'Guardar'.

**Resultado esperado:**
El sistema muestra mensaje 'Recargo creado correctamente' y el nuevo registro aparece en la lista.

**Datos de prueba:**
{ "year": 2024, "month": 6, "porc_recargo": 2.5, "porc_multa": 1.5 }

---

## Caso de Uso 2: Edición de Recargo Existente

**Descripción:** El usuario modifica el porcentaje de multa para el recargo de junio 2024.

**Precondiciones:**
Existe un recargo para junio 2024.

**Pasos a seguir:**
1. Accede a la página de Recargos.
2. Busca el año 2024.
3. Da clic en 'Editar' en el recargo de junio.
4. Cambia % Multa a 2.0.
5. Da clic en 'Guardar'.

**Resultado esperado:**
El sistema muestra mensaje 'Recargo actualizado correctamente' y el valor se actualiza en la lista.

**Datos de prueba:**
{ "year": 2024, "month": 6, "porc_recargo": 2.5, "porc_multa": 2.0 }

---

## Caso de Uso 3: Eliminación de Recargo

**Descripción:** El usuario elimina el recargo del mes de junio 2024.

**Precondiciones:**
Existe un recargo para junio 2024.

**Pasos a seguir:**
1. Accede a la página de Recargos.
2. Busca el año 2024.
3. Da clic en 'Eliminar' en el recargo de junio.
4. Confirma la eliminación.

**Resultado esperado:**
El sistema muestra mensaje 'Recargo eliminado correctamente' y el registro desaparece de la lista.

**Datos de prueba:**
{ "year": 2024, "month": 6 }

---



## Casos de Prueba

# Casos de Prueba para Mantenimiento de Recargos

## 1. Alta de Recargo Correcto
- **Entrada:** year=2024, month=6, porc_recargo=2.5, porc_multa=1.5
- **Acción:** recargos.create
- **Esperado:** success=true, message='Recargo creado correctamente'

## 2. Alta de Recargo Duplicado
- **Entrada:** year=2024, month=6, porc_recargo=2.5, porc_multa=1.5 (ya existe)
- **Acción:** recargos.create
- **Esperado:** success=false, message='Ya existe un recargo para ese periodo'

## 3. Edición de Recargo Existente
- **Entrada:** year=2024, month=6, porc_recargo=2.5, porc_multa=2.0
- **Acción:** recargos.update
- **Esperado:** success=true, message='Recargo actualizado correctamente'

## 4. Edición de Recargo Inexistente
- **Entrada:** year=2025, month=7, porc_recargo=2.0, porc_multa=1.0
- **Acción:** recargos.update
- **Esperado:** success=false, message='No existe recargo para ese periodo'

## 5. Eliminación de Recargo Existente
- **Entrada:** year=2024, month=6
- **Acción:** recargos.delete
- **Esperado:** success=true, message='Recargo eliminado correctamente'

## 6. Eliminación de Recargo Inexistente
- **Entrada:** year=2025, month=7
- **Acción:** recargos.delete
- **Esperado:** success=false, message='No existe recargo para ese periodo'

## 7. Consulta de Recargos por Año
- **Entrada:** year=2024
- **Acción:** recargos.list
- **Esperado:** success=true, data=[...], message=''

## 8. Validación de Campos Obligatorios
- **Entrada:** year=2024, month=null, porc_recargo=2.5, porc_multa=1.5
- **Acción:** recargos.create
- **Esperado:** success=false, message='The month field is required.'


