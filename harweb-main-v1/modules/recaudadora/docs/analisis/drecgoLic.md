# Documentación Técnica: Migración Formulario drecgoLic (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la gestión de descuentos en recargos y multas para licencias y anuncios. Incluye búsqueda, alta y baja de descuentos, validación de permisos y control de funcionarios autorizados. La migración se realiza a una arquitectura moderna con Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Frontend**: Componente Vue.js como página independiente, sin tabs, con navegación y formularios separados.
- **Base de Datos**: PostgreSQL con stored procedures para lógica de negocio y consultas.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: `{ "eRequest": { "action": "string", "params": { ... } } }`
- **Salida**: `{ "eResponse": { "success": bool, "message": string, "data": any } }`
- **Acciones soportadas**:
  - `searchLicencia`, `searchAnuncio`, `buscaDescto`, `altaRecargo`, `altaMulta`, `bajaRecargo`, `bajaMulta`, `consultaPermiso`, `consultaFuncionarios`

## 4. Stored Procedures
- Todas las operaciones de negocio (alta, baja, consulta) se implementan como funciones/procedimientos en PostgreSQL.
- Los procedimientos devuelven tablas o VOID según corresponda.

## 5. Seguridad y Validaciones
- Validación de permisos de usuario antes de permitir alta/baja de descuentos.
- Validación de porcentaje máximo permitido según funcionario autorizado.
- Validación de existencia de licencia/anuncio y de periodos válidos.

## 6. Frontend (Vue.js)
- Cada formulario es una página independiente.
- Navegación breadcrumb para contexto.
- Formularios reactivos y validaciones en cliente.
- Llamadas a la API usando Axios.
- Mensajes de error y éxito claros.

## 7. Casos de Uso
- Búsqueda de licencia/anuncio y visualización de periodos.
- Alta de descuento de recargo/multa con validación de funcionario.
- Cancelación de descuento existente.

## 8. Pruebas
- Casos de prueba unitarios y de integración para cada endpoint y flujo de usuario.
- Pruebas de validación de reglas de negocio y seguridad.

## 9. Consideraciones de Migración
- Los nombres de tablas y campos se adaptan a convención snake_case.
- Los procedimientos almacenados encapsulan la lógica antes dispersa en el frontend Delphi.
- El frontend Vue.js es desacoplado y no usa tabs, cada formulario es una ruta/página.

## 10. Ejemplo de Flujo
1. Usuario busca una licencia.
2. El sistema muestra periodos y propietario.
3. Usuario selecciona "Descuento Recargo", ingresa porcentaje y funcionario.
4. El sistema valida y registra el descuento.
5. Usuario puede cancelar el descuento si es necesario.

---
