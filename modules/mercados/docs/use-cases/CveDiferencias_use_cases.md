# Casos de Uso - CveDiferencias

**Categoría:** Form

## Caso de Uso 1: Alta de nueva Clave de Diferencia

**Descripción:** Un usuario autorizado desea agregar una nueva clave de diferencia para registrar diferencias de caja.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos de acceso al módulo.

**Pasos a seguir:**
1. El usuario ingresa a la página de Clave de Diferencias.
2. Hace clic en 'Agregar'.
3. Llena el campo 'Descripción' con 'DIFERENCIA DE CAJA'.
4. Selecciona la cuenta de ingreso '44501 - DIFERENCIAS DE CAJA'.
5. Confirma el alta.

**Resultado esperado:**
La nueva clave aparece en la tabla con su número consecutivo, descripción y cuenta asociada.

**Datos de prueba:**
{ "descripcion": "DIFERENCIA DE CAJA", "cuenta_ingreso": 44501, "id_usuario": 1 }

---

## Caso de Uso 2: Modificación de una Clave de Diferencia existente

**Descripción:** El usuario necesita corregir la descripción de una clave de diferencia existente.

**Precondiciones:**
Debe existir al menos una clave de diferencia registrada.

**Pasos a seguir:**
1. El usuario selecciona una fila en la tabla.
2. Hace clic en 'Modificar'.
3. Cambia la descripción a 'DIFERENCIA DE CAJA CORREGIDA'.
4. Guarda los cambios.

**Resultado esperado:**
La descripción se actualiza en la tabla y en la base de datos.

**Datos de prueba:**
{ "clave_diferencia": 1, "descripcion": "DIFERENCIA DE CAJA CORREGIDA", "cuenta_ingreso": 44501, "id_usuario": 1 }

---

## Caso de Uso 3: Consulta de claves de diferencias

**Descripción:** El usuario desea visualizar todas las claves de diferencias registradas.

**Precondiciones:**
Debe haber al menos una clave registrada.

**Pasos a seguir:**
1. El usuario accede a la página de Clave de Diferencias.
2. El sistema muestra la tabla con todas las claves existentes.

**Resultado esperado:**
La tabla muestra todas las claves con sus datos.

**Datos de prueba:**
N/A

---

