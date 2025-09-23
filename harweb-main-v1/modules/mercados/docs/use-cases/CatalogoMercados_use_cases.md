# Casos de Uso - CatalogoMercados

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo Mercado

**Descripción:** El usuario desea agregar un nuevo mercado al catálogo.

**Precondiciones:**
El usuario está autenticado y tiene permisos de administrador.

**Pasos a seguir:**
- El usuario ingresa a la página Catálogo de Mercados.
- Hace clic en 'Agregar Mercado'.
- Llena el formulario con los datos requeridos (oficina, número de mercado, categoría, descripción, cuentas, zona, tipo emisión).
- Hace clic en 'Guardar'.
- El sistema valida y envía la petición a `/api/execute` con action 'create'.

**Resultado esperado:**
El mercado se agrega correctamente y aparece en la tabla. Se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "oficina": 2,
  "num_mercado_nvo": 10,
  "categoria": 1,
  "descripcion": "Mercado San Juan",
  "cuenta_ingreso": 44501,
  "cuenta_energia": 44119,
  "id_zona": 3,
  "tipo_emision": "M"
}

---

## Caso de Uso 2: Modificación de un Mercado existente

**Descripción:** El usuario edita la descripción y cuenta de ingreso de un mercado.

**Precondiciones:**
El mercado existe y el usuario tiene permisos de edición.

**Pasos a seguir:**
- El usuario selecciona un mercado de la tabla y hace clic en 'Editar'.
- Cambia la descripción y la cuenta de ingreso.
- Hace clic en 'Guardar'.
- El sistema valida y envía la petición a `/api/execute` con action 'update'.

**Resultado esperado:**
El mercado se actualiza correctamente y los cambios se reflejan en la tabla.

**Datos de prueba:**
{
  "oficina": 2,
  "num_mercado_nvo": 10,
  "categoria": 1,
  "descripcion": "Mercado San Juan Renovado",
  "cuenta_ingreso": 44502,
  "cuenta_energia": 44119,
  "id_zona": 3,
  "tipo_emision": "M"
}

---

## Caso de Uso 3: Eliminación de un Mercado

**Descripción:** El usuario elimina un mercado del catálogo.

**Precondiciones:**
El mercado existe y el usuario tiene permisos de eliminación.

**Pasos a seguir:**
- El usuario hace clic en 'Eliminar' en la fila correspondiente.
- Confirma la eliminación.
- El sistema envía la petición a `/api/execute` con action 'delete'.

**Resultado esperado:**
El mercado se elimina de la base de datos y desaparece de la tabla.

**Datos de prueba:**
{
  "oficina": 2,
  "num_mercado_nvo": 10
}

---

