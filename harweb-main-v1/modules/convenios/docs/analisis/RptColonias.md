# Documentación Técnica: Migración de Formulario RptColonias (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este documento describe la migración del formulario de reporte de colonias (RptColonias) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad original, modernizando la interfaz y la lógica de acceso a datos.

## 2. Arquitectura
- **Backend**: Laravel API con endpoint unificado `/api/execute` que recibe peticiones con el patrón `eRequest/eResponse`.
- **Frontend**: Componente Vue.js como página independiente, mostrando el catálogo de colonias en formato tabla.
- **Base de Datos**: PostgreSQL, con lógica SQL encapsulada en stored procedures.

## 3. Endpoint Unificado
- **Ruta**: `/api/execute`
- **Método**: POST
- **Payload**:
  ```json
  {
    "eRequest": "RptColoniasList",
    "params": {}
  }
  ```
- **Respuesta**:
  ```json
  {
    "eResponse": "OK",
    "message": "Colonias obtenidas correctamente",
    "data": {
      "colonias": [ ... ],
      "total": 123
    }
  }
  ```

## 4. Stored Procedure
- **Nombre**: `rpt_colonias_list`
- **Propósito**: Devuelve el catálogo de colonias con su zona asociada.
- **Uso**: Llamado desde Laravel vía `DB::select('SELECT * FROM rpt_colonias_list()')`.

## 5. Vue.js
- **Página independiente**: No usa tabs ni componentes compartidos.
- **Carga de datos**: Llama a `/api/execute` con `eRequest: 'RptColoniasList'`.
- **Visualización**: Tabla con columnas COLONIA, DESCRIPCIÓN, REC., ID ZONA, ZONA.
- **Resumen**: Muestra el total de colonias y metadatos del reporte.

## 6. Seguridad
- El endpoint puede protegerse con middleware de autenticación según la política del sistema.
- Validación de parámetros y manejo de errores implementados en el controlador.

## 7. Extensibilidad
- Para agregar más reportes o formularios, basta con agregar nuevos casos en el switch del controlador y nuevos stored procedures.

## 8. Consideraciones de Migración
- El reporte original usaba QuickReport en Delphi; la versión web replica la estructura visual y los datos.
- El logo debe estar disponible en `/src/assets/logo_guadalajara.png` o la ruta correspondiente.
- El frontend asume uso de Bootstrap-Vue para notificaciones, pero puede adaptarse a cualquier framework de UI.

## 9. Pruebas
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.

---
