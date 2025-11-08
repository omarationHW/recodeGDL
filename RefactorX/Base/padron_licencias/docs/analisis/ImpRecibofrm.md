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
