# Casos de Uso - Unit1

**Categoría:** Form

## Caso de Uso 1: Carga exitosa del formulario Unit1

**Descripción:** El usuario accede a la página del formulario Unit1 y la aplicación carga correctamente el mensaje de éxito.

**Precondiciones:**
El servidor Laravel y la base de datos PostgreSQL están en funcionamiento.

**Pasos a seguir:**
1. El usuario navega a la ruta /unit1 en la aplicación Vue.js.
2. El componente Vue envía una petición POST a /api/execute con eRequest 'unit1_get_form_data'.
3. El backend responde con éxito y mensaje.

**Resultado esperado:**
La página muestra el mensaje 'Formulario Unit1 cargado correctamente.' sin errores.

**Datos de prueba:**
No se requieren datos de entrada.

---

## Caso de Uso 2: Error de eRequest no reconocido

**Descripción:** El usuario (o un desarrollador) envía un eRequest inválido a la API.

**Precondiciones:**
El servidor Laravel está en funcionamiento.

**Pasos a seguir:**
1. Realizar una petición POST a /api/execute con eRequest 'unit1_invalid_request'.

**Resultado esperado:**
La respuesta contiene success=false y un mensaje de error indicando que el eRequest no es reconocido.

**Datos de prueba:**
{ "eRequest": "unit1_invalid_request", "params": {} }

---

## Caso de Uso 3: Error de red o servidor

**Descripción:** El usuario intenta cargar la página pero el servidor Laravel está caído.

**Precondiciones:**
El servidor Laravel está detenido.

**Pasos a seguir:**
1. El usuario navega a /unit1.
2. El componente Vue intenta llamar a /api/execute.

**Resultado esperado:**
La página muestra un mensaje de error de red o servidor.

**Datos de prueba:**
No aplica (simulación de caída del servidor).

---

