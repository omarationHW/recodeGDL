# Casos de Uso - Cons_Cves_operacion

**Categoría:** Form

## Caso de Uso 1: Consulta de Claves de Operación ordenadas por Descripción

**Descripción:** El usuario desea ver todas las claves de operación ordenadas alfabéticamente por descripción.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en ta_16_operacion.

**Pasos a seguir:**
1. El usuario accede a la página de Claves de Operación.
2. Selecciona 'Descripción' en el combo de clasificación.
3. El sistema envía eRequest con action 'list' y data.order='descripcion'.
4. El backend responde con el listado ordenado.

**Resultado esperado:**
Se muestra la tabla de claves de operación ordenada alfabéticamente por descripción.

**Datos de prueba:**
Registros de ejemplo: {ctrol_operacion:1, cve_operacion:'A', descripcion:'Cuota Normal'}, {ctrol_operacion:2, cve_operacion:'E', descripcion:'Excedente'}

---

## Caso de Uso 2: Alta de Nueva Clave de Operación

**Descripción:** El usuario desea agregar una nueva clave de operación.

**Precondiciones:**
El usuario tiene permisos de alta. La clave y descripción no existen.

**Pasos a seguir:**
1. El usuario hace clic en 'Nuevo'.
2. Llena los campos: Clave='D', Descripción='Contenedores'.
3. Hace clic en 'Guardar'.
4. El frontend envía eRequest con action 'create' y los datos.
5. El backend ejecuta el SP y responde.

**Resultado esperado:**
La clave se agrega correctamente y aparece en el listado.

**Datos de prueba:**
{cve_operacion:'D', descripcion:'Contenedores'}

---

## Caso de Uso 3: Intento de Borrar Clave con Pagos Asociados

**Descripción:** El usuario intenta eliminar una clave de operación que tiene pagos asociados.

**Precondiciones:**
Existe una clave con ctrol_operacion=1 y hay registros en ta_16_pagos con ctrol_operacion=1.

**Pasos a seguir:**
1. El usuario hace clic en 'Eliminar' sobre la clave.
2. Confirma la eliminación.
3. El frontend envía eRequest con action 'delete' y ctrol_operacion=1.
4. El backend ejecuta el SP y detecta pagos asociados.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'EXISTEN PAGOS CON ESTA CLAVE DE OPERACION, NO SE PUEDE BORRAR.'

**Datos de prueba:**
{ctrol_operacion:1}

---

