# Documentación Técnica: Contratos_Upd_01

## Análisis

# Documentación Técnica: Migración Formulario Contratos_Upd_01 (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel API, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (NO tabs)
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures

## Flujo de Trabajo
1. **Carga de Catálogos**: Al cargar la página, el frontend solicita catálogos (tipos de aseo, unidades, zonas, recaudadoras) usando la acción correspondiente.
2. **Búsqueda de Contrato**: El usuario ingresa número de contrato y tipo de aseo, el frontend llama a `buscarContrato`.
3. **Selección de Opción de Actualización**: El usuario elige la operación a realizar (unidad, cantidad, empresa, domicilio, etc.). Cada opción muestra un formulario específico.
4. **Actualización**: Al enviar el formulario, el frontend llama a `actualizarContrato` con los parámetros requeridos según la opción.
5. **Licencias de Giro**: Operaciones sobre licencias usan stored procedures específicos.
6. **Todas las operaciones** usan el endpoint `/api/execute` con el patrón:
   ```json
   {
     "eRequest": {
       "action": "nombre_accion",
       "data": { ... }
     }
   }
   ```
   y reciben:
   ```json
   {
     "eResponse": { ... }
   }
   ```

## API: Ejemplo de Uso
- **Obtener tipos de aseo**:
  ```json
  { "eRequest": { "action": "getTipoAseo" } }
  ```
- **Buscar contrato**:
  ```json
  { "eRequest": { "action": "buscarContrato", "data": { "num_contrato": 123, "ctrol_aseo": 9 } } }
  ```
- **Actualizar contrato (cambio de domicilio)**:
  ```json
  { "eRequest": { "action": "actualizarContrato", "data": { "control_cont": 1001, "opcion": 4, "domicilio": "Av. Alcalde 123" } } }
  ```

## Validaciones
- El backend valida la existencia de contratos, empresas, y parámetros requeridos.
- Los stored procedures devuelven un campo `status` y un mensaje `concepto` para indicar éxito o error.

## Seguridad
- Todas las operaciones requieren autenticación Laravel (middleware `auth:api` recomendado).
- Validación de parámetros en el controlador antes de llamar a los SP.

## Extensibilidad
- Para agregar nuevas opciones, basta con crear un nuevo SP y mapear la acción en el controlador.

## Estructura de Componentes Vue
- Cada opción de actualización es un componente Vue independiente.
- El componente principal selecciona el subcomponente según la opción elegida.
- Comunicación entre componentes por eventos (`@actualizar`).

## Manejo de Errores
- Los errores de SP o de validación se devuelven en el campo `error` de la respuesta.
- El frontend muestra mensajes amigables al usuario.

## Pruebas
- Se recomienda usar Postman para pruebas de API y Cypress/Jest para frontend.



## Casos de Uso

# Casos de Uso - Contratos_Upd_01

**Categoría:** Form

## Caso de Uso 1: Cambio de Domicilio de un Contrato

**Descripción:** El usuario desea actualizar el domicilio de un contrato existente.

**Precondiciones:**
El contrato debe existir y estar vigente.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y selecciona el tipo de aseo.
2. Presiona 'Buscar'.
3. Selecciona la opción 'Domicilio'.
4. Ingresa los nuevos datos de domicilio (calle, número, colonia).
5. Ingresa el documento probatorio y descripción.
6. Presiona 'Ejecutar'.

**Resultado esperado:**
El domicilio del contrato se actualiza y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "num_contrato": 1234, "ctrol_aseo": 9, "domicilio": "Av. Reforma 100 Int. 2 Col. Centro", "docto": "DR/14/2024", "descrip": "Cambio por mudanza" }

---

## Caso de Uso 2: Cambio de Empresa Asociada al Contrato

**Descripción:** El usuario desea cambiar la empresa ligada a un contrato.

**Precondiciones:**
El contrato debe existir y la nueva empresa debe estar registrada.

**Pasos a seguir:**
1. El usuario ingresa el número de contrato y tipo de aseo.
2. Presiona 'Buscar'.
3. Selecciona la opción 'Empresa'.
4. Busca la nueva empresa por nombre y la selecciona.
5. Ingresa el documento probatorio y descripción.
6. Presiona 'Ejecutar'.

**Resultado esperado:**
La empresa asociada al contrato se actualiza correctamente.

**Datos de prueba:**
{ "num_contrato": 5678, "ctrol_aseo": 8, "num_emp": 200, "ctrol_emp": 9, "docto": "DR/15/2024", "descrip": "Cambio por fusión empresarial" }

---

## Caso de Uso 3: Desligar una Licencia de Giro de un Contrato

**Descripción:** El usuario desea eliminar la relación entre una licencia de giro y un contrato.

**Precondiciones:**
La licencia debe estar relacionada al contrato.

**Pasos a seguir:**
1. El usuario busca el contrato y selecciona la opción 'Licencias de Giro'.
2. Visualiza las licencias relacionadas.
3. Selecciona la licencia y elige la acción 'Desligar/Eliminar'.
4. Presiona 'Aplica'.

**Resultado esperado:**
La licencia se elimina de la relación y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "opc": "D", "licencia_giro": 12345, "control_contrato": 1001 }

---



## Casos de Prueba

# Casos de Prueba para Contratos_Upd_01

## 1. Buscar Contrato Existente
- **Entrada:** { "eRequest": { "action": "buscarContrato", "data": { "num_contrato": 1234, "ctrol_aseo": 9 } } }
- **Esperado:** Respuesta contiene datos del contrato.

## 2. Actualizar Cantidad de Unidades a Recolectar
- **Entrada:** { "eRequest": { "action": "actualizarContrato", "data": { "control_cont": 1001, "cant_recolec": 5, "opcion": 2 } } }
- **Esperado:** status=0, concepto='Cantidad de unidades actualizada'.

## 3. Cambio de Zona
- **Entrada:** { "eRequest": { "action": "actualizarContrato", "data": { "control_cont": 1001, "ctrol_zona": 2002, "opcion": 5 } } }
- **Esperado:** status=0, concepto='Zona actualizada'.

## 4. Relacionar Licencia de Giro
- **Entrada:** { "eRequest": { "action": "aplicarLicenciaGiro", "data": { "opc": "A", "licencia_giro": 12345, "control_contrato": 1001 } } }
- **Esperado:** status=0, leyenda='Licencia activada o reactivada'.

## 5. Buscar Empresas por Nombre
- **Entrada:** { "eRequest": { "action": "buscarEmpresas", "data": { "nombre": "S.A. de C.V." } } }
- **Esperado:** Lista de empresas cuyo nombre contiene 'S.A. de C.V.'.

## 6. Error por Opción Inválida
- **Entrada:** { "eRequest": { "action": "actualizarContrato", "data": { "control_cont": 1001, "opcion": 99 } } }
- **Esperado:** status=1, concepto='Opción no válida'.


