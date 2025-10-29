# Casos de Uso - mensaje

**Categoría:** Form

## Caso de Uso 1: Mostrar mensaje de error crítico

**Descripción:** El sistema debe mostrar un mensaje de error crítico con el ícono de 'alto' y el texto correspondiente.

**Precondiciones:**
El usuario está en una página donde ocurre un error crítico.

**Pasos a seguir:**
1. El sistema detecta un error crítico.
2. Redirige al usuario a la página /mensaje con los parámetros: tipo=Error, msg='Ocurrió un error inesperado.', icono=alto.
3. El componente Vue muestra el mensaje y el ícono de 'alto'.
4. El usuario hace clic en 'Aceptar'.

**Resultado esperado:**
El usuario ve el mensaje de error con el ícono de 'alto' y puede cerrar el mensaje.

**Datos de prueba:**
{ "tipo": "Error", "msg": "Ocurrió un error inesperado.", "icono": "alto" }

---

## Caso de Uso 2: Mostrar mensaje de confirmación

**Descripción:** El sistema debe mostrar un mensaje de confirmación con el ícono de 'pregunta'.

**Precondiciones:**
El usuario realiza una acción que requiere confirmación.

**Pasos a seguir:**
1. El sistema solicita confirmación para una acción.
2. Redirige al usuario a la página /mensaje con los parámetros: tipo=Confirmación, msg='¿Está seguro de continuar?', icono=pregunta.
3. El componente Vue muestra el mensaje y el ícono de 'pregunta'.
4. El usuario hace clic en 'Aceptar'.

**Resultado esperado:**
El usuario ve el mensaje de confirmación con el ícono de 'pregunta' y puede cerrar el mensaje.

**Datos de prueba:**
{ "tipo": "Confirmación", "msg": "¿Está seguro de continuar?", "icono": "pregunta" }

---

## Caso de Uso 3: Mostrar mensaje informativo

**Descripción:** El sistema debe mostrar un mensaje informativo con el ícono de 'informacion'.

**Precondiciones:**
El usuario completa una acción satisfactoriamente.

**Pasos a seguir:**
1. El sistema detecta que la acción fue exitosa.
2. Redirige al usuario a la página /mensaje con los parámetros: tipo=Información, msg='La operación se realizó correctamente.', icono=informacion.
3. El componente Vue muestra el mensaje y el ícono de 'informacion'.
4. El usuario hace clic en 'Aceptar'.

**Resultado esperado:**
El usuario ve el mensaje informativo con el ícono de 'informacion' y puede cerrar el mensaje.

**Datos de prueba:**
{ "tipo": "Información", "msg": "La operación se realizó correctamente.", "icono": "informacion" }

---

