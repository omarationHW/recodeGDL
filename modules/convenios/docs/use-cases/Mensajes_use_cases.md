# Casos de Uso - Mensajes

**Categoría:** Form

## Caso de Uso 1: Mostrar un mensaje informativo

**Descripción:** El usuario accede a la página de mensajes para visualizar un mensaje informativo con icono.

**Precondiciones:**
El frontend y backend están desplegados y accesibles.

**Pasos a seguir:**
1. El usuario navega a /mensajes?mensaje=Bienvenido!&imagen=1
2. El componente muestra el mensaje 'Bienvenido!' y el icono informativo.
3. El usuario presiona OK.

**Resultado esperado:**
El mensaje se muestra correctamente con el icono. Al presionar OK, el usuario regresa a la página principal.

**Datos de prueba:**
mensaje: 'Bienvenido!'
imagen: 1

---

## Caso de Uso 2: Guardar un mensaje de advertencia

**Descripción:** El usuario visualiza un mensaje de advertencia y decide guardarlo en el historial.

**Precondiciones:**
El frontend y backend están desplegados y accesibles.

**Pasos a seguir:**
1. El usuario navega a /mensajes?mensaje=Atención!&imagen=2
2. El usuario presiona 'Guardar Mensaje'.
3. El sistema guarda el mensaje en la base de datos y muestra confirmación.

**Resultado esperado:**
El mensaje se guarda correctamente y aparece en el historial.

**Datos de prueba:**
mensaje: 'Atención!'
imagen: 2

---

## Caso de Uso 3: Listar historial de mensajes

**Descripción:** El usuario accede a la página de mensajes con la opción de ver el historial.

**Precondiciones:**
Existen mensajes previamente guardados.

**Pasos a seguir:**
1. El usuario navega a /mensajes?list=1
2. El sistema muestra la lista de mensajes guardados con sus iconos.

**Resultado esperado:**
Se visualiza el historial de mensajes con los datos correctos.

**Datos de prueba:**
No requiere datos adicionales.

---

