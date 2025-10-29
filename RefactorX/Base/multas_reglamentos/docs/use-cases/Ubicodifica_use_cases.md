# Casos de Uso - Ubicodifica

**Categoría:** Form

## Caso de Uso 1: Alta de Codificación de Ubicación para una Cuenta Nueva

**Descripción:** El usuario desea dar de alta la codificación de ubicación para una cuenta catastral que no tiene registro previo en la tabla de codificación.

**Precondiciones:**
El usuario está autenticado y tiene permisos de alta. La cuenta catastral existe y no tiene registro en ubicacion_req.

**Pasos a seguir:**
1. El usuario ingresa el número de cuenta en el formulario.
2. El sistema consulta los datos de la cuenta y muestra la información del contribuyente.
3. El usuario presiona el botón 'Dar de Alta'.
4. El sistema envía la acción 'alta_ubicodifica' al endpoint API.
5. El backend ejecuta el stored procedure de alta y retorna éxito.

**Resultado esperado:**
La codificación se da de alta correctamente, el usuario ve los datos de codificación y el estado cambia a 'Vigente'.

**Datos de prueba:**
{ "cvecuenta": 123456 }

---

## Caso de Uso 2: Cancelación de Codificación de Ubicación

**Descripción:** El usuario desea cancelar (dar de baja lógica) la codificación de ubicación de una cuenta existente.

**Precondiciones:**
La cuenta tiene un registro vigente en ubicacion_req. El usuario tiene permisos de cancelación.

**Pasos a seguir:**
1. El usuario busca la cuenta y visualiza la codificación vigente.
2. El usuario presiona el botón 'Cancelar'.
3. El sistema envía la acción 'cancela_ubicodifica' al endpoint API.
4. El backend ejecuta el stored procedure de cancelación y retorna éxito.

**Resultado esperado:**
La codificación cambia a estado 'Cancelada', se registra la fecha de baja y usuario.

**Datos de prueba:**
{ "cvecuenta": 123456 }

---

## Caso de Uso 3: Listado de Cuentas sin Zona/Subzona

**Descripción:** El usuario desea obtener un listado de cuentas que no tienen zona/subzona asignada en un rango de cuentas.

**Precondiciones:**
El usuario está autenticado. Existen cuentas en el rango solicitado sin zona/subzona.

**Pasos a seguir:**
1. El usuario ingresa los parámetros de recaudadora, cuenta inicial y cuenta final.
2. El usuario presiona 'Buscar'.
3. El sistema envía la acción 'listado_ubicodifica' al endpoint API.
4. El backend ejecuta el stored procedure de listado y retorna los resultados.

**Resultado esperado:**
El usuario visualiza una tabla con las cuentas sin zona/subzona en el rango solicitado.

**Datos de prueba:**
{ "reca": 1, "ctaini": 1000, "ctafin": 2000 }

---

