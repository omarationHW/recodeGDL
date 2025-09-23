# Documentación Técnica: Migración de Formulario GirosDconAdeudo (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el formulario de reporte de giros restringidos con adeudos anteriores, migrado desde Delphi a una arquitectura moderna usando Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El acceso a la funcionalidad se realiza mediante un endpoint API unificado y un componente Vue.js de página completa.

## 2. Arquitectura
- **Backend:** Laravel 10+, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js (SPA o multipágina), componente independiente
- **Base de Datos:** PostgreSQL, lógica de reporte encapsulada en stored procedure

## 3. Flujo de Datos
1. El usuario ingresa el año del adeudo y presiona "Imprimir".
2. El frontend envía una petición POST a `/api/execute` con `eRequest: 'GirosDconAdeudoReport'` y el año en el payload.
3. El backend ejecuta el stored procedure `report_giros_dcon_adeudo(p_year)` en PostgreSQL.
4. El resultado se retorna en el campo `data` del eResponse.
5. El frontend muestra el reporte en tabla y permite imprimirlo.

## 4. Endpoint API
- **URL:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "eRequest": "GirosDconAdeudoReport",
    "payload": { "year": 2022 }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": "Datos encontrados.",
    "errors": []
  }
  ```

## 5. Stored Procedure
- **Nombre:** `report_giros_dcon_adeudo(p_year INTEGER)`
- **Tipo:** REPORT
- **Descripción:** Devuelve licencias con adeudo desde el año especificado, incluyendo nombre, ubicación y giro.
- **Parámetro:** `p_year` (año del adeudo)
- **Retorno:** Tabla con columnas: licencia, propietario, propietarionvo, domCompleto, descripcion, axo

## 6. Componente Vue.js
- Página independiente con ruta propia
- Formulario para año del adeudo
- Tabla de resultados con totales
- Botón para imprimir el reporte
- Mensajes de error y estado

## 7. Seguridad
- Validación de parámetros en frontend y backend
- Manejo de errores y mensajes claros
- El endpoint puede protegerse con middleware de autenticación según la política del sistema

## 8. Consideraciones de Migración
- El reporte Delphi usaba componentes visuales y BDE; ahora todo es vía API y SPA
- El SQL original fue adaptado a sintaxis PostgreSQL y encapsulado en un stored procedure
- El frontend es responsivo y amigable

## 9. Extensibilidad
- El endpoint unificado permite agregar más reportes y procesos usando el mismo patrón eRequest/eResponse
- El stored procedure puede ser optimizado o extendido según necesidades futuras

## 10. Dependencias
- Laravel 10+
- Vue.js 2/3
- PostgreSQL 12+
- Bootstrap 4+ (para estilos en el ejemplo)

---
