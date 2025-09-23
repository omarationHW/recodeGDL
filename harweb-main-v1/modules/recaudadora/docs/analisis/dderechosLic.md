# Documentación Técnica: Migración Formulario dderechosLic (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la gestión de descuentos en derechos de licencias municipales (licencias, anuncios, formas) para el municipio de Guadalajara. Incluye:
- Consulta de licencias/anuncios/formas por folio
- Alta y cancelación de descuentos
- Consulta de campañas de descuento vigentes
- Reporte de estado de cuenta de licencias/anuncios

## 2. Arquitectura
- **Backend:** Laravel 10+, PostgreSQL 13+
- **Frontend:** Vue.js 3 (SPA, cada formulario es una página independiente)
- **API:** Unificada, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Base de Datos:** PostgreSQL, procedimientos almacenados para lógica de negocio

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "nombreAccion",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "data": [ ... ]
  }
  ```
- **Acciones soportadas:**
  - buscarLicencia
  - buscarAnuncio
  - buscarForma
  - buscarCampania
  - buscarDescuento
  - altaDescuento
  - cancelarDescuento
  - reporteEdoCtaLic

## 4. Seguridad
- Autenticación JWT recomendada
- El usuario autenticado se pasa como contexto para auditoría

## 5. Stored Procedures
- Toda la lógica de negocio y validación reside en SPs de PostgreSQL
- Los SPs devuelven tablas (RETURNS TABLE)
- Los SPs de alta/cancelación devuelven un campo `result` ('OK' o mensaje de error)

## 6. Frontend (Vue.js)
- Cada formulario es una página independiente (NO tabs)
- Navegación por rutas (vue-router)
- Breadcrumbs para navegación
- Formularios reactivos, validación en frontend y backend
- Uso de Axios para llamadas a `/api/execute`
- Mensajes de éxito/error amigables

## 7. Backend (Laravel)
- Controlador único: `DerechosLicController`
- Métodos para cada acción, validación de parámetros
- Uso de DB::select para invocar SPs
- Respuestas JSON estándar

## 8. Base de Datos
- Tablas principales: licencias, anuncios, saldos_lic, descderlic, c_autdescmul
- Índices en campos de búsqueda (folio, licencia, anuncio, estado)
- Integridad referencial en descuentos

## 9. Auditoría
- Todos los movimientos de alta/cancelación de descuentos registran usuario y fecha

## 10. Pruebas y Casos de Uso
- Incluidos en los apartados siguientes

---
