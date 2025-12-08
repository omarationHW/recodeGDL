# Documentación Técnica: ImpRecibofrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario ImpRecibofrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este documento describe la migración del formulario de impresión de recibos de constancia/certificación de licencias (Delphi) a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos). El flujo principal permite buscar una licencia vigente y generar un recibo de pago para constancia o certificación.

## 2. Arquitectura
- **Backend**: Laravel 10+, API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend**: Vue.js 3+, componente de página independiente (`ImpReciboPage.vue`).
- **Base de Datos**: PostgreSQL 13+, lógica SQL encapsulada en stored procedures.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint**: `POST /api/execute`
- **Request JSON**:
  - `action`: Nombre de la acción (ej: `getLicenciaRecibo`, `printRecibo`)
  - `params`: Objeto con parámetros específicos
- **Response JSON**:
  - `success`: true/false
  - `data`: Objeto con datos de respuesta
  - `message`: Mensaje de error o éxito

## 4. Flujo de Negocio
1. El usuario ingresa el número de licencia y selecciona el tipo de recibo (constancia/certificación).
2. Al presionar Enter o buscar, se valida la existencia de la licencia vigente.
3. Si existe, se habilita el botón de impresión.
4. Al imprimir, se consulta el costo correspondiente y se genera el recibo con los datos de la licencia y el monto en número y letra.

## 5. Seguridad
- Validación de parámetros en backend.
- Solo se permite imprimir recibos para licencias vigentes.
- El endpoint puede protegerse con autenticación JWT o session según la política del sistema.

## 6. Stored Procedures
- Toda la lógica SQL se encapsula en SPs para facilitar mantenimiento y auditoría.
- Se provee un SP para conversión de número a letras (simplificado; para producción se recomienda una extensión robusta).

## 7. Integración Frontend-Backend
- El componente Vue.js interactúa exclusivamente con `/api/execute`.
- No hay acoplamiento directo a tablas ni queries en frontend.
- El backend retorna todos los datos listos para mostrar/imprimir.

## 8. Consideraciones de Migración
- El formulario Delphi usaba componentes visuales y lógica de eventos; en Vue.js se usan métodos y estados reactivos.
- El reporte impreso puede integrarse con un sistema de generación de PDFs en backend si se requiere impresión real.
- El formato de número a letra puede mejorarse usando extensiones de PostgreSQL o librerías PHP.

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- El frontend puede evolucionar a otras tecnologías sin cambiar la API.

## 10. Pruebas y Validación
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez del sistema.

## Casos de Prueba

# Casos de Prueba para Impresión de Recibos

## Caso 1: Licencia vigente, certificación
- **Entrada:** licencia=12345, tipo=certificacion
- **Acción:** Buscar y generar recibo
- **Esperado:**
  - Se muestra recibo con datos correctos
  - Concepto: CERTIFICACIÓN
  - Monto igual a costo_certific
  - Cantidad en letra correcta

## Caso 2: Licencia inexistente
- **Entrada:** licencia=99999, tipo=certificacion
- **Acción:** Buscar
- **Esperado:**
  - Mensaje de error 'No se encontró licencia con ese número'
  - No se habilita botón de imprimir

## Caso 3: Licencia vigente, constancia
- **Entrada:** licencia=54321, tipo=constancia
- **Acción:** Buscar y generar recibo
- **Esperado:**
  - Se muestra recibo con datos correctos
  - Concepto: CONSTANCIA
  - Monto igual a costo_constancia
  - Cantidad en letra correcta

## Caso 4: Licencia no vigente
- **Entrada:** licencia=11111 (no vigente), tipo=certificacion
- **Acción:** Buscar
- **Esperado:**
  - Mensaje de error 'No se encontró licencia con ese número'
  - No se habilita botón de imprimir

## Caso 5: Error de conexión
- **Simulación:** API no responde
- **Acción:** Buscar o imprimir
- **Esperado:**
  - Mensaje de error 'Error de conexión'

## Casos de Uso

# Casos de Uso - ImpRecibofrm

**Categoría:** Form

## Caso de Uso 1: Imprimir recibo de certificación para licencia vigente

**Descripción:** El usuario busca una licencia vigente y genera el recibo de pago para certificación.

**Precondiciones:**
La licencia existe y está vigente en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de impresión de recibos.
2. Ingresa el número de licencia (ej: 12345).
3. Selecciona 'Certificación'.
4. Presiona Enter o clic en 'Imprimir'.
5. El sistema consulta la licencia y muestra el recibo con los datos y monto correspondiente.

**Resultado esperado:**
Se muestra la vista previa del recibo con los datos de la licencia, el concepto 'CERTIFICACIÓN', el monto y la cantidad en letra.

**Datos de prueba:**
licencia: 12345, tipo: 'certificacion'

---

## Caso de Uso 2: Intentar imprimir recibo para licencia inexistente

**Descripción:** El usuario ingresa un número de licencia que no existe.

**Precondiciones:**
La licencia no existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de impresión de recibos.
2. Ingresa el número de licencia (ej: 99999).
3. Presiona Enter.
4. El sistema muestra un mensaje de error.

**Resultado esperado:**
Se muestra un mensaje 'No se encontró licencia con ese número' y no se habilita el botón de imprimir.

**Datos de prueba:**
licencia: 99999, tipo: 'certificacion'

---

## Caso de Uso 3: Imprimir recibo de constancia para licencia vigente

**Descripción:** El usuario busca una licencia vigente y genera el recibo de pago para constancia.

**Precondiciones:**
La licencia existe y está vigente en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de impresión de recibos.
2. Ingresa el número de licencia (ej: 54321).
3. Selecciona 'Constancia'.
4. Presiona Enter o clic en 'Imprimir'.
5. El sistema consulta la licencia y muestra el recibo con los datos y monto correspondiente.

**Resultado esperado:**
Se muestra la vista previa del recibo con los datos de la licencia, el concepto 'CONSTANCIA', el monto y la cantidad en letra.

**Datos de prueba:**
licencia: 54321, tipo: 'constancia'

---
