# Casos de Uso - ABCFolio

**Categoría:** Form

## Caso de Uso 1: Consulta de Folio Existente

**Descripción:** El usuario busca un folio existente para visualizar y editar sus datos.

**Precondiciones:**
El usuario está autenticado y conoce el número de folio.

**Pasos a seguir:**
1. El usuario ingresa el número de folio en el campo de búsqueda.
2. Presiona el botón 'Buscar'.
3. El sistema consulta el folio y muestra los datos principales, adicionales y adeudos vigentes.

**Resultado esperado:**
Se muestran todos los datos del folio, incluyendo datos adicionales y adeudos. El usuario puede editar los campos.

**Datos de prueba:**
folio = 12345 (existente en la base de datos)

---

## Caso de Uso 2: Modificación de Datos y Adicionales

**Descripción:** El usuario edita los datos principales y los datos adicionales de un folio.

**Precondiciones:**
El folio existe y el usuario tiene permisos de edición.

**Pasos a seguir:**
1. El usuario busca el folio.
2. Modifica campos como nombre, domicilio, metros, etc.
3. Modifica o agrega datos adicionales (RFC, CURP, teléfono, IFE).
4. Presiona 'Guardar Cambios'.
5. El sistema actualiza los datos y muestra confirmación.

**Resultado esperado:**
Los datos se actualizan correctamente en la base de datos y se registra el histórico.

**Datos de prueba:**
folio = 12345, nombre = 'JUAN PEREZ', telefono = '3312345678', rfc = 'PEPJ800101XXX'

---

## Caso de Uso 3: Baja Lógica de Folio

**Descripción:** El usuario da de baja lógica un folio (vigencia = 'B').

**Precondiciones:**
El folio existe y el usuario tiene permisos de baja.

**Pasos a seguir:**
1. El usuario busca el folio.
2. Presiona el botón 'Dar de Baja'.
3. Confirma la acción.
4. El sistema actualiza la vigencia y registra el histórico.

**Resultado esperado:**
El folio queda con vigencia 'B' y no puede ser editado salvo por un administrador.

**Datos de prueba:**
folio = 12345

---

