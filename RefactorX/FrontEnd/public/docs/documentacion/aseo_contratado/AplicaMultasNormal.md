# Documentación Técnica: AplicaMultasNormal

## Análisis

# Documentación Técnica: AplicaMultasNormal

## Descripción General
El módulo **AplicaMultasNormal** permite consultar y modificar la configuración global de la aplicación de requerimientos normales para cobro de multas en el sistema. Esta configuración determina si la aplicación es normal (aplica = 'S') o si se aplica un porcentaje de descuento (aplica = 'N', porc > 0).

## Arquitectura
- **Backend**: Laravel Controller expuesto en `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend**: Componente Vue.js como página independiente.
- **Base de Datos**: PostgreSQL, lógica encapsulada en stored procedures.

## API (eRequest/eResponse)
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  - `action`: (string) Acción a ejecutar (`get_aplicareq`, `update_aplicareq`)
  - `params`: (object) Parámetros para la acción

### Acciones soportadas
- `get_aplicareq`: Devuelve la configuración actual.
- `update_aplicareq`: Actualiza la configuración. Requiere `aplica` ('S' o 'N') y `porc` (entero).

## Stored Procedures
- `sp_get_aplicareq()`: Devuelve la fila de configuración.
- `sp_update_aplicareq(p_aplica, p_porc)`: Actualiza la configuración.

## Validaciones
- Si `aplica = 'N'`, `porc` debe ser > 0 y <= 100.
- Si `aplica = 'S'`, `porc` debe ser 0.

## Seguridad
- Solo usuarios autenticados con permisos de administración pueden modificar la configuración.
- Todas las operaciones quedan registradas en logs de auditoría (a implementar en el futuro).

## Frontend
- Página Vue.js independiente, sin tabs.
- Muestra los valores actuales y permite modificar la opción y porcentaje.
- Mensajes claros de éxito/error.

## Navegación
- Puede integrarse en el menú principal o accederse directamente por ruta.

## Errores comunes
- Si se intenta guardar con `aplica = 'N'` y `porc <= 0`, se muestra mensaje de error.
- Si la acción no es soportada, se devuelve error desde el backend.

## Ejemplo de eRequest
```json
{
  "action": "update_aplicareq",
  "params": {
    "aplica": "N",
    "porc": 50
  }
}
```

## Ejemplo de eResponse
```json
{
  "success": true,
  "message": "La NO Aplicación Normal CON PORCENTAJE Realizada",
  "data": null
}
```


## Casos de Uso

# Casos de Uso - AplicaMultasNormal

**Categoría:** Form

## Caso de Uso 1: Consulta de configuración actual de aplicación de multas normales

**Descripción:** El usuario accede a la página para visualizar la configuración vigente de aplicación de requerimientos normales.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de consulta.

**Pasos a seguir:**
1. El usuario navega a la página 'Aplicación Normal de Requerimientos para Cobro'.
2. El sistema realiza una petición a /api/execute con action 'get_aplicareq'.
3. El sistema muestra la descripción, si aplica y el porcentaje actual.

**Resultado esperado:**
La página muestra los valores actuales de la configuración.

**Datos de prueba:**
No se requiere data específica, solo que exista al menos una fila en ta_aplicareq.

---

## Caso de Uso 2: Cambio a aplicación normal (sin porcentaje)

**Descripción:** El usuario decide que la aplicación debe ser normal (sin descuento) y guarda el cambio.

**Precondiciones:**
El usuario tiene permisos de edición.

**Pasos a seguir:**
1. El usuario selecciona la opción 'SI' en la radio de aplicación.
2. El usuario deja el campo porcentaje en 0 (o vacío).
3. El usuario pulsa 'Guardar Cambios'.
4. El sistema envía action 'update_aplicareq' con aplica='S', porc=0.

**Resultado esperado:**
El sistema actualiza la configuración y muestra el mensaje 'La Aplicación Normal Realizada'.

**Datos de prueba:**
aplica: 'S', porc: 0

---

## Caso de Uso 3: Cambio a no aplicación normal con porcentaje

**Descripción:** El usuario decide que la aplicación no será normal y debe aplicar un porcentaje de descuento.

**Precondiciones:**
El usuario tiene permisos de edición.

**Pasos a seguir:**
1. El usuario selecciona la opción 'NO' en la radio de aplicación.
2. El usuario ingresa un valor mayor a 0 en el campo porcentaje (ejemplo: 25).
3. El usuario pulsa 'Guardar Cambios'.
4. El sistema envía action 'update_aplicareq' con aplica='N', porc=25.

**Resultado esperado:**
El sistema actualiza la configuración y muestra el mensaje 'La NO Aplicación Normal CON PORCENTAJE Realizada'.

**Datos de prueba:**
aplica: 'N', porc: 25

---



## Casos de Prueba

## Casos de Prueba: AplicaMultasNormal

### Caso 1: Consulta de configuración actual
- **Acción:** GET (POST /api/execute con action 'get_aplicareq')
- **Esperado:** Respuesta con los campos descripcion, aplica, porc.
- **Validación:** Los valores corresponden a la base de datos.

### Caso 2: Cambio a aplicación normal
- **Acción:** POST /api/execute con action 'update_aplicareq', aplica='S', porc=0
- **Esperado:** Mensaje 'La Aplicación Normal Realizada'.
- **Validación:** En la base de datos, aplica='S', porc=0.

### Caso 3: Cambio a no aplicación normal con porcentaje
- **Acción:** POST /api/execute con action 'update_aplicareq', aplica='N', porc=30
- **Esperado:** Mensaje 'La NO Aplicación Normal CON PORCENTAJE Realizada'.
- **Validación:** En la base de datos, aplica='N', porc=30.

### Caso 4: Error por porcentaje faltante
- **Acción:** POST /api/execute con action 'update_aplicareq', aplica='N', porc=0
- **Esperado:** Mensaje de error 'Falta el porcentaje de Aplicación de Multa'.
- **Validación:** No se actualiza la base de datos.

### Caso 5: Error por acción no soportada
- **Acción:** POST /api/execute con action 'no_existente'
- **Esperado:** Mensaje de error 'Acción no soportada'.
- **Validación:** No se realiza ningún cambio.

