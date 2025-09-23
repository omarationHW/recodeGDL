# Casos de Uso - TDMConection

**Categoría:** Form

## Caso de Uso 1: Conexión Exitosa con Usuario Válido

**Descripción:** El usuario ingresa credenciales válidas y se conecta exitosamente a la base de datos, visualizando el listado de bases de datos.

**Precondiciones:**
El usuario y contraseña existen en PostgreSQL y tienen permisos de conexión.

**Pasos a seguir:**
1. Ingresar usuario y contraseña válidos en el formulario.
2. Presionar el botón 'Conectar'.
3. Esperar la respuesta del sistema.

**Resultado esperado:**
El sistema muestra el mensaje 'Conexión exitosa.' y lista las bases de datos disponibles.

**Datos de prueba:**
{ "user": "cajero", "password": "c4j3r0" }

---

## Caso de Uso 2: Conexión Fallida por Contraseña Incorrecta

**Descripción:** El usuario ingresa una contraseña incorrecta y el sistema rechaza la conexión.

**Precondiciones:**
El usuario existe pero la contraseña es incorrecta.

**Pasos a seguir:**
1. Ingresar usuario válido y contraseña incorrecta.
2. Presionar 'Conectar'.

**Resultado esperado:**
El sistema muestra el mensaje 'Usuario o contraseña incorrectos.' y no lista bases de datos.

**Datos de prueba:**
{ "user": "cajero", "password": "incorrecta" }

---

## Caso de Uso 3: Cierre de Conexión

**Descripción:** El usuario cierra la conexión después de haberse conectado exitosamente.

**Precondiciones:**
El usuario está conectado.

**Pasos a seguir:**
1. Presionar el botón 'Cerrar Conexión'.

**Resultado esperado:**
El sistema limpia el estado, oculta el listado de bases de datos y muestra el mensaje 'Conexión cerrada.'

**Datos de prueba:**
N/A

---

