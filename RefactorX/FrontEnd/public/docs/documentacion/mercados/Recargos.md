# Recargos

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Módulo Recargos (Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
El módulo de Recargos permite la administración de los porcentajes de recargo por año y mes, usados para el cálculo de recargos en pagos atrasados. Incluye operaciones de alta, modificación, eliminación y consulta de recargos.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente, sin tabs.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "recargos.list|recargos.create|recargos.update|recargos.delete",
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedures
- `sp_recargos_list()`: Devuelve todos los recargos.
- `sp_recargos_create(axo, periodo, porcentaje, usuario_id)`: Inserta un nuevo recargo.
- `sp_recargos_update(axo, periodo, porcentaje, usuario_id)`: Actualiza un recargo existente.
- `sp_recargos_delete(axo, periodo)`: Elimina un recargo.

## 5. Validaciones
- Año (`axo`): Obligatorio, entero.
- Mes (`periodo`): Obligatorio, entero entre 1 y 12.
- Porcentaje: Obligatorio, numérico.
- Usuario: Obligatorio, entero.

## 6. Seguridad
- Todas las operaciones requieren autenticación (middleware Laravel recomendado).
- Validación de parámetros en backend.

## 7. Frontend
- Página Vue.js independiente.
- Tabla con listado de recargos.
- Modales para alta y edición.
- Acciones de editar y eliminar por fila.
- Navegación breadcrumb.

## 8. Consideraciones
- No se usan tabs ni componentes tabulares.
- El frontend consume el endpoint unificado.
- Los stored procedures encapsulan toda la lógica de acceso a datos.

## 9. Ejemplo de Request para Alta
```json
{
  "eRequest": {
    "action": "recargos.create",
    "params": {
      "axo": 2024,
      "periodo": 6,
      "porcentaje": 2.5,
      "usuario_id": 1
    }
  }
}
```

## 10. Ejemplo de Response
```json
{
  "eResponse": {
    "success": true,
    "data": null,
    "message": ""
  }
}
```


## Casos de Uso

# Casos de Uso - Recargos

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo recargo

**Descripción:** El usuario desea registrar el porcentaje de recargo para el mes de julio de 2024.

**Precondiciones:**
El usuario está autenticado y tiene permisos de administración.

**Pasos a seguir:**
1. Ingresa a la página de Recargos.
2. Da clic en 'Agregar Recargo'.
3. Llena los campos: Año=2024, Mes=7, Porcentaje=2.5, Usuario=1.
4. Da clic en 'Guardar'.

**Resultado esperado:**
El nuevo recargo aparece en la tabla y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "axo": 2024, "periodo": 7, "porcentaje": 2.5, "usuario_id": 1 }

---

## Caso de Uso 2: Modificación de un recargo existente

**Descripción:** El usuario necesita actualizar el porcentaje de recargo de julio 2024 a 3.0%.

**Precondiciones:**
Existe un recargo para 2024/7. El usuario tiene permisos.

**Pasos a seguir:**
1. Busca el recargo 2024/7 en la tabla.
2. Da clic en 'Editar'.
3. Cambia el porcentaje a 3.0.
4. Da clic en 'Guardar Cambios'.

**Resultado esperado:**
El porcentaje se actualiza y se refleja en la tabla.

**Datos de prueba:**
{ "axo": 2024, "periodo": 7, "porcentaje": 3.0, "usuario_id": 1 }

---

## Caso de Uso 3: Eliminación de un recargo

**Descripción:** El usuario elimina el recargo del mes de junio 2023.

**Precondiciones:**
Existe un recargo para 2023/6.

**Pasos a seguir:**
1. Busca el recargo 2023/6 en la tabla.
2. Da clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
El recargo desaparece de la tabla.

**Datos de prueba:**
{ "axo": 2023, "periodo": 6 }

---



## Casos de Prueba

# Casos de Prueba: Módulo Recargos

## 1. Alta de Recargo Válido
- **Entrada:** Año=2024, Mes=7, Porcentaje=2.5, Usuario=1
- **Acción:** POST /api/execute con action=recargos.create
- **Esperado:** Código 200, success=true, recargo aparece en listado

## 2. Alta de Recargo con Mes Inválido
- **Entrada:** Año=2024, Mes=13, Porcentaje=2.5, Usuario=1
- **Acción:** POST /api/execute con action=recargos.create
- **Esperado:** Código 200, success=false, mensaje de error "periodo debe ser entre 1 y 12"

## 3. Modificación de Recargo Existente
- **Entrada:** Año=2024, Mes=7, Porcentaje=3.0, Usuario=1
- **Acción:** POST /api/execute con action=recargos.update
- **Esperado:** Código 200, success=true, porcentaje actualizado

## 4. Eliminación de Recargo Existente
- **Entrada:** Año=2023, Mes=6
- **Acción:** POST /api/execute con action=recargos.delete
- **Esperado:** Código 200, success=true, recargo eliminado

## 5. Consulta de Recargos
- **Acción:** POST /api/execute con action=recargos.list
- **Esperado:** Código 200, success=true, lista de recargos

## 6. Alta de Recargo Duplicado
- **Entrada:** Año=2024, Mes=7, Porcentaje=2.5, Usuario=1 (ya existe)
- **Acción:** POST /api/execute con action=recargos.create
- **Esperado:** Código 200, success=false, mensaje de error de clave duplicada



