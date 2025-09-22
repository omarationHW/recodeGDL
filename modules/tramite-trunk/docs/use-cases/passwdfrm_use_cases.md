# Casos de Uso - passwdfrm

**Categoría:** Form

## Caso de Uso 1: Autorización Exitosa de Usuario

**Descripción:** Un usuario autorizado ingresa su usuario y contraseña correctamente para autorizar una operación sensible.

**Precondiciones:**
El usuario existe en la tabla usuarios y su clave inicia con '&T'.

**Pasos a seguir:**
- El usuario abre el formulario de autorización.
- Ingresa su usuario y contraseña.
- Presiona 'Aceptar'.
- El sistema valida los datos y muestra mensaje de éxito.

**Resultado esperado:**
El sistema permite continuar con la operación protegida.

**Datos de prueba:**
{ "usuario": "admin", "password": "&T123456" }

---

## Caso de Uso 2: Intento de Autorización con Contraseña Incorrecta

**Descripción:** Un usuario existente ingresa una contraseña incorrecta.

**Precondiciones:**
El usuario existe pero la contraseña ingresada es incorrecta.

**Pasos a seguir:**
- El usuario abre el formulario.
- Ingresa su usuario y una contraseña incorrecta.
- Presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra mensaje 'Password incorrecto' y no permite continuar.

**Datos de prueba:**
{ "usuario": "admin", "password": "wrongpass" }

---

## Caso de Uso 3: Usuario No Autorizado para Acciones Sensibles

**Descripción:** Un usuario válido ingresa su contraseña pero no está autorizado (su clave no inicia con '&T').

**Precondiciones:**
El usuario existe pero su clave no inicia con '&T'.

**Pasos a seguir:**
- El usuario abre el formulario.
- Ingresa su usuario y contraseña.
- Presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra mensaje 'Usuario NO registrado para autorizaciones' y no permite continuar.

**Datos de prueba:**
{ "usuario": "user1", "password": "123456" }

---

