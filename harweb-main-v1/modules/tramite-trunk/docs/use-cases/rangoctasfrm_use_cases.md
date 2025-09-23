# Casos de Uso - rangoctasfrm

**Categoría:** Form

## Caso de Uso 1: Impresión de extractos por rango de cuentas (por recaudadora)

**Descripción:** El usuario desea imprimir extractos de adquiriente para un rango de cuentas de una recaudadora específica.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta. Existen cuentas en el rango especificado.

**Pasos a seguir:**
- El usuario accede a la página de 'Extractos por Rango de Cuentas'.
- Selecciona la opción 'Por Recaudadora'.
- Ingresa el número de recaudadora (ej: 5).
- Ingresa la cuenta inicial (ej: 1000).
- Ingresa la cuenta final (ej: 1050).
- Presiona el botón 'Imprimir'.

**Resultado esperado:**
Se muestra una tabla con los extractos de adquiriente correspondientes al rango de cuentas y recaudadora seleccionados.

**Datos de prueba:**
{ "recaud": 5, "inicial": 1000, "final": 1050 }

---

## Caso de Uso 2: Impresión de extractos por capturista y fechas

**Descripción:** El usuario desea imprimir extractos de adquiriente capturados por un usuario específico en un rango de fechas.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta. Existen extractos capturados por el capturista en el rango de fechas.

**Pasos a seguir:**
- El usuario accede a la página de 'Extractos por Rango de Cuentas'.
- Selecciona la opción 'Por Capturista'.
- Ingresa el nombre de usuario del capturista (ej: 'sigonzal').
- Ingresa la fecha de inicio (ej: '2024-01-01').
- Ingresa la fecha de fin (ej: '2024-01-31').
- Presiona el botón 'Imprimir'.

**Resultado esperado:**
Se muestra una tabla con los extractos de adquiriente capturados por el usuario en el rango de fechas especificado.

**Datos de prueba:**
{ "capturista": "sigonzal", "fecha_ini": "2024-01-01", "fecha_fin": "2024-01-31" }

---

## Caso de Uso 3: Validación de campos requeridos

**Descripción:** El usuario intenta imprimir extractos sin llenar todos los campos requeridos.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
- El usuario accede a la página de 'Extractos por Rango de Cuentas'.
- Selecciona la opción 'Por Recaudadora'.
- Deja vacío el campo 'Cuenta Inicial'.
- Presiona el botón 'Imprimir'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el campo 'Cuenta Inicial' es requerido y no ejecuta la consulta.

**Datos de prueba:**
{ "recaud": 5, "inicial": "", "final": 1050 }

---

