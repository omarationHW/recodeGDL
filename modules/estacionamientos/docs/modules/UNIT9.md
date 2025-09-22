# Documentación Técnica: Migración de Formulario UNIT9 (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario UNIT9 de Delphi ha sido migrado a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El formulario corresponde a una "vista previa personalizada" de reportes, con navegación de páginas, carga/guardado de archivos, impresión y ajustes de visualización.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful unificada vía `/api/execute`.
- **Frontend:** Vue.js 2/3 SPA, cada formulario es una página independiente.
- **Base de datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  - `eRequest`: Identificador de la operación (ej: `UNIT9_PREVIEW_NAVIGATE`)
  - `params`: Parámetros específicos de la operación
- **Salida:**
  - `eResponse`:
    - `success`: boolean
    - `data`: resultado de la operación
    - `message`: mensaje de error o información

## 4. Controlador Laravel
- **Ubicación:** `App\Http\Controllers\Api\ExecuteController`
- **Responsabilidad:**
  - Recibe todas las solicitudes del frontend.
  - Despacha a los stored procedures según el valor de `eRequest`.
  - Retorna la respuesta estructurada en `eResponse`.

## 5. Componente Vue.js
- **Nombre:** `Unit9PreviewPage.vue`
- **Características:**
  - Página completa, no usa tabs.
  - Barra de herramientas con botones para todas las acciones del formulario original.
  - Llama al endpoint `/api/execute` con el `eRequest` correspondiente.
  - Muestra la vista previa (simulada) y mensajes de estado.
  - Navegación breadcrumb.

## 6. Stored Procedures PostgreSQL
- **Prefijo:** `sp_unit9_preview_*`
- **Responsabilidad:**
  - Simulan la lógica de navegación, carga, guardado, impresión y visualización de la vista previa.
  - Devuelven datos en formato JSON.
  - Pueden ser extendidos para lógica real de reportes.

## 7. Flujo de Navegación
1. El usuario accede a la página de vista previa.
2. El frontend muestra la primera página llamando a `UNIT9_PREVIEW_NAVIGATE` con `action: 'first'`.
3. El usuario puede navegar, cargar, guardar, imprimir o ajustar la vista.
4. Cada acción genera una llamada a `/api/execute` con el `eRequest` y parámetros adecuados.
5. El backend ejecuta el stored procedure correspondiente y retorna el resultado.

## 8. Seguridad
- Todas las operaciones se realizan vía API protegida (middleware de autenticación recomendado).
- Validación de parámetros en el controlador.

## 9. Extensibilidad
- Para agregar nuevas acciones, definir un nuevo `eRequest`, su stored procedure y lógica en el controlador.

## 10. Notas
- La lógica de reportes es simulada; para integración real, conectar con el motor de reportes correspondiente.
- El frontend puede ser adaptado para mostrar PDFs, imágenes o HTML según la implementación real.
